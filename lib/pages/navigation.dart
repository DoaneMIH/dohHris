// import 'package:flutter/material.dart';
// import 'package:mobile_application/pages/homepage.dart';
// import 'package:mobile_application/pages/UserCredentials/user_details.dart';
// import 'package:mobile_application/pages/about.dart';

// class MainNavigation extends StatefulWidget {
//   final String token;
//   final String baseUrl;
//   final int initialIndex;

//   const MainNavigation({
//     super.key,
//     required this.token,
//     required this.baseUrl,
//     this.initialIndex = 0,
//   });

//   @override
//   State<MainNavigation> createState() => _MainNavigationState();
// }

// class _MainNavigationState extends State<MainNavigation> {
//   late int _selectedIndex;
//   bool _isOnProfilePage = false;
//   final GlobalKey<ScaffoldState> _profileScaffoldKey =
//       GlobalKey<ScaffoldState>();

//   @override
//   void initState() {
//     super.initState();
//     _selectedIndex = widget.initialIndex;
//     _isOnProfilePage = widget.initialIndex == 1;
//   }

//   void _toggleDrawer() {
//     if (_profileScaffoldKey.currentState?.isEndDrawerOpen ?? false) {
//       Navigator.of(context).pop();
//     } else {
//       _profileScaffoldKey.currentState?.openEndDrawer();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     final List<Widget> pages = [
//       Homepage(token: widget.token, baseUrl: widget.baseUrl),
//       UserDetailsPageContent(
//         token: widget.token,   
//         baseUrl: widget.baseUrl,
//         scaffoldKey: _profileScaffoldKey,
//       ),
//       AboutPage(token: widget.token, baseUrl: widget.baseUrl),
//     ];

//     return Scaffold(
//       body: IndexedStack(index: _selectedIndex, children: pages),
//       bottomNavigationBar: BottomNavigationBar(
//         backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//         items: <BottomNavigationBarItem>[
//           const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//           BottomNavigationBarItem(
//             icon: Icon(_isOnProfilePage ? Icons.menu : Icons.person),
//             label: _isOnProfilePage ? 'Menu' : 'Profile',
//           ),
//           const BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About'),
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: Theme.of(context).brightness == Brightness.dark
//         ? Color(0xFF587CA5) // ←  in dark
//         : Theme.of(context).primaryColor,           // ←  in light
//         unselectedItemColor: isDark ? Colors.grey[500] : Colors.grey,
//         onTap: (index) {
//           if (index == 1) {
//             if (!_isOnProfilePage) {
//               setState(() {
//                 _selectedIndex = 1;
//                 _isOnProfilePage = true;
//               });
//             } else {
//               _toggleDrawer();
//             }
//           } else {
//             if (_profileScaffoldKey.currentState?.isEndDrawerOpen ?? false) {
//               Navigator.of(context).pop();
//             }
//             setState(() {
//               _selectedIndex = index;
//               _isOnProfilePage = false;
//             });
//           }
//         },
//         type: BottomNavigationBarType.fixed,
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:mobile_application/pages/homepage.dart';
import 'package:mobile_application/pages/UserCredentials/user_details.dart';
import 'package:mobile_application/pages/about.dart';

class MainNavigation extends StatefulWidget {
  final String token;
  final String baseUrl;
  final int initialIndex;

  const MainNavigation({
    super.key,
    required this.token,
    required this.baseUrl,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _selectedIndex;
  bool _isOnProfilePage = false;
  final GlobalKey<ScaffoldState> _profileScaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _isOnProfilePage = widget.initialIndex == 1;
  }

  void _toggleDrawer() {
    if (_profileScaffoldKey.currentState?.isEndDrawerOpen ?? false) {
      Navigator.of(context).pop();
    } else {
      _profileScaffoldKey.currentState?.openEndDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> pages = [
      Homepage(token: widget.token, baseUrl: widget.baseUrl),
      UserDetailsPageContent(
        token: widget.token,
        baseUrl: widget.baseUrl,
        scaffoldKey: _profileScaffoldKey,
      ),
      AboutPage(token: widget.token, baseUrl: widget.baseUrl),
    ];

    // Icon data for each tab
    final List<IconData> icons = [
      Icons.home_outlined,
      _isOnProfilePage ? Icons.menu : Icons.person_outline,
      Icons.info_outline,
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: _FloatingNavBar(
        isDark: isDark,
        selectedIndex: _selectedIndex,
        icons: icons,
        onTap: (index) {
          if (index == 1) {
            if (!_isOnProfilePage) {
              setState(() {
                _selectedIndex = 1;
                _isOnProfilePage = true;
              });
            } else {
              _toggleDrawer();
            }
          } else {
            if (_profileScaffoldKey.currentState?.isEndDrawerOpen ?? false) {
              Navigator.of(context).pop();
            }
            setState(() {
              _selectedIndex = index;
              _isOnProfilePage = false;
            });
          }
        },
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  final bool isDark;
  final int selectedIndex;
  final List<IconData> icons;
  final void Function(int) onTap;

  const _FloatingNavBar({
    required this.isDark,
    required this.selectedIndex,
    required this.icons,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final activeColor = isDark ? const Color(0xFF587CA5) : Theme.of(context).primaryColor;
    final activeCircleColor = activeColor.withOpacity(0.15);

    return SafeArea(
      child: Padding(
        // padding: const EdgeInsets.only(left: 24, right: 24, bottom: 4, top: 8),
        padding: EdgeInsets.zero,
        child: Container(
          height: 64,
          // decoration: BoxDecoration(
          //   color: bgColor,
          //   borderRadius: BorderRadius.circular(10),
          //   boxShadow: [
          //     BoxShadow(
          //       color: Colors.black.withOpacity(isDark ? 0.4 : 0.12),
          //       blurRadius: 20,
          //       offset: const Offset(0, 4),
          //     ),
          //   ],
          // ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(icons.length, (index) {
              final isSelected = index == selectedIndex;
              return GestureDetector(
                onTap: () => onTap(index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeInOut,
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isSelected ? activeCircleColor : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icons[index],
                    size: 24,
                    color: isSelected
                        ? activeColor
                        : (isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}