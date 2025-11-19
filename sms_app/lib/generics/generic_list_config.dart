import 'package:flutter/material.dart';

class GenericListConfig<T> {
  final String baseUrl;
  final String storageKey; // for sorting prefs
  final T Function(Map<String, dynamic>) fromJson;

  /// Key selector used for sorting, e.g. (cust) => cust.name
  final Map<String, Comparable Function(T)> sortFields;

  /// UI builder for list tile
  final Widget Function(BuildContext, T) itemBuilder;

  /// When tapping a tile
  final void Function(BuildContext, T)? onTap;

  /// Add new item page
  final Widget Function()? addScreenBuilder;

  const GenericListConfig({
    required this.baseUrl,
    required this.storageKey,
    required this.fromJson,
    required this.sortFields,
    required this.itemBuilder,
    this.onTap,
    this.addScreenBuilder,
  });
}
