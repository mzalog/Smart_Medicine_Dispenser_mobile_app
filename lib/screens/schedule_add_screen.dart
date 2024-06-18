import 'package:flutter/material.dart';
import '../models/schedule.dart';
import '../models/medication.dart';
import '../services/schedule_service.dart';
import '../services/medication_service.dart';
import 'schedule_list_screen.dart';

class ScheduleAddScreen extends StatefulWidget {
  @override
  _ScheduleAddScreenState createState() => _ScheduleAddScreenState();
}

class _ScheduleAddScreenState extends State<ScheduleAddScreen> {
  final MedicationService medicationService = MedicationService();
  final ScheduleService scheduleService = ScheduleService();
  List<Medication> medications = [];
  Medication? selectedMedication;
  DateTime startDate = DateTime.now();
  int repeatDays = 1;
  int pillsPerDose = 1;
  int dailyFrequency = 1;
  List<String> scheduledTimes = [];
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _pillsController = TextEditingController();
  bool _isChanged = false;

  @override
  void initState() {
    super.initState();
    _pillsController.text = '1'; // initial value for pills per dose
    loadMedications();
    _initializeScheduledTimes();
  }

  void loadMedications() async {
    var meds = await medicationService.getMedications();
    setState(() {
      medications = meds;
      medications.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase())); // Case-insensitive sort
    });
  }

  void _initializeScheduledTimes() {
    scheduledTimes = List.generate(dailyFrequency, (index) => '08:00');
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
        _isChanged = true;
      });
    }
  }

  void _addScheduledTime() {
    if (scheduledTimes.length < dailyFrequency) {
      setState(() {
        scheduledTimes.add('08:00'); // Default time
        _isChanged = true;
      });
    }
  }

  TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }

  int _compareTimes(String a, String b) {
    final timeA = _parseTime(a);
    final timeB = _parseTime(b);
    if (timeA.hour != timeB.hour) {
      return timeA.hour.compareTo(timeB.hour);
    } else {
      return timeA.minute.compareTo(timeB.minute);
    }
  }

  Future<bool> _onWillPop() async {
    if (_isChanged) {
      return (await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Potwierdź'),
          content: Text('Czy na pewno chcesz opuścić ekran? Wszystkie niezapisane zmiany zostaną utracone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Nie'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Tak'),
            ),
          ],
        ),
      )) ?? false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Dodaj Harmonogram"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.help_outline),
              onPressed: () {
                // Show help dialog or navigate to help screen
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Pomoc'),
                    content: Text('Wybierz lek, datę rozpoczęcia dawkowania, ilość tabletek na dawkę, ile razy dziennie oraz godziny podawania. '
                        'Następnie naciśnij przycisk "Dodaj Harmonogram".'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Zamknij'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (medications.isNotEmpty) ...[
                  DropdownButtonFormField<Medication>(
                    value: selectedMedication,
                    onChanged: (Medication? newValue) {
                      setState(() {
                        selectedMedication = newValue;
                        _isChanged = true;
                      });
                    },
                    items: medications.map<DropdownMenuItem<Medication>>((Medication medication) {
                      return DropdownMenuItem<Medication>(
                        value: medication,
                        child: Text(medication.name),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Wybierz lek',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  ListTile(
                    title: Text(
                      "Data rozpoczęcia dawkowania ${startDate.toIso8601String().split('T')[0]}",
                      style: TextStyle(fontSize: 16),
                    ),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _pillsController,
                          decoration: InputDecoration(
                            labelText: 'Ilość tabletek na dawkę',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'To pole nie może być puste';
                            if (int.tryParse(value)! < 1) return 'Wartość musi być większa niż 0';
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              _isChanged = true;
                              int? newVal = int.tryParse(value);
                              if (newVal != null && newVal > 0) {
                                pillsPerDose = newVal;
                              } else {
                                pillsPerDose = 1;
                              }
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Column(
                        children: [
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                pillsPerDose++;
                                _pillsController.text = pillsPerDose.toString();
                                _isChanged = true;
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: pillsPerDose > 1
                                ? () {
                              setState(() {
                                pillsPerDose--;
                                _pillsController.text = pillsPerDose.toString();
                                _isChanged = true;
                              });
                            }
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Ile razy dziennie', style: TextStyle(fontSize: 16)),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: dailyFrequency > 1
                                  ? () => setState(() {
                                dailyFrequency--;
                                _initializeScheduledTimes();
                                _isChanged = true;
                              })
                                  : null,
                            ),
                            Text('$dailyFrequency', style: TextStyle(fontSize: 16)),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: dailyFrequency < 8
                                  ? () => setState(() {
                                dailyFrequency++;
                                _initializeScheduledTimes();
                                _isChanged = true;
                              })
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  ...List<Widget>.generate(dailyFrequency, (index) {
                    return Column(
                      children: [
                        TimePickerWidget(
                          initialTime: scheduledTimes.length > index ? scheduledTimes[index] : '08:00',
                          onTimeChanged: (newTime) {
                            setState(() {
                              _isChanged = true;
                              if (index < scheduledTimes.length) {
                                scheduledTimes[index] = newTime;
                              } else {
                                scheduledTimes.add(newTime);
                              }
                            });
                          },
                        ),
                        SizedBox(height: 10), // Add spacing between time pickers
                      ],
                    );
                  }),
                  SizedBox(height: 30), // Adjust the height for spacing
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate() && selectedMedication != null) {
                          scheduledTimes.sort(_compareTimes);
                          Schedule newSchedule = Schedule(
                            scheduleId: 0,
                            startDate: startDate,
                            repeatDays: repeatDays,
                            pillsPerDose: pillsPerDose,
                            dailyFrequency: dailyFrequency,
                            scheduledTimes: scheduledTimes,
                            medicationId: selectedMedication!.id,
                            medicationName: selectedMedication!.name,
                            containerNumber: selectedMedication!.containerNumber,
                          );
                          bool success = await scheduleService.createMedicationSchedule(selectedMedication!.id, newSchedule);
                          if (success) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => ScheduleScreen()),
                                  (Route<dynamic> route) => false,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Harmonogram został dodany pomyślnie."))
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Nie udało się dodać harmonogramu."))
                            );
                          }
                        }
                      },
                      child: Text('Dodaj Harmonogram'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                        textStyle: TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TimePickerWidget extends StatefulWidget {
  final String initialTime;
  final Function(String) onTimeChanged;

  TimePickerWidget({required this.initialTime, required this.onTimeChanged});

  @override
  _TimePickerWidgetState createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    List<String> parts = widget.initialTime.split(':');
    _selectedTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  void _pickTime() async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (time != null && time != _selectedTime) {
      int roundedMinute = (time.minute / 15).round() * 15;
      if (roundedMinute == 60) {
        time = TimeOfDay(hour: (time.hour + 1) % 24, minute: 0);
      } else {
        time = TimeOfDay(hour: time.hour, minute: roundedMinute);
      }
      setState(() {
        _selectedTime = time!;
        widget.onTimeChanged('${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Wybierz godzinę'),
      subtitle: Text('${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}'),
      trailing: Icon(Icons.timer),
      onTap: _pickTime,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: Colors.grey, width: 1.0),
      ),
    );
  }
}
