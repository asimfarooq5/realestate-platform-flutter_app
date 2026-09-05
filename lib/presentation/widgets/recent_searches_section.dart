import 'package:flutter/material.dart';
import 'package:malkiyat_app/core/di/injection.dart';
import 'package:malkiyat_app/core/services/recent_searches_store.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';
import 'package:malkiyat_app/presentation/screens/search_screen.dart';

/// Local search-term history shown on Home — distinct from the city-based
/// "Popular searches" pills inside HomesForYouSection.
class RecentSearchesSection extends StatefulWidget {
  const RecentSearchesSection({super.key});

  @override
  State<RecentSearchesSection> createState() => _RecentSearchesSectionState();
}

class _RecentSearchesSectionState extends State<RecentSearchesSection> {
  final RecentSearchesStore _store = sl<RecentSearchesStore>();
  List<String> _terms = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final terms = await _store.getAll();
    if (mounted) setState(() => _terms = terms);
  }

  @override
  Widget build(BuildContext context) {
    if (_terms.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Recent Searches',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, letterSpacing: -0.2, color: AppTheme.textPrimary),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _terms.length,
            itemBuilder: (context, index) {
              final term = _terms[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SearchScreen(initialQuery: term)),
                    );
                    _load();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.history, size: 14, color: AppTheme.accentColor),
                        const SizedBox(width: 6),
                        Text(term, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
