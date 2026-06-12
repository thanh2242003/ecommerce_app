class ApiConfig {
  static const String serverUrl = "http://172.20.10.3:3000";
  static const String baseUrl =
      // "http://10.0.2.2:3000/v1/api";
      "$serverUrl/v1/api";
  static const String paymentBaseUrl = "$serverUrl/api/payments";
}
