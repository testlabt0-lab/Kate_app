class FarmerOrder {
  final String? id;
  final String farmerId;
  final String description;
  final double? estimatedPrice;
  final double? actualPrice;
  final String status;
  FarmerOrder({this.id, required this.farmerId, required this.description, this.estimatedPrice, this.actualPrice, this.status = 'pending'});
  factory FarmerOrder.fromJson(Map<String, dynamic> json) => FarmerOrder(
      id: json['id'], farmerId: json['farmer_id'], description: json['description'], estimatedPrice: (json['estimated_price'] as num?)?.toDouble(), actualPrice: (json['actual_price'] as num?)?.toDouble(), status: json['status'] ?? 'pending');
  Map<String, dynamic> toJson() => {if (id != null) 'id': id, 'farmer_id': farmerId, 'description': description, if (estimatedPrice != null) 'estimated_price': estimatedPrice, if (actualPrice != null) 'actual_price': actualPrice, 'status': status};
}
