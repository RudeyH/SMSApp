import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../models/sales_order_model.dart';

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
// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:http/http.dart' as http;
// import 'package:sms_app/models/sales_order_model.dart';
// import '../config.dart';
//
// final String baseUrl =  '${Config().baseUrl}/salesorder';
//
// /// ✅ This provider manages fetching (GET) all SalesOrders
// final salesOrderProvider =
// AsyncNotifierProvider<SalesOrderNotifier, List<SalesOrder>>(SalesOrderNotifier.new);
//
// class SalesOrderNotifier extends AsyncNotifier<List<SalesOrder>> {
//   @override
//   FutureOr<List<SalesOrder>> build() async {
//     return listData();
//   }
//
//   Future<List<SalesOrder>> listData() async {
//     final response = await http.get(Uri.parse(baseUrl));
//     if (response.statusCode == 200) {
//       final List<dynamic> data = jsonDecode(response.body);
//       return data.map((item) => SalesOrder.fromJson(item)).toList();
//     } else {
//       throw Exception('Failed to load data');
//     }
//   }
// }

/// ✅ This provider manages Create, Update, Delete (POST/PUT/DELETE)
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
