// services/medication_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/medication.dart';
import 'config.dart';

class MedicationService {
  //final String apiUrl = 'http://10.0.2.2:8000/medications/';
  final String apiUrl = '${Config.baseUrl}/medications/';


  Future<List<Medication>> getMedications() async {
    var response = await http.get(Uri.parse(apiUrl), headers: {'Accept': 'application/json'});
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Medication> medications = body.map((dynamic item) => Medication.fromJson(item)).toList();
      return medications;
    } else {
      throw Exception("Nie można załadować listy leków. Status Code: ${response.statusCode}");
    }
  }

  Future<bool> updateMedication(Medication medication) async {
    var response = await http.put(
      Uri.parse('$apiUrl${medication.id}/update/'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        },
      body: json.encode(medication.toJson()),
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteMedication(int id) async {
    var response = await http.delete(
      Uri.parse('$apiUrl$id/delete/'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    return response.statusCode == 200;
  }



  Future<bool> addMedication(Medication medication) async {
    var url = Uri.parse('$apiUrl${'create/'}');
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode(medication.toJson()),
    );

    if (response.statusCode == 201) {
      return true;
    } else if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to create schedule: ${response.statusCode} ${response.body}');
      return false;
    }
  }
}