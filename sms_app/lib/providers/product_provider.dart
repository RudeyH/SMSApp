import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../models/product_model.dart';

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

  Future<List<Product>> _fetchPage({bool reset = false}) async {
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

      List<Product> products =
      data.map((e) => Product.fromJson(e)).toList();

      _applySort(products);

      if (!reset) {
        final current = state.value ?? [];
        return [...current, ...products];
      }
      return products;
    } else {
      throw Exception('Failed to load data');
    }
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
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data.toCreateJson()),
      );
      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to create data');
      }
      else {
        ref.invalidate(productProvider);
      }
    });
  }

  Future<void> updateData(Product data) async {
    if (data.id == null) {
      throw Exception('Cannot update data without ID');
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await http.put(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data.toUpdateJson()),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to update data');
      }
      else {
        ref.invalidate(productProvider);
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
