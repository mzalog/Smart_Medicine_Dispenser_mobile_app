import 'package:flutter/material.dart';
import '../models/medication.dart';
import '../services/medication_service.dart';
import 'medication_edit_screen.dart';

class MedicationListScreen extends StatefulWidget {
  @override
  _MedicationListScreenState createState() => _MedicationListScreenState();
}

class _MedicationListScreenState extends State<MedicationListScreen> {
  late Future<List<Medication>> _medicationsFuture;

  @override
  void initState() {
    super.initState();
    _reloadMedications();
  }

  void _reloadMedications() {
    setState(() {
      _medicationsFuture = MedicationService().getMedications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista Leków'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Medication>>(
          future: _medicationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Błąd: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Brak leków do wyświetlenia.'));
            } else {
              List<Medication> inContainerMedications = snapshot.data!.where((m) => m.containerNumber != null).toList();
              List<Medication> notInContainerMedications = snapshot.data!.where((m) => m.containerNumber == null).toList();

              inContainerMedications.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
              notInContainerMedications.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

              return SingleChildScrollView(
                child: Column(
                  children: [
                    buildMedicationSection('Leki w urządzeniu', inContainerMedications),
                    buildMedicationSection('Wszystkie leki', notInContainerMedications),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget buildMedicationSection(String title, List<Medication> medications) {
    return ExpansionTile(
      title: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      initiallyExpanded: title == 'Leki w urządzeniu',
      children: medications.map((med) => medicationTile(med)).toList(),
    );
  }

  Widget medicationTile(Medication medication) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        title: Text(
          medication.name,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dawka: ${medication.dosage} mg',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 4),
            Text(
              'Ilość w urządzeniu: ${medication.quantityInDispenser ?? "N/A"}',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              'Pojemnik: ${medication.containerNumber ?? "Brak"}',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MedicationEditScreen(medication: medication),
                  ),
                ).then((_) => _reloadMedications());
              },
              tooltip: 'Edytuj lek',
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _confirmDelete(context, medication),
              tooltip: 'Usuń lek',
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Medication medication) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Usuwanie leku'),
          content: Text('Czy na pewno chcesz usunąć lek ${medication.name}?'),
          actions: <Widget>[
            TextButton(
              child: Text('Anuluj'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Usuń'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteMedication(medication.id);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteMedication(int id) {
    MedicationService().deleteMedication(id).then((success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Lek został usunięty' : 'Nie udało się usunąć leku'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success) {
        _reloadMedications();
      }
    });
  }
}
