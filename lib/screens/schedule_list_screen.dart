import 'package:flutter/material.dart';
import '../services/schedule_service.dart';
import '../models/schedule.dart';
import '../models/medication.dart';
import '../services/medication_service.dart';
import './schedule_edit_screen.dart';
import 'home_screen.dart';

class ScheduleScreen extends StatefulWidget {
  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final ScheduleService scheduleService = ScheduleService();
  final MedicationService medicationService = MedicationService();
  late Future<List<Schedule>> _schedulesFuture;
  List<Medication> medications = [];

  @override
  void initState() {
    super.initState();
    _reloadSchedules();
    _loadMedications();
  }

  void _reloadSchedules() {
    setState(() {
      _schedulesFuture = scheduleService.getMedicationsSchedule();
    });
  }

  void _loadMedications() async {
    var meds = await medicationService.getMedications();
    setState(() {
      medications = meds;
    });
  }

  Medication? getMedication(int medicationId) {
    try {
      return medications.firstWhere(
            (med) => med.id == medicationId,
        orElse: () => throw Exception('Medication not found'),
      );
    } catch (e) {
      return null;
    }
  }

  String getRepeatDaysDescription(int days) {
    switch (days) {
      case 1:
        return "Codziennie";
      case 2:
        return "Co dwa dni";
      case 3:
        return "Co trzy dni";
      case 4:
        return "Co cztery dni";
      case 5:
        return "Co pięć dni";
      case 6:
        return "Co sześć dni";
      case 7:
        return "Co siedem dni";
      default:
        return "Niezdefiniowany";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Harmonogram Leków"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
                  (Route<dynamic> route) => false,
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Schedule>>(
          future: _schedulesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Błąd: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Brak harmonogramów do wyświetlenia.'));
            } else {
              List<Schedule> schedulesInContainer = snapshot.data!.where((s) => s.containerNumber != null).toList();
              List<Schedule> schedulesNotInContainer = snapshot.data!.where((s) => s.containerNumber == null).toList();

              schedulesInContainer.sort((a, b) => a.medicationName.toLowerCase().compareTo(b.medicationName.toLowerCase()));
              schedulesNotInContainer.sort((a, b) => a.medicationName.toLowerCase().compareTo(b.medicationName.toLowerCase()));

              return SingleChildScrollView(
                child: Column(
                  children: [
                    buildScheduleSection('Leki w pojemnikach', schedulesInContainer),
                    buildScheduleSection('Leki nie w pojemnikach', schedulesNotInContainer),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget buildScheduleSection(String title, List<Schedule> schedules) {
    return ExpansionTile(
      title: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      initiallyExpanded: title == 'Leki w pojemnikach',
      children: schedules.map((schedule) => buildScheduleItem(schedule)).toList(),
    );
  }

  Widget buildScheduleItem(Schedule schedule) {
    Medication? medication = getMedication(schedule.medicationId);
    int quantityInDispenser = medication?.quantityInDispenser ?? 0;
    int daysAvailable = schedule.calculateDays(quantityInDispenser);
    int dosesAvailable = schedule.calculateDoses(quantityInDispenser);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        title: Text(
          schedule.medicationName,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ilość tabletek na dawkę: ${schedule.pillsPerDose}',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 4),
            Text(
              'Dni: ${getRepeatDaysDescription(schedule.repeatDays)}',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              'Godziny: ${schedule.scheduledTimes.join(", ")}',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              'Wystarczy na: $daysAvailable dni / $dosesAvailable dawkowań',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            if (schedule.containerNumber != null)
              Text(
                'Pojemnik: ${schedule.containerNumber}',
                style: TextStyle(fontSize: 14),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () async {
                bool? result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScheduleEditScreen(schedule: schedule),
                  ),
                );
                if (result == true) {
                  _reloadSchedules();
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _confirmDeleteDialog(context, schedule.scheduleId),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteDialog(BuildContext context, int scheduleId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Potwierdź"),
          content: Text("Czy na pewno chcesz usunąć ten harmonogram?"),
          actions: [
            TextButton(
              child: Text("Anuluj"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Usuń"),
              onPressed: () async {
                bool success = await scheduleService.deleteMedicationSchedule(scheduleId);
                Navigator.of(context).pop();
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Harmonogram usunięty."), backgroundColor: Colors.green));
                  _reloadSchedules();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Nie udało się usunąć harmonogramu."), backgroundColor: Colors.red));
                }
              },
            ),
          ],
        );
      },
    );
  }
}