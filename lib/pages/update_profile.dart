import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:shepherd_mo/api/api_service.dart';
import 'package:shepherd_mo/models/user.dart';
import 'package:shepherd_mo/services/get_login.dart';
import 'package:shepherd_mo/widgets/progressHUD.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({Key? key}) : super(key: key);

  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  late User user;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Edit Profile',
            style: Theme.of(context).textTheme.headlineMedium),
        actions: const [],
      ),
      body: FutureBuilder(
        future: Future.wait([
          getLoginInfoFromPrefs(),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final loginInfo = snapshot.data! as User?;

            if (loginInfo != null) {
              return _uiSetup(loginInfo, context);
            } else {
              return const Center(child: Text('Login information is missing.'));
            }
          }
        },
      ),
    );
  }

  Widget _uiSetup(User loginInfo, BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    var fullNameController = TextEditingController();
    var phoneController = TextEditingController();
    final FocusNode fullNameFocus = FocusNode();
    final FocusNode phoneFocus = FocusNode();
    ApiService apiService = ApiService();
    bool isApiCallProcess = false;
    String initialName = loginInfo.name;
    String initialPhone = loginInfo.phone;
    fullNameController.text = initialName;
    phoneController.text = initialPhone;
    ImageProvider<Object> backgroundImage =
        const AssetImage('assets/images/user.png');
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
                    radius: 60,
                    backgroundImage: backgroundImage,
                    backgroundColor: Colors.orange,
                  ),
                  const SizedBox(height: 50),
                  Form(
                    key: globalFormKey,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 350,
                          child: TextFormField(
                            focusNode: fullNameFocus,
                            controller: fullNameController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'This field is required.';
                              }
                              return null;
                            },
                            onSaved: (input) {
                              setState(() {
                                if (input!.trim() != initialName) {
                                  fullNameController.text = input;
                                  user.name = input.trim();
                                } else {
                                  user.name = '';
                                }
                              });
                            },
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: 'Full Name',
                              prefixIcon: Icon(LineAwesomeIcons.user,
                                  color: isDark ? Colors.white : Colors.black),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 350,
                          child: TextFormField(
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            focusNode: phoneFocus,
                            controller: phoneController,
                            validator: (value) {
                              if (value!.trim().isEmpty) {
                                return 'This field is required.';
                              }
                              if (!isPhoneNumberValid(value.trim())) {
                                return 'Invalid phone number!';
                              }
                              return null;
                            },
                            onSaved: (input) {
                              setState(() {
                                if (input!.trim() != initialPhone) {
                                  user.phone = input.trim();
                                } else {
                                  user.phone = '';
                                }
                              });
                            },
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: 'Phone',
                              prefixIcon: Icon(Icons.phone,
                                  color: isDark ? Colors.white : Colors.black),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 350,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (validateAndSave()) {
                                if (user.name.isNotEmpty ||
                                    user.phone.isNotEmpty) {
                                  setState(() {
                                    isApiCallProcess = true;
                                  });
                                  final id = loginInfo.id;
                                  final statusCode = 1;
                                  //await apiService.updateUser(id!, user);
                                  if (statusCode == 200) {
                                    Fluttertoast.showToast(
                                      msg: "Updated Profile Successfully",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.green,
                                      textColor: Colors.white,
                                      fontSize: 16.0,
                                    );

                                    Get.back();
                                  } else {
                                    print('Error Code: $statusCode');
                                  }
                                } else {
                                  Fluttertoast.showToast(
                                    msg: "You didn't edit anything!",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              side: BorderSide.none,
                              shape: const StadiumBorder(),
                            ),
                            child: const Text(
                              'Edit Profile',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 20),
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
    final RegExp regex = RegExp(r'^(?:\+[0-9])?[0-9]{10}$');
    return regex.hasMatch(phoneNumber);
  }
}
