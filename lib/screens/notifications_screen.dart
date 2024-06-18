import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class NotificationHistoryScreen extends StatefulWidget {
  @override
  _NotificationHistoryScreenState createState() => _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState extends State<NotificationHistoryScreen> {
  List notifications = [];

  final Map<String, String> notificationDescriptions = {
    "TAKE_MEDICATION": "Przypomnienie o wzięciu leku",
    "MEDICATION_TAKEN": "Lek został wzięty w ciągu 10 minut",
    "DELAY_IN_TAKING_MEDICATION": "Opóźnienie w wzięciu leku (10 minut)",
    "MEDICATION_TAKEN_WITH_DELAY": "Lek wzięty z opóźnieniem (10-20 minut)",
    "MEDICATION_NOT_TAKEN_INTERVENTION": "Lek nie został wzięty (10-20 minut) - wymagana interwencja",
    "MEDICATION_TAKEN_SIGNIFICANT_DELAY": "Lek wzięty ze znacznym opóźnieniem (ponad 20 minut)",
    "NO_CUP_UNDER_DISPENSER": "Brak kubka pod dozownikiem"
  };

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    final response = await http.get(Uri.parse('http://192.168.1.8:8000/dispenser_logs/'));

    if (response.statusCode == 200) {
      setState(() {
        notifications = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  String formatDateTime(String dateTimeStr) {
    final dateTime = DateTime.parse(dateTimeStr);
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historia powiadomień'),
        backgroundColor: Colors.teal[400],
      ),
      body: notifications.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4.0,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              title: Text(
                notificationDescriptions[notifications[index]['DispenseStatus']] ?? notifications[index]['DispenseStatus'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Text(
                utf8.decode(notifications[index]['DispenserResponse'].codeUnits),
                style: TextStyle(fontSize: 16),
              ),
              trailing: Text(
                formatDateTime(notifications[index]['DispenseDateTime']),
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          );
        },
      ),
    );
  }
}
