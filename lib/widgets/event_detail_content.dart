import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shepherd_mo/models/event.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EventDetailsContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final event = Provider.of<Event>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final locale = Localizations.localeOf(context).languageCode;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 100),

          // Event Name with custom text style and shadows for readability
          Padding(
            padding: EdgeInsets.only(
                left: screenWidth * 0.24, right: screenWidth * 0.1),
            child: Text(
              event.eventName ?? "No Name",
              style: TextStyle(
                fontSize: screenHeight * 0.03,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    color: Colors.black26,
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 10),

          // Status row with custom padding
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.24),
            child: FittedBox(
              child: Row(
                children: <Widget>[
                  Text(
                    "-",
                    style: TextStyle(
                      fontSize: screenHeight * 0.02,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Icon(Icons.star,
                      color: Colors.white, size: screenHeight * 0.02),
                  SizedBox(width: 5),
                  Text(
                    event.status!,
                    style: TextStyle(
                      fontSize: screenHeight * 0.02,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: screenHeight * 0.04),

          // Total Cost with Label
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04, vertical: screenHeight * 0.01),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.totalCost,
                        style: TextStyle(
                          fontSize: screenHeight * 0.02,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        textAlign: TextAlign.right,
                        event.isPublic!
                            ? AppLocalizations.of(context)!.public
                            : AppLocalizations.of(context)!.private,
                        style: TextStyle(
                          fontSize: screenHeight * 0.02,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ]),
                Text(
                  "\$${event.totalCost}",
                  style: TextStyle(
                    fontSize: screenHeight * 0.017,
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.015),
          // Date Information (Start and End Dates) with Labels
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateInfo(AppLocalizations.of(context)!.start,
                    event.fromDate.toString(), screenHeight, locale),
                SizedBox(height: screenHeight * 0.005),
                _buildDateInfo(AppLocalizations.of(context)!.end,
                    event.toDate.toString(), screenHeight, locale),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.005),
          // Description with Label
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.description,
                  style: TextStyle(
                    fontSize: screenHeight * 0.02,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  event.description ?? "",
                  style: TextStyle(fontSize: screenHeight * 0.018),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateInfo(
      String label, String dateTime, double screenHeight, String locale) {
    final date =
        DateFormat('EEEE, dd/MM/yyyy', locale).format(DateTime.parse(dateTime));
    final time = DateFormat('HH:mm', locale).format(DateTime.parse(dateTime));

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.005),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event,
                color: const Color(0xFF6B4E71),
                size: screenHeight * 0.025,
              ),
              SizedBox(width: screenHeight * 0.01),
              Text(
                "$label:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6B4E71),
                  fontSize: screenHeight * 0.02,
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.005),
          Text('$date $time', style: TextStyle(fontSize: screenHeight * 0.017)),
        ],
      ),
    );
  }
}
