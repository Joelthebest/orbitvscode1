import 'dart:convert';
import 'package:http/http.dart' as http;

class YelpService {
  // TODO: Replace with your actual Yelp API key
  static const String _apiKey = 'YELP_API_KEY_PLACEHOLDER';
  static const String _baseUrl = 'https://api.yelp.com/v3';

  // Search for restaurants
  Future<List<YelpRestaurant>> searchRestaurants(
    String query,
    String location,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/businesses/search').replace(
          queryParameters: {
            'term': query,
            'location': location,
            'categories': 'restaurants,food',
            'limit': '10',
          },
        ),
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final businesses = data['businesses'] as List;
        
        return businesses
            .map((business) => YelpRestaurant.fromJson(business))
            .toList();
      } else {
        throw Exception('Failed to search restaurants: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching restaurants: $e');
    }
  }

  // Get specific restaurant details
  Future<YelpRestaurant?> getRestaurantDetails(String businessId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/businesses/$businessId'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return YelpRestaurant.fromJson(data);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting restaurant details: $e');
    }
  }
}

// Model for Yelp restaurant data
class YelpRestaurant {
  final String id;
  final String name;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final String price;
  final List<String> categories;
  final String phone;
  final String address;
  final double? latitude;
  final double? longitude;

  YelpRestaurant({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.price,
    required this.categories,
    required this.phone,
    required this.address,
    this.latitude,
    this.longitude,
  });

  factory YelpRestaurant.fromJson(Map<String, dynamic> json) {
    // Extract address
    String address = '';
    if (json['location'] != null) {
      final location = json['location'];
      address = location['address1'] ?? '';
      if (location['city'] != null) {
        address += ', ${location['city']}';
      }
    }

    // Extract categories
    List<String> categories = [];
    if (json['categories'] != null) {
      categories = (json['categories'] as List)
          .map((cat) => cat['title'] as String)
          .toList();
    }

    return YelpRestaurant(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Restaurant',
      imageUrl: json['image_url'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      price: json['price'] ?? '\$\$',
      categories: categories,
      phone: json['phone'] ?? '',
      address: address,
      latitude: json['coordinates']?['latitude']?.toDouble(),
      longitude: json['coordinates']?['longitude']?.toDouble(),
    );
  }

  // Estimate delivery prices based on restaurant price point
  Map<String, double> estimatedDeliveryPrices() {
    // Base price multiplier based on restaurant price category
    double baseMultiplier = 1.0;
    switch (price) {
      case '\$':
        baseMultiplier = 0.85;
        break;
      case '\$\$':
        baseMultiplier = 1.0;
        break;
      case '\$\$\$':
        baseMultiplier = 1.2;
        break;
      case '\$\$\$\$':
        baseMultiplier = 1.5;
        break;
    }

    // Typical delivery fees and markups for each platform
    return {
      'UberEats': (12.99 + (rating * 2)) * baseMultiplier,
      'DoorDash': (11.99 + (rating * 2)) * baseMultiplier,
      'GrubHub': (13.99 + (rating * 2)) * baseMultiplier,
    };
  }

  // Estimate delivery times (in minutes)
  Map<String, int> estimatedDeliveryTimes() {
    // Add some randomness to make it realistic
    return {
      'UberEats': 25 + (reviewCount % 15),
      'DoorDash': 30 + (reviewCount % 10),
      'GrubHub': 20 + (reviewCount % 20),
    };
  }
}