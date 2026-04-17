class Agent {
  final String? id;
  final String name;
  final String? phone;
  final double balance;

  Agent({this.id, required this.name, this.phone, this.balance = 0.0});

  factory Agent.fromJson(Map<String, dynamic> json) => Agent(
      id: json['id'], name: json['name'], phone: json['phone'],
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0);
  Map<String, dynamic> toJson() => {if (id != null) 'id': id, 'name': name, 'phone': phone, 'balance': balance};
}
