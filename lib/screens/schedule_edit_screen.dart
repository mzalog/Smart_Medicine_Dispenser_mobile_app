import 'package:flutter/material.dart';
import '../models/schedule.dart';
import '../services/schedule_service.dart';

class ScheduleEditScreen extends StatefulWidget {
  final Schedule schedule;

  ScheduleEditScreen({required this.schedule});

  @override
  _ScheduleEditScreenState createState() => _ScheduleEditScreenState();
}

class _ScheduleEditScreenState extends State<ScheduleEditScreen> {
  final TextEditingController _pillsPerDoseController = TextEditingController();
  final TextEditingController _dailyFrequencyController = TextEditingController();
  List<TextEditingController> _timeControllers = [];
  final _formKey = GlobalKey<FormState>();
  bool _isChanged = false;
  late Schedule _editedSchedule;

  @override
  void initState() {
    super.initState();
    _editedSchedule = widget.schedule.copyWith();
    _pillsPerDoseController.text = _editedSchedule.pillsPerDose.toString();
    _dailyFrequencyController.text = _editedSchedule.dailyFrequency.toString();
    _timeControllers = _editedSchedule.scheduledTimes
        .map((time) => TextEditingController(text: time))
        .toList();
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

  Future<void> _selectDate(BuildContext context) async {
    if (_editedSchedule.startDate.isAfter(DateTime.now())) {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _editedSchedule.startDate,
        firstDate: DateTime.now(),
        lastDate: DateTime(2101),
      );
      if (picked != null && picked != _editedSchedule.startDate) {
        setState(() {
          _editedSchedule = _editedSchedule.copyWith(startDate: picked);
          _isChanged = true;
        });
      }
    }
  }

  void _saveSchedule() {
    if (!_formKey.currentState!.validate()) return;

    List<String> updatedTimes = _timeControllers.map((c) => c.text).toList();
    updatedTimes.sort(_compareTimes);
    Schedule updatedSchedule = _editedSchedule.copyWith(
      pillsPerDose: int.parse(_pillsPerDoseController.text),
      dailyFrequency: int.parse(_dailyFrequencyController.text),
      scheduledTimes: updatedTimes,
    );

    ScheduleService().updateMedicationSchedule(updatedSchedule).then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Harmonogram został zaktualizowany pomyślnie')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nie udało się zaktualizować harmonogramu')),
        );
      }
    });
  }

  void _adjustTimeControllers() {
    int frequency = int.tryParse(_dailyFrequencyController.text) ?? _editedSchedule.dailyFrequency;
    if (frequency != _timeControllers.length) {
      if (frequency > _timeControllers.length) {
        for (int i = _timeControllers.length; i < frequency; i++) {
          _timeControllers.add(TextEditingController(text: "08:00"));  // Default time
        }
      } else {
        _timeControllers = _timeControllers.sublist(0, frequency);
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Edytuj Harmonogram"),
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
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Pomoc'),
                    content: Text('Na tej stronie możesz edytować harmonogram przyjmowania leku. '
                        'Możesz zmienić ilość tabletek na dawkę oraz liczbę dawek w ciągu dnia. '
                        'Dla każdej dawki możesz wybrać godzinę przyjęcia. '
                        'Kliknij przycisk "Zapisz zmiany", aby zatwierdzić wprowadzone zmiany.'),
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
                Center(
                  child: Text(
                    'Edytujesz harmonogram dla leku - ${_editedSchedule.medicationName}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 20),
                if (_editedSchedule.startDate.isAfter(DateTime.now()))
                  ListTile(
                    title: Text(
                      "Data rozpoczęcia dawkowania ${_editedSchedule.startDate.toIso8601String().split('T')[0]}",
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
                        controller: _pillsPerDoseController,
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
                              _editedSchedule = _editedSchedule.copyWith(pillsPerDose: newVal);
                            } else {
                              _editedSchedule = _editedSchedule.copyWith(pillsPerDose: 1);
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
                              _editedSchedule = _editedSchedule.copyWith(pillsPerDose: _editedSchedule.pillsPerDose + 1);
                              _pillsPerDoseController.text = _editedSchedule.pillsPerDose.toString();
                              _isChanged = true;
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: _editedSchedule.pillsPerDose > 1
                              ? () {
                            setState(() {
                              _editedSchedule = _editedSchedule.copyWith(pillsPerDose: _editedSchedule.pillsPerDose - 1);
                              _pillsPerDoseController.text = _editedSchedule.pillsPerDose.toString();
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
                            onPressed: _editedSchedule.dailyFrequency > 1
                                ? () => setState(() {
                              _editedSchedule = _editedSchedule.copyWith(dailyFrequency: _editedSchedule.dailyFrequency - 1);
                              _dailyFrequencyController.text = _editedSchedule.dailyFrequency.toString();
                              _adjustTimeControllers();
                              _isChanged = true;
                            })
                                : null,
                          ),
                          Text('${_editedSchedule.dailyFrequency}', style: TextStyle(fontSize: 16)),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: _editedSchedule.dailyFrequency < 8
                                ? () => setState(() {
                              _editedSchedule = _editedSchedule.copyWith(dailyFrequency: _editedSchedule.dailyFrequency + 1);
                              _dailyFrequencyController.text = _editedSchedule.dailyFrequency.toString();
                              _adjustTimeControllers();
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
                ...List<Widget>.generate(_editedSchedule.dailyFrequency, (index) {
                  return Column(
                    children: [
                      TimePickerWidget(
                        initialTime: _timeControllers.length > index ? _timeControllers[index].text : '08:00',
                        onTimeChanged: (newTime) {
                          setState(() {
                            _isChanged = true;
                            if (index < _timeControllers.length) {
                              _timeControllers[index].text = newTime;
                            } else {
                              _timeControllers.add(TextEditingController(text: newTime));
                            }
                          });
                        },
                      ),
                      SizedBox(height: 10),
                    ],
                  );
                }),
                SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: _saveSchedule,
                    child: Text('Zapisz zmiany'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                      textStyle: TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pillsPerDoseController.dispose();
    _dailyFrequencyController.dispose();
    _timeControllers.forEach((controller) => controller.dispose());
    super.dispose();
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
