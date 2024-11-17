import 'package:flutter/material.dart';
import 'package:shepherd_mo/pages/home_page.dart';
import 'package:shepherd_mo/pages/login_page.dart';
import 'package:shepherd_mo/utils/toast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TokenCheckPage extends StatelessWidget {
  final bool isTokenExpired;
  const TokenCheckPage({super.key, required this.isTokenExpired});

  @override
  Widget build(BuildContext context) {
    // Display toast message if the token is expired
    if (isTokenExpired) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final tokenExpiredMessage = AppLocalizations.of(context)?.tokenExpired;
        if (tokenExpiredMessage != null) {
          showToast(tokenExpiredMessage);
        }
      });
    }

    return isTokenExpired ? const LoginPage() : const HomePage();
  }
}
