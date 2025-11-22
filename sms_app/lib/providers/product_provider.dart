import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../models/api_response_model.dart';
import '../models/product_model.dart';
import 'auth_provider.dart';

final String baseUrl = '${Config().baseUrl}/product';

final productProvider =
AsyncNotifierProvider<ProductNotifier, List<Product>>(ProductNotifier.new);

class ProductNotifier extends AsyncNotifier<List<Product>> {
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMore = true;
  String _searchQuery = '';
  String _sortField = 'name';
  bool _sortAsc = true;
  bool get hasMore => _hasMore;
  String get sortLabel => '$_sortField ${_sortAsc ? '↑' : '↓'}';

  @override
  Future<List<Product>> build() async {
    await _loadSortPreferences();
    return _fetchPage(reset: true);
  }

  Future<void> _loadSortPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _sortField = prefs.getString('productSortField') ?? 'name';
    _sortAsc = prefs.getBool('productSortAsc') ?? true;
  }

  Future<void> _saveSortPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('productSortField', _sortField);
    await prefs.setBool('productSortAsc', _sortAsc);
  }

  // Future<List<Product>> _fetchPage({bool reset = false}) async {
  //   if (reset) {
  //     _currentPage = 1;
  //     _hasMore = true;
  //   }
  //
  //   final uri = Uri.parse(
  //     '$baseUrl?page=$_currentPage&pageSize=$_pageSize&search=$_searchQuery',
  //   );
  //
  //   final response = await ref
  //       .read(authProvider.notifier)
  //       .authenticatedRequest(ref, (headers) {
  //     return http.get(uri, headers: headers);
  //   });
  //
  //   final ApiResponse api = ApiResponse.fromJson(jsonDecode(response.body));
  //   if (!api.success) {
  //     throw Exception(api.message ?? 'Failed to load data');
  //   }
  //   final List<dynamic> data = api.data as List<dynamic>;
  //
  //   if (data.length < _pageSize) _hasMore = false;
  //   List<Product> products =
  //   data.map((e) => Product.fromJson(e)).toList();
  //   _applySort(products);
  //   if (!reset) {
  //     final current = state.value ?? [];
  //     return [...current, ...products];
  //   }
  //   return products;
  // }
  Future<List<Product>> _fetchPage({bool reset = false}) async {
    if (reset) {
      _currentPage = 1;
      _hasMore = true;
    }

    final uri = Uri.parse(
        '$baseUrl?page=$_currentPage&pageSize=$_pageSize&search=$_searchQuery');

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
    List<Product> products =
    data.map((e) => Product.fromJson(e)).toList();
    _currentPage++;
    if (!reset) {
      final current = state.value ?? [];
      final merged = [...current, ...products];
      _applySort(merged);
      return merged;
    }
    _applySort(products);
    return products;
  }


  void _applySort(List<Product> list) {
    list.sort((a, b) {
      int compare;
      switch (_sortField) {
        case 'code':
          compare = a.code.compareTo(b.code);
          break;
        case 'price':
          compare = a.price.compareTo(b.price);
          break;
        case 'quantity':
          compare = a.quantity.compareTo(b.quantity);
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
final productActionProvider =
AsyncNotifierProvider<ProductActionNotifier, void>(ProductActionNotifier.new);

class ProductActionNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> createData(Product data) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await ref
          .read(authProvider.notifier)
          .authenticatedRequest(ref, (headers) {
        return http.post(
          Uri.parse(baseUrl),
          headers: {...headers,'Content-Type': 'application/json'},
          body: jsonEncode(data.toCreateJson()),
        );
      });
      final ApiResponse api = ApiResponse.fromJson(jsonDecode(response.body));
      if (!api.success) {
        throw Exception(api.message ?? 'Failed to create data');
      }
      ref.invalidate(productProvider);
    });
  }

  Future<void> updateData(Product data) async {
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
          body: jsonEncode(data.toUpdateJson()),
        );
      });
      final ApiResponse api = ApiResponse.fromJson(jsonDecode(response.body));
      if (!api.success) {
        throw Exception(api.message ?? 'Failed to update data');
      }
      ref.invalidate(productProvider);
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
