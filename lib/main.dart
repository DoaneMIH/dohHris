import 'package:flutter/material.dart';
import 'package:mobile_application/widgets/routes.dart';
import 'package:mobile_application/widgets/splash.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HRIS Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
     
        useMaterial3: true,
      ),
       home: Splash2(),
      initialRoute: MyRoutes.splashPage,
      routes: MyRoutes.routes,
      
    );
  }
}