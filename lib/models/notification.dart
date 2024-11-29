
class NotificationModel {
  final String id;
  final String title;
  final String content;
  final DateTime time;

  // Constructor
  NotificationModel({
    required this.id,
    required this.title,
    required this.content,
    required this.time,
  });

  // Factory constructor to create a NotificationModel from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      time: DateTime.parse(json['time']),
    );
  }

  // Method to convert the NotificationModel into JSON format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'time': time.toIso8601String(),
    };
  }

  // Optional: Method to return a string representation of the notification
  @override
  String toString() {
    return 'NotificationModel{id: $id, title: $title, content: $content, time: $time}';
  }
}
