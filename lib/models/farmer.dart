class Farmer {
  final String? id;
  final String name;
  final String? phone;
  final double totalDebt;

  Farmer({this.id, required this.name, this.phone, this.totalDebt = 0.0});

  factory Farmer.fromJson(Map<String, dynamic> json) => Farmer(
      id: json['id'], name: json['name'], phone: json['phone'],
      totalDebt: (json['total_debt'] as num?)?.toDouble() ?? 0.0);
  Map<String, dynamic> toJson() => {if (id != null) 'id': id, 'name': name, 'phone': phone, 'total_debt': totalDebt};
}
