import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shepherd_mo/api/api_service.dart';
import 'package:shepherd_mo/models/event.dart';
import 'package:shepherd_mo/widgets/event_detail_background.dart';
import 'package:shepherd_mo/widgets/event_detail_content.dart';
import 'package:shepherd_mo/widgets/progressHUD.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EventDetailsPage extends StatefulWidget {
  final String eventId;

  EventDetailsPage({required this.eventId});

  @override
  _EventDetailsPageState createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  Future<Event>? event;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    event = fetchEventDetails(widget.eventId);
  }

  Future<Event> fetchEventDetails(String id) async {
    setState(() {
      isLoading = true;
    });
    try {
      final apiService = ApiService();
      return await apiService.fetchEventDetails(id);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Event Details",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFEEC05C),
      ),
      body: ProgressHUD(
        inAsyncCall: isLoading,
        child: FutureBuilder<Event>(
          future: event,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error: ${snapshot.error}",
                  style: TextStyle(fontSize: screenHeight * 0.02),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data == null) {
              return Center(
                child: Text(
                  "No data available",
                  style: TextStyle(fontSize: screenHeight * 0.02),
                ),
              );
            } else {
              // Data is ready, provide the event to the Provider and render the page
              return Provider<Event>.value(
                value: snapshot.data!, // Use the fetched event data
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    EventDetailsBackground(),
                    EventDetailsContent(),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
