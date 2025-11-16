import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../models/sales_order_item_model.dart';
import '../models/sales_order_model.dart';
import '../utils/json_utils.dart';

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

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (data.length < _pageSize) _hasMore = false;

      List<SalesOrder> salesOrders =
      data.map((e) => SalesOrder.fromJson(e)).toList();

      _applySort(salesOrders);

      if (!reset) {
        final current = state.value ?? [];
        return [...current, ...salesOrders];
      }
      return salesOrders;
    } else {
      throw Exception('Failed to load data');
    }
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
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data.toCreateJson()),
      );
      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to create data');
      }
      else {
        ref.invalidate(salesOrderProvider);
      }
    });
  }

  Future<void> updateData(SalesOrder data) async {
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
        ref.invalidate(salesOrderProvider);
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

  Future<SalesOrder> createOrderWithoutItems(SalesOrder data) async {
    final resp = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data.toCreateJson()),
    );

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      final Map<String, dynamic> body = jsonDecode(resp.body);
      return SalesOrder.fromJson(JsonUtils.ensureMap(body));
    } else {
      throw Exception('Failed to create order: ${resp.statusCode} ${resp.body}');
    }
  }

  Future<SalesOrderItem> addItemToOrder(int orderId, SalesOrderItem item) async {
    final dto = {
      "productId": item.product.id,
      "quantity": item.quantity,
      "unitPrice": item.unitPrice,
    };
    final resp = await http.post(
      Uri.parse('$baseUrl/$orderId/items'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dto),
    );

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      final body = jsonDecode(resp.body);
      return SalesOrderItem.fromJson(JsonUtils.ensureMap(body));
    } else {
      throw Exception('Failed to add item: ${resp.statusCode} ${resp.body}');
    }
  }

  Future<void> deleteOrderItem(int itemId) async {
    final resp = await http.delete(Uri.parse('$baseUrl/items/$itemId'));
    if (resp.statusCode != 200 && resp.statusCode != 204) {
      throw Exception('Failed to delete item: ${resp.statusCode} ${resp.body}');
    }
  }

  Future<void> updateOrderCustomer(int orderId, int customerId) async {
    final resp = await http.put(
      Uri.parse('$baseUrl/$orderId/customer'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"customerId": customerId}),
    );
    if (resp.statusCode != 200 && resp.statusCode != 204) {
      throw Exception('Failed to update customer: ${resp.statusCode} ${resp.body}');
    }
  }
}
