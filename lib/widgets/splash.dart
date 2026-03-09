import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile_application/widgets/routes.dart';

/// Splash screen shown at app startup to check session status; either navigates to home if logged in or login if not.
class Splash2 extends StatefulWidget {
  /// If true, skip the 5-second splash delay and navigate directly to home; used when user session is already valid.
  final bool skipToHome;
  
  const Splash2({super.key, this.skipToHome = false});

  @override
  State<Splash2> createState() => _Splash2State();
}

/// State class that handles the delayed navigation logic and prevents back button navigation.
class _Splash2State extends State<Splash2> {
  @override
  void initState() {
    super.initState();
 
    // If user is already logged in, navigate immediately
    // Otherwise wait 5 seconds for splash screen
    final delayDuration = widget.skipToHome 
        ? Duration.zero 
        : const Duration(seconds: 5);
    
    Future.delayed(delayDuration, () {
      if (mounted) {
        if (widget.skipToHome) {
          // User already logged in, go directly to home page
          // Remove splash from stack so back button won't show splash
          Navigator.of(context).pushReplacementNamed(MyRoutes.homePage);
        } else {
          // New user, show login page
          // Remove splash from stack so back button won't show splash
          Navigator.of(context).pushReplacementNamed(MyRoutes.loginPage);
        }
      }
    });
  }


@override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // Exit the app instead of navigating back
        exit(0);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;

              // Responsive sizes
              final containerW = (w * 0.85).clamp(260.0, 420.0);
              final containerH = (containerW * 0.58).clamp(180.0, 260.0);

              // Make logo size responsive too
              (containerH * 0.75).clamp(120.0, 220.0);

              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    width: containerW,
                    height: containerH,
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Center(
                      child: ClipRRect(
                        child: Image.asset(
                          'assets/images/welcomelogo.png',
                          width: 400,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               margin: const EdgeInsets.all(16),
//               width: 480,
//               height: 280,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 boxShadow: [
//                   BoxShadow(
//                     color: const Color.fromARGB(255, 242, 242, 242).withOpacity(0.5),
//                     blurRadius: 50,
//                     offset: const Offset(0, 3), // changes position of shadow
//                   ),
//                 ],
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(500),
//                   child: Image.asset(
//                     'assets/images/welcomelogo.png',
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(
//               height: 20,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }