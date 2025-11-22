import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'generic_list_config.dart';
import 'generic_list_notifier.dart';
import 'generic_action_notifier.dart';

final genericListProvider = StateNotifierProvider.family
    .autoDispose<GenericListNotifier, AsyncValue<List<dynamic>>, GenericListConfig>(
      (ref, config) => GenericListNotifier(config),
);

final genericActionProvider = StateNotifierProvider.family
    .autoDispose<GenericActionNotifier, AsyncValue<void>, GenericListConfig>(
      (ref, config) => GenericActionNotifier(config),
);
