import 'package:factor/model/response/price_response_model.dart';
import 'package:factor/model/response/token_response_model.dart';
import 'package:factor/repository/network/coingecko_api_constants.dart';
import 'package:factor/repository/services/api/api_services.dart';
import 'package:flutter/foundation.dart';

/// Backend for CoinGecko API integration.
///
/// Provides access to 200+ chains, 18K+ cryptocurrencies, and real-time pricing.
/// This is used as a SECONDARY source alongside Jupiter (which remains primary for Solana).
class CoinGeckoBackend extends CoinGeckoApiConstants {
  final ApiServices _api = ApiServices();

  /// Search for coins across all chains.
  /// Returns tokens sorted by market cap rank.
  ///
  /// CoinGecko search returns the main token for each coin (e.g., ETH = Ethereum mainnet).
  /// Tokens are marked as non-Solana since CoinGecko is our secondary source.
  Future<List<TokenResponseModel>> search(String query) async {
    if (query.isEmpty) return const [];

    try {
      final response = await _api.get(
        uri: searchUri(query.trim()),
        header: apiHeader,
      );

      final results = <TokenResponseModel>[];

      if (response is Map<String, dynamic>) {
        // Parse coins from search results
        final coins = response['coins'] as List?;
        if (coins != null) {
          for (final coin in coins) {
            if (coin is Map<String, dynamic>) {
              final id = coin['id'] as String?;
              final marketCapRank = coin['market_cap_rank'] as int?;

              // Infer chain from common CoinGecko ID patterns
              final chainId = _inferChainFromCoinGeckoId(id);

              results.add(
                TokenResponseModel(
                  id: id,
                  name: coin['name'] as String?,
                  symbol: (coin['symbol'] as String?)?.toUpperCase(),
                  icon: coin['large'] as String? ?? coin['thumb'] as String?,
                  chainId: chainId,
                  // Use negative market cap rank for sorting (lower rank = higher priority)
                  marketCap: marketCapRank != null
                      ? (1000000000000 - marketCapRank).toDouble()
                      : null,
                ),
              );
            }
          }
        }
      }

      return results;
    } catch (e) {
      debugPrint('CoinGecko search error: $e');
      return const [];
    }
  }

  /// Infers the chain from a CoinGecko coin ID.
  /// Major coins like "ethereum", "binancecoin" are their native chain tokens.
  String _inferChainFromCoinGeckoId(String? id) {
    if (id == null) return 'unknown';

    // Map of known CoinGecko IDs to their native chains
    const nativeChainMap = {
      'ethereum': 'ethereum',
      'binancecoin': 'binance-smart-chain',
      'matic-network': 'polygon-pos',
      'avalanche-2': 'avalanche',
      'fantom': 'fantom',
      'arbitrum': 'arbitrum-one',
      'optimism': 'optimistic-ethereum',
      'base': 'base',
      'sui': 'sui',
      'aptos': 'aptos',
      'bitcoin': 'bitcoin',
      'dogecoin': 'dogecoin',
      'litecoin': 'litecoin',
      'cardano': 'cardano',
      'polkadot': 'polkadot',
      'cosmos': 'cosmos',
      'near': 'near-protocol',
      'tron': 'tron',
      'stellar': 'stellar',
      'ripple': 'ripple',
      'solana': 'solana', // In case CoinGecko returns Solana too
    };

    // Check if this is a known native chain token
    if (nativeChainMap.containsKey(id)) {
      return nativeChainMap[id]!;
    }

    // For other tokens, try to infer from ID patterns
    if (id.contains('ethereum') || id.contains('-eth')) return 'ethereum';
    if (id.contains('binance') || id.contains('-bsc'))
      return 'binance-smart-chain';
    if (id.contains('polygon')) return 'polygon-pos';
    if (id.contains('arbitrum')) return 'arbitrum-one';
    if (id.contains('optimism')) return 'optimistic-ethereum';
    if (id.contains('avalanche')) return 'avalanche';
    if (id.contains('solana')) return 'solana';

    // Default to 'other' for unknown chains (better than 'unknown')
    return 'other';
  }

  /// Get top coins by market cap.
  /// Useful for showing popular tokens from all chains.
  Future<List<TokenResponseModel>> getTopCoins({
    int limit = 100,
    int page = 1,
    String? category,
  }) async {
    try {
      final response = await _api.get(
        uri: coinsMarketsUri(perPage: limit, page: page, category: category),
        header: apiHeader,
      );

      final results = <TokenResponseModel>[];

      if (response is List) {
        for (final coin in response) {
          if (coin is Map<String, dynamic>) {
            results.add(TokenResponseModel.fromCoinGecko(coin));
          }
        }
      }

      return results;
    } catch (e) {
      debugPrint('CoinGecko getTopCoins error: $e');
      return const [];
    }
  }

  /// Get price for a coin by CoinGecko ID.
  Future<TokenPrice?> getPrice(String coinId) async {
    try {
      final response = await _api.get(
        uri: simplePriceUri(
          ids: [coinId],
          include24hChange: true,
          includeMarketCap: true,
        ),
        header: apiHeader,
      );

      if (response is Map<String, dynamic>) {
        final priceData = response[coinId];
        if (priceData is Map<String, dynamic>) {
          return TokenPrice(
            usdPrice: (priceData['usd'] as num?)?.toDouble() ?? 0,
          );
        }
      }

      return null;
    } catch (e) {
      debugPrint('CoinGecko getPrice error: $e');
      return null;
    }
  }

  /// Get prices for multiple coins at once (max 250 per request).
  Future<Map<String, double>> getPrices(List<String> coinIds) async {
    if (coinIds.isEmpty) return {};

    try {
      // CoinGecko allows up to 250 ids per request
      final prices = <String, double>{};

      const batchSize = 250;
      for (var i = 0; i < coinIds.length; i += batchSize) {
        final batch = coinIds.skip(i).take(batchSize).toList();

        final response = await _api.get(
          uri: simplePriceUri(ids: batch),
          header: apiHeader,
        );

        if (response is Map<String, dynamic>) {
          for (final entry in response.entries) {
            final priceData = entry.value;
            if (priceData is Map<String, dynamic>) {
              prices[entry.key] = (priceData['usd'] as num?)?.toDouble() ?? 0;
            }
          }
        }
      }

      return prices;
    } catch (e) {
      debugPrint('CoinGecko getPrices error: $e');
      return {};
    }
  }

  /// Get trending coins (top 7 in last 24h).
  Future<List<TokenResponseModel>> getTrending() async {
    try {
      final response = await _api.get(uri: trendingUri, header: apiHeader);

      final results = <TokenResponseModel>[];

      if (response is Map<String, dynamic>) {
        final coins = response['coins'] as List?;
        if (coins != null) {
          for (final item in coins) {
            final coin = item['item'];
            if (coin is Map<String, dynamic>) {
              results.add(
                TokenResponseModel(
                  id: coin['id'] as String?,
                  name: coin['name'] as String?,
                  symbol: (coin['symbol'] as String?)?.toUpperCase(),
                  icon: coin['large'] as String? ?? coin['thumb'] as String?,
                  usdPrice: (coin['data']?['price'] as num?)?.toDouble(),
                  priceChange24h:
                      (coin['data']?['price_change_percentage_24h']?['usd']
                              as num?)
                          ?.toDouble(),
                  marketCap: (coin['data']?['market_cap'] as String?) != null
                      ? double.tryParse(
                          (coin['data']['market_cap'] as String).replaceAll(
                            RegExp(r'[^\d.]'),
                            '',
                          ),
                        )
                      : null,
                ),
              );
            }
          }
        }
      }

      return results;
    } catch (e) {
      debugPrint('CoinGecko getTrending error: $e');
      return const [];
    }
  }

  /// Get list of all supported chains/platforms.
  Future<List<ChainInfo>> getChains() async {
    try {
      final response = await _api.get(
        uri: assetPlatformsUri,
        header: apiHeader,
      );

      final chains = <ChainInfo>[];

      if (response is List) {
        for (final item in response) {
          if (item is Map<String, dynamic>) {
            chains.add(
              ChainInfo(
                id: item['id'] as String? ?? '',
                name: item['name'] as String? ?? '',
                shortName: item['shortname'] as String?,
                nativeCoinId: item['native_coin_id'] as String?,
              ),
            );
          }
        }
      }

      return chains;
    } catch (e) {
      debugPrint('CoinGecko getChains error: $e');
      return const [];
    }
  }
}

/// Represents a blockchain network/platform.
class ChainInfo {
  const ChainInfo({
    required this.id,
    required this.name,
    this.shortName,
    this.nativeCoinId,
  });

  final String id;
  final String name;
  final String? shortName;
  final String? nativeCoinId;

  /// Common chain constants
  static const solana = ChainInfo(
    id: 'solana',
    name: 'Solana',
    shortName: 'SOL',
    nativeCoinId: 'solana',
  );

  static const ethereum = ChainInfo(
    id: 'ethereum',
    name: 'Ethereum',
    shortName: 'ETH',
    nativeCoinId: 'ethereum',
  );

  static const bitcoin = ChainInfo(
    id: 'bitcoin',
    name: 'Bitcoin',
    shortName: 'BTC',
    nativeCoinId: 'bitcoin',
  );

  static const List<ChainInfo> popular = [
    solana,
    ethereum,
    bitcoin,
    ChainInfo(id: 'polygon-pos', name: 'Polygon', shortName: 'MATIC'),
    ChainInfo(id: 'arbitrum-one', name: 'Arbitrum One', shortName: 'ARB'),
    ChainInfo(id: 'optimistic-ethereum', name: 'Optimism', shortName: 'OP'),
    ChainInfo(id: 'base', name: 'Base', shortName: 'BASE'),
    ChainInfo(id: 'binance-smart-chain', name: 'BNB Chain', shortName: 'BNB'),
    ChainInfo(id: 'avalanche', name: 'Avalanche', shortName: 'AVAX'),
  ];
}
