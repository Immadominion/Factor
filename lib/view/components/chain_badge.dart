import 'package:factor/model/response/token_response_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A small badge that displays the chain of a token.
///
/// Shows a colored badge with the chain name (e.g., "ETH", "BSC", "SOL").
/// Returns an empty SizedBox for Solana tokens to keep the Jupiter experience clean.
class ChainBadge extends StatelessWidget {
  const ChainBadge({
    super.key,
    required this.token,
    this.showForSolana = false,
  });

  final TokenResponseModel token;

  /// Whether to show the badge for Solana tokens.
  /// Default is false (Solana is the primary chain, no badge needed).
  final bool showForSolana;

  @override
  Widget build(BuildContext context) {
    // Don't show badge for Solana unless explicitly requested
    if (token.isSolana && !showForSolana) {
      return const SizedBox.shrink();
    }

    final chainInfo = _getChainInfo(token.chainId);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 2.r),
      decoration: BoxDecoration(
        color: chainInfo.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(
          color: chainInfo.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        chainInfo.shortName,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: chainInfo.color,
          height: 1.2,
        ),
      ),
    );
  }

  _ChainDisplayInfo _getChainInfo(String? chainId) {
    final id = chainId?.toLowerCase() ?? '';

    // Chain-specific colors and short names
    switch (id) {
      case 'solana':
        return _ChainDisplayInfo('SOL', const Color(0xFF9945FF));
      case 'ethereum':
        return _ChainDisplayInfo('ETH', const Color(0xFF627EEA));
      case 'binance-smart-chain':
        return _ChainDisplayInfo('BSC', const Color(0xFFF3BA2F));
      case 'polygon-pos':
        return _ChainDisplayInfo('MATIC', const Color(0xFF8247E5));
      case 'avalanche':
        return _ChainDisplayInfo('AVAX', const Color(0xFFE84142));
      case 'arbitrum-one':
        return _ChainDisplayInfo('ARB', const Color(0xFF28A0F0));
      case 'optimistic-ethereum':
        return _ChainDisplayInfo('OP', const Color(0xFFFF0420));
      case 'base':
        return _ChainDisplayInfo('BASE', const Color(0xFF0052FF));
      case 'fantom':
        return _ChainDisplayInfo('FTM', const Color(0xFF1969FF));
      case 'sui':
        return _ChainDisplayInfo('SUI', const Color(0xFF4DA2FF));
      case 'aptos':
        return _ChainDisplayInfo('APT', const Color(0xFF2DD8A3));
      case 'bitcoin':
        return _ChainDisplayInfo('BTC', const Color(0xFFF7931A));
      case 'cosmos':
        return _ChainDisplayInfo('ATOM', const Color(0xFF2E3148));
      case 'near-protocol':
        return _ChainDisplayInfo('NEAR', const Color(0xFF00EC97));
      case 'tron':
        return _ChainDisplayInfo('TRX', const Color(0xFFFF0013));
      case 'ripple':
        return _ChainDisplayInfo('XRP', const Color(0xFF23292F));
      case 'cardano':
        return _ChainDisplayInfo('ADA', const Color(0xFF0033AD));
      case 'polkadot':
        return _ChainDisplayInfo('DOT', const Color(0xFFE6007A));
      case 'dogecoin':
        return _ChainDisplayInfo('DOGE', const Color(0xFFC2A633));
      case 'litecoin':
        return _ChainDisplayInfo('LTC', const Color(0xFF345D9D));
      case 'stellar':
        return _ChainDisplayInfo('XLM', const Color(0xFF14B6E7));
      default:
        // Try to extract a meaningful short name from chain ID
        final shortName = _extractShortName(id);
        return _ChainDisplayInfo(shortName, const Color(0xFF6B7280));
    }
  }

  String _extractShortName(String chainId) {
    if (chainId.isEmpty || chainId == 'other' || chainId == 'unknown') {
      return 'MULTI';
    }
    // Take first 4 characters and uppercase
    final cleaned = chainId.replaceAll(RegExp(r'[^a-zA-Z]'), '');
    return cleaned.substring(0, cleaned.length.clamp(0, 4)).toUpperCase();
  }
}

class _ChainDisplayInfo {
  const _ChainDisplayInfo(this.shortName, this.color);
  final String shortName;
  final Color color;
}
