import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/project.dart';
import '../services/api_service.dart';
import '../services/voter_service.dart';
import '../services/favorite_service.dart';
import '../widgets/kudo_background.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen>
    with SingleTickerProviderStateMixin {
  // Design System
  static const Color backgroundColor = Color(0xFF020205);
  static const Color accentColor = Color(0xFF3B82F6);
  static const Color cardColor = Color(0x33262626);
  static const Color surfaceColor = Color(0x1AFFFFFF);

  final ApiService _apiService = ApiService();
  double _rating = 0;
  bool _isSubmitting = false;
  bool _hasAlreadyVoted = false;
  int _previousScore = 0;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // Unified eval fields
  final TextEditingController _commentCtrl = TextEditingController();
  final TextEditingController _tagCtrl = TextEditingController();
  List<String> _tags = [];
  String _savedComment = '';
  List<String> _savedTags = [];

  // Favorite
  bool _isFavorite = false;

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
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final isFav = await FavoriteService.isFavorite(widget.project.id);
    if (mounted) setState(() => _isFavorite = isFav);
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
        _savedComment = result['comment'] ?? '';
        _savedTags =
            result['tags'] != null ? List<String>.from(result['tags']) : [];
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _commentCtrl.dispose();
    _tagCtrl.dispose();
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
      comment: _commentCtrl.text.trim(),
      tags: _tags,
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
    return KudoBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          slivers: [
            // Hero Image
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: Colors.transparent,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(100),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon:
                      const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(100),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: _isFavorite ? Colors.redAccent : Colors.white,
                    ),
                    onPressed: _toggleFavorite,
                  ),
                ),
              ],
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
                            const Color(0xFF020205).withAlpha(150),
                            const Color(0xFF020205).withAlpha(0),
                          ],
                          stops: const [0.0, 0.7, 1.0],
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
                      // Category + Platform + Votes row
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
                          if (widget.project.platform.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: surfaceColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withAlpha(10),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _platformIcon(widget.project.platform),
                                    color: Colors.grey.shade400,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.project.platform,
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
                          border: Border.all(color: Colors.white.withAlpha(25)),
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

                      // Role Description (if available)
                      if (widget.project.roleDescription.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _buildSectionHeader(
                          Icons.person_outline_rounded,
                          'Rol del Creador',
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border:
                                Border.all(color: Colors.white.withAlpha(25)),
                          ),
                          child: Text(
                            widget.project.roleDescription,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade400,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],

                      // Tech Stack (if available)
                      if (widget.project.techStack.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _buildSectionHeader(Icons.code_rounded, 'Tecnologías'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.project.techStack.map((tech) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: accentColor.withAlpha(15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: accentColor.withAlpha(30),
                                ),
                              ),
                              child: Text(
                                tech,
                                style: const TextStyle(
                                  color: accentColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],

                      // Outcomes (if available)
                      if (widget.project.outcomes.results.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _buildSectionHeader(
                          Icons.emoji_events_outlined,
                          'Resultados',
                        ),
                        const SizedBox(height: 12),
                        ...widget.project.outcomes.results.map((result) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 6),
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    result,
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],

                      // Learnings (if available)
                      if (widget.project.outcomes.learnings.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _buildSectionHeader(
                          Icons.lightbulb_outline_rounded,
                          'Aprendizajes',
                        ),
                        const SizedBox(height: 12),
                        ...widget.project.outcomes.learnings.map((learning) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 6),
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFBBF24),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    learning,
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],

                      // Image Gallery (if multiple images)
                      if (widget.project.allImageUrls.length > 1) ...[
                        const SizedBox(height: 24),
                        _buildSectionHeader(
                          Icons.photo_library_outlined,
                          'Galería',
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 160,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.project.allImageUrls.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    widget.project.allImageUrls[index],
                                    height: 160,
                                    width: 220,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      height: 160,
                                      width: 220,
                                      color: surfaceColor,
                                      child: Icon(
                                        Icons.broken_image_rounded,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],

                      // Video link (if available)
                      if (widget.project.media.videoUrl.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(14),
                            border:
                                Border.all(color: Colors.white.withAlpha(25)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.red.withAlpha(20),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.play_circle_filled_rounded,
                                  color: Colors.redAccent,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Video del Proyecto',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      widget.project.media.videoUrl,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // External Links (if available)
                      if (widget.project.media.links.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _buildSectionHeader(Icons.link_rounded, 'Enlaces'),
                        const SizedBox(height: 12),
                        ...widget.project.media.links.map((link) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withAlpha(6),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.open_in_new_rounded,
                                  color: accentColor,
                                  size: 18,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        link.label.isNotEmpty
                                            ? link.label
                                            : 'Enlace',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        link.url,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],

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
                          _buildStatCard(
                            Icons.devices_rounded,
                            widget.project.platform.isNotEmpty
                                ? widget.project.platform
                                : '-',
                            'Plataforma',
                          ),
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
                            color: accentColor.withAlpha(40),
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

                            // Comment + tags (only before voting)
                            if (!_hasAlreadyVoted) ...[
                              const SizedBox(height: 20),
                              TextField(
                                controller: _commentCtrl,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                maxLines: 3,
                                minLines: 1,
                                decoration: InputDecoration(
                                  hintText:
                                      'Escribe tu comentario sobre el proyecto...',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                  filled: true,
                                  fillColor: surfaceColor,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.all(14),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Tags input
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _tagCtrl,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Agregar etiqueta...',
                                        hintStyle: TextStyle(
                                          color: Colors.grey.shade600,
                                        ),
                                        filled: true,
                                        fillColor: surfaceColor,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 12,
                                        ),
                                      ),
                                      onSubmitted: (_) => _addTag(),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: _addTag,
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: accentColor,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.add_rounded,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (_tags.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: _tags.map((tag) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: accentColor.withAlpha(20),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '#$tag',
                                            style: const TextStyle(
                                              color: accentColor,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          GestureDetector(
                                            onTap: () => setState(
                                                () => _tags.remove(tag)),
                                            child: const Icon(
                                              Icons.close,
                                              color: accentColor,
                                              size: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ],
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
                                  disabledBackgroundColor:
                                      accentColor.withAlpha(
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
                                                : 'Enviar Evaluación',
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

            // Saved evaluation (read-only after voting)
            if (_hasAlreadyVoted)
              SliverToBoxAdapter(child: _buildEvaluationSection()),

            // Bottom spacing
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  IconData _platformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'mobile':
        return Icons.phone_android_rounded;
      case 'web':
        return Icons.language_rounded;
      case 'desktop':
        return Icons.desktop_windows_rounded;
      case 'iot':
        return Icons.sensors_rounded;
      default:
        return Icons.devices_rounded;
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await FavoriteService.removeFavorite();
      if (mounted) {
        setState(() => _isFavorite = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.favorite_border, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Favorito eliminado'),
              ],
            ),
            backgroundColor: Colors.grey.shade800,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Check if another project is already favorite
      final currentFav = await FavoriteService.getFavoriteProjectId();
      if (currentFav != null && currentFav != widget.project.id && mounted) {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF222222), // Solid background
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.white.withAlpha(25)),
            ),
            title: const Text(
              'Cambiar favorito',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Ya tienes un proyecto favorito. ¿Quieres reemplazarlo con este?',
              style: TextStyle(color: Colors.grey),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Cambiar',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        );
        if (confirm != true) return;
      }
      await FavoriteService.setFavorite(widget.project.id);
      if (mounted) {
        setState(() => _isFavorite = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.favorite_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('${widget.project.title} es tu favorito ♥'),
                ),
              ],
            ),
            backgroundColor: Colors.redAccent.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _addTag() {
    final tag = _tagCtrl.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagCtrl.clear();
      });
    }
  }

  Widget _buildEvaluationSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF10B981).withAlpha(40)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF10B981),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Tu evaluación',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                // Stars display
                Row(
                  children: List.generate(5, (i) {
                    return Icon(
                      Icons.star_rounded,
                      size: 18,
                      color: i < _previousScore
                          ? const Color(0xFFFBBF24)
                          : const Color(0xFF374151),
                    );
                  }),
                ),
              ],
            ),
            if (_savedComment.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                _savedComment,
                style: TextStyle(color: Colors.grey.shade300, fontSize: 13),
              ),
            ],
            if (_savedTags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _savedTags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '#$tag',
                      style: const TextStyle(color: accentColor, fontSize: 12),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
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
          border: Border.all(color: Colors.white.withAlpha(25)),
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
