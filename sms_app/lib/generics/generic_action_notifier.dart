// import 'dart:async';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'generic_list_config.dart';
//
// class GenericActionNotifier<T> extends AsyncNotifier<void> {
//   final GenericListConfig<T> config;
//
//   GenericActionNotifier({required this.config});
//
//   @override
//   FutureOr<void> build() {}
//
//   Future<String?> deleteData(int id) async {
//     state = const AsyncLoading();
//
//     final res = await http.delete(Uri.parse('${config.baseUrl}/$id'));
//
//     if (res.statusCode == 200 || res.statusCode == 204) {
//       state = const AsyncData(null);
//       return null;
//     }
//
//     if (res.statusCode == 409) {
//       final msg = jsonDecode(res.body)["message"];
//       state = AsyncError(msg, StackTrace.current);
//       return msg;
//     }
//
//     throw Exception("Delete failed");
//   }
// }
