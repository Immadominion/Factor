import 'package:factor/model/response/fiat_currency_model.dart';
import 'package:factor/src/config.dart';
import 'package:factor/src/view_model.dart';
import 'package:factor/view/components/neumorphic_bottom_sheet.dart';
import 'package:factor/view/components/neumorphic_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class SelectCurrencyScreen extends StatefulWidget {
  const SelectCurrencyScreen({super.key});

  @override
  State<SelectCurrencyScreen> createState() => _SelectCurrencyScreenState();
}

class _SelectCurrencyScreenState extends State<SelectCurrencyScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSelecting = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onQueryChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    context.read<ExchangeRateViewModel>().searchCurrencies(
      _searchController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ExchangeRateViewModel>();
    final currencies = viewModel.currencies;
    final isLoading = viewModel.currenciesLoading && currencies.isEmpty;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const NeumorphicSheetHandle(),
            Text(
              FactorStrings.hdrSelectCurrency,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: FactorStrings.hintSearch,
                prefixIcon: Icon(
                  FactorIcons.search,
                  size: FactorIcons.defaultSize,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () => _searchController.clear(),
                        icon: Icon(
                          FactorIcons.close,
                          size: FactorIcons.defaultSize,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: currencies.length,
                      itemBuilder: (context, index) {
                        final FiatCurrency currency = currencies[index];
                        final subtitle =
                            '1 USD = ${currency.rateToUsd.toStringAsFixed(4)} ${currency.code}';
                        final isSelected =
                            currency.code == viewModel.selectedCurrency?.code;
                        final isFavorite = viewModel.isCurrencyFavorite(
                          currency.code,
                        );
                        return Padding(
                          padding: const EdgeInsets.only(right: 4, left: 4),
                          child: NeumorphicSelectorTile(
                            title: '${currency.code} • ${currency.name}',
                            subtitle: subtitle,
                            leading: _CurrencyLeading(
                              symbol: currency.symbol,
                              code: currency.code,
                            ),
                            isSelected: isSelected,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _FavoriteStar(
                                  isFavorite: isFavorite,
                                  onTap: () => viewModel
                                      .toggleFavoriteCurrency(currency.code),
                                ),
                                if (isSelected) ...[
                                  SizedBox(width: 8.r),
                                  Icon(
                                    FactorIcons.checkCircle,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    size: FactorIcons.defaultSize,
                                  ),
                                ],
                              ],
                            ),
                            onTap: () {
                              if (_isSelecting) return;
                              _isSelecting = true;
                              try {
                                viewModel.selectCurrency(currency);
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              } finally {
                                if (mounted) {
                                  _isSelecting = false;
                                }
                              }
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrencyLeading extends StatelessWidget {
  const _CurrencyLeading({required this.symbol, required this.code});

  final String symbol;
  final String code;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final display = symbol.length > 1 ? code : symbol;
    return CircleAvatar(
      backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
      foregroundColor: theme.colorScheme.secondary,
      child: Text(display),
    );
  }
}

/// Tappable star that toggles favorite state for a currency tile.
class _FavoriteStar extends StatelessWidget {
  const _FavoriteStar({required this.isFavorite, required this.onTap});

  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isFavorite
        ? theme.colorScheme.primary
        : theme.iconTheme.color?.withValues(alpha: 0.45);
    return InkResponse(
      onTap: onTap,
      radius: 18.r,
      child: Padding(
        padding: EdgeInsets.all(6.r),
        child: Icon(
          isFavorite ? PhosphorIconsFill.star : PhosphorIconsRegular.star,
          size: FactorIcons.smallSize,
          color: color,
        ),
      ),
    );
  }
}
