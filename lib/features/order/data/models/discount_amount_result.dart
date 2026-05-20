class DiscountAmountResult {
  const DiscountAmountResult({
    required this.totalOrder,
    required this.discount,
    required this.totalPrice,
  });

  final int totalOrder;
  final int discount;
  final int totalPrice;

  factory DiscountAmountResult.fromJson(Map<String, dynamic> json) {
    return DiscountAmountResult(
      totalOrder: _readInt(json, const [
        'totalOrder',
        'totalPriceBeforeDiscount',
        'subTotal',
        'subtotal',
      ]),
      discount: _readInt(json, const ['discount', 'discountAmount']),
      totalPrice: _readInt(json, const [
        'totalPrice',
        'finalPrice',
        'amountAfterDiscount',
      ]),
    );
  }

  static int _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is num) {
        return value.toInt();
      }
      if (value != null) {
        final parsed = int.tryParse(value.toString());
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return 0;
  }
}
