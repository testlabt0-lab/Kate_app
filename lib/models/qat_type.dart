class QatType {
  final String? id;
  final String name;
  final double commissionAmount;
  final String commissionPer; // 'piece' (حبة), 'pair' (زوج)

  QatType({
    this.id,
    required this.name,
    this.commissionAmount = 0.0,
    this.commissionPer = 'piece',
  });

  factory QatType.fromJson(Map<String, dynamic> json) {
    return QatType(
      id: json['id'],
      name: json['name'],
      commissionAmount: (json['commission_amount'] as num?)?.toDouble() ?? 0.0,
      commissionPer: json['commission_per'] ?? 'piece',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'commission_amount': commissionAmount,
      'commission_per': commissionPer,
    };
  }
}
