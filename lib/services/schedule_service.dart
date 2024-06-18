import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/schedule.dart';
import 'config.dart';

class ScheduleService {
  //final String baseUrl = "http://10.0.2.2:8000";
  //final String baseUrl = "http://192.168.1.3:8000";
  final String baseUrl = Config.baseUrl;

  Future<List<Schedule>> getMedicationsSchedule() async {
    var response = await http.get(Uri.parse('$baseUrl/schedules/'));
    if (response.statusCode == 200) {
      Iterable data = json.decode(response.body);
      return List<Schedule>.from(data.map((model) => Schedule.fromJson(model)));
    } else {
      throw Exception('Failed to load schedules');
    }
  }

  Future<bool> updateMedicationSchedule(Schedule schedule) async {
    var response = await http.put(
      Uri.parse('$baseUrl/schedule/${schedule.scheduleId}/update/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(schedule.toJson()),
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteMedicationSchedule(int scheduleId) async {
    var response = await http.delete(
      Uri.parse('$baseUrl/schedule/$scheduleId/delete/'),
    );
    return response.statusCode == 200;
  }

  Future<List<Schedule>> getSchedulesForMedication(int medicationId) async {
    var response = await http.get(
      Uri.parse('$baseUrl/medications/$medicationId/schedule/'),
    );
    if (response.statusCode == 200) {
      Iterable data = json.decode(response.body);
      return List<Schedule>.from(data.map((model) => Schedule.fromJson(model)));
    } else {
      throw Exception('Failed to load medication schedules');
    }
  }

  Future<bool> createMedicationSchedule(int medicationId, Schedule schedule) async {
    var url = Uri.parse('$baseUrl/medications/$medicationId/schedule/create/');
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode(schedule.toJson()),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      print('Failed to create schedule: ${response.statusCode} ${response.body}');
      return false;
    }
  }

}
