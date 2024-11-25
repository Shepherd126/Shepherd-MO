import 'package:shepherd_mo/models/group_user.dart';

class Activity {
  final String id;
  final String? activityName;
  final String? description;
  final String? startTime;
  final String? endTime;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createTime;
  final DateTime? updateTime;
  final String? status;
  final int? totalCost;
  final List<GroupAndUser>? groupAndUsers;

  Activity(
      {required this.id,
      this.activityName,
      this.description,
      this.startTime,
      this.endTime,
      this.startDate,
      this.endDate,
      this.createTime,
      this.updateTime,
      this.status,
      this.totalCost,
      this.groupAndUsers});

  // Factory method to create an Activity from a JSON map
  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String,
      activityName: json['activityName'] as String,
      description:
          json['description'] != null ? json['description'] as String : null,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'] as String)
          : null,
      createTime: json['createTime'] != null
          ? DateTime.parse(json['createTime'] as String)
          : null,
      updateTime: json['updateTime'] != null
          ? DateTime.parse(json['updateTime'] as String)
          : null,
      status: json['status'] as String,
      totalCost: json['totalCost'] != null
          ? int.tryParse(json['totalCost'].toString())
          : null,
      groupAndUsers: json['groupAndUsers'] != null
          ? (json['groupAndUsers'] as List<dynamic>)
              .map((e) => GroupAndUser.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  // Method to convert an Activity instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activityName': activityName,
      'description': description,
      'startTime': startTime,
      'endTime': endTime,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'createTime': createTime?.toIso8601String(),
      'updateTime': updateTime?.toIso8601String(),
      'status': status,
      'totalCost': totalCost,
    };
  }
}
