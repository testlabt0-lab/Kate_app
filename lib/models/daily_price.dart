class DailyPrice {
  final String? id;
  final String agentId;
  final String qatTypeId;
  final double price;
  final DateTime priceDate;

  DailyPrice({
    this.id,
    required this.agentId,
    required this.qatTypeId,
    required this.price,
    required this.priceDate,
  });

  factory DailyPrice.fromJson(Map<String, dynamic> json) {
    return DailyPrice(
      id: json['id'],
      agentId: json['agent_id'],
      qatTypeId: json['qat_type_id'],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      priceDate: DateTime.parse(json['price_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'agent_id': agentId,
      'qat_type_id': qatTypeId,
      'price': price,
      'price_date': priceDate.toIso8601String().split('T')[0],
    };
  }
}
