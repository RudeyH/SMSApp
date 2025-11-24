import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../models/api_response_model.dart';
import '../models/uom_model.dart';
import '../utils/action_result.dart';
import 'auth_provider.dart';

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
    List<UOM> uoms =
    data.map((e) => UOM.fromJson(e)).toList();
    _currentPage++;
    if (!reset) {
      final current = state.value ?? [];
      final merged = [...current, ...uoms];
      _applySort(merged);
      return merged;
    }
    _applySort(uoms);
    return uoms;
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
AsyncNotifierProvider<UomActionNotifier, ActionResult?>(UomActionNotifier.new);

class UomActionNotifier extends AsyncNotifier<ActionResult?> {
  @override
  ActionResult? build() => null;

  Future<ActionResult> _handleRequest({
    required Future<http.Response> Function(Map<String, String> headers)
    requestFn,
    required ActionType actionType,
  }) async {
    state = const AsyncLoading();

    try {
      final response = await ref
          .read(authProvider.notifier)
          .authenticatedRequest(ref, requestFn);

      final api = ApiResponse.fromJson(jsonDecode(response.body));

      if (!api.success) {
        // choose correct failure message
        final failMessage = switch (actionType) {
          ActionType.created => ActionMessage.createFailed,
          ActionType.updated => ActionMessage.updateFailed,
          ActionType.deleted => ActionMessage.deleteFailed,
        };
        throw Exception(api.message ?? failMessage);
      }

      // Refresh product list
      ref.invalidate(uomProvider);

      // choose correct success message
      final successMessage = switch (actionType) {
        ActionType.created => ActionMessage.created,
        ActionType.updated => ActionMessage.updated,
        ActionType.deleted => ActionMessage.deleted,
      };

      final result = ActionResult(actionType, successMessage);
      state = AsyncData(result);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  // CREATE
  Future<ActionResult> createData(UOM data) {
    return _handleRequest(
      actionType: ActionType.created,
      requestFn: (headers) {
        return http.post(
          Uri.parse(baseUrl),
          headers: {...headers, 'Content-Type': 'application/json'},
          body: jsonEncode(data.toJson()),
        );
      },
    );
  }

  // UPDATE
  Future<ActionResult> updateData(UOM data) {
    if (data.id == null) {
      throw Exception("Cannot update data without ID");
    }

    return _handleRequest(
      actionType: ActionType.updated,
      requestFn: (headers) {
        return http.put(
          Uri.parse(baseUrl),
          headers: {...headers, 'Content-Type': 'application/json'},
          body: jsonEncode(data.toJson()),
        );
      },
    );
  }

  // DELETE
  Future<ActionResult> deleteData(int id) {
    return _handleRequest(
      actionType: ActionType.deleted,
      requestFn: (headers) {
        return http.delete(
          Uri.parse('$baseUrl/$id'),
          headers: headers,
        );
      },
    );
  }
}
