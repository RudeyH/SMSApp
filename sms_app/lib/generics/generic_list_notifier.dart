import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'generic_list_config.dart';

class GenericListNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  GenericListNotifier(this.config) : super(const AsyncValue.loading()) {
    load();
  }

  final GenericListConfig config;

  Future<void> load() async {
    try {
      final result = await config.fetchFunction();
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
