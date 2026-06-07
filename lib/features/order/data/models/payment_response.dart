class PaymentResponse {
  const PaymentResponse({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.status,
    this.transactionId,
    this.userId,
    this.paymentMethod,
    this.expiredAt,
    this.paidAt,
    this.qrData,
  });

  final String id;
  final String orderId;
  final int amount;
  final String status;
  final String? transactionId;
  final String? userId;
  final String? paymentMethod;
  final DateTime? expiredAt;
  final DateTime? paidAt;
  final PaymentQrData? qrData;

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      id: _readString(json, const ['_id', 'id']),
      orderId: _readString(json, const ['orderId']),
      amount: _readInt(json, const ['amount']),
      status: _readString(json, const ['status']),
      transactionId: _readNullableString(json['transactionId']),
      userId: _readNullableString(json['userId']),
      paymentMethod: _readNullableString(json['paymentMethod']),
      expiredAt: _readDate(json['expiredAt']),
      paidAt: _readDate(json['paidAt']),
      qrData: json['qrData'] is Map<String, dynamic>
          ? PaymentQrData.fromJson(json['qrData'] as Map<String, dynamic>)
          : null,
    );
  }

  static String _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return '';
  }

  static int _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is num) {
        return value.toInt();
      }
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return 0;
  }

  static DateTime? _readDate(dynamic value) {
    if (value == null) {
      return null;
    }
    return DateTime.tryParse(value.toString());
  }

  static String? _readNullableString(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text == 'null') {
      return null;
    }
    return text;
  }
}

class PaymentQrData {
  const PaymentQrData({
    required this.paymentCode,
    required this.amount,
    required this.bankName,
    required this.bankAccount,
    required this.transferContent,
    required this.qrText,
  });

  final String paymentCode;
  final int amount;
  final String bankName;
  final String bankAccount;
  final String transferContent;
  final String qrText;

  factory PaymentQrData.fromJson(Map<String, dynamic> json) {
    return PaymentQrData(
      paymentCode: (json['paymentCode'] ?? '').toString(),
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      bankName: (json['bankName'] ?? '').toString(),
      bankAccount: (json['bankAccount'] ?? '').toString(),
      transferContent: (json['transferContent'] ?? '').toString(),
      qrText: (json['qrText'] ?? '').toString(),
    );
  }
}
