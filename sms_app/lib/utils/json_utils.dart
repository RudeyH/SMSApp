class JsonUtils {
  /// Safely parses int values from any dynamic input
  static int? parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  /// Safely parses double values from any dynamic input
  static double parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value?.toString() ?? '0') ?? 0;
  }

  /// Safely parses string values
  static String parseString(dynamic value) {
    return value?.toString() ?? '';
  }

  /// Ensures map
  static Map<String, dynamic> ensureMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    return <String, dynamic>{};
  }
}
