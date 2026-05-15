import 'package:shared_preferences/shared_preferences.dart';

/// Centralised wrapper around [SharedPreferences] for Factor.
///
/// Stores user defaults (last paired token + currency), recents, favorites
/// and feature toggles so the app picks up where the user left off.
class PreferencesService {
  PreferencesService({SharedPreferences? preferences})
    : _preferencesFuture = preferences != null
          ? Future<SharedPreferences>.value(preferences)
          : SharedPreferences.getInstance();

  final Future<SharedPreferences> _preferencesFuture;

  // Keys ---------------------------------------------------------------------
  static const _kLastTokenId = 'last_token_id';
  static const _kLastCurrencyCode = 'last_currency_code';
  static const _kTopField = 'top_field';
  static const _kRecentTokens = 'recent_token_ids';
  static const _kRecentCurrencies = 'recent_currency_codes';
  static const _kFavoriteTokens = 'favorite_token_ids';
  static const _kFavoriteCurrencies = 'favorite_currency_codes';
  static const _kRestoreLastPair = 'restore_last_pair_enabled';
  static const _kPrioritizeRecents = 'prioritize_recents_enabled';
  static const _kHaptics = 'haptics_enabled';
  static const _kAudio = 'audio_click_enabled';

  static const int recentsLimit = 5;

  // Generic ------------------------------------------------------------------
  Future<SharedPreferences> get _prefs => _preferencesFuture;

  // Last pair ----------------------------------------------------------------
  Future<String?> getLastTokenId() async =>
      (await _prefs).getString(_kLastTokenId);
  Future<void> setLastTokenId(String? id) async {
    final prefs = await _prefs;
    if (id == null || id.isEmpty) {
      await prefs.remove(_kLastTokenId);
    } else {
      await prefs.setString(_kLastTokenId, id);
    }
  }

  Future<String?> getLastCurrencyCode() async =>
      (await _prefs).getString(_kLastCurrencyCode);
  Future<void> setLastCurrencyCode(String? code) async {
    final prefs = await _prefs;
    if (code == null || code.isEmpty) {
      await prefs.remove(_kLastCurrencyCode);
    } else {
      await prefs.setString(_kLastCurrencyCode, code);
    }
  }

  /// 'token' or 'currency'.
  Future<String?> getTopField() async => (await _prefs).getString(_kTopField);
  Future<void> setTopField(String value) async =>
      (await _prefs).setString(_kTopField, value);

  // Recents ------------------------------------------------------------------
  Future<List<String>> getRecentTokenIds() async =>
      (await _prefs).getStringList(_kRecentTokens) ?? const <String>[];
  Future<List<String>> getRecentCurrencyCodes() async =>
      (await _prefs).getStringList(_kRecentCurrencies) ?? const <String>[];

  Future<List<String>> pushRecentTokenId(String id) async {
    final prefs = await _prefs;
    final next = _bumpRecent(
      prefs.getStringList(_kRecentTokens) ?? const <String>[],
      id,
    );
    await prefs.setStringList(_kRecentTokens, next);
    return next;
  }

  Future<List<String>> pushRecentCurrencyCode(String code) async {
    final prefs = await _prefs;
    final next = _bumpRecent(
      prefs.getStringList(_kRecentCurrencies) ?? const <String>[],
      code,
    );
    await prefs.setStringList(_kRecentCurrencies, next);
    return next;
  }

  List<String> _bumpRecent(List<String> existing, String value) {
    final cleaned = existing.where((entry) => entry != value).toList()
      ..insert(0, value);
    if (cleaned.length > recentsLimit) {
      return cleaned.sublist(0, recentsLimit);
    }
    return cleaned;
  }

  Future<void> clearRecents() async {
    final prefs = await _prefs;
    await prefs.remove(_kRecentTokens);
    await prefs.remove(_kRecentCurrencies);
  }

  // Favorites ----------------------------------------------------------------
  Future<Set<String>> getFavoriteTokenIds() async =>
      ((await _prefs).getStringList(_kFavoriteTokens) ?? const <String>[])
          .toSet();
  Future<Set<String>> getFavoriteCurrencyCodes() async =>
      ((await _prefs).getStringList(_kFavoriteCurrencies) ?? const <String>[])
          .toSet();

  Future<Set<String>> toggleFavoriteToken(String id) async {
    final prefs = await _prefs;
    final current =
        (prefs.getStringList(_kFavoriteTokens) ?? const <String>[]).toSet();
    if (!current.add(id)) current.remove(id);
    await prefs.setStringList(_kFavoriteTokens, current.toList());
    return current;
  }

  Future<Set<String>> toggleFavoriteCurrency(String code) async {
    final prefs = await _prefs;
    final current =
        (prefs.getStringList(_kFavoriteCurrencies) ?? const <String>[]).toSet();
    if (!current.add(code)) current.remove(code);
    await prefs.setStringList(_kFavoriteCurrencies, current.toList());
    return current;
  }

  Future<void> clearFavorites() async {
    final prefs = await _prefs;
    await prefs.remove(_kFavoriteTokens);
    await prefs.remove(_kFavoriteCurrencies);
  }

  // Feature toggles ----------------------------------------------------------
  Future<bool> getRestoreLastPair() async =>
      (await _prefs).getBool(_kRestoreLastPair) ?? true;
  Future<void> setRestoreLastPair(bool value) async =>
      (await _prefs).setBool(_kRestoreLastPair, value);

  Future<bool> getPrioritizeRecents() async =>
      (await _prefs).getBool(_kPrioritizeRecents) ?? true;
  Future<void> setPrioritizeRecents(bool value) async =>
      (await _prefs).setBool(_kPrioritizeRecents, value);

  Future<bool> getHapticsEnabled() async =>
      (await _prefs).getBool(_kHaptics) ?? true;
  Future<void> setHapticsEnabled(bool value) async =>
      (await _prefs).setBool(_kHaptics, value);

  Future<bool> getAudioClickEnabled() async =>
      (await _prefs).getBool(_kAudio) ?? true;
  Future<void> setAudioClickEnabled(bool value) async =>
      (await _prefs).setBool(_kAudio, value);
}
