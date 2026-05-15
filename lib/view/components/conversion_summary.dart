import 'package:factor/cofig/factor_icons.dart';
import 'package:factor/model/response/fiat_currency_model.dart';
import 'package:factor/model/response/token_response_model.dart';
import 'package:factor/view/components/chain_badge.dart';
import 'package:factor/view/components/neumorphic_card.dart';
import 'package:factor/view/components/neumorphic_style.dart';
import 'package:factor/view/components/token_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Identifies which side of the conversion is on top (the editable input).
enum SwapTopField { token, currency }

/// Solflare-style swap layout: the top card is always the input, the bottom
/// card shows the derived amount, and a circular swap button between them
/// flips which card is on top.
class ConversionSummary extends StatelessWidget {
  const ConversionSummary({
    super.key,
    required this.token,
    required this.currency,
    required this.tokenAmountDisplay,
    required this.fiatAmountDisplay,
    required this.unitPriceDisplay,
    required this.topField,
    required this.onTokenTap,
    required this.onCurrencyTap,
    required this.onSwap,
    this.lastUpdatedLabel,
    this.ratesUpdatedLabel,
    this.onRefresh,
  });

  final TokenResponseModel? token;
  final FiatCurrency? currency;
  final String tokenAmountDisplay;
  final String fiatAmountDisplay;
  final String unitPriceDisplay;
  final SwapTopField topField;
  final VoidCallback onTokenTap;
  final VoidCallback onCurrencyTap;
  final VoidCallback onSwap;
  final String? lastUpdatedLabel;
  final String? ratesUpdatedLabel;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTokenTop = topField == SwapTopField.token;

    final tokenCard = _SwapCard(
      label: isTokenTop ? 'YOU PAY' : 'YOU GET',
      amount: tokenAmountDisplay,
      caption: token?.symbol?.toUpperCase(),
      isInput: isTokenTop,
      pill: _TokenPill(token: token, onTap: onTokenTap),
    );

    final currencyCard = _SwapCard(
      label: !isTokenTop ? 'YOU PAY' : 'YOU GET',
      amount: fiatAmountDisplay,
      caption: currency?.code,
      isInput: !isTokenTop,
      pill: _CurrencyPill(currency: currency, onTap: onCurrencyTap),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Column(
              children: [
                isTokenTop ? tokenCard : currencyCard,
                const SizedBox(height: 12),
                isTokenTop ? currencyCard : tokenCard,
              ],
            ),
            _SwapButton(onTap: onSwap),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                unitPriceDisplay,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withValues(
                    alpha: 0.6,
                  ),
                ),
              ),
            ),
            if (onRefresh != null)
              GestureDetector(
                onTap: onRefresh,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    FactorIcons.refresh,
                    size: FactorIcons.smallSize,
                    color: theme.colorScheme.primary.withValues(alpha: 0.8),
                  ),
                ),
              ),
          ],
        ),
        if (lastUpdatedLabel != null) ...[
          const SizedBox(height: 4),
          Text(
            lastUpdatedLabel!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
            ),
          ),
        ],
        if (ratesUpdatedLabel != null)
          Text(
            'FX rates: $ratesUpdatedLabel',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
            ),
          ),
      ],
    );
  }
}

/// One side of the swap layout. Amount sits on the left, the
/// token/currency selector pill sits on the right.
class _SwapCard extends StatelessWidget {
  const _SwapCard({
    required this.label,
    required this.amount,
    required this.caption,
    required this.isInput,
    required this.pill,
  });

  final String label;
  final String amount;
  final String? caption;
  final bool isInput;
  final Widget pill;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedColor = theme.textTheme.bodySmall?.color?.withValues(
      alpha: 0.55,
    );
    final amountBaseColor =
        theme.textTheme.displaySmall?.color ?? theme.colorScheme.onSurface;
    final amountColor = isInput
        ? amountBaseColor
        : amountBaseColor.withValues(alpha: 0.65);

    return NeumorphicCard(
      borderRadius: 24,
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: mutedColor,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      amount,
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: amountColor,
                        fontWeight: FontWeight.w700,
                        height: 1.05,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),
                if (caption != null && caption!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    caption!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: mutedColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          pill,
        ],
      ),
    );
  }
}

class _TokenPill extends StatelessWidget {
  const _TokenPill({required this.token, required this.onTap});

  final TokenResponseModel? token;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final symbol = token?.symbol?.toUpperCase() ?? 'Select';
    return _PillShell(
      onTap: onTap,
      leading: SizedBox(
        width: 32.r,
        height: 28.r,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            TokenAvatar(
              imageUrl: token?.icon,
              symbol: token?.symbol,
              size: 28,
            ),
            if (token != null && !token!.isSolana)
              Positioned(
                right: -4.r,
                bottom: -4.r,
                child: ChainBadge(token: token!),
              ),
          ],
        ),
      ),
      label: Text(
        symbol,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _CurrencyPill extends StatelessWidget {
  const _CurrencyPill({required this.currency, required this.onTap});

  final FiatCurrency? currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final code = currency?.code ?? 'Select';
    final symbol = currency?.symbol ?? code;
    final glyph = symbol.length > 2 ? code.substring(0, 1) : symbol;
    return _PillShell(
      onTap: onTap,
      leading: Container(
        width: 28.r,
        height: 28.r,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.primary.withValues(alpha: 0.16),
        ),
        child: Text(
          glyph,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
      label: Text(
        code,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PillShell extends StatefulWidget {
  const _PillShell({
    required this.onTap,
    required this.leading,
    required this.label,
  });

  final VoidCallback onTap;
  final Widget leading;
  final Widget label;

  @override
  State<_PillShell> createState() => _PillShellState();
}

class _PillShellState extends State<_PillShell> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final decoration = NeumorphicStyle.outerDecoration(
      context,
      borderRadius: 18,
      isPressed: _pressed,
    );
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: decoration,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.leading,
            const SizedBox(width: 8),
            widget.label,
            const SizedBox(width: 4),
            Icon(
              FactorIcons.chevronDown,
              size: FactorIcons.smallSize,
              color: theme.iconTheme.color?.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwapButton extends StatefulWidget {
  const _SwapButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_SwapButton> createState() => _SwapButtonState();
}

class _SwapButtonState extends State<_SwapButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );

  bool _pressed = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward(from: 0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        _handleTap();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        width: 48,
        height: 48,
        decoration: NeumorphicStyle.outerDecoration(
          context,
          borderRadius: 24,
          isPressed: _pressed,
        ),
        alignment: Alignment.center,
        child: RotationTransition(
          turns: Tween<double>(begin: 0, end: 0.5).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
          ),
          child: Icon(
            FactorIcons.swap,
            size: 22.r,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
