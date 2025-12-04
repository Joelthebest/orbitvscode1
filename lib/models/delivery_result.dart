class DeliveryResult {
  final String platform;
  final String restaurantName;
  final String itemName;
  final double price;
  final int estimatedDeliveryMinutes;
  final String deepLink;
  final String? imageUrl;        // NEW
  final double? rating;          // NEW
  final String? address;         // NEW

  DeliveryResult({
    required this.platform,
    required this.restaurantName,
    required this.itemName,
    required this.price,
    required this.estimatedDeliveryMinutes,
    required this.deepLink,
    this.imageUrl,                // NEW
    this.rating,                  // NEW
    this.address,                 // NEW
  });
}