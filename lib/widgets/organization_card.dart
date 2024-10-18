import 'package:flutter/material.dart';

class OrganizationCard extends StatelessWidget {
  final Color color;
  final String title;
  final int membersCount;

  OrganizationCard(
      {required this.color, required this.title, required this.membersCount});
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(right: screenWidth * 0.05),
      child: Container(
        width: screenWidth * 0.5,
        padding: EdgeInsets.all(screenWidth * 0.03),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: screenHeight * 0.025,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline),
            ),
            SizedBox(height: screenHeight * 0.02),
            Text('$membersCount thành viên'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                minimumSize: Size(screenWidth * 0.5,
                    screenHeight * 0.06), // Same width as container
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0), // Padding to control the inner space
                backgroundColor: Colors.black, // Button color
                foregroundColor: Colors.white, // Text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      8), // Make the button less rounded (sharper)
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Chi tiết',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenHeight * 0.02)),
                  Container(
                    width: screenWidth *
                        0.07, // Set width and height based on radius
                    height: screenWidth * 0.07,
                    decoration: BoxDecoration(
                      shape:
                          BoxShape.circle, // This makes the container circular
                      color: Colors.grey.shade700, // Background color
                    ),
                    child: Icon(
                      Icons.arrow_right_alt_rounded,
                      size: screenWidth *
                          0.055, // Adjust the icon size relative to the screen width
                      color: Colors.white, // Icon color
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
