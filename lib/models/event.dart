class Event {
  final String id;
  final String eventName;
  final String ceremonyId;
  final String description;
  final DateTime fromDate;
  final DateTime toDate;
  final bool isPublic;
  final bool allowVolunteers;
  final String recurringType;
  final String status;
  final double totalCost;
  final DateTime? approvalDate;
  final String approvedBy;

  Event({
    required this.id,
    required this.eventName,
    required this.ceremonyId,
    required this.description,
    required this.fromDate,
    required this.toDate,
    required this.isPublic,
    required this.allowVolunteers,
    required this.recurringType,
    required this.status,
    required this.totalCost,
    this.approvalDate,
    required this.approvedBy,
  });

  // Factory constructor to parse from JSON (for fetching from API)
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      eventName: json['eventName'],
      ceremonyId: json['ceremonyId'],
      description: json['description'],
      fromDate: DateTime.parse(json['fromDate']),
      toDate: DateTime.parse(json['toDate']),
      isPublic: json['isPublic'],
      allowVolunteers: json['allowVolunteers'],
      recurringType: json['recurringType'],
      status: json['status'],
      totalCost: json['totalCost'].toDouble(),
      approvalDate: json['approvalDate'] != null
          ? DateTime.parse(json['approvalDate'])
          : null,
      approvedBy: json['approvedBy'],
    );
  }

  // Method to convert to JSON (for sending to API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventName': eventName,
      'ceremonyId': ceremonyId,
      'description': description,
      'fromDate': fromDate.toIso8601String(),
      'toDate': toDate.toIso8601String(),
      'isPublic': isPublic,
      'allowVolunteers': allowVolunteers,
      'recurringType': recurringType,
      'status': status,
      'totalCost': totalCost,
      'approvalDate': approvalDate?.toIso8601String(),
      'approvedBy': approvedBy,
    };
  }
}
