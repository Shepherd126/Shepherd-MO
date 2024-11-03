import 'package:flutter/material.dart';

class EventDetailsBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Align(
      alignment: Alignment.topCenter,
      child: ClipPath(
        clipper: ImageClipper(),
        child: Stack(
          children: [
            Image.asset(
              'assets/images/stained_glass_window.jpg',
              fit: BoxFit.cover,
              width: screenWidth,
              height: screenHeight * 0.5,
              color: Color.fromARGB(134, 0, 0, 0), // Semi-transparent overlay
              colorBlendMode: BlendMode.darken,
            ),
          ],
        ),
      ),
    );
  }
}

class ImageClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Define starting and ending points
    Offset curveStartingPoint =
        Offset(0, 40); // Lower start for a more dramatic curve
    Offset curveEndPoint = Offset(
        size.width, size.height * 0.88); // Higher endpoint for rounded shape

    // Define rounder control points for smoother curve
    path.lineTo(curveStartingPoint.dx, curveStartingPoint.dy);
    path.quadraticBezierTo(
      size.width *
          0.25, // Control point closer to the start for a tighter curve
      size.height * 0.8, // Lifted up for a rounder middle arc
      curveEndPoint.dx, // Close to the endpoint for a smooth transition
      curveEndPoint.dy,
    );
    path.quadraticBezierTo(
      size.width * 0.95,
      size.height,
      curveEndPoint.dx,
      curveEndPoint.dy,
    );
    path.lineTo(size.width, 0); // Close the path on the right side
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true; // Ensures the clip path updates on rebuild
  }
}
