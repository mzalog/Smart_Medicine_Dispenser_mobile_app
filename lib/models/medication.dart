class Medication {
  int id;
  String name;
  int dosage;
  String description;
  int? quantityInDispenser;
  int? containerNumber;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.description,
    this.quantityInDispenser,
    this.containerNumber,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['MedicationID'] as int,
      name: json['MedicationName'] as String,
      dosage: json['Dosage'] as int,
      description: json['Description'] as String,
      quantityInDispenser: json['QuantityInDispenser'] as int? ?? 0,
      containerNumber: json['ContainerNumber'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'MedicationID': id,
      'MedicationName': name,
      'Dosage': dosage,
      'Description': description,
      'QuantityInDispenser': quantityInDispenser,
      'ContainerNumber': containerNumber,
    };
  }

  Medication copyWith({
    int? id,
    String? name,
    int? dosage,
    String? description,
    int? quantityInDispenser,
    int? containerNumber,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      description: description ?? this.description,
      quantityInDispenser: quantityInDispenser ?? this.quantityInDispenser,
      containerNumber: containerNumber ?? this.containerNumber,
    );
  }

}
