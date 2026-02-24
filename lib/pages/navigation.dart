import 'package:flutter/material.dart';
import 'package:mobile_application/pages/homepage.dart';
import 'package:mobile_application/pages/UserCredentials/user_details.dart';
import 'package:mobile_application/pages/about.dart';

class MainNavigation extends StatefulWidget {
  final String token;
  final String baseUrl;
  final int initialIndex;

  const MainNavigation({
    Key? key,
    required this.token,
    required this.baseUrl,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _selectedIndex;
  bool _isOnProfilePage = false; // tracks if user is on profile page
  final GlobalKey<ScaffoldState> _profileScaffoldKey = GlobalKey<ScaffoldState>();

  @override
void initState() {
  super.initState();
  _selectedIndex = widget.initialIndex; // make sure initialIndex = 1 when calling MainNavigation
  _isOnProfilePage = widget.initialIndex == 1; // ✅ if starts on profile, show Menu icon
}

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePageContent(token: widget.token, baseUrl: widget.baseUrl),
      UserDetailsPageContent(
        token: widget.token,
        baseUrl: widget.baseUrl,
        scaffoldKey: _profileScaffoldKey,
      ),
      AboutPage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            // Shows Menu icon only when already on profile page
            icon: Icon(_isOnProfilePage ? Icons.menu : Icons.person),
            label: _isOnProfilePage ? 'Menu' : 'Profile',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'About',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF00674F),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 1) {
            if (!_isOnProfilePage) {
              // First tap: go to profile page, change icon to Menu
              setState(() {
                _selectedIndex = 1;
                _isOnProfilePage = true;
              });
            } else {
              // Second tap (now shows Menu): open the drawer
              _profileScaffoldKey.currentState?.openEndDrawer();
            }
          } else {
            // Home or About: reset profile state
            setState(() {
              _selectedIndex = index;
              _isOnProfilePage = false;
            });
          }
        },
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}