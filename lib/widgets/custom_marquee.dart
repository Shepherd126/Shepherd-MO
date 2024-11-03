import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class CustomMarquee extends StatefulWidget {
  final String text;

  CustomMarquee({required this.text});

  @override
  _CustomMarqueeState createState() => _CustomMarqueeState();
}

class _CustomMarqueeState extends State<CustomMarquee> {
  ScrollController _controller = ScrollController();
  final marqueeKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    try {
      return Marquee(
        key: marqueeKey, // If using a GlobalKey, ensure it’s initialized
        text: widget.text,
        style: TextStyle(
          fontSize: screenHeight * 0.025,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        startAfter: const Duration(seconds: 1),
        crossAxisAlignment: CrossAxisAlignment.start,
        pauseAfterRound: const Duration(seconds: 1),
        blankSpace: 20.0,
        scrollAxis: Axis.horizontal,
        velocity: 50.0,
        accelerationDuration: const Duration(seconds: 1),
        accelerationCurve: Curves.linear,
        decelerationDuration: const Duration(milliseconds: 500),
        decelerationCurve: Curves.easeOut,
      );
    } catch (e) {
      print("Marquee error: $e");
      return Text("Error loading marquee"); // Fallback UI
    }
  }
}
