 import 'package:flutter/material.dart';
import 'package:mobile_application/pages/login_page.dart';
import 'package:mobile_application/widgets/splash.dart';

class MyRoutes {
  static const String splashPage = "/splash";
  static const String loginPage = "/login_page";
 
 static final routes = <String, WidgetBuilder>{
    splashPage: (context) => Splash2(),
    loginPage: (context) => const LoginPage(),

 };
}