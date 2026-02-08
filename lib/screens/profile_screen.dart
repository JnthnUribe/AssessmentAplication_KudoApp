import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 32),

            // Avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF3B82F6),
                    const Color(0xFF3B82F6).withAlpha(127),
                  ],
                ),
              ),
              child: const Icon(Icons.person, size: 56, color: Colors.white),
            ),
            const SizedBox(height: 24),

            // Guest text
            const Text(
              'Guest Voter',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'You are voting anonymously',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 48),

            // Info cards
            _buildInfoCard(
              icon: Icons.info_outline,
              title: 'About KUDO',
              subtitle: 'Academic project voting platform',
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              icon: Icons.school,
              title: 'University Fair 2025',
              subtitle: 'Vote for your favorite projects!',
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              icon: Icons.how_to_vote,
              title: 'How to Vote',
              subtitle: 'Tap a project and rate it 1-5 stars',
            ),

            const Spacer(),

            // Version
            const Text(
              'KUDO v1.0.0 MVP',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            const Text(
              'Made with ♥ for education',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withAlpha(51),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF3B82F6)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
