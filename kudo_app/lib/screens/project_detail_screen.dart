import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/project.dart';
import '../services/api_service.dart';
import '../services/voter_service.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen>
    with SingleTickerProviderStateMixin {
  // Design System
  static const Color backgroundColor = Color(0xFF0B1221);
  static const Color accentColor = Color(0xFF3B82F6);
  static const Color cardColor = Color(0xFF111827);
  static const Color surfaceColor = Color(0xFF1E293B);

  final ApiService _apiService = ApiService();
  double _rating = 0;
  bool _isSubmitting = false;
  bool _hasAlreadyVoted = false;
  int _previousScore = 0;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    _checkExistingVote();
  }

  Future<void> _checkExistingVote() async {
    final voterId = await VoterService.getVoterId();
    final result = await _apiService.checkVote(
      projectId: widget.project.id,
      voterId: voterId,
    );
    if (mounted && result['hasVoted'] == true) {
      setState(() {
        _hasAlreadyVoted = true;
        _previousScore = result['score'] ?? 0;
        _rating = _previousScore.toDouble();
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _submitVote() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Selecciona una calificación primero'),
            ],
          ),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final voterId = await VoterService.getVoterId();
    final result = await _apiService.submitVote(
      projectId: widget.project.id,
      voterId: voterId,
      score: _rating.toInt(),
    );

    if (mounted) {
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  '¡Votaste ${_rating.toInt()}/5 para ${widget.project.title}!',
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop(true); // true = voto exitoso para refrescar
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.warning_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(result['message'] ?? 'Error al votar')),
              ],
            ),
            backgroundColor: Colors.orange.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }

    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Hero Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: backgroundColor,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(100),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.project.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: surfaceColor,
                      child: const Center(
                        child: Icon(
                          Icons.image_rounded,
                          size: 64,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withAlpha(30),
                          backgroundColor.withAlpha(60),
                          backgroundColor,
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category + Votes row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                accentColor.withAlpha(40),
                                accentColor.withAlpha(15),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.project.category,
                            style: const TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.how_to_vote_rounded,
                                color: accentColor,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${widget.project.totalVotes} votos',
                                style: TextStyle(
                                  color: Colors.grey.shade300,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      widget.project.title,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // About section
                    _buildSectionHeader(
                      Icons.info_outline_rounded,
                      'Acerca del proyecto',
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withAlpha(6)),
                      ),
                      child: Text(
                        widget.project.description,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade400,
                          height: 1.7,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Stats row
                    Row(
                      children: [
                        _buildStatCard(
                          Icons.how_to_vote_rounded,
                          '${widget.project.totalVotes}',
                          'Votos',
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          Icons.category_rounded,
                          widget.project.category,
                          'Categoría',
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(Icons.star_rounded, '-', 'Promedio'),
                      ],
                    ),
                    const SizedBox(height: 36),

                    // Vote Section
                    _buildSectionHeader(
                      Icons.star_rounded,
                      'Califica este proyecto',
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [cardColor, accentColor.withAlpha(8)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: accentColor.withAlpha(30),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withAlpha(8),
                            blurRadius: 30,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            _hasAlreadyVoted
                                ? 'Ya votaste $_previousScore/5 ⭐'
                                : _rating > 0
                                ? '¡Gracias por tu voto!'
                                : 'Toca las estrellas para votar',
                            style: TextStyle(
                              color: _hasAlreadyVoted
                                  ? const Color(0xFF10B981)
                                  : Colors.grey.shade400,
                              fontSize: 14,
                              fontWeight: _hasAlreadyVoted
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Stars
                          RatingBar.builder(
                            initialRating: 0,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: false,
                            itemCount: 5,
                            itemSize: 44,
                            unratedColor: const Color(0xFF374151),
                            itemBuilder: (context, index) {
                              return Icon(
                                Icons.star_rounded,
                                color: index < _rating
                                    ? const Color(0xFFFBBF24)
                                    : const Color(0xFF374151),
                              );
                            },
                            onRatingUpdate: (rating) {
                              setState(() => _rating = rating);
                            },
                          ),
                          const SizedBox(height: 12),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: _rating > 0
                                ? Text(
                                    '${_rating.toInt()} de 5 estrellas',
                                    key: ValueKey(_rating),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFFBBF24),
                                    ),
                                  )
                                : const SizedBox(height: 20),
                          ),
                          const SizedBox(height: 24),

                          // Submit button
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: (_isSubmitting || _hasAlreadyVoted)
                                  ? null
                                  : _submitVote,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                disabledBackgroundColor: accentColor.withAlpha(
                                  80,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          _hasAlreadyVoted
                                              ? Icons.check_circle_rounded
                                              : Icons.send_rounded,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          _hasAlreadyVoted
                                              ? 'Voto Registrado'
                                              : 'Enviar Voto',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: accentColor, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label) {
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
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
}
