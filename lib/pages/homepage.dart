import 'package:flutter/material.dart';

class HomePageContent extends StatelessWidget {
  final String token;
  final String baseUrl;

  const HomePageContent({
    Key? key,
    required this.token,
    required this.baseUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Home'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.home_outlined,
                size: 100,
                color: Colors.green.shade300,
              ),
              const SizedBox(height: 24),
              const Text(
                'Welcome to Home Page',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'This is a placeholder for your home page content.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.info_outline, color: Colors.blue),
                        title: const Text('Coming Soon'),
                        subtitle: const Text('Home page features will be added here'),
                      ),
                      const Divider(),
                      ListTile(
                        leading: Icon(Icons.dashboard, color: Colors.orange),
                        title: const Text('Dashboard'),
                        subtitle: const Text('View your statistics and insights'),
                      ),
                      const Divider(),
                      ListTile(
                        leading: Icon(Icons.notifications, color: Colors.red),
                        title: const Text('Notifications'),
                        subtitle: const Text('Stay updated with latest alerts'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 80), // Extra padding for bottom nav
            ],
          ),
        ),
      ),
    );
  }
}