import 'package:collection/collection.dart';
import 'package:factor/model/response/price_response_model.dart';
import 'package:factor/model/response/token_response_model.dart';
import 'package:factor/src/repository.dart';

/// Backend for Jupiter API (Solana tokens).
///
/// This is the PRIMARY source for Solana tokens, including:
/// - Verified tokens
/// - LSTs (Liquid Staking Tokens)
/// - Pump.fun launches
/// - Any tradable token on Jupiter
class FactorsBackend extends ApiServices {
  Future<TokenPrice> getPriceBackend(String id) async {
    final response = await get(uri: priceInUSDUri(id), header: apiHeader);
    if (response is Map<String, dynamic>) {
      final priceResponse = PriceResponseModel.fromJson(
        Map<String, dynamic>.from(response),
      );
      final tokenPrice = priceResponse[id];
      if (tokenPrice != null) {
        return tokenPrice;
      }
    }
    throw UnknownApiException('Price data unavailable for $id');
  }

  Future<List<TokenResponseModel>> fetchTokenCatalogue() async {
    final response = await get(uri: allTokensUri, header: apiHeader);
    final tokens = <TokenResponseModel>[];
    if (response is List) {
      for (final item in response) {
        if (item is Map<String, dynamic>) {
          tokens.add(_parseJupiterToken(item));
        }
      }
    } else if (response is Map<String, dynamic>) {
      if (response['tokens'] is List) {
        for (final item in response['tokens'] as List) {
          if (item is Map<String, dynamic>) {
            tokens.add(_parseJupiterToken(item));
          }
        }
      } else {
        for (final value in response.values) {
          if (value is List) {
            for (final item in value) {
              if (item is Map<String, dynamic>) {
                tokens.add(_parseJupiterToken(item));
              }
            }
          }
        }
      }
    }

    final uniqueById = <String, TokenResponseModel>{};
    for (final token in tokens) {
      final tokenId = token.id;
      final symbol = token.symbol;
      if (tokenId == null || symbol == null || symbol.isEmpty) continue;
      uniqueById[tokenId] = token;
    }

    final cleaned = uniqueById.values.toList()
      ..sort(
        (a, b) => compareAsciiLowerCaseNatural(a.symbol ?? '', b.symbol ?? ''),
      );
    return cleaned;
  }

  Future<List<TokenResponseModel>> searchTokens(String query) async {
    if (query.isEmpty) return const <TokenResponseModel>[];
    final response = await get(
      uri: searchTokensUri(query.trim(), limit: 50),
      header: apiHeader,
    );
    final results = <TokenResponseModel>[];

    void ingest(dynamic payload) {
      if (payload is List) {
        for (final entry in payload) {
          ingest(entry);
        }
        return;
      }
      if (payload is Map<String, dynamic>) {
        results.add(_parseJupiterToken(payload));
      }
    }

    if (response is List || response is Map<String, dynamic>) {
      ingest(response);
    }

    final uniqueById = <String, TokenResponseModel>{};
    for (final token in results) {
      final tokenId = token.id;
      if (tokenId == null || tokenId.isEmpty) continue;
      uniqueById[tokenId] = token;
    }

    final cleaned = uniqueById.values.toList()
      ..sort(
        (a, b) => compareAsciiLowerCaseNatural(a.symbol ?? '', b.symbol ?? ''),
      );
    return cleaned;
  }

  /// Parse a Jupiter API token response, always tagging as Solana
  TokenResponseModel _parseJupiterToken(Map<String, dynamic> json) {
    return TokenResponseModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      symbol: json['symbol'] as String?,
      icon: json['icon'] as String?,
      decimals: (json['decimals'] as num?)?.toInt(),
      circSupply: (json['circSupply'] as num?)?.toDouble(),
      totalSupply: (json['totalSupply'] as num?)?.toDouble(),
      tokenProgram: json['tokenProgram'] as String?,
      ctLikes: (json['ctLikes'] as num?)?.toInt(),
      smartCtLikes: (json['smartCtLikes'] as num?)?.toInt(),
      updatedAt: json['updatedAt'] as String?,
      tags: (json['tags'] as List?)?.map((tag) => tag.toString()).toList(),
      usdPrice: (json['usdPrice'] as num?)?.toDouble(),
      launchpad: json['launchpad'] as String?,
      holderCount: (json['holderCount'] as num?)?.toInt(),
      // Jupiter tokens are always Solana
      chainId: 'solana',
    );
  }
}
