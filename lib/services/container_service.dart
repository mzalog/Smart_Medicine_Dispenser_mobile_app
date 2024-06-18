import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';

class ContainerService {
  //final String baseUrl = "http://10.0.2.2:8000";
  final String baseUrl = Config.baseUrl;


  Future<List<int>> getAvailableContainers() async {
    var response = await http.get(Uri.parse('$baseUrl/available_containers/'));
    if (response.statusCode == 200) {
      List<int> availableContainers = List<int>.from(json.decode(response.body));
      return availableContainers;
    } else {
      throw Exception('Failed to load available containers');
    }
  }
}
