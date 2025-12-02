class Worker {
  final int id;
  final String name;
  final String position;
  final String reportPath;

  Worker({required this.id, required this.name, required this.position, required this.reportPath});

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['id'],
      name: json['name'],
      position: json['position'],
      reportPath: json['reportPath'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'position': position,
  };
}
