class Task {
  String? id;
  String? title;
  String? description;
  double? cost;
  String? status;
  String? userId;
  String? groupUserId;
  String? groupId;
  String? eventId;
  String? activityId;
  String? groupPresetId;
  String? userName;
  String? eventName;
  String? eventDescription;
  String? activityName;
  String? activityDescription;
  bool? isConfirmed;

  Task(
      {this.id,
      this.title,
      this.description,
      this.cost,
      this.status,
      this.userId,
      this.groupUserId,
      this.groupId,
      this.eventId,
      this.activityId,
      this.groupPresetId,
      this.userName,
      this.eventName,
      this.eventDescription,
      this.activityName,
      this.activityDescription,
      this.isConfirmed});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] != null ? json['title'] as String : "N/A",
      description: json['description'] as String,
      status: json['status'] as String,
      cost: json['cost'] != null ? json['cost'].toDouble() : 0.0,
      userId: json['userId'] as String,
      groupUserId: json['groupUserId'] as String,
      groupId: json['groupId'] as String,
      eventId: json['eventId'] as String,
      activityId: json['activityId'] as String,
      groupPresetId: json['groupPresetId'] as String?,
      userName: json['userName'] as String,
      eventName: json['eventName'] as String,
      eventDescription: json['eventDescription'] as String,
      activityName: json['activityName'] as String,
      activityDescription: json['activityDescription'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (activityId != null) 'activityID': activityId,
      if (groupId != null) 'groupID': groupId,
      if (userId != null) 'userID': userId,
      if (groupPresetId != null) 'groupPresetID': groupPresetId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (cost != null) 'cost': cost,
      if (isConfirmed != null) 'isConfirmed': isConfirmed,
    };
  }
}
