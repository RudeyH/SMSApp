import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../models/api_response_model.dart';
import '../models/sales_order_item_model.dart';
import '../models/sales_order_model.dart';
import '../utils/json_utils.dart';
import 'auth_provider.dart';

final String baseUrl = '${Config().baseUrl}/salesorder';

final salesOrderProvider =
AsyncNotifierProvider<SalesOrderNotifier, List<SalesOrder>>(SalesOrderNotifier.new);

class SalesOrderNotifier extends AsyncNotifier<List<SalesOrder>> {
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMore = true;
  String _searchQuery = '';
  String _sortField = 'name';
  bool _sortAsc = true;
  bool get hasMore => _hasMore;
  String get sortLabel => '$_sortField ${_sortAsc ? '↑' : '↓'}';

  @override
  Future<List<SalesOrder>> build() async {
    await _loadSortPreferences();
    return _fetchPage(reset: true);
  }

  Future<void> _loadSortPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _sortField = prefs.getString('salesOrderSortField') ?? 'name';
    _sortAsc = prefs.getBool('salesOrderSortAsc') ?? true;
  }

  Future<void> _saveSortPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('salesOrderSortField', _sortField);
    await prefs.setBool('salesOrderSortAsc', _sortAsc);
  }

  Future<List<SalesOrder>> _fetchPage({bool reset = false}) async {
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
    List<SalesOrder> salesOrders =
    data.map((e) => SalesOrder.fromJson(e)).toList();
    _currentPage++;
    if (!reset) {
      final current = state.value ?? [];
      final merged = [...current, ...salesOrders];
      _applySort(merged);
      return merged;
    }
    _applySort(salesOrders);
    return salesOrders;
  }

  void _applySort(List<SalesOrder> list) {
    list.sort((a, b) {
      int compare;
      switch (_sortField) {
        case 'customer code':
          compare = a.customer.code.compareTo(b.customer.code);
          break;
        case 'customer name':
          compare = a.customer.name.compareTo(b.customer.name);
          break;
        default:
          compare = a.transNumber.compareTo(b.transNumber);
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

final salesOrderActionProvider =
AsyncNotifierProvider<SalesOrderActionNotifier, void>(SalesOrderActionNotifier.new);

class SalesOrderActionNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> createData(SalesOrder data) async {
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
      ref.invalidate(salesOrderProvider);
    });
  }

  Future<void> updateData(SalesOrder data) async {
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
      ref.invalidate(salesOrderProvider);
    });
  }

  Future<void> deleteData(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await ref
          .read(authProvider.notifier)
          .authenticatedRequest(ref, (headers) {
        return http.delete(Uri.parse('$baseUrl/$id'), headers: headers);
      });

      final api = ApiResponse.fromJson(jsonDecode(response.body));

      if (!api.success) {
        throw Exception(api.message ?? 'Failed to delete data');
      }
    });
  }

  Future<SalesOrder> createOrderWithoutItems(SalesOrder data) async {
    final response = await ref
        .read(authProvider.notifier)
        .authenticatedRequest(ref, (headers) {
      return http.post(
        Uri.parse(baseUrl),
        headers: {...headers, 'Content-Type': 'application/json'},
        body: jsonEncode(data.toCreateJson()),
      );
    });
    final api = ApiResponse.fromJson(jsonDecode(response.body));
    if (!api.success) {
      throw Exception(api.message ?? 'Failed to create order');
    }
    return SalesOrder.fromJson(JsonUtils.ensureMap(api.data));
  }

  Future<SalesOrderItem> addItemToOrder(int orderId, SalesOrderItem item) async {
    final dto = {
      "productId": item.product.id,
      "quantity": item.quantity,
      "unitPrice": item.unitPrice,
    };
    final response = await ref
        .read(authProvider.notifier)
        .authenticatedRequest(ref, (headers) {
      return http.post(
        Uri.parse('$baseUrl/$orderId/items'),
        headers: {...headers, 'Content-Type': 'application/json'},
        body: jsonEncode(dto),
      );
    });
    final api = ApiResponse.fromJson(jsonDecode(response.body));
    if (!api.success) {
      throw Exception(api.message ?? 'Failed to add item');
    }
    return SalesOrderItem.fromJson(JsonUtils.ensureMap(api.data));
  }

  Future<void> deleteOrderItem(int itemId) async {
    final response = await ref
        .read(authProvider.notifier)
        .authenticatedRequest(ref, (headers) {
      return http.delete(Uri.parse('$baseUrl/items/$itemId'), headers: headers);
    });
    final api = ApiResponse.fromJson(jsonDecode(response.body));
    if (!api.success) {
      throw Exception(api.message ?? 'Failed to delete item');
    }
  }

  Future<void> updateOrderCustomer(int orderId, int customerId) async {
    final response = await ref
        .read(authProvider.notifier)
        .authenticatedRequest(ref, (headers) {
      return http.put(
        Uri.parse('$baseUrl/$orderId/customer'),
        headers: {...headers, 'Content-Type': 'application/json'},
        body: jsonEncode({"customerId": customerId}),
      );
    });
    final api = ApiResponse.fromJson(jsonDecode(response.body));
    if (!api.success) {
      throw Exception(api.message ?? 'Failed to update customer');
    }
  }

}
