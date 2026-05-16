class Booking {
  final String id;
  final String planId;
  final String? planTitle;
  final String? planImageUrl;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final int numberOfPeople;
  final DateTime travelDate;
  final String? specialRequests;
  final double totalPrice;
  final String status;
  final String? paymentMethod;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Booking({
    required this.id,
    required this.planId,
    this.planTitle,
    this.planImageUrl,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.numberOfPeople,
    required this.travelDate,
    this.specialRequests,
    required this.totalPrice,
    required this.status,
    this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPending => status == 'PENDING';
  bool get isConfirmed => status == 'CONFIRMED';
  bool get isCancelled => status == 'CANCELLED';

  factory Booking.fromJson(Map<String, dynamic> json) {
    final plan = json['plan'] as Map<String, dynamic>?;
    final images = plan?['images'] as List<dynamic>?;
    final primaryImage = images != null && images.isNotEmpty
        ? (images.firstWhere(
            (img) => (img as Map<String, dynamic>)['isPrimary'] == true,
            orElse: () => images.first,
          ) as Map<String, dynamic>?)
        : null;

    return Booking(
      id: json['id'] as String,
      planId: json['planId'] as String,
      planTitle: plan?['title'] as String?,
      planImageUrl: primaryImage?['url'] as String?,
      customerName: json['customerName'] as String,
      customerEmail: json['customerEmail'] as String,
      customerPhone: json['customerPhone'] as String,
      numberOfPeople: json['numberOfPeople'] as int,
      travelDate: DateTime.parse(json['travelDate'] as String),
      specialRequests: json['specialRequests'] as String?,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: json['status'] as String,
      paymentMethod: json['paymentMethod'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'planId': planId,
        'customerName': customerName,
        'customerEmail': customerEmail,
        'customerPhone': customerPhone,
        'numberOfPeople': numberOfPeople,
        'travelDate': travelDate.toIso8601String(),
        'specialRequests': specialRequests,
        'totalPrice': totalPrice,
        'status': status,
        'paymentMethod': paymentMethod,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  Booking copyWith({
    String? id,
    String? planId,
    String? planTitle,
    String? planImageUrl,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    int? numberOfPeople,
    DateTime? travelDate,
    String? specialRequests,
    double? totalPrice,
    String? status,
    String? paymentMethod,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Booking(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      planTitle: planTitle ?? this.planTitle,
      planImageUrl: planImageUrl ?? this.planImageUrl,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      numberOfPeople: numberOfPeople ?? this.numberOfPeople,
      travelDate: travelDate ?? this.travelDate,
      specialRequests: specialRequests ?? this.specialRequests,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Booking && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
