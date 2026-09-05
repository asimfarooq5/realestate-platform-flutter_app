import 'package:shared_preferences/shared_preferences.dart';

/// Local search-term history — distinct from the city-based "Popular
/// searches" pills, which come from the backend's city list instead.
class RecentSearchesStore {
  static const _key = 'recent_searches';
  static const _maxEntries = 8;

  Future<List<String>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  Future<void> add(String term) async {
    final trimmed = term.trim();
    if (trimmed.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? [];
    current.removeWhere((e) => e.toLowerCase() == trimmed.toLowerCase());
    current.insert(0, trimmed);
    await prefs.setStringList(
      _key,
      current.take(_maxEntries).toList(),
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
