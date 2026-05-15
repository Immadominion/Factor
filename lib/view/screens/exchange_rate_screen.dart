import 'package:factor/model/response/fiat_currency_model.dart';
import 'package:factor/src/components.dart';
import 'package:factor/src/config.dart';
import 'package:factor/src/screens.dart';
import 'package:factor/src/utils.dart';
import 'package:factor/src/view_model.dart';
import 'package:factor/utils/app_toast.dart';
import 'package:factor/view/components/neumorphic_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

enum ActiveAmountField { token, currency }

SwapTopField _toSwapTopField(ActiveAmountField field) =>
    field == ActiveAmountField.token
        ? SwapTopField.token
        : SwapTopField.currency;

class _KeypadGridCell {
  const _KeypadGridCell({
    required this.value,
    required this.row,
    required this.column,
    this.rowSpan = 1,
    this.colSpan = 1,
  });

  final String value;
  final int row;
  final int column;
  final int rowSpan;
  final int colSpan;
}

class ExchangeRateScreen extends StatefulWidget {
  const ExchangeRateScreen({super.key});

  @override
  State<ExchangeRateScreen> createState() => _ExchangeRateScreenState();
}

class _ExchangeRateScreenState extends State<ExchangeRateScreen> {
  final ExchangeRateCalculator _exchangeRateProvider = ExchangeRateCalculator();
  String? _lastErrorShown;
  ActiveAmountField _activeField = ActiveAmountField.token;
  String _fiatAmountDigits = '0';
  bool _currencyDigitsMaxed = false;
  FiatCurrency? _lastCurrency;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ExchangeRateViewModel>();
    _handleErrors(viewModel);
    _handleCurrencyChange(viewModel);
    final theme = Theme.of(context);

    final isLoadingInitial =
        (viewModel.tokensLoading || viewModel.currenciesLoading) &&
        (viewModel.tokens.isEmpty || viewModel.currencies.isEmpty);
    final hasCatalogue =
        viewModel.tokens.isNotEmpty && viewModel.currencies.isNotEmpty;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          FactorStrings.factor,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              FactorIcons.gear,
              color: theme.colorScheme.primary.withAlpha(200),
              size: 28.r,
            ),
            onPressed: _openSettings,
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: isLoadingInitial
              ? const Center(child: CircularProgressIndicator())
              : hasCatalogue
              ? _buildBody(context, viewModel)
              : _buildErrorState(viewModel),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ExchangeRateViewModel viewModel) {
    final tokenDigits = _exchangeRateProvider.coinAmountDigits;
    final tokenDisplay = UtilFunctions.formatAmount(tokenDigits);
    final editingCurrency = _activeField == ActiveAmountField.currency;

    double fiatValue;
    if (editingCurrency) {
      fiatValue = double.tryParse(_fiatAmountDigits) ?? 0;
    } else {
      fiatValue = viewModel.convertTokenAmount(tokenDigits);
      final syncedDigits = _formatEditableNumber(fiatValue);
      if (_fiatAmountDigits != syncedDigits) {
        _fiatAmountDigits = syncedDigits;
      }
    }

    final fiatDisplay = editingCurrency
        ? _formatEditingFiat(viewModel.selectedCurrency)
        : _formatFiatAmount(fiatValue, viewModel.selectedCurrency);
    final unitPriceDisplay = _buildUnitPriceDisplay(viewModel);
    final lastUpdatedLabel = _formatLastUpdated(viewModel.priceFetchedAt);

    final summary = ConversionSummary(
      token: viewModel.selectedToken,
      currency: viewModel.selectedCurrency,
      tokenAmountDisplay: tokenDisplay,
      fiatAmountDisplay: fiatDisplay,
      unitPriceDisplay: unitPriceDisplay,
      topField: _toSwapTopField(_activeField),
      onTokenTap: () => _openCoinSelector(viewModel),
      onCurrencyTap: () => _openCurrencySelector(viewModel),
      onSwap: () => _toggleActiveField(viewModel),
      lastUpdatedLabel: lastUpdatedLabel,
      ratesUpdatedLabel: viewModel.ratesLastUpdatedLabel,
      onRefresh: viewModel.refreshPrice,
    );

    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 12, right: 3),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: summary,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        _buildKeypad(viewModel),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildErrorState(ExchangeRateViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(FactorIcons.cloudOff, size: FactorIcons.xlSize),
          const SizedBox(height: 16),
          Text(
            'Unable to load live markets right now.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'Check your connection and retry.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              viewModel.reloadCatalogue();
            },
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypad(ExchangeRateViewModel viewModel) {
    const buttonSpacing = 16.0;
    const columns = 4;
    const rows = 4;

    final cells = <_KeypadGridCell>[
      const _KeypadGridCell(value: '7', row: 0, column: 0),
      const _KeypadGridCell(value: '8', row: 0, column: 1),
      const _KeypadGridCell(value: '9', row: 0, column: 2),
      const _KeypadGridCell(value: 'clear', row: 0, column: 3, rowSpan: 2),
      const _KeypadGridCell(value: '4', row: 1, column: 0),
      const _KeypadGridCell(value: '5', row: 1, column: 1),
      const _KeypadGridCell(value: '6', row: 1, column: 2),
      const _KeypadGridCell(value: '1', row: 2, column: 0),
      const _KeypadGridCell(value: '2', row: 2, column: 1),
      const _KeypadGridCell(value: '3', row: 2, column: 2),
      const _KeypadGridCell(value: 'delete', row: 2, column: 3),
      const _KeypadGridCell(value: '00', row: 3, column: 0, colSpan: 2),
      const _KeypadGridCell(value: '0', row: 3, column: 2),
      const _KeypadGridCell(value: '.', row: 3, column: 3),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : (72.0 + buttonSpacing) * columns;
        final totalSpacing = buttonSpacing * (columns - 1);
        final rawButtonSize = columns == 0
            ? 0.0
            : (availableWidth - totalSpacing) / columns;
        final buttonSizeValue = (rawButtonSize.isFinite ? rawButtonSize : 72.0)
            .clamp(0.0, 96.0);
        final buttonSize = buttonSizeValue.toDouble();

        final gridWidth = buttonSize * columns + buttonSpacing * (columns - 1);
        final gridHeight = buttonSize * rows + buttonSpacing * (rows - 1);

        return SizedBox(
          width: double.infinity,
          child: Center(
            child: SizedBox(
              width: gridWidth,
              height: gridHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  for (final cell in cells)
                    Positioned(
                      left: cell.column * (buttonSize + buttonSpacing),
                      top: cell.row * (buttonSize + buttonSpacing),
                      child: SizedBox(
                        width:
                            buttonSize * cell.colSpan +
                            buttonSpacing * (cell.colSpan - 1),
                        height:
                            buttonSize * cell.rowSpan +
                            buttonSpacing * (cell.rowSpan - 1),
                        child: _buildKeypadCell(cell.value, viewModel),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildKeypadCell(String value, ExchangeRateViewModel viewModel) {
    final isAccent = value == 'clear' || value == 'delete';
    final label = switch (value) {
      'clear' => FactorStrings.lblClear,
      'delete' => '⌫',
      _ => value,
    };

    return CalculatorButton(
      label: label,
      onTap: () => _handleKeyTap(value, viewModel),
      isAccent: isAccent,
    );
  }

  void _handleKeyTap(String value, ExchangeRateViewModel viewModel) {
    if (_exchangeRateProvider.hapticsEnabled) {
      HapticFeedback.lightImpact();
    }
    if (_exchangeRateProvider.audioClickEnabled) {
      SystemSound.play(SystemSoundType.click);
    }

    if (_activeField == ActiveAmountField.token) {
      final wasMax = _exchangeRateProvider.maximumDigitsReached;
      setState(() {
        _exchangeRateProvider.onKeyPressed(value);
      });
      final updatedFiat = viewModel.convertTokenAmount(
        _exchangeRateProvider.coinAmountDigits,
      );
      _fiatAmountDigits = _formatEditableNumber(updatedFiat);
      if (!wasMax &&
          _exchangeRateProvider.maximumDigitsReached &&
          _isNumericInput(value)) {
        showToast(msg: FactorStrings.sbMaximumDigitsReached);
      }
      return;
    }

    final previousDigits = _fiatAmountDigits;
    final wasMaxed = _currencyDigitsMaxed;
    final result = _applyKeyToDigits(previousDigits, value);

    setState(() {
      _fiatAmountDigits = result.digits;
      _currencyDigitsMaxed = result.reachedMax;

      final shouldUpdateTokens =
          value == 'clear' || previousDigits != result.digits;
      if (!shouldUpdateTokens) return;

      if (value == 'clear') {
        _exchangeRateProvider.setCoinAmountDigits('0');
        return;
      }

      final rate = viewModel.convertedPricePerToken;
      if (rate > 0) {
        final fiatAmount = double.tryParse(result.digits) ?? 0;
        final tokens = fiatAmount / rate;
        final limited = _limitDigits(_formatEditableNumber(tokens));
        _exchangeRateProvider.setCoinAmountDigits(limited);
      } else {
        _exchangeRateProvider.setCoinAmountDigits('0');
      }
    });

    if (!wasMaxed && result.reachedMax && _isNumericInput(value)) {
      showToast(msg: FactorStrings.sbMaximumDigitsReached);
    }
  }

  Future<void> _openCoinSelector(ExchangeRateViewModel viewModel) async {
    await showNeumorphicModalSheet(
      context: context,
      builder: (_) => const SelectCoinScreen(),
    );
  }

  Future<void> _openCurrencySelector(ExchangeRateViewModel viewModel) async {
    await showNeumorphicModalSheet(
      context: context,
      builder: (_) => const SelectCurrencyScreen(),
    );
  }

  /// Flips which side of the conversion is on top (the input). The amount
  /// values themselves stay correct because the bottom card is always derived
  /// from the top card via [ExchangeRateViewModel].
  void _toggleActiveField(ExchangeRateViewModel viewModel) {
    if (_exchangeRateProvider.hapticsEnabled) {
      HapticFeedback.selectionClick();
    }
    setState(() {
      if (_activeField == ActiveAmountField.token) {
        _activeField = ActiveAmountField.currency;
        // Switching to currency input: seed the editable digits with the
        // currently displayed fiat value so the user picks up where the math
        // left off.
        final synced = viewModel.convertTokenAmount(
          _exchangeRateProvider.coinAmountDigits,
        );
        _fiatAmountDigits = _formatEditableNumber(synced);
        _currencyDigitsMaxed = false;
      } else {
        _activeField = ActiveAmountField.token;
      }
    });
  }

  String _formatEditableNumber(double value) {
    final isLarge = value.abs() >= 1;
    final decimals = isLarge ? 2 : 6;
    final text = value.toStringAsFixed(decimals);
    return _trimTrailingZeros(text);
  }

  String _trimTrailingZeros(String value) {
    if (!value.contains('.')) return value;
    return value
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  String _formatEditingFiat(FiatCurrency? currency) {
    final symbol = currency?.symbol ?? currency?.code ?? '';
    final digits = _fiatAmountDigits.isEmpty ? '0' : _fiatAmountDigits;
    return [symbol, digits].where((part) => part.isNotEmpty).join(' ');
  }

  ({String digits, bool reachedMax}) _applyKeyToDigits(
    String current,
    String input,
  ) {
    if (input == 'clear') {
      return (digits: '0', reachedMax: false);
    }
    if (input == 'delete') {
      if (current.length <= 1) {
        return (digits: '0', reachedMax: false);
      }
      return (
        digits: current.substring(0, current.length - 1),
        reachedMax: false,
      );
    }
    if (input == '.' && current.contains('.')) {
      return (digits: current, reachedMax: false);
    }

    String next;
    if (current == '0') {
      if (input == '0' || input == '00') {
        return (digits: '0', reachedMax: false);
      }
      if (input == '.') {
        next = '0.';
      } else {
        next = input;
      }
    } else {
      next = '$current$input';
    }

    const maxLength = 15;
    if (next.length > maxLength) {
      return (digits: current, reachedMax: true);
    }

    return (digits: next, reachedMax: false);
  }

  String _limitDigits(String digits, {int maxLength = 15}) {
    if (digits.length <= maxLength) return digits;
    if (!digits.contains('.')) {
      return digits.substring(0, maxLength);
    }
    final parts = digits.split('.');
    final whole = parts.first;
    final fraction = parts.last;
    final remaining = maxLength - whole.length - 1;
    if (remaining <= 0) {
      return whole.substring(0, maxLength);
    }
    final allowed = remaining >= fraction.length ? fraction.length : remaining;
    final trimmedFraction = fraction.substring(0, allowed);
    final combined = '$whole.$trimmedFraction';
    return _trimTrailingZeros(combined);
  }

  bool _isNumericInput(String value) => value != 'delete' && value != 'clear';

  void _openSettings() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
  }

  void _handleErrors(ExchangeRateViewModel viewModel) {
    final message = viewModel.errorMessage;
    if (message == null || message == _lastErrorShown) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showToast(msg: message);
      viewModel.clearError();
    });
    _lastErrorShown = message;
  }

  void _handleCurrencyChange(ExchangeRateViewModel viewModel) {
    final currentCurrency = viewModel.selectedCurrency;
    if (currentCurrency == null) return;

    // Detect currency change
    if (_lastCurrency != null && _lastCurrency!.code != currentCurrency.code) {
      // Currency changed - ALWAYS keep the token amount and recalculate fiat
      // Users want to know "how much is X tokens worth in the new currency?"
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          // Keep token amount unchanged, only update fiat display
          final tokenAmount = _exchangeRateProvider.coinAmountDigits;
          final convertedFiat = viewModel.convertTokenAmount(tokenAmount);
          _fiatAmountDigits = _formatEditableNumber(convertedFiat);
        });
      });
    }
    _lastCurrency = currentCurrency;
  }

  String _buildUnitPriceDisplay(ExchangeRateViewModel viewModel) {
    final token = viewModel.selectedToken;
    final currency = viewModel.selectedCurrency;
    if (token == null || currency == null) {
      return 'Choose a token and currency to see live pricing';
    }
    if (viewModel.priceLoading && viewModel.usdPricePerToken == 0) {
      return 'Fetching live price…';
    }
    if (viewModel.usdPricePerToken == 0) {
      return 'No price data available for ${token.symbol?.toUpperCase() ?? ''} yet';
    }
    final formatted = _formatFiatAmount(
      viewModel.convertedPricePerToken,
      currency,
    );
    return '1 ${token.symbol?.toUpperCase() ?? ''} ≈ $formatted';
  }

  String? _formatLastUpdated(DateTime? timestamp) {
    if (timestamp == null) return null;
    final local = timestamp.toLocal();
    final formatter = DateFormat('MMM d, h:mm a');
    return 'Price updated ${formatter.format(local)}';
  }

  String _formatFiatAmount(double amount, FiatCurrency? currency) {
    if (currency == null) return '--';
    final decimals = amount >= 1 ? 2 : 6;
    final formatter = NumberFormat.currency(
      symbol: currency.symbol,
      decimalDigits: decimals,
    );
    return formatter.format(amount);
  }
}
