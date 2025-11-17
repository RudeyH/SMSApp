import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../models/uom_model.dart';

final String baseUrl = '${Config().baseUrl}/uom';

final uomProvider =
AsyncNotifierProvider<UomNotifier, List<UOM>>(UomNotifier.new);

class UomNotifier extends AsyncNotifier<List<UOM>> {
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMore = true;
  String _searchQuery = '';
  String _sortField = 'name';
  bool _sortAsc = true;
  bool get hasMore => _hasMore;
  String get sortLabel => '$_sortField ${_sortAsc ? '↑' : '↓'}';

  @override
  Future<List<UOM>> build() async {
    await _loadSortPreferences();
    return _fetchPage(reset: true);
  }

  Future<void> _loadSortPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _sortField = prefs.getString('uomSortField') ?? 'name';
    _sortAsc = prefs.getBool('uomSortAsc') ?? true;
  }

  Future<void> _saveSortPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uomSortField', _sortField);
    await prefs.setBool('uomSortAsc', _sortAsc);
  }

  Future<List<UOM>> _fetchPage({bool reset = false}) async {
    if (reset) {
      _currentPage = 1;
      _hasMore = true;
    }

    final uri = Uri.parse(
      '$baseUrl?page=$_currentPage&pageSize=$_pageSize&search=$_searchQuery',
    );

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (data.length < _pageSize) _hasMore = false;

      List<UOM> uoms =
      data.map((e) => UOM.fromJson(e)).toList();

      _applySort(uoms);

      if (!reset) {
        final current = state.value ?? [];
        return [...current, ...uoms];
      }
      return uoms;
    } else {
      throw Exception('Failed to load data');
    }
  }

  void _applySort(List<UOM> list) {
    list.sort((a, b) {
      int compare;
      switch (_sortField) {
        case 'code':
          compare = a.code.compareTo(b.code);
          break;
        default:
          compare = a.name.compareTo(b.name);
      }
      return _sortAsc ? compare : -compare;
    });
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => await _fetchPage(reset: true));
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;
    _currentPage++;
    state = AsyncValue.data(await _fetchPage());
  }

  void search(String query) {
    _searchQuery = query;
    refresh();
  }

  void toggleSort(String field) async {
    if (_sortField == field) {
      _sortAsc = !_sortAsc;
    } else {
      _sortField = field;
      _sortAsc = true;
    }
    await _saveSortPreferences();
    refresh();
  }
}

/// ✅ This provider manages Create, Update, Delete (POST/PUT/DELETE)
final uomActionProvider =
AsyncNotifierProvider<UomActionNotifier, void>(UomActionNotifier.new);

class UomActionNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> createData(UOM data) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data.toJson()),
      );
      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to create data');
      }
      else {
        ref.invalidate(uomProvider);
      }
    });
  }

  Future<void> updateData(UOM data) async {
    if (data.id == null) {
      throw Exception('Cannot update data without ID');
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await http.put(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data.toJson()),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to update data');
      }
      else {
        ref.invalidate(uomProvider);
      }
    });
  }

  // Future<void> deleteData(int id) async {
  //   state = const AsyncLoading();
  //   state = await AsyncValue.guard(() async {
  //     final response = await http.delete(Uri.parse('$baseUrl/$id'));
  //     if (response.statusCode != 200 && response.statusCode != 204) {
  //       throw Exception('Failed to delete data');
  //     }
  //   });
  // }

  Future<String?> deleteData(int id) async {
    state = const AsyncLoading();

    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));

      if (response.statusCode == 200 || response.statusCode == 204) {
        state = const AsyncData(null);
        return null; // success
      }

      if (response.statusCode == 409) {
        final msg = jsonDecode(response.body)['message'] ?? 'Conflict error';
        state = AsyncError(msg, StackTrace.current);
        return msg; // return backend message
      }

      throw Exception('Failed to delete data');
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
