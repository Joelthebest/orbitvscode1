import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/delivery_result.dart';
import '../services/yelp_service.dart';

// Provider for search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// Provider for user's location (you'll want to get this from GPS or user input)
final userLocationProvider = StateProvider<String>((ref) => 'State College, PA');

// Yelp service provider
final yelpServiceProvider = Provider((ref) => YelpService());

// Enhanced delivery results provider using Yelp
final deliveryResultsProvider = FutureProvider<List<DeliveryResult>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final location = ref.watch(userLocationProvider);
  
  if (query.isEmpty) {
    return [];
  }

  try {
    final yelpService = ref.read(yelpServiceProvider);
    
    // Search restaurants on Yelp
    final restaurants = await yelpService.searchRestaurants(query, location);
    
    // Convert each restaurant into delivery options for each platform
    final List<DeliveryResult> allResults = [];
    
    for (final restaurant in restaurants) {
      final prices = restaurant.estimatedDeliveryPrices();
      final times = restaurant.estimatedDeliveryTimes();
      
      // Create a result for each platform
      prices.forEach((platform, price) {
        allResults.add(
          DeliveryResult(
            platform: platform,
            restaurantName: restaurant.name,
            itemName: query, // The search query (e.g., "burger", "pizza")
            price: price,
            estimatedDeliveryMinutes: times[platform] ?? 30,
            deepLink: _generateDeepLink(platform, restaurant),
            imageUrl: restaurant.imageUrl,
            rating: restaurant.rating,
            address: restaurant.address,
          ),
        );
      });
    }
    
    // Sort by price (cheapest first)
    allResults.sort((a, b) {
      final priceCompare = a.price.compareTo(b.price);
      if (priceCompare != 0) return priceCompare;
      return a.estimatedDeliveryMinutes.compareTo(b.estimatedDeliveryMinutes);
    });
    
    return allResults;
    
  } catch (e) {
    // Return empty list on error
    return [];
  }
});

// Generate deep links for each platform
String _generateDeepLink(String platform, YelpRestaurant restaurant) {
  final restaurantName = Uri.encodeComponent(restaurant.name);
  
  switch (platform) {
    case 'UberEats':
      // UberEats deep link format
      return 'ubereats://search?query=$restaurantName';
    case 'DoorDash':
      // DoorDash deep link format
      return 'doordash://search?query=$restaurantName';
    case 'GrubHub':
      // GrubHub deep link format
      return 'grubhub://search?query=$restaurantName';
    default:
      return '';
  }
}