import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'generic_list_config.dart';
import '../providers/auth_provider.dart';

class GenericListNotifier<T> extends AsyncNotifier<List<T>> {
  final GenericListConfig<T> config;

  GenericListNotifier({required this.config});

  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  String _searchQuery = '';

  late String _sortField;
  late bool _sortAsc;

  String get sortLabel => '$_sortField ${_sortAsc ? "↑" : "↓"}';

  @override
  Future<List<T>> build() async {
    await _loadSortPrefs();
    return _fetchPage(reset: true);
  }

  Future<void> _loadSortPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _sortField = prefs.getString("${config.storageKey}_sortField")
        ?? config.sortFields.keys.first;
    _sortAsc = prefs.getBool("${config.storageKey}_sortAsc") ?? true;
  }

  Future<void> _saveSortPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("${config.storageKey}_sortField", _sortField);
    await prefs.setBool("${config.storageKey}_sortAsc", _sortAsc);
  }

  Future<List<T>> _fetchPage({bool reset = false}) async {
    if (reset) {
      _currentPage = 1;
      _hasMore = true;
    }

    final uri = Uri.parse(
      '${config.baseUrl}?page=$_currentPage&pageSize=$_pageSize&search=$_searchQuery',
    );

    final response = await ref
        .read(authProvider.notifier)
        .authenticatedRequest(ref, (headers) {
      return http.get(uri, headers: headers);
    });

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      if (data.length < _pageSize) _hasMore = false;

      List<T> items = data.map((e) => config.fromJson(e)).toList();

      _applySort(items);

      if (!reset) {
        return [...state.value ?? [], ...items];
      }

      return items;
    } else {
      throw Exception("Failed to load list");
    }
  }

  void _applySort(List<T> list) {
    final selector = config.sortFields[_sortField]!;
    list.sort((a, b) {
      final left = selector(a);
      final right = selector(b);
      final cmp = Comparable.compare(left, right);
      return _sortAsc ? cmp : -cmp;
    });
  }

  void search(String text) {
    _searchQuery = text;
    refresh();
  }

  Future<void> toggleSort(String field) async {
    if (_sortField == field) {
      _sortAsc = !_sortAsc;
    }
    else {
      _sortField = field;
      _sortAsc = true;
    }
    await _saveSortPrefs();
    refresh();
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;
    _currentPage++;
    state = AsyncValue.data(await _fetchPage());
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => await _fetchPage(reset: true));
  }
}
