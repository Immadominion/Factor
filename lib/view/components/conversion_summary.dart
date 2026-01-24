import 'package:factor/model/response/fiat_currency_model.dart';
import 'package:factor/model/response/token_response_model.dart';
import 'package:factor/view/components/chain_badge.dart';
import 'package:factor/view/components/neumorphic_card.dart';
import 'package:factor/view/components/token_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ConversionSummary extends StatelessWidget {
  const ConversionSummary({
    super.key,
    required this.token,
    required this.currency,
    required this.tokenAmountDisplay,
    required this.fiatAmountDisplay,
    required this.unitPriceDisplay,
    required this.onTokenTap,
    required this.onCurrencyTap,
    required this.isTokenActive,
    required this.isCurrencyActive,
    this.onTokenAmountTap,
    this.onCurrencyAmountTap,
    this.lastUpdatedLabel,
    this.ratesUpdatedLabel,
    this.onRefresh,
  });

  final TokenResponseModel? token;
  final FiatCurrency? currency;
  final String tokenAmountDisplay;
  final String fiatAmountDisplay;
  final String unitPriceDisplay;
  final VoidCallback onTokenTap;
  final VoidCallback onCurrencyTap;
  final bool isTokenActive;
  final bool isCurrencyActive;
  final VoidCallback? onTokenAmountTap;
  final VoidCallback? onCurrencyAmountTap;
  final String? lastUpdatedLabel;
  final String? ratesUpdatedLabel;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SelectionTile(
          title: token?.symbol?.toUpperCase() ?? '--',
          subtitle: token?.name ?? 'Select token',
          value: tokenAmountDisplay,
          caption: token?.symbol?.toUpperCase(),
          isActive: isTokenActive,
          onTileTap: onTokenTap,
          onValueTap: onTokenAmountTap,
          leading: _TokenLeadingWithBadge(token: token),
        ),
        const SizedBox(height: 12),
        _SelectionTile(
          title: currency?.code ?? '--',
          subtitle: currency?.name ?? 'Select currency',
          value: fiatAmountDisplay,
          caption: currency?.symbol ?? currency?.code,
          isActive: isCurrencyActive,
          onTileTap: onCurrencyTap,
          onValueTap: onCurrencyAmountTap,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (lastUpdatedLabel != null)
              Text(
                lastUpdatedLabel!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withValues(
                    alpha: 0.58,
                  ),
                ),
              ),
            Text(
              unitPriceDisplay,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(
                  alpha: 0.58,
                ),
              ),
            ),
          ],
        ),

        if (ratesUpdatedLabel != null)
          Text(
            'FX rates: $ratesUpdatedLabel',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.58),
            ),
          ),
      ],
    );
  }
}

class _SelectionTile extends StatelessWidget {
  const _SelectionTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.isActive,
    required this.onTileTap,
    this.onValueTap,
    this.caption,
    this.leading,
  });

  final String title;
  final String subtitle;
  final String value;
  final bool isActive;
  final VoidCallback onTileTap;
  final VoidCallback? onValueTap;
  final String? caption;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor =
        theme.textTheme.bodyLarge?.color ?? theme.colorScheme.onSurface;

    return NeumorphicCard(
      isActive: isActive,
      onTap: onTileTap,
      borderRadius: 28,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 12)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    height: 1.05,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: textColor.withValues(alpha: 0.6),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _AmountDisplay(
            value: value,
            caption: caption,
            isActive: isActive,
            onTap: onValueTap,
          ),
        ],
      ),
    );
  }
}

class _AmountDisplay extends StatelessWidget {
  const _AmountDisplay({
    required this.value,
    required this.isActive,
    this.caption,
    this.onTap,
  });

  final String value;
  final bool isActive;
  final String? caption;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final valueStyle = theme.textTheme.displaySmall?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
      height: 1.1,
    );

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          height: 16,
          child: AnimatedOpacity(
            opacity: isActive ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: const _ActiveBadge(),
          ),
        ),
        const SizedBox(height: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 150),
          child: FittedBox(
            alignment: Alignment.centerRight,
            fit: BoxFit.scaleDown,
            child: Text(value, style: valueStyle),
          ),
        ),
      ],
    );

    if (onTap != null) {
      content = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}

class _ActiveBadge extends StatelessWidget {
  const _ActiveBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: baseColor.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.24 : 0.2,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: baseColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            'Typing',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
              height: .5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Token avatar with chain badge overlay for non-Solana tokens
class _TokenLeadingWithBadge extends StatelessWidget {
  const _TokenLeadingWithBadge({required this.token});

  final TokenResponseModel? token;

  @override
  Widget build(BuildContext context) {
    if (token == null) {
      return TokenAvatar(imageUrl: null, symbol: null, size: 36);
    }

    return SizedBox(
      width: 44.r,
      height: 36.r,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          TokenAvatar(imageUrl: token!.icon, symbol: token!.symbol, size: 36),
          // Chain badge positioned at bottom-right of avatar
          if (!token!.isSolana)
            Positioned(
              right: -4.r,
              bottom: -4.r,
              child: ChainBadge(token: token!),
            ),
        ],
      ),
    );
  }
}
