import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/favorite_service.dart';
import '../services/api_service.dart';
import '../services/voter_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Design System
  static const Color backgroundColor = Color(0xFF020205);
  static const Color accentColor = Color(0xFF3B82F6);
  static const Color cardColor = Color(0x33262626); // Glassmorphic background

  String? _favoriteProjectName;
  String _voterId = '';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final voterId = await VoterService.getVoterId();
    final favId = await FavoriteService.getFavoriteProjectId();

    String? favName;
    if (favId != null) {
      try {
        final projects = await ApiService().fetchProjects();
        final fav = projects.where((p) => p.id == favId).toList();
        if (fav.isNotEmpty) favName = fav.first.title;
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _voterId = voterId.substring(0, 8);
        _favoriteProjectName = favName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 36),
            // Favorite project card
            if (_favoriteProjectName != null) _buildFavoriteCard(),
            if (_favoriteProjectName != null) const SizedBox(height: 20),
            _buildInfoSection(),
            const SizedBox(height: 36),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
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
          'Evaluador',
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
          child: Text(
            'ID: $_voterId',
            style: const TextStyle(
              color: accentColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.redAccent.withAlpha(30)),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.redAccent.withAlpha(25),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Colors.redAccent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tu proyecto favorito',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _favoriteProjectName ?? '',
                      style:
                          TextStyle(color: Colors.grey.shade400, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
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
          subtitle: 'Plataforma de evaluación de proyectos académicos',
          gradient: [accentColor.withAlpha(15), accentColor.withAlpha(5)],
          iconColor: accentColor,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          icon: Icons.touch_app_rounded,
          title: 'Cómo evaluar',
          subtitle: 'Toca un proyecto, califica, comenta y etiqueta',
          gradient: [
            const Color(0xFFFBBF24).withAlpha(15),
            const Color(0xFFFBBF24).withAlpha(5),
          ],
          iconColor: const Color(0xFFFBBF24),
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          icon: Icons.favorite_border_rounded,
          title: 'Favoritos',
          subtitle: 'Marca 1 proyecto como favorito y sigue su posición',
          gradient: [
            Colors.redAccent.withAlpha(15),
            Colors.redAccent.withAlpha(5),
          ],
          iconColor: Colors.redAccent,
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withAlpha(25)),
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
                      style:
                          TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
