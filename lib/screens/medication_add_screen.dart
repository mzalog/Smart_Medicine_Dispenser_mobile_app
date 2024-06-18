import 'package:flutter/material.dart';
import '../models/medication.dart';
import '../services/medication_service.dart';
import '../services/container_service.dart';
import 'schedule_add_screen.dart';

class MedicationAddScreen extends StatefulWidget {
  @override
  _MedicationAddScreenState createState() => _MedicationAddScreenState();
}

class _MedicationAddScreenState extends State<MedicationAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final MedicationService medicationService = MedicationService();
  final ContainerService containerService = ContainerService();

  Medication _newMedication = Medication(
    id: 0,
    name: '',
    dosage: 0,
    description: '',
    quantityInDispenser: 0,
    containerNumber: null,
  );
  bool _addToDispenser = false;
  bool _createSchedule = false;
  bool _formChanged = false;
  List<int> availableContainers = [];
  int? selectedContainer;

  @override
  void initState() {
    super.initState();
    loadAvailableContainers();
  }

  void loadAvailableContainers() async {
    availableContainers = await containerService.getAvailableContainers();
    setState(() {});
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _newMedication = _newMedication.copyWith(
        containerNumber: _addToDispenser ? selectedContainer : null,
      );

      medicationService.addMedication(_newMedication).then((success) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Nowy lek został dodany')),
          );
          if (_createSchedule) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScheduleAddScreen(),
              ),
            );
          } else {
            Navigator.pop(context);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Nie udało się dodać leku')),
          );
        }
      });
    }
  }

  Widget _buildPillsToAddWidget() {
    if (_addToDispenser) {
      if (availableContainers.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Brak wolnych pojemników',
            style: TextStyle(color: Colors.red, fontSize: 16),
          ),
        );
      }
      return Column(
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: 'Ilość w dozowniku'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Ilość w dozowniku jest wymagana';
              if (int.tryParse(value) == null || int.parse(value) <= 0) {
                return 'Ilość musi być dodatnią liczbą całkowitą';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                _formChanged = true;
              });
            },
            onSaved: (value) {
              _newMedication = _newMedication.copyWith(quantityInDispenser: int.tryParse(value ?? '0') ?? 0);
            },
          ),
          DropdownButtonFormField<int>(
            value: selectedContainer,
            decoration: InputDecoration(labelText: 'Wybierz pojemnik'),
            onChanged: (int? newValue) {
              setState(() {
                selectedContainer = newValue;
                _formChanged = true;
              });
            },
            items: availableContainers.map<DropdownMenuItem<int>>((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text(value.toString()),
              );
            }).toList(),
            validator: (value) {
              if (_addToDispenser && value == null) {
                return 'Proszę wybrać pojemnik';
              }
              return null;
            },
          ),
        ],
      );
    }
    return SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!_formChanged) {
          return true;
        }
        bool shouldPop = await showDialog(
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
        );
        return shouldPop;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Dodaj Lek'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () async {
              if (!_formChanged) {
                Navigator.of(context).pop();
              } else {
                bool shouldPop = await showDialog(
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
                );
                if (shouldPop) {
                  Navigator.of(context).pop();
                }
              }
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: () {
                // Show help dialog or navigate to help screen
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Pomoc'),
                    content: Text('Wprowadź szczegóły leku, takie jak nazwa, dawkowanie, opis. '
                        'Możesz również dodać lek do pojemnika i utworzyć harmonogram. '
                        'Po wypełnieniu formularza naciśnij przycisk "Dodaj Lek" na dole ekranu.'),
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
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Nazwa leku'),
                  onChanged: (value) {
                    setState(() {
                      _formChanged = true;
                    });
                  },
                  onSaved: (value) {
                    _newMedication = _newMedication.copyWith(name: value ?? '');
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nazwa leku jest wymagana';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Dawkowanie (mg)'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _formChanged = true;
                          });
                        },
                        onSaved: (value) {
                          _newMedication = _newMedication.copyWith(dosage: int.parse(value ?? '0'));
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Dawkowanie jest wymagane';
                          }
                          if (int.tryParse(value) == null || int.parse(value) <= 0) {
                            return 'Wprowadź prawidłową liczbę';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("mg"),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Opis'),
                  onChanged: (value) {
                    setState(() {
                      _formChanged = true;
                    });
                  },
                  onSaved: (value) {
                    _newMedication = _newMedication.copyWith(description: value ?? '');
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Opis jest wymagany';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                SwitchListTile(
                  title: Text("Dodaj lek do pojemnika"),
                  value: _addToDispenser,
                  onChanged: (bool value) {
                    setState(() {
                      _addToDispenser = value;
                      _formChanged = true;
                      if (!_addToDispenser) {
                        _newMedication = _newMedication.copyWith(quantityInDispenser: 0, containerNumber: null);
                      }
                    });
                  },
                ),
                _buildPillsToAddWidget(),
                if (_addToDispenser)
                  SwitchListTile(
                    title: Text("Utwórz harmonogram po zapisaniu leku"),
                    value: _createSchedule,
                    onChanged: (bool value) {
                      setState(() {
                        _createSchedule = value;
                        _formChanged = true;
                      });
                    },
                  ),
                SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: _saveForm,
                    child: Text('Dodaj Lek'),
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
}
