// import 'package:flutter/material.dart';
// import 'package:mobile_application/pages/homepage.dart';
// import 'package:mobile_application/pages/user_details.dart';


// class MainNavigation extends StatefulWidget {
//   final String token;
//   final String baseUrl;
//   final int initialIndex;

//   const MainNavigation({
//     Key? key,
//     required this.token,
//     required this.baseUrl,
//     this.initialIndex = 1, // Default to Profile page
//   }) : super(key: key);

//   @override
//   State<MainNavigation> createState() => _MainNavigationState();
// }

// class _MainNavigationState extends State<MainNavigation> {
//   late int _selectedIndex;

//   @override
//   void initState() {
//     super.initState();
//     _selectedIndex = widget.initialIndex;
//     print('🎯 [MainNavigation] Initialized with index: $_selectedIndex');
//   }

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//     print('📱 [MainNavigation] Tab changed to index: $index');
//   }

//   @override
//   Widget build(BuildContext context) {
//     // List of pages to display
//     final List<Widget> pages = [
//       HomePageContent(token: widget.token, baseUrl: widget.baseUrl),
//       UserDetailsPageContent(token: widget.token, baseUrl: widget.baseUrl),
//       // Add more pages here as needed
//     ];

//     return Scaffold(
//       body: IndexedStack(
//         index: _selectedIndex,
//         children: pages,
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Profile',
//           ),
          
//           // Add more BottomNavigationBarItem here when you need more tabs
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: Colors.green,
//         unselectedItemColor: Colors.grey,
//         onTap: _onItemTapped,
//         type: BottomNavigationBarType.fixed,
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:mobile_application/pages/homepage.dart';
import 'package:mobile_application/pages/user_details.dart';

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
  final GlobalKey<ScaffoldState> _profileScaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePageContent(token: widget.token, baseUrl: widget.baseUrl),
      UserDetailsPageContent(
        token: widget.token,
        baseUrl: widget.baseUrl,
        scaffoldKey: _profileScaffoldKey, // ← pass as named param, NOT widget key
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
        ],
        currentIndex: _selectedIndex == 1 ? 1 : 0,
        selectedItemColor: const Color(0xFF00674F),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 1) {
            setState(() => _selectedIndex = 1);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _profileScaffoldKey.currentState?.openEndDrawer();
            });
          } else {
            setState(() => _selectedIndex = index);
          }
        },
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}