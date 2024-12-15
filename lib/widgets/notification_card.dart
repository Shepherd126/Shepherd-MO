import 'package:flutter/material.dart';
import 'package:shepherd_mo/api/api_service.dart';
import 'package:shepherd_mo/models/notification.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shepherd_mo/utils/toast.dart';

class NotificationCard extends StatefulWidget {
  final NotificationModel notification;

  NotificationCard({
    required this.notification,
  });

  @override
  _NotificationCardState createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  final Stream<DateTime> _realTimeStream = Stream.periodic(
    const Duration(seconds: 1),
    (_) => DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Function to get the appropriate icon for the notification type
  IconData getTypeIcon(String type) {
    switch (type) {
      case 'Task':
        return Icons.task;
      case 'warning':
        return Icons.warning_amber_outlined;
      case 'alert':
        return Icons.error_outline;
      case 'message':
        return Icons.message_outlined;
      default:
        return Icons.notifications_none;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    final apiService = ApiService();

    bool isDark = Theme.of(context).brightness == Brightness.dark;

    Color cardColor = widget.notification.isRead
        ? isDark
            ? Colors.grey[900]!
            : const Color.fromARGB(255, 230, 236, 239)!
        : isDark
            ? Colors.blue[900]!.withOpacity(0.4)
            : const Color.fromARGB(255, 192, 224, 250)!;

    final localizations = AppLocalizations.of(context)!;

    // Function to format the time duration
    String formatTimeAgo(DateTime pastTime, DateTime currentTime) {
      final language = localizations.localeName;
      Duration duration = currentTime.difference(pastTime);

      int days = duration.inDays.abs();
      int hours = duration.inHours.remainder(24).abs();
      int minutes = duration.inMinutes.remainder(60).abs();
      int seconds = duration.inSeconds.remainder(60).abs();
      int weeks = days ~/ 7;

      // Pluralization logic for English
      String dayLabel = (language == 'en' && days > 1)
          ? '${localizations.day}s'
          : localizations.day;
      String hourLabel = (language == 'en' && hours > 1)
          ? '${localizations.hour}s'
          : localizations.hour;
      String minuteLabel = (language == 'en' && minutes > 1)
          ? '${localizations.minute}s'
          : localizations.minute;
      String secondLabel = (language == 'en' && seconds > 1)
          ? '${localizations.second}s'
          : localizations.second;
      String weekLabel = (language == 'en' && weeks > 1)
          ? '${localizations.week}s'
          : localizations.week;

      // Logic to display the time ago format
      if (weeks > 0) {
        return '$weeks $weekLabel ${localizations.ago}';
      } else if (days > 1) {
        return '$days $dayLabel ${localizations.ago}';
      } else if (days == 1) {
        return '1 $dayLabel ${localizations.ago}';
      } else if (hours > 0) {
        return '$hours $hourLabel ${localizations.ago}';
      } else if (minutes > 0) {
        return '$minutes $minuteLabel ${localizations.ago}';
      } else if (seconds > 0) {
        return '$seconds $secondLabel ${localizations.ago}';
      } else {
        return localizations.justNow; // 'Just now' for very recent times
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.005),
      child: ElevatedButton(
        onPressed: () {}, // Executes the callback if provided
        style: ElevatedButton.styleFrom(
          backgroundColor: cardColor, // Button color
          elevation: 4, // Elevation to create depth
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenHeight * 0.012),
          ),
          padding: EdgeInsets.only(
            top: screenHeight * 0.01,
            bottom: screenHeight * 0.01,
            left: screenHeight * 0.015,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type Icon
            Container(
              padding: EdgeInsets.all(screenHeight * 0.012),
              decoration: BoxDecoration(
                color: isDark ? Colors.blue[800] : Colors.blue[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                getTypeIcon(widget.notification.type),
                color: isDark ? Colors.white : Colors.black,
                size: screenHeight * 0.028,
              ),
            ),
            SizedBox(width: screenWidth * 0.05),
            // Notification Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.notification.title,
                    style: TextStyle(
                      fontSize: screenHeight * 0.018,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  // Content
                  Text(
                    widget.notification.content,
                    style: TextStyle(
                      fontSize: screenHeight * 0.015,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  // Time
                  StreamBuilder<DateTime>(
                    stream: _realTimeStream,
                    builder: (context, snapshot) {
                      String formattedDuration = snapshot.hasData
                          ? formatTimeAgo(
                              widget.notification.time, snapshot.data!)
                          : formatTimeAgo(
                              widget.notification.time, DateTime.now());

                      return Text(
                        formattedDuration,
                        style: TextStyle(
                          fontSize: screenHeight * 0.0125,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                        textAlign: TextAlign.end,
                      );
                    },
                  ),
                  if (widget.notification.type == 'Task' &&
                      widget.notification.taskStatus != null) ...[
                    if (widget.notification.taskStatus == 0) ...[
                      // Task not confirmed, show buttons (Accept / Decline)
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.005),
                        child: Row(
                          children: [
                            // Confirm Button
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  // Handle accept task logic
                                  final success = await apiService.confirmTask(
                                      widget.notification.relevantId!, true);
                                  if (success) {
                                    await apiService
                                        .readNoti(widget.notification.id);
                                    showToast(
                                        '${localizations.confirmTask} ${localizations.success.toLowerCase()}');
                                    setState(() {
                                      widget.notification.taskStatus = 1;
                                      widget.notification.isRead = true;
                                    });
                                  } else {
                                    showToast(
                                        '${localizations.confirmTask} ${localizations.unsuccess.toLowerCase()}');
                                  }
                                },
                                icon: Icon(Icons.check, color: Colors.white),
                                label: Text(
                                  localizations.accept,
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        screenHeight * 0.008),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: screenHeight * 0.005),
                                  elevation: 5,
                                ),
                              ),
                            ),

                            // Optional space between the buttons
                            SizedBox(width: screenWidth * 0.025),

                            // Decline Button
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  // Handle reject task logic
                                  final success = await apiService.confirmTask(
                                      widget.notification.relevantId!, false);
                                  if (success) {
                                    await apiService
                                        .readNoti(widget.notification.id);
                                    showToast(
                                        '${localizations.declineTask} ${localizations.success.toLowerCase()}');
                                    setState(() {
                                      widget.notification.taskStatus = 2;
                                      widget.notification.isRead = true;
                                    });
                                  } else {
                                    showToast(
                                        '${localizations.declineTask} ${localizations.unsuccess.toLowerCase()}');
                                  }
                                },
                                icon: Icon(Icons.close, color: Colors.white),
                                label: Text(
                                  localizations.decline,
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        screenHeight * 0.008),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: screenHeight * 0.005),
                                  elevation: 5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (widget.notification.taskStatus == 1) ...[
                      // Task is accepted, show text
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.005),
                        child: Text(
                          localizations.taskAccepted, // "Task Accepted" message
                          style: TextStyle(
                            fontSize: screenHeight * 0.015,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ] else if (widget.notification.taskStatus == 2) ...[
                      // Task is rejected, show text
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.005),
                        child: Text(
                          localizations.taskDeclined, // "Task Declined" message
                          style: TextStyle(
                            fontSize: screenHeight * 0.015,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ] else if (widget.notification.taskStatus == 3) ...[
                      // Task is assigned to another person, show text
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.005),
                        child: Text(
                          localizations
                              .taskAssignedToAnother, // "Task Assigned to Another" message
                          style: TextStyle(
                              fontSize: screenHeight * 0.015,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey),
                        ),
                      ),
                    ],
                  ]
                ],
              ),
            ),
            // Menu Icon Button (for actions)
            IconButton(
              icon: Icon(Icons.more_vert,
                  color: isDark ? Colors.white : Colors.black),
              onPressed: () {
                // Handle menu action here (e.g., show a menu, etc.)
                showModalBottomSheet(
                  context: context,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  builder: (BuildContext context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade300,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ),
                        // Mark as Read
                        ListTile(
                          leading:
                              Icon(Icons.mark_chat_read, color: Colors.blue),
                          title: Text(widget.notification.isRead
                              ? localizations.markAsUnread
                              : localizations.markAsRead),
                          onTap: () {
                            apiService.readNoti(widget.notification.id);
                            Navigator.pop(context); // Close the bottom sheet
                          },
                        ),
                        // Delete Notification
                        ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text(localizations.deleteNoti),
                          onTap: () {
                            // Delete notification logic
                            Navigator.pop(context); // Close the bottom sheet
                          },
                        ),
                        // Other actions can be added here...
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
