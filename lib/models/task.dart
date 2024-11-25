class Task {
  String? id;
  String? title;
  String? description;
  int? cost;
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

  Task({
    this.id,
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
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String?,
      title: json['title'] != null ? json['title'] as String : null,
      description: json['description'] as String?,
      status: json['status'] as String?,
      cost: json['cost']?.toInt(),
      userId: json['userId'] as String?,
      groupUserId: json['groupUserId'] as String?,
      groupId: json['groupId'] as String?,
      eventId: json['eventId'] as String?,
      activityId: json['activityId'] as String?,
      groupPresetId: json['groupPresetId'] as String?,
      userName: json['userName'] as String?,
      eventName: json['eventName'] as String?,
      eventDescription: json['eventDescription'] as String?,
      activityName: json['activityName'] as String?,
      activityDescription: json['activityDescription'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (activityId != null) 'activityID': activityId,
      if (groupId != null) 'groupID': groupId,
      if (userId != null) 'userID': userId,
      if (groupPresetId != null) 'groupPresetID': groupPresetId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (cost != null) 'cost': cost.toString(),
    };
  }

  @override
  String toString() {
    return 'Task('
        'id: $id, '
        'title: $title, '
        'description: $description, '
        'cost: $cost, '
        'status: $status, '
        'userId: $userId, '
        'groupUserId: $groupUserId, '
        'groupId: $groupId, '
        'eventId: $eventId, '
        'activityId: $activityId, '
        'groupPresetId: $groupPresetId, '
        'userName: $userName, '
        'eventName: $eventName, '
        'eventDescription: $eventDescription, '
        'activityName: $activityName, '
        'activityDescription: $activityDescription, '
        ')';
  }
}
