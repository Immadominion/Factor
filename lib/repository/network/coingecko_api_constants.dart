import 'dart:io';

/// API constants for CoinGecko crypto data aggregator.
///
/// CoinGecko provides:
/// - 200+ blockchain networks
/// - 18,000+ cryptocurrencies
/// - 24M+ tokens across all chains
/// - NFT floor prices
/// - Real-time pricing data
///
/// Free tier (Demo): 10,000 calls/month, 30 calls/min
/// Basic tier ($29/mo): 100,000 calls/month, 250 calls/min
class CoinGeckoApiConstants {
  /// Whether to use Pro API (requires paid API key)
  static const bool usePro = false;

  /// Base URL for API requests
  static String get baseUrl => usePro
      ? 'https://pro-api.coingecko.com/api/v3'
      : 'https://api.coingecko.com/api/v3';

  /// API key header name
  static String get apiKeyHeader =>
      usePro ? 'x-cg-pro-api-key' : 'x-cg-demo-api-key';

  /// Optional API key (set via environment variable or hardcode for dev)
  /// Get your key at: https://www.coingecko.com/en/api/pricing
  static const String apiKey = String.fromEnvironment(
    'COINGECKO_API_KEY',
    defaultValue: '',
  );

  static bool get hasApiKey => apiKey.isNotEmpty;

  // ═══════════════════════════════════════════════════════════════════════════
  // ENDPOINTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get list of all supported coins with id, name, symbol
  /// Includes `platforms` field showing which chains each coin is on
  Uri get coinsListUri => Uri.parse(
    '$baseUrl/coins/list',
  ).replace(queryParameters: {'include_platform': 'true'});

  /// Get simple price for multiple coins
  Uri simplePriceUri({
    required List<String> ids,
    List<String> vsCurrencies = const ['usd'],
    bool includeMarketCap = false,
    bool include24hVol = false,
    bool include24hChange = false,
    bool includeLastUpdatedAt = true,
  }) {
    return Uri.parse('$baseUrl/simple/price').replace(
      queryParameters: {
        'ids': ids.join(','),
        'vs_currencies': vsCurrencies.join(','),
        if (includeMarketCap) 'include_market_cap': 'true',
        if (include24hVol) 'include_24hr_vol': 'true',
        if (include24hChange) 'include_24hr_change': 'true',
        if (includeLastUpdatedAt) 'include_last_updated_at': 'true',
      },
    );
  }

  /// Search for coins, NFTs, exchanges
  Uri searchUri(String query) =>
      Uri.parse('$baseUrl/search').replace(queryParameters: {'query': query});

  /// Get coin market data with price, market cap, volume
  Uri coinsMarketsUri({
    String vsCurrency = 'usd',
    List<String>? ids,
    String? category,
    String order = 'market_cap_desc',
    int perPage = 100,
    int page = 1,
    bool sparkline = false,
  }) {
    return Uri.parse('$baseUrl/coins/markets').replace(
      queryParameters: {
        'vs_currency': vsCurrency,
        if (ids != null) 'ids': ids.join(','),
        if (category != null) 'category': category,
        'order': order,
        'per_page': '$perPage',
        'page': '$page',
        'sparkline': '$sparkline',
      },
    );
  }

  /// Get list of supported asset platforms (chains)
  Uri get assetPlatformsUri => Uri.parse('$baseUrl/asset_platforms');

  /// Get trending search (top 7 coins in last 24h)
  Uri get trendingUri => Uri.parse('$baseUrl/search/trending');

  /// Get coin categories list
  Uri get categoriesListUri => Uri.parse('$baseUrl/coins/categories/list');

  /// Get coins by category with market data
  Uri categoriesMarketsUri({
    String category = '',
    String vsCurrency = 'usd',
    String order = 'market_cap_desc',
    int perPage = 100,
    int page = 1,
  }) {
    return Uri.parse('$baseUrl/coins/markets').replace(
      queryParameters: {
        'vs_currency': vsCurrency,
        'category': category,
        'order': order,
        'per_page': '$perPage',
        'page': '$page',
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // NFT ENDPOINTS (for future implementation)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get list of all NFT collections
  Uri nftsListUri({int perPage = 100, int page = 1}) {
    return Uri.parse(
      '$baseUrl/nfts/list',
    ).replace(queryParameters: {'per_page': '$perPage', 'page': '$page'});
  }

  /// Get NFT collection data by ID
  Uri nftDataUri(String id) => Uri.parse('$baseUrl/nfts/$id');

  // ═══════════════════════════════════════════════════════════════════════════
  // HEADERS
  // ═══════════════════════════════════════════════════════════════════════════

  Map<String, String> get apiHeader => {
    HttpHeaders.contentTypeHeader: 'application/json',
    HttpHeaders.acceptHeader: 'application/json',
    if (hasApiKey) apiKeyHeader: apiKey,
  };
}
