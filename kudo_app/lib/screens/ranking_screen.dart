import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/api_service.dart';
import '../services/favorite_service.dart';

/// Pantalla de Ranking - Muestra proyectos ordenados por votos con animaciones
class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen>
    with TickerProviderStateMixin {
  // Design System
  static const Color backgroundColor = Color(0xFF020205);
  static const Color cardColor = Color(0x33262626); // Glassmorphism backdrop
  static const Color surfaceColor = Color(0x1AFFFFFF);
  static const Color accentColor = Color(0xFF3B82F6);
  static const Color greenColor = Color(0xFF10B981);
  static const Color redColor = Color(0xFFEF4444);
  static const Color goldColor = Color(0xFFFFD700);

  final ApiService _apiService = ApiService();
  List<Project> _ranking = [];
  Map<String, int> _previousPositions = {}; // projectId -> previous rank
  Map<String, int> _previousVotes = {}; // projectId -> previous votes
  bool _isLoading = true;
  String? _error;
  Timer? _pollTimer;
  late AnimationController _headerAnim;
  late AnimationController _pulseAnim;
  late AnimationController _podiumAnim;
  bool _isFirstLoad = true;

  // Favorite tracking
  String? _favoriteProjectId;
  int _favoriteRank = -1; // -1 = not in ranking

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    _pulseAnim = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _podiumAnim = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _loadRanking();
    _loadFavorite();
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _loadRanking(silent: true);
    });
  }

  Future<void> _loadFavorite() async {
    final favId = await FavoriteService.getFavoriteProjectId();
    if (mounted) setState(() => _favoriteProjectId = favId);
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
      projects.sort((a, b) {
        final ratingCmp = b.averageRating.compareTo(a.averageRating);
        if (ratingCmp != 0) return ratingCmp;
        return b.totalVotes.compareTo(a.totalVotes);
      });

      // Save previous state before updating
      if (!_isFirstLoad) {
        _previousPositions = {};
        _previousVotes = {};
        for (int i = 0; i < _ranking.length; i++) {
          _previousPositions[_ranking[i].id] = i + 1;
          _previousVotes[_ranking[i].id] = _ranking[i].totalVotes;
        }
      }

      setState(() {
        _ranking = projects;
        _isLoading = false;
      });

      if (_isFirstLoad) {
        _isFirstLoad = false;
        _podiumAnim.forward();
      }

      // Check favorite position
      await _loadFavorite();
      if (_favoriteProjectId != null) {
        final idx = projects.indexWhere((p) => p.id == _favoriteProjectId);
        final newRank = idx >= 0 ? idx + 1 : -1;
        if (mounted) setState(() => _favoriteRank = newRank);
      }
    } catch (e) {
      if (!silent) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  /// Returns position change: positive = moved up, negative = moved down, 0 = same
  int _getPositionChange(String projectId, int currentRank) {
    if (!_previousPositions.containsKey(projectId)) return 0;
    final prevRank = _previousPositions[projectId]!;
    return prevRank -
        currentRank; // positive means moved up (lower rank number)
  }

  /// Returns vote change since last poll
  int _getVoteChange(String projectId, int currentVotes) {
    if (!_previousVotes.containsKey(projectId)) return 0;
    return currentVotes - _previousVotes[projectId]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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
                          // Favorite banner
                          if (_favoriteProjectId != null &&
                              _favoriteRank > 0 &&
                              _favoriteRank <= 5)
                            SliverToBoxAdapter(child: _buildFavoriteBanner()),
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
                                    ? (_ranking.length - 3)
                                        .clamp(0, _ranking.length)
                                    : _ranking.length,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildFavoriteBanner() {
    final favProject = _ranking.firstWhere(
      (p) => p.id == _favoriteProjectId,
      orElse: () => _ranking.first,
    );

    final rankChange = _favoriteProjectId != null
        ? _getPositionChange(_favoriteProjectId!, _favoriteRank)
        : 0;
    String message = '¡Tu favorito está en el Top $_favoriteRank!';
    if (rankChange > 0) {
      message = '¡Tu favorito subió al puesto #$_favoriteRank! 🚀';
    } else if (rankChange < 0) {
      message = 'Tu favorito bajó al puesto #$_favoriteRank 📉';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.redAccent.shade700.withAlpha(40),
              Colors.pinkAccent.shade700.withAlpha(20),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.redAccent.withAlpha(60)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.favorite_rounded,
              color: Colors.redAccent,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    favProject.title,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.redAccent.withAlpha(40),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '#$_favoriteRank',
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
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
            // Animated LIVE indicator with pulse
            ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1.0).animate(
                CurvedAnimation(parent: _pulseAnim, curve: Curves.easeInOut),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: greenColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: greenColor.withAlpha(40)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(
                      opacity: Tween<double>(begin: 0.4, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _pulseAnim,
                          curve: Curves.easeInOut,
                        ),
                      ),
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: greenColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'LIVE',
                      style: TextStyle(
                        color: greenColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodium() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: AnimatedBuilder(
        animation: _podiumAnim,
        builder: (context, child) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 2nd place
              Expanded(
                child: _buildPodiumItem(_ranking[1], 2, 120, _podiumAnim.value),
              ),
              const SizedBox(width: 8),
              // 1st place
              Expanded(
                child: _buildPodiumItem(_ranking[0], 1, 160, _podiumAnim.value),
              ),
              const SizedBox(width: 8),
              // 3rd place
              Expanded(
                child: _buildPodiumItem(_ranking[2], 3, 100, _podiumAnim.value),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPodiumItem(
    Project project,
    int rank,
    double maxHeight,
    double animValue,
  ) {
    final colors = {
      1: goldColor,
      2: const Color(0xFFC0C0C0),
      3: const Color(0xFFCD7F32),
    };
    final medals = {1: '🥇', 2: '🥈', 3: '🥉'};
    final color = colors[rank]!;

    // Stagger: 1st place has slight delay, 2nd starts first, 3rd last
    final delays = {1: 0.15, 2: 0.0, 3: 0.3};
    final delay = delays[rank]!;
    final progress = ((animValue - delay) / (1.0 - delay)).clamp(0.0, 1.0);
    final curvedProgress = Curves.easeOutBack.transform(progress);
    final barHeight = maxHeight * curvedProgress;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Medal with scale animation
        Transform.scale(
          scale: curvedProgress.clamp(0.0, 1.2),
          child: Text(medals[rank]!, style: const TextStyle(fontSize: 28)),
        ),
        const SizedBox(height: 6),
        // Title
        Opacity(
          opacity: progress,
          child: Text(
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
        ),
        const SizedBox(height: 4),
        // Rating & votes
        Opacity(
          opacity: progress,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_rounded, color: color, size: 14),
                  const SizedBox(width: 2),
                  Text(
                    project.averageRating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${project.totalVotes} votos',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Animated podium bar
        Container(
          height: barHeight,
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
            child: Opacity(
              opacity: progress,
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
        ),
      ],
    );
  }

  Widget _buildRankingItem(Project project, int rank, int index) {
    final posChange = _getPositionChange(project.id, rank);
    final voteChange = _getVoteChange(project.id, project.totalVotes);

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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: posChange > 0
                    ? greenColor.withAlpha(30)
                    : posChange < 0
                        ? redColor.withAlpha(30)
                        : Colors.white.withAlpha(25), // Subtle white border
              ),
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
                const SizedBox(width: 6),
                // Position change indicator
                _buildPositionIndicator(posChange),
                const SizedBox(width: 10),
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
                      if (project.category.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          project.category,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Votes with change
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withAlpha(15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
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
                    if (voteChange > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '+$voteChange nuevos',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: greenColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPositionIndicator(int change) {
    if (change == 0) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.grey.withAlpha(15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Center(
          child: Text(
            '—',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    final isUp = change > 0;
    final color = isUp ? greenColor : redColor;
    final icon =
        isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Center(child: Icon(icon, color: color, size: 14)),
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
    _pulseAnim.dispose();
    _podiumAnim.dispose();
    super.dispose();
  }
}
