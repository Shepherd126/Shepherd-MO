import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shepherd_mo/models/event.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shepherd_mo/pages/event_detail.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.screenHeight,
    required this.isDark,
    required this.screenWidth,
  });

  final Event event;
  final double screenHeight;
  final bool isDark;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        title: Text(
          event.eventName!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontSize: screenHeight * 0.019, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.event, size: 16),
                const SizedBox(width: 4),
                Text(
                    "${AppLocalizations.of(context)!.start}: ${DateFormat('dd/MM/yyyy').format(event.fromDate!)} | ${DateFormat('HH:mm').format(event.fromDate!)}"),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.event_available, size: 16),
                const SizedBox(width: 4),
                Text(
                    "${AppLocalizations.of(context)!.end}: ${DateFormat('dd/MM/yyyy').format(event.toDate!)} | ${DateFormat('HH:mm').format(event.toDate!)}"),
              ],
            ),
          ],
        ),
        leading: const Icon(Icons.event, color: Colors.orange),
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${event.description}",
                  style: TextStyle(
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Status: ${event.status}",
                  style: const TextStyle(color: Colors.blue),
                ),
                if (event.isPublic != null) Text("Public: ${event.isPublic}"),
                // Action buttons
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed: () {
                      Get.to(() => EventDetailsPage(eventId: event.id!),
                          id: 2, transition: Transition.rightToLeftWithFade);
                    },
                    child: Text(AppLocalizations.of(context)!.details),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
