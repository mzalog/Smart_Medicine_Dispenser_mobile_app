import 'package:http/http.dart' as http;
import 'dart:convert';

class DrugService {
  Future<Map<String, dynamic>?> fetchDrugInfo(String barcode) async {
    final response = await http.get(Uri.parse('https://world.openfoodfacts.org/api/v0/product/$barcode.json'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 1) {
        return data['product'];
      } else {
        return null;
      }
    } else {
      throw Exception('Failed to load drug information');
    }
  }
}
