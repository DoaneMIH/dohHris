import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile_application/pages/homepage.dart';
import 'package:mobile_application/pages/UserCredentials/user_details.dart';
import 'package:mobile_application/pages/about.dart';

/// Main navigation container with bottom tab bar for switching between Home, Profile, and About sections.
class MainNavigation extends StatefulWidget {
  final String token;
  final String baseUrl;
  /// Index of the initially selected tab (0=Home, 1=Profile, 2=About).
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
  /// Tracks which tab is currently selected to display the correct page.
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

// Check if drawer is currently open
  void _toggleDrawer() {
    if (_profileScaffoldKey.currentState?.isEndDrawerOpen ?? false) {
      Navigator.of(context).pop();
    } else {
      _profileScaffoldKey.currentState?.openEndDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      Homepage(token: widget.token, baseUrl: widget.baseUrl),
      UserDetailsPageContent(
        token: widget.token,
        baseUrl: widget.baseUrl,
        scaffoldKey: _profileScaffoldKey,
      ),
      
     AboutPage(token: widget.token, baseUrl: widget.baseUrl),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        
        // Close drawer if open
        if (_profileScaffoldKey.currentState?.isEndDrawerOpen ?? false) {
          Navigator.of(context).pop();
          return;
        }
        
        // Exit the app when back is pressed
        exit(0);
      },
      child: Scaffold(
        body: IndexedStack(index: _selectedIndex, children: pages),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          items: <BottomNavigationBarItem>[
            const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(_isOnProfilePage ? Icons.menu : Icons.person),
              label: _isOnProfilePage ? 'Menu' : 'Profile',
            ),
            const BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF2C5F4F),
          unselectedItemColor: Colors.grey,
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
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}