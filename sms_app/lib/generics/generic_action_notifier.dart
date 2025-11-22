import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'generic_list_config.dart';

class GenericActionNotifier extends StateNotifier<AsyncValue<void>> {
  GenericActionNotifier(this.config) : super(const AsyncValue.data(null));

  final GenericListConfig config;

  Future<void> execute() async {
    state = const AsyncValue.loading();
    try {
      await config.actionFunction();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
