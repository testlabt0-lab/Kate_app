class Payment {
  final String? id;
  final String? farmerId;
  final String? agentId;
  final double amount;
  final DateTime paymentDate;
  final String paymentType; // 'farmer_payment', 'agent_transfer'
  final String? notes;

  Payment({
    this.id,
    this.farmerId,
    this.agentId,
    required this.amount,
    required this.paymentDate,
    required this.paymentType,
    this.notes,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      farmerId: json['farmer_id'],
      agentId: json['agent_id'],
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentDate: DateTime.parse(json['payment_date'] ?? DateTime.now().toIso8601String()),
      paymentType: json['payment_type'] ?? 'farmer_payment',
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (farmerId != null) 'farmer_id': farmerId,
      if (agentId != null) 'agent_id': agentId,
      'amount': amount,
      'payment_date': paymentDate.toIso8601String().split('T')[0],
      'payment_type': paymentType,
      if (notes != null) 'notes': notes,
    };
  }
}
