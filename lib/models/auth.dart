class LoginResponseModel {
  String token;
  final String? errorMessage;

  LoginResponseModel({
    required this.token,
    this.errorMessage,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      token: json['token'],
    );
  }
}

class LoginRequestModel {
  String? email;
  String? password;
  String? deviceToken;

  LoginRequestModel({this.email, this.password, this.deviceToken});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'Email': email?.trim(),
      'Password': password?.trim(),
      'deviceToken': deviceToken?.trim(),
    };
    return map;
  }
}

class RegisterResponseModel {
  String token;
  final String? errorMessage;

  RegisterResponseModel({
    required this.token,
    this.errorMessage,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      token: json['token'],
    );
  }
}

class RegisterRequestModel {
  String? email;
  String? password;
  String? phone;
  String? deviceToken;

  RegisterRequestModel({this.email, this.password, this.deviceToken});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'Email': email?.trim(),
      'Password': password?.trim(),
      'Phone': phone?.trim(),
      'deviceToken': deviceToken?.trim(),
    };
    return map;
  }
}
