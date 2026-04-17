class Transporter {
  final String? id;
  final String name;
  final String? phone;
  final double commissionRate;

  Transporter({this.id, required this.name, this.phone, this.commissionRate = 0.0});

  factory Transporter.fromJson(Map<String, dynamic> json) => Transporter(
      id: json['id'], name: json['name'], phone: json['phone'],
      commissionRate: (json['commission_rate'] as num?)?.toDouble() ?? 0.0);
  Map<String, dynamic> toJson() => {if (id != null) 'id': id, 'name': name, 'phone': phone, 'commission_rate': commissionRate};
}
