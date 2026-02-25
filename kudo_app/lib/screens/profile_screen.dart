import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Design System
  static const Color backgroundColor = Color(0xFF0B1221);
  static const Color accentColor = Color(0xFF3B82F6);
  static const Color cardColor = Color(0xFF111827);
  static const Color surfaceColor = Color(0xFF1E293B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
        child: Column(
          children: [
            // Avatar + Name
            _buildProfileHeader(),
            const SizedBox(height: 36),
            // Quick stats
            _buildQuickStats(),
            const SizedBox(height: 28),
            // Info cards
            _buildInfoSection(),
            const SizedBox(height: 36),
            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        // Avatar
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [accentColor, accentColor.withAlpha(150)],
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withAlpha(40),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_rounded,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Votante Invitado',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: accentColor.withAlpha(20),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Modo anónimo',
            style: TextStyle(
              color: accentColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        _buildStatChip(Icons.how_to_vote_rounded, '0', 'Votos'),
        const SizedBox(width: 10),
        _buildStatChip(Icons.star_rounded, '-', 'Prom.'),
        const SizedBox(width: 10),
        _buildStatChip(Icons.visibility_rounded, '5', 'Vistos'),
      ],
    );
  }

  Widget _buildStatChip(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withAlpha(6)),
        ),
        child: Column(
          children: [
            Icon(icon, color: accentColor, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      children: [
        _buildInfoCard(
          icon: Icons.rocket_launch_rounded,
          title: 'Acerca de KUDO',
          subtitle: 'Plataforma de votación de proyectos académicos',
          gradient: [accentColor.withAlpha(15), accentColor.withAlpha(5)],
          iconColor: accentColor,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          icon: Icons.school_rounded,
          title: 'Feria Universitaria 2025',
          subtitle: '¡Vota por tus proyectos favoritos!',
          gradient: [
            const Color(0xFF10B981).withAlpha(15),
            const Color(0xFF10B981).withAlpha(5),
          ],
          iconColor: const Color(0xFF10B981),
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          icon: Icons.touch_app_rounded,
          title: 'Cómo votar',
          subtitle: 'Toca un proyecto y califica de 1 a 5 estrellas',
          gradient: [
            const Color(0xFFFBBF24).withAlpha(15),
            const Color(0xFFFBBF24).withAlpha(5),
          ],
          iconColor: const Color(0xFFFBBF24),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(6)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: iconColor.withAlpha(25),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: iconColor, size: 22),
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
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: Colors.grey.shade700,
            size: 22,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'KUDO v1.0.0',
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Hecho con ♥ para la educación',
          style: TextStyle(color: Colors.grey.shade800, fontSize: 12),
        ),
      ],
    );
  }
}
