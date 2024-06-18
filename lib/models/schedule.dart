import 'dart:convert';

class Schedule {
  final int scheduleId;
  final DateTime startDate;
  final int repeatDays;
  final int pillsPerDose;
  final int dailyFrequency;
  List<String> scheduledTimes;
  final int medicationId;
  final String medicationName;
  int? containerNumber;

  Schedule({
    required this.scheduleId,
    required this.startDate,
    required this.repeatDays,
    required this.pillsPerDose,
    required this.dailyFrequency,
    required this.scheduledTimes,
    required this.medicationId,
    required this.medicationName,
    this.containerNumber,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    List<String> scheduledTimesParsed = [];
    var timesFromJson = json['ScheduledTimes'];

    if (timesFromJson != null) {
      if (timesFromJson is String) {
        scheduledTimesParsed = List<String>.from(jsonDecode(timesFromJson));
      } else {
        scheduledTimesParsed = List<String>.from(timesFromJson.map((time) => time.toString()));
      }
    }

    return Schedule(
      scheduleId: json['ScheduleID'],
      startDate: DateTime.parse(json['StartDate']),
      repeatDays: json['RepeatDays'],
      pillsPerDose: json['PillsPerDose'],
      dailyFrequency: json['DailyFrequency'],
      scheduledTimes: scheduledTimesParsed,
      medicationId: json['Medication'],
      medicationName: json['MedicationName'],
      containerNumber: json['ContainerNumber'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ScheduleID': scheduleId,
      'StartDate': startDate.toIso8601String().split('T')[0],
      'RepeatDays': repeatDays,
      'PillsPerDose': pillsPerDose,
      'DailyFrequency': dailyFrequency,
      'ScheduledTimes': scheduledTimes,
      'Medication': medicationId,
      'MedicationName': medicationName,
      'ContainerNumber': containerNumber,
    };
  }

  bool get isCurrentlyTaken {
    return startDate.isBefore(DateTime.now());
  }

  Schedule copyWith({
    int? scheduleId,
    DateTime? startDate,
    int? repeatDays,
    int? pillsPerDose,
    int? dailyFrequency,
    List<String>? scheduledTimes,
    int? medicationId,
    String? medicationName,
    int? containerNumber,
  }) {
    return Schedule(
      scheduleId: scheduleId ?? this.scheduleId,
      startDate: startDate ?? this.startDate,
      repeatDays: repeatDays ?? this.repeatDays,
      pillsPerDose: pillsPerDose ?? this.pillsPerDose,
      dailyFrequency: dailyFrequency ?? this.dailyFrequency,
      scheduledTimes: scheduledTimes ?? this.scheduledTimes,
      medicationId: medicationId ?? this.medicationId,
      medicationName: medicationName ?? this.medicationName,
      containerNumber: containerNumber ?? this.containerNumber,
    );
  }

  int calculateDays(int quantityInDispenser) {
    int totalDoses = calculateDoses(quantityInDispenser);
    return totalDoses ~/ dailyFrequency;
  }

  int calculateDoses(int quantityInDispenser) {
    return quantityInDispenser ~/ pillsPerDose;
  }

}