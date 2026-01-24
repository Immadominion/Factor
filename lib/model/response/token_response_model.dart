class TokenResponseModel {
  TokenResponseModel({
    this.id,
    this.name,
    this.symbol,
    this.icon,
    this.decimals,
    this.circSupply,
    this.totalSupply,
    this.tokenProgram,
    this.ctLikes,
    this.smartCtLikes,
    this.updatedAt,
    this.tags,
    this.usdPrice,
    this.launchpad,
    this.holderCount,
    this.chainId,
    this.marketCap,
    this.priceChange24h,
  });

  final String? id;
  final String? name;
  final String? symbol;
  final String? icon;
  final int? decimals;
  final double? circSupply;
  final double? totalSupply;
  final String? tokenProgram;
  final int? ctLikes;
  final int? smartCtLikes;
  final String? updatedAt;
  final List<String>? tags;
  final double? usdPrice;
  final String? launchpad;
  final int? holderCount;

  /// Chain identifier (e.g., 'solana', 'ethereum', 'bitcoin')
  /// Defaults to 'solana' for Jupiter-sourced tokens
  final String? chainId;

  /// Market capitalization in USD
  final double? marketCap;

  /// 24-hour price change percentage
  final double? priceChange24h;

  /// Returns the display name of the chain
  String get chainDisplayName {
    switch (chainId) {
      case 'solana':
        return 'Solana';
      case 'ethereum':
        return 'Ethereum';
      case 'bitcoin':
        return 'Bitcoin';
      case 'polygon-pos':
        return 'Polygon';
      case 'arbitrum-one':
        return 'Arbitrum';
      case 'optimistic-ethereum':
        return 'Optimism';
      case 'base':
        return 'Base';
      case 'binance-smart-chain':
        return 'BNB Chain';
      case 'avalanche':
        return 'Avalanche';
      default:
        return chainId?.toUpperCase() ?? 'Unknown';
    }
  }

  /// Whether this token is from Solana (Jupiter source)
  bool get isSolana => chainId == 'solana' || chainId == null;

  TokenResponseModel copyWith({
    String? id,
    String? name,
    String? symbol,
    String? icon,
    int? decimals,
    double? circSupply,
    double? totalSupply,
    String? tokenProgram,
    int? ctLikes,
    int? smartCtLikes,
    String? updatedAt,
    List<String>? tags,
    double? usdPrice,
    String? launchpad,
    int? holderCount,
    String? chainId,
    double? marketCap,
    double? priceChange24h,
  }) {
    return TokenResponseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      icon: icon ?? this.icon,
      decimals: decimals ?? this.decimals,
      circSupply: circSupply ?? this.circSupply,
      totalSupply: totalSupply ?? this.totalSupply,
      tokenProgram: tokenProgram ?? this.tokenProgram,
      ctLikes: ctLikes ?? this.ctLikes,
      smartCtLikes: smartCtLikes ?? this.smartCtLikes,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      usdPrice: usdPrice ?? this.usdPrice,
      launchpad: launchpad ?? this.launchpad,
      holderCount: holderCount ?? this.holderCount,
      chainId: chainId ?? this.chainId,
      marketCap: marketCap ?? this.marketCap,
      priceChange24h: priceChange24h ?? this.priceChange24h,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'symbol': symbol,
      'icon': icon,
      'decimals': decimals,
      'circSupply': circSupply,
      'totalSupply': totalSupply,
      'tokenProgram': tokenProgram,
      'ctLikes': ctLikes,
      'smartCtLikes': smartCtLikes,
      'updatedAt': updatedAt,
      'tags': tags,
      'usdPrice': usdPrice,
      'launchpad': launchpad,
      'holderCount': holderCount,
      'chainId': chainId,
      'marketCap': marketCap,
      'priceChange24h': priceChange24h,
    };
  }

  factory TokenResponseModel.fromJson(Map<String, dynamic> json) {
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
      chainId: json['chainId'] as String?,
      marketCap: (json['marketCap'] as num?)?.toDouble(),
      priceChange24h: (json['priceChange24h'] as num?)?.toDouble(),
    );
  }

  /// Factory for creating from CoinGecko API response
  factory TokenResponseModel.fromCoinGecko(Map<String, dynamic> json) {
    return TokenResponseModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      symbol: (json['symbol'] as String?)?.toUpperCase(),
      icon:
          json['image'] as String? ??
          json['large'] as String? ??
          json['thumb'] as String?,
      usdPrice: (json['current_price'] as num?)?.toDouble(),
      marketCap: (json['market_cap'] as num?)?.toDouble(),
      priceChange24h: (json['price_change_percentage_24h'] as num?)?.toDouble(),
      // CoinGecko doesn't specify chain in search results, we infer from platforms
      chainId: _inferChainFromPlatforms(json['platforms']),
    );
  }

  static String? _inferChainFromPlatforms(dynamic platforms) {
    if (platforms == null || platforms is! Map) return null;
    final platformMap = Map<String, dynamic>.from(platforms);
    // Priority order for chain detection
    const priorityOrder = [
      'ethereum',
      'solana',
      'polygon-pos',
      'arbitrum-one',
      'optimistic-ethereum',
      'base',
      'binance-smart-chain',
      'avalanche',
    ];
    for (final chain in priorityOrder) {
      if (platformMap.containsKey(chain)) return chain;
    }
    // Return first available chain if none match priority
    return platformMap.keys.isNotEmpty ? platformMap.keys.first : null;
  }

  bool matchesQuery(String query) {
    if (query.isEmpty) return true;
    final normalizedQuery = query.toLowerCase();
    final attributes = [name, symbol, id];
    return attributes.whereType<String>().any(
      (value) => value.toLowerCase().contains(normalizedQuery),
    );
  }

  @override
  String toString() =>
      'TokenResponseModel(id: $id, name: $name, symbol: $symbol, icon: $icon, decimals: $decimals, circSupply: $circSupply, totalSupply: $totalSupply, usdPrice: $usdPrice)';

  @override
  int get hashCode => Object.hash(
    id,
    name,
    symbol,
    icon,
    decimals,
    circSupply,
    totalSupply,
    tokenProgram,
    ctLikes,
    smartCtLikes,
    updatedAt,
    usdPrice,
    launchpad,
    holderCount,
  );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TokenResponseModel &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            symbol == other.symbol;
  }
}
