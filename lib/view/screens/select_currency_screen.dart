import 'package:factor/model/response/fiat_currency_model.dart';
import 'package:factor/src/config.dart';
import 'package:factor/src/view_model.dart';
import 'package:factor/view/components/neumorphic_bottom_sheet.dart';
import 'package:factor/view/components/neumorphic_selector.dart';
import 'package:flutter/material.dart';
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
                        return Padding(
                          padding: const EdgeInsets.only(right: 4, left: 4),
                          child: NeumorphicSelectorTile(
                            title: '${currency.code} • ${currency.name}',
                            subtitle: subtitle,
                            leading: _CurrencyLeading(
                              symbol: currency.symbol,
                              code: currency.code,
                            ),
                            isSelected:
                                currency.code ==
                                viewModel.selectedCurrency?.code,
                            trailing:
                                currency.code ==
                                    viewModel.selectedCurrency?.code
                                ? Icon(
                                    FactorIcons.checkCircle,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    size: FactorIcons.defaultSize,
                                  )
                                : null,
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
