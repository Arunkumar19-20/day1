class SupervisorModel {
  final String supervisorId;
  final String name;
  final String phone;
  final String dob;
  final String bloodGroup;
  final String shift;
  final String address;
  final String workingArea;

  SupervisorModel({
    required this.supervisorId,
    required this.name,
    required this.phone,
    required this.dob,
    required this.bloodGroup,
    required this.shift,
    required this.address,
    required this.workingArea,
  });

  factory SupervisorModel.fromJson(Map<String, dynamic> json) {
    return SupervisorModel(
      supervisorId: json['supervisor_id']?.toString() ?? "",
      name: json['name'] ?? "",
      phone: json['phone'] ?? "",
      dob: json['dob'] ?? "",
      bloodGroup: json['blood_group'] ?? "",
      shift: json['shift'] ?? "",
      address: json['address'] ?? "",
      workingArea: json['working_area'] ?? "",
    );
  }
}