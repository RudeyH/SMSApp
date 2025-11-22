import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../models/api_response_model.dart';
import '../models/supplier_model.dart';
import 'auth_provider.dart';

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
    final response = await ref
        .read(authProvider.notifier)
        .authenticatedRequest(ref, (headers) {
      return http.get(uri, headers: headers);
    });
    final ApiResponse api = ApiResponse.fromJson(jsonDecode(response.body));
    if (!api.success) {
      throw Exception(api.message ?? 'Failed to load data');
    }
    if (api.data is! List) {
      throw Exception("API returned non-list data");
    }

    final List<dynamic> data = api.data as List<dynamic>;
    if (data.length < _pageSize) _hasMore = false;
    List<Supplier> suppliers =
    data.map((e) => Supplier.fromJson(e)).toList();
    _currentPage++;
    if (!reset) {
      final current = state.value ?? [];
      final merged = [...current, ...suppliers];
      _applySort(merged);
      return merged;
    }
    _applySort(suppliers);
    return suppliers;
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
      final response = await ref
          .read(authProvider.notifier)
          .authenticatedRequest(ref, (headers) {
        return http.post(
          Uri.parse(baseUrl),
          headers: {...headers,'Content-Type': 'application/json'},
          body: jsonEncode(data.toJson()),
        );
      });
      final ApiResponse api = ApiResponse.fromJson(jsonDecode(response.body));
      if (!api.success) {
        throw Exception(api.message ?? 'Failed to create data');
      }
      ref.invalidate(supplierProvider);
    });
  }

  Future<void> updateData(Supplier data) async {
    if (data.id == null) {
      throw Exception('Cannot update data without ID');
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await ref
          .read(authProvider.notifier)
          .authenticatedRequest(ref, (headers) {
        return http.put(
          Uri.parse(baseUrl),
          headers: {...headers,'Content-Type': 'application/json'},
          body: jsonEncode(data.toJson()),
        );
      });
      final ApiResponse api = ApiResponse.fromJson(jsonDecode(response.body));
      if (!api.success) {
        throw Exception(api.message ?? 'Failed to update data');
      }
      ref.invalidate(supplierProvider);
    });
  }

  Future<String?> deleteData(int id) async {
    state = const AsyncLoading();

    try {
      final response = await ref
          .read(authProvider.notifier)
          .authenticatedRequest(ref, (headers) {
        return http.delete(Uri.parse('$baseUrl/$id'),headers: headers);
      });
      final ApiResponse api = ApiResponse.fromJson(jsonDecode(response.body));
      if (!api.success) {
        return api.message ?? 'Failed to delete data';
      }
      state = const AsyncData(null);
      return null; // success
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
