import 'package:factor/repository/services/preferences_service.dart';

class ExchangeRateCalculator {
  ExchangeRateCalculator._();
  static final ExchangeRateCalculator _instance = ExchangeRateCalculator._();
  factory ExchangeRateCalculator() => _instance;

  final List<String> _keyPadValues = [
    '7',
    '8',
    '9',
    '4',
    '5',
    '6',
    '1',
    '2',
    '3',
    '00',
    '0',
    '.',
  ];
  List<String> get keyPadValues => _keyPadValues;
  String _coinAmountDigits = '0';
  String get coinAmountDigits => _coinAmountDigits;
  final num _currencyAmount = 0;
  num get currencyAmount => _currencyAmount;
  double _exchangeRateItemFontSize = 32;
  double get exchangeRateItemFontSize => _exchangeRateItemFontSize;
  bool _maximumDigitsReached = false;
  bool get maximumDigitsReached => _maximumDigitsReached;
  int _selectedCurrency = 0;
  int get selectedCurrency => _selectedCurrency;
  int _selectedCoin = 0;
  int get selectedCoin => _selectedCoin;
  bool _searchingForACoin = false;
  bool get searchingForACoin => _searchingForACoin;
  bool _searchingForACurrency = false;
  bool get searchingForACurrency => _searchingForACurrency;
  bool _isSelectCoinScreenInteractionDisabled = false;
  bool get isSelectCoinScreenInteractionDisabled =>
      _isSelectCoinScreenInteractionDisabled;
  bool _isSelectCurrencyScreenInteractionDisabled = false;
  bool get isSelectCurrencyScreenInteractionDisabled =>
      _isSelectCurrencyScreenInteractionDisabled;
  bool _hapticsEnabled = true;
  bool _audioClickEnabled = true;

  bool get hapticsEnabled => _hapticsEnabled;
  bool get audioClickEnabled => _audioClickEnabled;

  PreferencesService? _preferences;

  /// Wires the singleton up to a [PreferencesService] and hydrates the
  /// persisted feedback toggles. Safe to call multiple times.
  Future<void> bindPreferences(PreferencesService preferences) async {
    _preferences = preferences;
    _hapticsEnabled = await preferences.getHapticsEnabled();
    _audioClickEnabled = await preferences.getAudioClickEnabled();
  }

  Future<void> setHapticsEnabled(bool value) async {
    _hapticsEnabled = value;
    await _preferences?.setHapticsEnabled(value);
  }

  Future<void> setAudioClickEnabled(bool value) async {
    _audioClickEnabled = value;
    await _preferences?.setAudioClickEnabled(value);
  }

  ///Method handles keypad tap actions.
  /// - If the key is `'clear'`, resets [_coinAmountDigits] to `'0'`.
  /// - If the key is `'delete'`, removes the last character or resets to `'0'`
  ///   when only one character remains.
  /// - Otherwise, appends the digit (or `.`) to [_coinAmountDigits],
  ///   unless the maximum length is reached.
  void onKeyPressed(String value) {
    if (value == 'clear') {
      _coinAmountDigits = '0';
      _maximumDigitsReached = false;
      adjustFontSizeByListLength();
      return;
    }
    if (value == 'delete') {
      if (_coinAmountDigits.length > 1) {
        _coinAmountDigits = _coinAmountDigits.substring(
          0,
          _coinAmountDigits.length - 1,
        );
        _maximumDigitsReached = false;
        adjustFontSizeByListLength();
      } else {
        _coinAmountDigits = '0';
      }
      return;
    }
    if (_coinAmountDigits.length < 15) {
      addDigitToCoinAmount(value);
      adjustFontSizeByListLength();
    } else {
      _maximumDigitsReached = true;
    }
  }

  /// Appends a digit from the keypad to [_coinAmountDigits].
  /// - Prevents multiple `.` characters.
  /// - If the current value is `'0'`:
  ///   - Ignores additional `'0'` inputs.
  ///   - Allows `'0.'` when `'.'` is pressed.
  ///   - Replaces `'0'` with a non-zero digit.
  void addDigitToCoinAmount(String value) {
    if (value == '.' && _coinAmountDigits.contains('.')) return;
    if (_coinAmountDigits == '0') {
      if (value == '0') return;
      if (value == '.') {
        _coinAmountDigits = _coinAmountDigits + value;
        return;
      }
      _coinAmountDigits = value;
    } else {
      _coinAmountDigits = _coinAmountDigits + value;
    }
  }

  /// Adjusts the font size of an exchange item based on the length of
  /// the entered coin amount, ensuring responsive scaling and avoiding overflow.
  void adjustFontSizeByListLength() {
    const maxFontSize = 32.0;
    const reductionStartLength = 7;
    const reduceFontSizeBy = 2.0;
    if (_coinAmountDigits.length <= 7) {
      _exchangeRateItemFontSize = maxFontSize;
    } else {
      final reductionAmount =
          (_coinAmountDigits.length - reductionStartLength) * reduceFontSizeBy;
      _exchangeRateItemFontSize = maxFontSize - reductionAmount;
    }
  }

  /// Overrides the current coin amount with [digits], keeping clamp logic in sync.
  void setCoinAmountDigits(String digits) {
    if (digits.isEmpty) {
      _coinAmountDigits = '0';
    } else {
      _coinAmountDigits = digits;
    }
    _maximumDigitsReached = _coinAmountDigits.length >= 15;
    adjustFontSizeByListLength();
  }

  ///Sets the currency index selected by the user for coin rate conversion.
  void selectACurrency(int index) {
    _selectedCurrency = index;
  }

  ///Sets the coin index selected by the user for conversion in the chosen currency.
  void selectACoin(int index) {
    _selectedCoin = index;
  }

  ///Sets the searchingForACoin and Screen interaction disability status to
  ///either `true` or `false` based on user's action.
  void setSearchingForACoin(bool value) {
    _isSelectCoinScreenInteractionDisabled = value;
    _searchingForACoin = value;
  }

  ///Sets the select coin Screen interaction disability status to
  ///either `true` or `false` based on user's action.
  void setSelectCoinScreenInteractionDisabilityStatus(bool value) {
    _isSelectCoinScreenInteractionDisabled = value;
  }

  ///Sets the searchingForACurrency and Screen interaction disability status to
  /// either `true` or `false` based on user's action.
  void setSearchingForACurrency(bool value) {
    _isSelectCurrencyScreenInteractionDisabled = value;
    _searchingForACurrency = value;
  }

  ///Sets the select currency Screen interaction disability status to
  ///either `true` or `false` based on user's action.
  void setSelectCurrencyScreenInteractionDisabilityStatus(bool value) {
    _isSelectCurrencyScreenInteractionDisabled = value;
  }

  /// Converts the entered coin amount into the selected currency
  /// by multiplying the currency rate with the entered coin amount.
  void convertCoinToCurrency(double currencyRate) {}
}
