import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../models/purchase_order_model.dart';

final String baseUrl = '${Config().baseUrl}/purchaseorder';

final purchaseOrderProvider =
AsyncNotifierProvider<PurchaseOrderNotifier, List<PurchaseOrder>>(PurchaseOrderNotifier.new);

class PurchaseOrderNotifier extends AsyncNotifier<List<PurchaseOrder>> {
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMore = true;
  String _searchQuery = '';
  String _sortField = 'name';
  bool _sortAsc = true;
  bool get hasMore => _hasMore;
  String get sortLabel => '$_sortField ${_sortAsc ? '↑' : '↓'}';

  @override
  Future<List<PurchaseOrder>> build() async {
    await _loadSortPreferences();
    return _fetchPage(reset: true);
  }

  Future<void> _loadSortPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _sortField = prefs.getString('purchaseOrderSortField') ?? 'name';
    _sortAsc = prefs.getBool('purchaseOrderSortAsc') ?? true;
  }

  Future<void> _saveSortPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('purchaseOrderSortField', _sortField);
    await prefs.setBool('purchaseOrderSortAsc', _sortAsc);
  }

  Future<List<PurchaseOrder>> _fetchPage({bool reset = false}) async {
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

      List<PurchaseOrder> purchaseOrders =
      data.map((e) => PurchaseOrder.fromJson(e)).toList();

      _applySort(purchaseOrders);

      if (!reset) {
        final current = state.value ?? [];
        return [...current, ...purchaseOrders];
      }
      return purchaseOrders;
    } else {
      throw Exception('Failed to load data');
    }
  }

  void _applySort(List<PurchaseOrder> list) {
    list.sort((a, b) {
      int compare;
      switch (_sortField) {
        case 'supplier code':
          compare = a.supplier.code.compareTo(b.supplier.code);
          break;
        case 'supplier name':
          compare = a.supplier.name.compareTo(b.supplier.name);
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
// import 'package:sms_app/models/purchase_order_model.dart';
// import '../config.dart';
//
// final String baseUrl =  '${Config().baseUrl}/purchaseorder';
//
// /// ✅ This provider manages fetching (GET) all PurchaseOrders
// final purchaseOrderProvider =
// AsyncNotifierProvider<PurchaseOrderNotifier, List<PurchaseOrder>>(PurchaseOrderNotifier.new);
//
// class PurchaseOrderNotifier extends AsyncNotifier<List<PurchaseOrder>> {
//   @override
//   FutureOr<List<PurchaseOrder>> build() async {
//     return listData();
//   }
//
//   Future<List<PurchaseOrder>> listData() async {
//     final response = await http.get(Uri.parse(baseUrl));
//     if (response.statusCode == 200) {
//       final List<dynamic> data = jsonDecode(response.body);
//       return data.map((item) => PurchaseOrder.fromJson(item)).toList();
//     } else {
//       throw Exception('Failed to load data');
//     }
//   }
// }

/// ✅ This provider manages Create, Update, Delete (POST/PUT/DELETE)
final purchaseOrderActionProvider =
AsyncNotifierProvider<PurchaseOrderActionNotifier, void>(PurchaseOrderActionNotifier.new);

class PurchaseOrderActionNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> createData(PurchaseOrder data) async {
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

  Future<void> updateData(PurchaseOrder data) async {
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
