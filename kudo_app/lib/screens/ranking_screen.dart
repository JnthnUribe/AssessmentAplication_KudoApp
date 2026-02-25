import 'dart:async';
import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/api_service.dart';

/// Pantalla de Ranking - Muestra proyectos ordenados por votos con animaciones
class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen>
    with TickerProviderStateMixin {
  // Design System
  static const Color backgroundColor = Color(0xFF0B1221);
  static const Color cardColor = Color(0xFF111827);
  static const Color surfaceColor = Color(0xFF1E293B);
  static const Color accentColor = Color(0xFF3B82F6);

  final ApiService _apiService = ApiService();
  List<Project> _ranking = [];
  bool _isLoading = true;
  String? _error;
  Timer? _pollTimer;
  late AnimationController _headerAnim;

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    _loadRanking();
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
      final projects = await _apiService.fetchProjects();
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
      body: _isLoading
          ? _buildLoading()
          : _error != null
          ? _buildErrorState()
          : _ranking.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadRanking,
              color: accentColor,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader()),
                  if (_ranking.length >= 3)
                    SliverToBoxAdapter(child: _buildPodium()),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final rank = _ranking.length >= 3
                              ? index + 4
                              : index + 1;
                          final item = _ranking.length >= 3
                              ? (index + 3 < _ranking.length
                                    ? _ranking[index + 3]
                                    : null)
                              : _ranking[index];
                          if (item == null) return const SizedBox();
                          return _buildRankingItem(item, rank, index);
                        },
                        childCount: _ranking.length >= 3
                            ? (_ranking.length - 3).clamp(0, _ranking.length)
                            : _ranking.length,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFBBF24).withAlpha(50),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ranking',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Los proyectos más votados',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
            // Live indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withAlpha(20),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF10B981).withAlpha(40),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodium() {
    final maxVotes = _ranking.isNotEmpty ? _ranking[0].totalVotes : 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place
          Expanded(child: _buildPodiumItem(_ranking[1], 2, maxVotes, 120)),
          const SizedBox(width: 8),
          // 1st place
          Expanded(child: _buildPodiumItem(_ranking[0], 1, maxVotes, 160)),
          const SizedBox(width: 8),
          // 3rd place
          Expanded(child: _buildPodiumItem(_ranking[2], 3, maxVotes, 100)),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(
    Project project,
    int rank,
    int maxVotes,
    double height,
  ) {
    final colors = {
      1: const Color(0xFFFFD700),
      2: const Color(0xFFC0C0C0),
      3: const Color(0xFFCD7F32),
    };
    final medals = {1: '🥇', 2: '🥈', 3: '🥉'};
    final color = colors[rank]!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Medal
        Text(medals[rank]!, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 6),
        // Title
        Text(
          project.title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          '${project.totalVotes} votos',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        // Podium bar
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color.withAlpha(80), color.withAlpha(20)],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: color.withAlpha(60)),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: color.withAlpha(80),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRankingItem(Project project, int rank, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + index * 60),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withAlpha(6)),
        ),
        child: Row(
          children: [
            // Rank number
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '#$rank',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Project info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    project.category,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            // Votes
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: accentColor.withAlpha(15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.how_to_vote_rounded,
                    color: accentColor,
                    size: 15,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${project.totalVotes}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: CircularProgressIndicator(
        color: accentColor,
        strokeWidth: 3,
        backgroundColor: accentColor.withAlpha(30),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_off_rounded,
              size: 44,
              color: Colors.redAccent,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No se pudo cargar el ranking',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadRanking,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
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
          Icon(Icons.leaderboard_outlined, size: 56, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No hay rankings aún',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 6),
          Text(
            '¡Sé el primero en votar!',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _headerAnim.dispose();
    super.dispose();
  }
}
