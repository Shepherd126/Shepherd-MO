class Ceremony {
  final String id;
  final String name;
  final String description;
  final DateTime date;
  final int? dayOfWeek;
  final int? dayOfMonth;
  final int? dayOfYear;
  final String? group;
  final String? timeSlot;
  final List<String> activityPresets;
  final List<String> events;

  Ceremony({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    this.dayOfWeek,
    this.dayOfMonth,
    this.dayOfYear,
    this.group,
    this.timeSlot,
    required this.activityPresets,
    required this.events,
  });

  // Factory constructor to create a Ceremony instance from a JSON map
  factory Ceremony.fromJson(Map<String, dynamic> json) {
    return Ceremony(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      dayOfWeek: json['dayOfWeek'] as int?,
      dayOfMonth: json['dayOfMonth'] as int?,
      dayOfYear: json['dayOfYear'] as int?,
      group: json['group'] as String?,
      timeSlot: json['timeSlot'] as String?,
      activityPresets: List<String>.from(json['activityPresets'] ?? []),
      events: List<String>.from(json['events'] ?? []),
    );
  }

  // Method to convert a Ceremony instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'date': date.toIso8601String(),
      'dayOfWeek': dayOfWeek,
      'dayOfMonth': dayOfMonth,
      'dayOfYear': dayOfYear,
      'group': group,
      'timeSlot': timeSlot,
      'activityPresets': activityPresets,
      'events': events,
    };
  }
}
