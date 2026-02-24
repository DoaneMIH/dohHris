import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header bar ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF2C5F4F),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: const Text(
                'ABOUT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
      
            // ── Body wrapped in SingleChildScrollView (fixes overflow) ──
            SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo
                  Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF2C5F4F).withOpacity(0.08),
                        border: Border.all(
                          color: const Color(0xFF2C5F4F).withOpacity(0.25),
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Image.asset(
                          'assets/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
      
                  const SizedBox(height: 16),
      
                  // App name
                  const Text(
                    'DOH WV CHD HRIS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2C5F4F),
                      letterSpacing: 0.8,
                    ),
                  ),
      
                  const SizedBox(height: 4),
      
                  // Subtitle
                  Text(
                    'Human Resource Information System',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
      
                  const SizedBox(height: 10),
      
                  // Version badge
                  _buildBadge('Version 1.0.0', const Color(0xFF2C5F4F)),
      
                  const SizedBox(height: 28),
                  const Divider(),
                  const SizedBox(height: 20),
      
                  // ── Contact & Organization Info ──────────────────────
                  _buildInfoRow(
                    Icons.business,
                    'Organization',
                    'Department of Health\nWestern Visayas Center for Health Development',
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.location_on_outlined,
                    'Address',
                    'Q. Abeto St., Mandurriao, Iloilo City, 5000',
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.phone_outlined,
                    'Contact',
                    '(033) 321-2356',
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.email_outlined,
                    'Email',
                    'dohro6@doh.gov.ph',
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.language_outlined,
                    'Website',
                    'www.doh.gov.ph',
                  ),
      
                  const SizedBox(height: 28),
                  const Divider(),
                  const SizedBox(height: 20),
      
                  // ── App Details ──────────────────────────────────────
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'APPLICATION DETAILS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500],
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildDetailRow('App Version', '1.0.0'),
                  _buildDetailRow('Platform', 'Android / iOS'),
                  _buildDetailRow('Developer', 'ICTU — DOH WV CHD'),
                  _buildDetailRow('Last Updated', 'June 2025'),
                  _buildDetailRow('Data Privacy', 'RA 10173 Compliant'),
      
                  const SizedBox(height: 28),
                  const Divider(),
                  const SizedBox(height: 20),
      
                  // ── Key Features ─────────────────────────────────────
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'KEY FEATURES',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500],
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildFeatureItem(Icons.person_outline,       'Personal Information Management'),
                  _buildFeatureItem(Icons.family_restroom,      'Family Background Records'),
                  _buildFeatureItem(Icons.school_outlined,      'Educational Background'),
                  _buildFeatureItem(Icons.verified_outlined,    'Civil Service Eligibility'),
                  _buildFeatureItem(Icons.work_outline,         'Work Experience'),
                  _buildFeatureItem(Icons.volunteer_activism,   'Voluntary Work'),
                  _buildFeatureItem(Icons.psychology_outlined,  'Learning & Development'),
                  _buildFeatureItem(Icons.people_alt_outlined,  'Person References'),
                  _buildFeatureItem(Icons.access_time,          'Daily Time Record (DTR)'),
      
                  const SizedBox(height: 28),
                  const Divider(),
                  const SizedBox(height: 16),
      
                  // Footer
                  Text(
                    '© ${DateTime.now().year} DOH WV CHD. All rights reserved.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Developed by ICTU',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Reusable Widgets ─────────────────────────────────────────────────────

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF2C5F4F)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF2C5F4F).withOpacity(0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF2C5F4F)),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}