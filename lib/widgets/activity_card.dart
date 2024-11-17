import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ActivityCard extends StatelessWidget {
  final String title;
  final String startDate;
  final String endDate;
  final String status;
  final VoidCallback onTap;

  const ActivityCard({
    super.key,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Screen dimensions for responsive design
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Localizations for multi-language support
    final localizations = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.symmetric(vertical: screenHeight * 0.008),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(screenHeight * 0.018),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleRow(screenHeight, screenWidth),
              SizedBox(height: screenHeight * 0.05),
              _buildDateRow(localizations, screenWidth, screenHeight),
            ],
          ),
        ),
      ),
    );
  }

  // Row widget to display title and status
  Widget _buildTitleRow(double screenHeight, double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: screenHeight * 0.016,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis, // Adds ellipsis for long titles
          ),
        ),
        SizedBox(width: screenWidth * 0.02), // Spacing between title and status
        Text(
          status,
          style: TextStyle(
            fontSize: screenHeight * 0.014,
            fontWeight: FontWeight.bold,
            color: _getStatusColor(status),
          ),
        ),
      ],
    );
  }

  // Row widget to display start and end dates
  Widget _buildDateRow(
      AppLocalizations localizations, double screenWidth, double screenHeight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDateInfo(
            localizations.start, startDate, screenWidth, screenHeight),
        _buildDateInfo(localizations.end, endDate, screenWidth, screenHeight),
      ],
    );
  }

  // Helper widget to display each date info with an icon
  Widget _buildDateInfo(
      String label, String date, double screenWidth, double screenHeight) {
    return Row(
      children: [
        const Icon(Icons.date_range),
        SizedBox(width: screenWidth * 0.01),
        Text(
          '$label: $date',
          style: TextStyle(fontSize: screenHeight * 0.012),
        ),
      ],
    );
  }

  // Determines the color based on the status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in progress':
        return Colors.orange;
      case 'pending':
        return Colors.blue;
      default:
        return Colors.blueGrey;
    }
  }
}
