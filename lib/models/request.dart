class RequestModel {
  final String id;
  final String title;
  final String content;
  final String? type;
  final bool? isAccepted;
  final DateTime createDate;
  final String? createdBy;
  final DateTime updateDate;
  final String? updatedBy;
  final String to;
  final String? group;
  final String? event;
  final List<dynamic> reports;
  final String? createdUser;
  final String? updatedUser;

  RequestModel({
    required this.id,
    required this.title,
    required this.content,
    this.type,
    this.isAccepted,
    required this.createDate,
    this.createdBy,
    required this.updateDate,
    this.updatedBy,
    required this.to,
    this.group,
    this.event,
    this.reports = const [],
    this.createdUser,
    this.updatedUser,
  });

  // Factory method for creating an instance from a JSON map
  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      type: json['type'],
      isAccepted: json['isAccepted'],
      createDate: DateTime.parse(json['createDate']),
      createdBy: json['createdBy'],
      updateDate: DateTime.parse(json['updateDate']),
      updatedBy: json['updatedBy'],
      to: json['to'],
      group: json['group'],
      event: json['event'],
      reports: json['reports'] ?? [],
      createdUser: json['createdUser'],
      updatedUser: json['updatedUser'],
    );
  }

  // Method to convert instance to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'type': type,
      'isAccepted': isAccepted,
      'createDate': createDate.toIso8601String(),
      'createdBy': createdBy,
      'updateDate': updateDate.toIso8601String(),
      'updatedBy': updatedBy,
      'to': to,
      'group': group,
      'event': event,
      'reports': reports,
      'createdUser': createdUser,
      'updatedUser': updatedUser,
    };
  }
}
