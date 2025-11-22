class ApiResponse {
  final bool success;
  final String? message;
  final dynamic data;
  final int statusCode;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    required this.statusCode,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'],
      statusCode: json['statusCode'] ?? 0,
    );
  }
}
