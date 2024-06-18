import 'package:flutter/material.dart';
import '../models/medication.dart';
import '../services/medication_service.dart';
import '../services/container_service.dart';

class MedicationEditScreen extends StatefulWidget {
  final Medication medication;

  MedicationEditScreen({required this.medication});

  @override
  _MedicationEditScreenState createState() => _MedicationEditScreenState();
}

class _MedicationEditScreenState extends State<MedicationEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late Medication _editedMedication;
  final MedicationService medicationService = MedicationService();
  List<int> availableContainers = [];
  int? selectedContainer;
  bool _addPillsToDevice = false;
  int? _pillsToAdd;
  bool _formChanged = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _editedMedication = widget.medication;
    _nameController.text = _editedMedication.name;
    _dosageController.text = _editedMedication.dosage.toString();
    _descriptionController.text = _editedMedication.description;
    _quantityController.text = _editedMedication.quantityInDispenser?.toString() ?? '0';
    selectedContainer = _editedMedication.containerNumber;
    loadAvailableContainers();
  }

  void loadAvailableContainers() async {
    availableContainers = await ContainerService().getAvailableContainers();
    if (selectedContainer != null && !availableContainers.contains(selectedContainer)) {
      availableContainers.add(selectedContainer!);
    }
    setState(() {});
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Aktualizacja instancji _editedMedication z nowymi wartościami z formularza
      _editedMedication = _editedMedication.copyWith(
        name: _nameController.text,
        dosage: int.parse(_dosageController.text),
        description: _descriptionController.text,
        quantityInDispenser: _addPillsToDevice && _pillsToAdd != null
            ? (_editedMedication.quantityInDispenser ?? 0) + _pillsToAdd!
            : _editedMedication.quantityInDispenser,
        containerNumber: selectedContainer,
      );

      medicationService.updateMedication(_editedMedication).then((success) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lek został zaktualizowany')),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Błąd podczas aktualizacji')),
          );
        }
      });
    }
  }

  Future<void> _confirmContainerChange(int? newValue) async {
    bool shouldChange = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Potwierdź zmianę pojemnika'),
        content: Text('Czy na pewno chcesz zmienić pojemnik? To wiąże się z przesypaniem tabletek do innego pojemnika.'),
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
    if (shouldChange) {
      setState(() {
        selectedContainer = newValue;
        _formChanged = true;
      });
    }
  }

  Widget _buildPillsToAddWidget() {
    if (_addPillsToDevice) {
      return Column(
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: 'Ilość tabletek do wsypania'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Ilość tabletek jest wymagana';
              if (int.tryParse(value) == null || int.parse(value) <= 0) {
                return 'Ilość musi być dodatnią liczbą całkowitą';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                _formChanged = true;
                _pillsToAdd = int.tryParse(value);
              });
            },
          ),
          DropdownButtonFormField<int>(
            value: selectedContainer,
            decoration: InputDecoration(labelText: 'Wybierz pojemnik'),
            onChanged: (int? newValue) {
              if (newValue != selectedContainer) {
                _confirmContainerChange(newValue);
              }
            },
            items: availableContainers.map<DropdownMenuItem<int>>((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text(value.toString()),
              );
            }).toList(),
            validator: (value) => value == null ? 'Proszę wybrać pojemnik' : null,
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
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Edytuj Lek'),
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
                    content: Text('Edytuj szczegóły leku, takie jak nazwa, dawkowanie, opis. '
                        'Możesz również dodać tabletki do urządzenia. '
                        'Po wprowadzeniu zmian naciśnij przycisk "Zapisz" na dole ekranu.'),
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
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Nazwa leku'),
                  onChanged: (value) {
                    setState(() {
                      _formChanged = true;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nazwa leku nie może być pusta';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _dosageController,
                  decoration: InputDecoration(labelText: 'Dawkowanie'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _formChanged = true;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Dawkowanie nie może być puste';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Opis'),
                  onChanged: (value) {
                    setState(() {
                      _formChanged = true;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Opis nie może być pusty';
                    }
                    return null;
                  },
                ),
                SwitchListTile(
                  title: Text('Dodać tabletki do urządzenia?'),
                  value: _addPillsToDevice,
                  onChanged: (bool value) {
                    setState(() {
                      _addPillsToDevice = value;
                      _formChanged = true;
                    });
                  },
                ),
                _buildPillsToAddWidget(),
                SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: _saveForm,
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
    _nameController.dispose();
    _dosageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
