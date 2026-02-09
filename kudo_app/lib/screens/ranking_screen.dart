import 'dart:async';
import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/api_service.dart';

/// Pantalla de Ranking - Muestra proyectos ordenados por votos
class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  // Colores del Design System
  static const Color backgroundColor = Color(0xFF0B1221);
  static const Color cardColor = Color(0xFF1E293B);
  static const Color accentColor = Color(0xFF3B82F6);

  final ApiService _apiService = ApiService();
  List<Project> _ranking = [];
  bool _isLoading = true;
  String? _error;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadRanking();
    // Poll every 10 seconds
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _loadRanking(silent: true);
    });
  }

  Future<void> _loadRanking({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      // Por ahora usamos fetchProjects ya que no hay endpoint de ranking
      final projects = await _apiService.fetchProjects();
      // Ordenar por totalVotes descendente
      projects.sort((a, b) => b.totalVotes.compareTo(a.totalVotes));
      setState(() {
        _ranking = projects;
        _isLoading = false;
      });
    } catch (e) {
      if (!silent) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events, color: Color(0xFFFBBF24)),
            SizedBox(width: 8),
            Text(
              'Ranking',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          // Live indicator
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withAlpha(51),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.circle, size: 8, color: Color(0xFF10B981)),
                SizedBox(width: 6),
                Text(
                  'LIVE',
                  style: TextStyle(
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: accentColor))
          : _error != null
          ? _buildErrorState()
          : _ranking.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadRanking,
              color: accentColor,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _ranking.length,
                itemBuilder: (context, index) {
                  if (index < 3) {
                    return _buildTopThreeCard(_ranking[index], index + 1);
                  }
                  return _buildRankingItem(_ranking[index], index + 1);
                },
              ),
            ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No se pudo cargar el ranking',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadRanking,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(backgroundColor: accentColor),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.leaderboard_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No hay rankings aún',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            '¡Sé el primero en votar!',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTopThreeCard(Project project, int rank) {
    final colors = {
      1: const Color(0xFFFFD700), // Gold
      2: const Color(0xFFC0C0C0), // Silver
      3: const Color(0xFFCD7F32), // Bronze
    };

    final icons = {1: '🥇', 2: '🥈', 3: '🥉'};

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors[rank]!.withAlpha(51), cardColor],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors[rank]!.withAlpha(127), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Rank Badge
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: colors[rank]!.withAlpha(51),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(icons[rank]!, style: const TextStyle(fontSize: 32)),
              ),
            ),
            const SizedBox(width: 16),

            // Project Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    project.category,
                    style: TextStyle(
                      color: colors[rank],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Votes
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Icon(Icons.how_to_vote, color: colors[rank], size: 24),
                    const SizedBox(width: 4),
                    Text(
                      '${project.totalVotes}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colors[rank],
                      ),
                    ),
                  ],
                ),
                const Text(
                  'votos',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingItem(Project project, int rank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Rank number
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF374151),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Project info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                Text(
                  project.category,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),

          // Votes
          Row(
            children: [
              const Icon(Icons.how_to_vote, color: accentColor, size: 18),
              const SizedBox(width: 4),
              Text(
                '${project.totalVotes}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}
