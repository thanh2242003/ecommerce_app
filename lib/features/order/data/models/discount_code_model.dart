class DiscountCodeModel {
  const DiscountCodeModel({
    required this.code,
    required this.description,
    required this.type,
    required this.value,
    required this.isActive,
    this.id,
    this.scope,
    this.shopId,
    this.appliesTo,
    this.minOrderValue,
    this.expiryDate,
    this.startDate,
  });

  final String? id;
  final String code;
  final String description;
  final String type;
  final num value;
  final bool isActive;
  final String? scope;
  final String? shopId;
  final String? appliesTo;
  final num? minOrderValue;
  final DateTime? expiryDate;
  final DateTime? startDate;

  factory DiscountCodeModel.fromJson(Map<String, dynamic> json) {
    return DiscountCodeModel(
      id: _readString(json, const ['id', '_id']),
      code: _readString(json, const ['code', 'codeId']) ?? '',
      description: _readString(json, const ['description', 'name']) ?? '',
      type: _readString(json, const ['type']) ?? '',
      value: _readNum(json, const ['value']) ?? 0,
      isActive: _readBool(json, const ['isActive', 'is_active']) ?? false,
      scope: _readString(json, const ['scope']),
      shopId: _readString(json, const ['shopId', 'shop_id']),
      appliesTo: _readString(json, const ['appliesTo', 'applies_to']),
      minOrderValue: _readNum(json, const ['minOrderValue', 'min_order_value']),
      expiryDate: _readDate(json, const ['expiryDate', 'endDate', 'end_date']),
      startDate: _readDate(json, const ['startDate', 'start_date']),
    );
  }

  static String? _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return null;
  }

  static num? _readNum(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is num) {
        return value;
      }
      if (value != null) {
        final parsed = num.tryParse(value.toString());
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return null;
  }

  static bool? _readBool(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is bool) {
        return value;
      }
      if (value != null) {
        final normalized = value.toString().trim().toLowerCase();
        if (normalized == 'true' || normalized == '1') {
          return true;
        }
        if (normalized == 'false' || normalized == '0') {
          return false;
        }
      }
    }
    return null;
  }

  static DateTime? _readDate(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) {
        continue;
      }
      final parsed = DateTime.tryParse(value.toString());
      if (parsed != null) {
        return parsed;
      }
    }
    return null;
  }
}
