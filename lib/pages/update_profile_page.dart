import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:shepherd_mo/api/api_service.dart';
import 'package:shepherd_mo/controller/controller.dart';
import 'package:shepherd_mo/formatter/avatar.dart';
import 'package:shepherd_mo/models/user.dart';
import 'package:shepherd_mo/services/get_login.dart';
import 'package:shepherd_mo/utils/toast.dart';
import 'package:shepherd_mo/widgets/progressHUD.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  var roleController = TextEditingController();
  var emailController = TextEditingController();
  var fullNameController = TextEditingController();
  var phoneController = TextEditingController();
  final FocusNode roleFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode fullNameFocus = FocusNode();
  final FocusNode phoneFocus = FocusNode();
  bool isApiCallProcess = false;
  User? user; // To store the fetched user data
  late Future<User?> userFuture; // For storing the Future

  @override
  void initState() {
    super.initState();
    // Fetch the user details on initialization
    userFuture = fetchUserDetails();
  }

  @override
  void dispose() {
    roleController.dispose();
    emailController.dispose();
    fullNameController.dispose();
    phoneController.dispose();
    super.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RefreshController refreshController = Get.find();
      refreshController.setShouldRefresh(true);
    });
  }

  Future<User?> fetchUserDetails() async {
    final loginInfo = await getLoginInfoFromPrefs();
    if (loginInfo == null) {
      return null;
    }

    ApiService apiService = ApiService();
    final userDetails = await apiService.getUserDetails(loginInfo.id!);
    if (userDetails != null) {
      // Initialize controllers here
      roleController.text = userDetails.role ?? '';
      emailController.text = userDetails.email ?? '';
      fullNameController.text = userDetails.name ?? '';
      phoneController.text = userDetails.phone ?? '';
      setState(() {
        user = userDetails; // Update the local user state
      });
    }
    return userDetails;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          localizations.editProfile,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: FutureBuilder<User?>(
        future: userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text(localizations.noData));
          } else {
            // Pass the user data to the UI setup
            return _uiSetup(snapshot.data!, context);
          }
        },
      ),
    );
  }

  Widget _uiSetup(User loginInfo, BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    ApiService apiService = ApiService();
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final localizations = AppLocalizations.of(context)!;

    return ProgressHUD(
        inAsyncCall: isApiCallProcess,
        opacity: 0.3,
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: AvatarFormat().getRandomAvatarColor(),
                    radius: screenHeight * 0.065,
                    child: Text(
                      AvatarFormat().getInitials(user!.name!, twoLetters: true),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.1,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Form(
                    key: globalFormKey,
                    child: Column(
                      children: [
                        SizedBox(
                          width: screenWidth * 0.8,
                          child: TextFormField(
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            focusNode: roleFocus,
                            controller: roleController,
                            readOnly: true,
                            validator: (value) {
                              if (value!.trim().isEmpty) {
                                return localizations.required;
                              }

                              return null;
                            },
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: localizations.role,
                              hintText:
                                  '${localizations.enter} ${localizations.role.toLowerCase()}',
                              prefixIcon: Icon(Icons.person,
                                  color: isDark ? Colors.white : Colors.black),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        SizedBox(
                          width: screenWidth * 0.8,
                          child: TextFormField(
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            focusNode: emailFocus,
                            controller: emailController,
                            readOnly: true,
                            validator: (value) {
                              if (value!.trim().isEmpty) {
                                return localizations.required;
                              }

                              return null;
                            },
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: 'Email',
                              hintText: '${localizations.enter} Email}',
                              prefixIcon: Icon(Icons.email,
                                  color: isDark ? Colors.white : Colors.black),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        SizedBox(
                          width: screenWidth * 0.8,
                          child: StatefulBuilder(
                            builder: (context, setState) {
                              String?
                                  phoneError; // Track dynamic validation error
                              return TextFormField(
                                keyboardType: TextInputType.phone,
                                focusNode: phoneFocus,
                                controller: phoneController,
                                onChanged: (value) {
                                  setState(() {
                                    // Validate the phone number dynamically
                                    if (value.trim().isEmpty) {
                                      phoneError = localizations.required;
                                    } else if (!isPhoneNumberValid(
                                        value.trim())) {
                                      phoneError = localizations.invalidPhone;
                                    } else {
                                      phoneError = null; // Clear error if valid
                                      // Dynamically format the number
                                      final formattedNumber =
                                          formatPhoneNumber(value);
                                      phoneController.value = TextEditingValue(
                                        text: formattedNumber,
                                        selection: TextSelection.collapsed(
                                            offset: formattedNumber.length),
                                      );
                                    }
                                  });
                                },
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  labelText: localizations.phone,
                                  hintText:
                                      '${localizations.enter} ${localizations.phone.toLowerCase()}',
                                  errorText:
                                      phoneError, // Display dynamic validation error
                                  prefixIcon: Icon(Icons.phone,
                                      color:
                                          isDark ? Colors.white : Colors.black),
                                  suffixIcon: phoneController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () {
                                            phoneController.clear();
                                            setState(() {
                                              phoneError =
                                                  null; // Clear error on clear
                                            });
                                          },
                                        )
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        SizedBox(
                          width: screenWidth * 0.8,
                          child: TextFormField(
                            focusNode: fullNameFocus,
                            controller: fullNameController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return localizations.required;
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: localizations.fullName,
                              hintText:
                                  '${localizations.enter} ${localizations.fullName.toLowerCase()}',
                              prefixIcon: Icon(LineAwesomeIcons.user,
                                  color: isDark ? Colors.white : Colors.black),
                              suffixIcon: fullNameController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        fullNameController.clear();
                                      },
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: screenWidth * 0.8,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (validateAndSave()) {
                                setState(() {
                                  isApiCallProcess = true;
                                });

                                final id = loginInfo.id;
                                final updatedUser = User(
                                  name: fullNameController.text,
                                  phone: phoneController.text,
                                  role: roleController.text,
                                  email: emailController.text,
                                  id: id,
                                );

                                final success =
                                    await apiService.updateUser(updatedUser);

                                setState(() {
                                  isApiCallProcess = false;
                                });

                                if (success) {
                                  showToast(
                                      '${localizations.editProfile} ${localizations.success.toLowerCase()}');
                                  Get.back(id: 4);
                                } else {
                                  showToast(
                                      '${localizations.editProfile} ${localizations.unsuccess.toLowerCase()}');
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              side: BorderSide.none,
                              shape: const StadiumBorder(),
                            ),
                            child: Text(
                              localizations.editProfile,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 20),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  bool validateAndSave() {
    final form = globalFormKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  bool isPhoneNumberValid(String phoneNumber) {
    final RegExp regex = RegExp(r'^\d{3}-?\d{3}-?\d{4}$');
    return regex.hasMatch(phoneNumber);
  }

  String formatPhoneNumber(String phoneNumber) {
    // Remove any non-digit characters
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Ensure there are exactly 10 digits
    if (digitsOnly.length != 10) {
      return phoneNumber; // Return the original input if not valid
    }

    // Format as 000-000-0000
    return '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3, 6)}-${digitsOnly.substring(6)}';
  }
}
