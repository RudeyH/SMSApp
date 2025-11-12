import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../models/supplier_model.dart';

final String baseUrl = '${Config().baseUrl}/supplier';

final supplierProvider =
AsyncNotifierProvider<SupplierNotifier, List<Supplier>>(SupplierNotifier.new);

class SupplierNotifier extends AsyncNotifier<List<Supplier>> {
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMore = true;
  String _searchQuery = '';
  String _sortField = 'name';
  bool _sortAsc = true;
  bool get hasMore => _hasMore;
  String get sortLabel => '$_sortField ${_sortAsc ? '↑' : '↓'}';

  @override
  Future<List<Supplier>> build() async {
    await _loadSortPreferences();
    return _fetchPage(reset: true);
  }

  Future<void> _loadSortPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _sortField = prefs.getString('supplierSortField') ?? 'name';
    _sortAsc = prefs.getBool('supplierSortAsc') ?? true;
  }

  Future<void> _saveSortPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('supplierSortField', _sortField);
    await prefs.setBool('supplierSortAsc', _sortAsc);
  }

  Future<List<Supplier>> _fetchPage({bool reset = false}) async {
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

      List<Supplier> suppliers =
      data.map((e) => Supplier.fromJson(e)).toList();

      _applySort(suppliers);

      if (!reset) {
        final current = state.value ?? [];
        return [...current, ...suppliers];
      }
      return suppliers;
    } else {
      throw Exception('Failed to load data');
    }
  }

  void _applySort(List<Supplier> list) {
    list.sort((a, b) {
      int compare;
      switch (_sortField) {
        case 'code':
          compare = a.code.compareTo(b.code);
          break;
        case 'contactNo':
          compare = a.contactNo.compareTo(b.contactNo);
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
final supplierActionProvider =
AsyncNotifierProvider<SupplierActionNotifier, void>(SupplierActionNotifier.new);

class SupplierActionNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> createData(Supplier data) async {
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
    });
  }

  Future<void> updateData(Supplier data) async {
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
    });
  }

  Future<void> deleteData(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete data');
      }
    });
  }
}
