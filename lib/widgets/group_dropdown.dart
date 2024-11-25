import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shepherd_mo/models/group_role.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shepherd_mo/providers/ui_provider.dart';

class GroupDropdown extends StatelessWidget {
  final List<GroupRole> userGroups;
  final String? selectedOrganization;
  final Function(String?) onChanged;

  const GroupDropdown({
    Key? key,
    required this.userGroups,
    required this.selectedOrganization,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final localizations = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.orangeAccent
              : Colors.orange.shade600,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(localizations.allCurrentlyUserOrganizations),
          value: selectedOrganization,
          isExpanded: true,
          focusColor: Colors.orange,
          icon: const Icon(Icons.arrow_drop_down),
          iconSize: screenHeight * 0.025,
          dropdownColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : Colors.white,
          style: TextStyle(
            fontSize: screenHeight * 0.016,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          items: [
            DropdownMenuItem<String>(
              value: "All", // Special value for "All" option
              child: Row(
                children: [
                  const Icon(Icons.group),
                  SizedBox(width: screenWidth * 0.03),
                  Text(localizations.allCurrentlyUserOrganizations),
                ],
              ),
            ),
            ...userGroups.map((GroupRole userGroup) {
              return DropdownMenuItem<String>(
                value: userGroup.groupId,
                child: Row(
                  children: [
                    const Icon(Icons.group),
                    SizedBox(width: screenWidth * 0.03),
                    Text(userGroup.groupName),
                  ],
                ),
              );
            }).toList(),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
