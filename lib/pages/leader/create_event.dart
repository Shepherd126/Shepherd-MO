import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:shepherd_mo/models/event.dart';
import 'package:shepherd_mo/providers/provider.dart';
import 'package:shepherd_mo/widgets/custom_checkbox.dart';
import 'package:shepherd_mo/widgets/datetime_picker.dart';
import 'package:shepherd_mo/widgets/progressHUD.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shepherd_mo/widgets/search_dialog.dart';
import 'package:shepherd_mo/widgets/search_widget.dart';

class CreateEditEventPage extends StatefulWidget {
  final Event? event; // If event is provided, the page is for editing

  const CreateEditEventPage({super.key, this.event});

  @override
  _CreateEditEventPageState createState() => _CreateEditEventPageState();
}

class _CreateEditEventPageState extends State<CreateEditEventPage> {
  final _formKey = GlobalKey<FormState>();
  var eventNameController = TextEditingController();
  var descriptionController = TextEditingController();
  var totalCostController = TextEditingController();
  var ceremonyController = TextEditingController();
  var groupController = TextEditingController();
  final FocusNode _eventFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();
  final FocusNode _ceremonyFocus = FocusNode();
  final FocusNode _groupFocus = FocusNode();
  final FocusNode _totalCostFocus = FocusNode();
  DateTime? fromDate;
  DateTime? toDate;
  TimeOfDay? fromTime;
  TimeOfDay? toTime;
  bool isPublic = false;
  late Event event;
  bool isApiCallProcess = false;
  final CurrencyTextInputFormatter formatter =
      CurrencyTextInputFormatter.currency(
    locale: 'vi',
    decimalDigits: 0,
    symbol: ' VND',
  );

  @override
  void initState() {
    super.initState();
    event = Event();
  }

  @override
  void dispose() {
    eventNameController.dispose();
    descriptionController.dispose();
    totalCostController.dispose();
    ceremonyController.dispose();
    groupController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate
          ? (fromDate ?? DateTime.now())
          : (toDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      inAsyncCall: isApiCallProcess,
      opacity: 0.3,
      child: _uiSetup(context),
    );
  }

  Widget _uiSetup(BuildContext context) {
    final uiProvider = Provider.of<UIProvider>(context);
    bool isDark = uiProvider.themeMode == ThemeMode.dark ||
        (uiProvider.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.event == null
              ? '${AppLocalizations.of(context)!.create} ${AppLocalizations.of(context)!.event}'
              : '${AppLocalizations.of(context)!.edit} ${AppLocalizations.of(context)!.event}',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                AppLocalizations.of(context)!.name,
                style: const TextStyle(fontSize: 16.0),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    focusNode: _eventFocus,
                    controller: eventNameController,
                    validator: (value) {
                      if (value!.trim().isEmpty) {
                        return AppLocalizations.of(context)!.required;
                      }
                      return null;
                    },
                    onSaved: (input) {
                      event.eventName = input!.trim();
                    },
                    decoration: InputDecoration(
                      icon: const Icon(
                        Icons.event,
                      ),
                      border: InputBorder.none,
                      labelText: AppLocalizations.of(context)!.name,
                      hintText: AppLocalizations.of(context)!.eventNameHint,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                AppLocalizations.of(context)!.dateAndTime,
                style: const TextStyle(fontSize: 16.0),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  DatePickerField(
                    label: AppLocalizations.of(context)!.startDate,
                    hintText:
                        '${AppLocalizations.of(context)!.enter} ${AppLocalizations.of(context)!.startDate.toLowerCase()}',
                    onDateSelected: (DateTime? date) {
                      fromDate = date;
                    },
                  ),
                  const SizedBox(width: 10),
                  TimePickerField(
                    label: AppLocalizations.of(context)!.startTime,
                    hintText:
                        '${AppLocalizations.of(context)!.enter} ${AppLocalizations.of(context)!.startTime.toLowerCase()}',
                    onTimeSelected: (TimeOfDay? time) {
                      fromTime = time;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  DatePickerField(
                    label: AppLocalizations.of(context)!.endDate,
                    hintText:
                        '${AppLocalizations.of(context)!.enter} ${AppLocalizations.of(context)!.endDate.toLowerCase()}',
                    onDateSelected: (DateTime? date) {
                      toDate = date;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return AppLocalizations.of(context)!.required;
                      }
                      if (fromDate != null) {
                        DateTime endDate = DateTime.parse(value);
                        if (endDate.isBefore(fromDate!)) {
                          return 'End Date cannot be before Start Date!';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(width: 10),
                  TimePickerField(
                    label: AppLocalizations.of(context)!.endTime,
                    hintText:
                        '${AppLocalizations.of(context)!.enter} ${AppLocalizations.of(context)!.endTime.toLowerCase()}',
                    onTimeSelected: (TimeOfDay? time) {
                      toTime = time;
                    },
                    validator: (value) {
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                AppLocalizations.of(context)!.description,
                style: const TextStyle(fontSize: 16.0),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    minLines: 4,
                    maxLines: null,
                    focusNode: _descriptionFocus,
                    controller: descriptionController,
                    validator: (value) {
                      if (value!.trim().isEmpty) {
                        return AppLocalizations.of(context)!.required;
                      }
                      return null;
                    },
                    onSaved: (input) {
                      event.description = input!.trim();
                    },
                    decoration: InputDecoration(
                        icon: const Icon(
                          Icons.description_outlined,
                        ),
                        border: InputBorder.none,
                        labelText: AppLocalizations.of(context)!.description,
                        hintText: AppLocalizations.of(context)!.descriptionHint,
                        alignLabelWithHint: false),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              CustomCheckboxField(
                enabledIcon: const Icon(Icons.public),
                disabledIcon: const Icon(Icons.public_off),
                enabledLabel: AppLocalizations.of(context)!.public,
                disabledLabel: AppLocalizations.of(context)!.private,
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    focusNode: _totalCostFocus,
                    controller: totalCostController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter an amount";
                      } else if (value.startsWith('0')) {
                        return "Amount cannot start with zero";
                      }
                      return null;
                    },
                    inputFormatters: <TextInputFormatter>[formatter],
                    onChanged: (value) {
                      print(formatter.getUnformattedValue()); // 2000.00
                    },
                    onSaved: (input) {
                      event.totalCost =
                          formatter.getUnformattedValue().toDouble();
                    },
                    decoration: InputDecoration(
                      icon: const Icon(
                        Icons.event,
                      ),
                      border: InputBorder.none,
                      labelText: AppLocalizations.of(context)!.totalCost,
                      hintText:
                          '${AppLocalizations.of(context)!.enter} ${AppLocalizations.of(context)!.totalCost.toLowerCase()}',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    readOnly: true,
                    focusNode: _ceremonyFocus,
                    controller: ceremonyController,
                    onTap: () {
                      showCeremonyDialog(context);
                    },
                    decoration: InputDecoration(
                      icon: const Icon(Icons.event_available),
                      border: InputBorder.none,
                      labelText: AppLocalizations.of(context)!.ceremony,
                      hintText:
                          '${AppLocalizations.of(context)!.enter} ${AppLocalizations.of(context)!.ceremony.toLowerCase()}',
                      // Conditionally add a clear icon at the end
                      suffixIcon: ceremonyController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                ceremonyController
                                    .clear(); // Clear the controller's text
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    readOnly: true,
                    focusNode: _groupFocus,
                    controller: groupController,
                    onTap: () {
                      showGroupDialog(context);
                    },
                    decoration: InputDecoration(
                      icon: const Icon(
                        Icons.people,
                      ),
                      border: InputBorder.none,
                      labelText: AppLocalizations.of(context)!.group,
                      hintText:
                          '${AppLocalizations.of(context)!.enter} ${AppLocalizations.of(context)!.group.toLowerCase()}',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  print(event.toString());
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.orange),
                ),
                child: Text(
                  widget.event == null ? 'Create Event' : 'Update Event',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to show the dialog
  void showCeremonyDialog(BuildContext context) async {
    final ceremony = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return const SearchListDialog();
      },
    );

    if (ceremony != null) {
      event.ceremonyId = ceremony["id"].toString();
      ceremonyController.text = ceremony["name"];
    }
  }

  void showGroupDialog(BuildContext context) async {
    final groups = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return const GroupListDialog(apiToken: 'String');
      },
    );
  }
}
