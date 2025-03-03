import 'dart:convert';
import '../../core/api/api_client.dart';

class ProductService {
  static const String endpoint = 'products/popular-public';

  Future<List<dynamic>> fetchProducts() async {
    try {
      final response = await ApiClient.getData(endpoint);
      print('Raw Response from ProductService: $response');

      if (response is List) {
        print('Data is List: $response');
        return response;
      } else if (response is Map && response.containsKey('message')) {
        print('No products found: ${response['message']}');
        return [];
      } else if (response is Map && response.containsKey('error')) {
        print('API Error: ${response['error']}');
        return [];
      } else {
        print('Unexpected response format: $response');
        return [];
      }
    } catch (e) {
      print('Error in fetchProducts: $e');
      throw Exception('Error: $e');
    }
  }
}