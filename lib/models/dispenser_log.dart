class DispenserLog {
  int logID;
  int medicationID;
  DateTime dispenseDateTime;
  String dispenseStatus;
  String dispenserResponse;

  DispenserLog({
    required this.logID,
    required this.medicationID,
    required this.dispenseDateTime,
    required this.dispenseStatus,
    required this.dispenserResponse,
  });

  factory DispenserLog.fromJson(Map<String, dynamic> json) {
    return DispenserLog(
      logID: json['logID'],
      medicationID: json['medicationID'],
      dispenseDateTime: DateTime.parse(json['dispenseDateTime']),
      dispenseStatus: json['dispenseStatus'],
      dispenserResponse: json['dispenserResponse'],
    );
  }
}
