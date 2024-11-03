import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:marquee/marquee.dart';
import 'package:shepherd_mo/widgets/custom_marquee.dart';

class OrganizationCard extends StatefulWidget {
  final Color color;
  final String title;
  final int membersCount;
  final VoidCallback onDetailsPressed;

  const OrganizationCard({
    super.key,
    required this.color,
    required this.title,
    required this.membersCount,
    required this.onDetailsPressed,
  });

  @override
  _OrganizationCardState createState() => _OrganizationCardState();
}

class _OrganizationCardState extends State<OrganizationCard> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final localizations = AppLocalizations.of(context);
    final membersText = localizations?.members ?? 'Members';
    final detailsText = localizations?.details ?? 'Details';

    double calculateTextWidth(String text, TextStyle style) {
      final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      return textPainter.width;
    }

    final double textWidth =
        calculateTextWidth(widget.title, const TextStyle(fontSize: 30.0));
    final double textMaxWidth = screenWidth * 0.5;
    final titleWidget = textWidth <= textMaxWidth
        ? Text(
            widget.title,
            style: TextStyle(
              fontSize: screenHeight * 0.025,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          )
        : CustomMarquee(
            text: widget.title,
          );

    return Padding(
      padding: EdgeInsets.only(right: screenWidth * 0.05),
      child: Container(
        width: screenWidth * 0.5,
        padding: EdgeInsets.all(screenWidth * 0.03),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.035, child: titleWidget),
            SizedBox(height: screenHeight * 0.01),
            Text(
              '${widget.membersCount} $membersText',
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: widget.onDetailsPressed,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(screenWidth * 0.5, screenHeight * 0.06),
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.03,
                    vertical: screenHeight * 0.015),
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    detailsText,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenHeight * 0.02,
                    ),
                  ),
                  Container(
                    width: screenWidth * 0.07,
                    height: screenWidth * 0.07,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade700,
                    ),
                    child: Icon(
                      Icons.arrow_right_alt_rounded,
                      size: screenWidth * 0.055,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
