import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/api_service.dart';
import 'project_detail_screen.dart';

/// Pantalla principal - Lista de proyectos con búsqueda y filtros
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Design System
  static const Color backgroundColor = Color(0xFF020205);
  static const Color accentColor = Color(0xFF3B82F6);

  final ApiService _apiService = ApiService();
  late Future<List<Project>> _projectsFuture;
  String _selectedCategory = 'Todos';
  late AnimationController _headerAnimController;
  late Animation<double> _headerFadeAnim;

  @override
  void initState() {
    super.initState();
    _projectsFuture = _apiService.fetchProjects();
    _headerAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _headerFadeAnim = CurvedAnimation(
      parent: _headerAnimController,
      curve: Curves.easeOut,
    );
    _headerAnimController.forward();
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    super.dispose();
  }

  Future<void> _refreshProjects() async {
    setState(() {
      _projectsFuture = _apiService.fetchProjects();
    });
  }

  List<Project> _filterProjects(List<Project> projects) {
    return projects.where((p) {
      final matchesCategory =
          _selectedCategory == 'Todos' || p.category == _selectedCategory;
      return matchesCategory;
    }).toList();
  }

  List<String> _getCategories(List<Project> projects) {
    final cats = projects
        .map((p) => p.category)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    cats.sort();
    return ['Todos', ...cats];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder<List<Project>>(
        future: _projectsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final allProjects = snapshot.data!;
          final filtered = _filterProjects(allProjects);
          final categories = _getCategories(allProjects);

          return RefreshIndicator(
            onRefresh: _refreshProjects,
            color: accentColor,
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(child: _buildHeader()),
                // Category chips
                if (categories.length > 1)
                  SliverToBoxAdapter(child: _buildCategoryChips(categories)),
                // Results count
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                    child: Text(
                      '${filtered.length} proyecto${filtered.length != 1 ? 's' : ''}',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                // Project cards
                filtered.isEmpty
                    ? SliverFillRemaining(child: _buildNoResults())
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            return _AnimatedProjectCard(
                              project: filtered[index],
                              index: index,
                              onTap: () => _navigateToDetail(filtered[index]),
                            );
                          }, childCount: filtered.length),
                        ),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _headerFadeAnim,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 64, 20, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Big bold title like web "Mis creaciones" / dashboard-title
            const Text(
              'Proyectos',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -1.5,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Descubre y vota por los mejores',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips(List<String> categories) {
    // Matches web .filter-btn: pill shape, rgba(255,255,255,0.1) bg, active = white bg + black text
    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  // Active = white solid; inactive = rgba(255,255,255,0.1)
                  color: isSelected ? Colors.white : Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color:
                        isSelected ? Colors.white : Colors.white.withAlpha(50),
                  ),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    // Active = black text; inactive = white text
                    color: isSelected ? Colors.black : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              color: accentColor,
              strokeWidth: 3,
              backgroundColor: accentColor.withAlpha(30),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Cargando proyectos...',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 48,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sin conexión al servidor',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Verifica que la API esté corriendo',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _refreshProjects,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: accentColor.withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.folder_open_rounded,
              size: 48,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No hay proyectos disponibles',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade600),
          const SizedBox(height: 16),
          Text(
            'Sin resultados',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Prueba con otros términos de búsqueda',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(Project project) async {
    final result = await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => ProjectDetailScreen(project: project),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            ),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    );
    // Si votó exitosamente, refrescar la lista
    if (result == true) {
      _refreshProjects();
    }
  }
}

/// Card animada con staggered entrance
class _AnimatedProjectCard extends StatefulWidget {
  final Project project;
  final int index;
  final VoidCallback onTap;

  const _AnimatedProjectCard({
    required this.project,
    required this.index,
    required this.onTap,
  });

  @override
  State<_AnimatedProjectCard> createState() => _AnimatedProjectCardState();
}

class _AnimatedProjectCardState extends State<_AnimatedProjectCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: 80 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Horizontal card layout matching web .project-card-horizontal
    // Image section (40% width) left, info section (60%) right
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: GestureDetector(
              onTapDown: (_) => setState(() => _isHovered = true),
              onTapUp: (_) => setState(() => _isHovered = false),
              onTapCancel: () => setState(() => _isHovered = false),
              onTap: widget.onTap,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    height: 140, // Fixed card height like web min-height: 240px proportionally
                    transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
                    decoration: BoxDecoration(
                    // Web: background: rgba(38, 38, 38, 0.55)
                    color: _isHovered
                        ? Colors.black
                            .withAlpha(153) // rgba(0,0,0,0.6) on hover
                        : const Color(0x8C262626), // rgba(38,38,38,0.55)
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      // Web: border: 1px solid rgba(255,255,255,0.1)
                      // hover: rgba(255,255,255,0.2)
                      color: _isHovered
                          ? Colors.white.withAlpha(50)
                          : Colors.white.withAlpha(25),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── IMAGE SECTION (40%) matching .project-card-image-section ──
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.38,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              widget.project.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.white.withAlpha(12),
                                child: Icon(
                                  Icons.image_rounded,
                                  size: 32,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              loadingBuilder: (_, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  color: Colors.white.withAlpha(12),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: const Color(0xFF3B82F6),
                                      strokeWidth: 2,
                                      value: progress.expectedTotalBytes != null
                                          ? progress.cumulativeBytesLoaded /
                                              progress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      // ── INFO SECTION (60%) matching .project-card-info-section ──
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(4, 14, 14, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title — matching .project-card-title
                              Text(
                                widget.project.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 5),
                              // Description — matching .project-card-description
                              Expanded(
                                child: Text(
                                  widget.project.description,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 12.5,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              // Tech pills — matching .tech-pill-small
                              Wrap(
                                spacing: 5,
                                runSpacing: 4,
                                children: [
                                  // Category pill
                                  _TechPill(label: widget.project.category),
                                  // Votes badge
                                  _TechPill(
                                    label:
                                        '▲ ${widget.project.totalVotes} votos',
                                    isAccent: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}

/// Small tech pill matching web .tech-pill-small
class _TechPill extends StatelessWidget {
  final String label;
  final bool isAccent;
  const _TechPill({required this.label, this.isAccent = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        // Web: background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.1)
        color: isAccent
            ? const Color(0xFF3B82F6).withAlpha(30)
            : Colors.white.withAlpha(12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isAccent
              ? const Color(0xFF3B82F6).withAlpha(60)
              : Colors.white.withAlpha(25),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: isAccent ? const Color(0xFF3B82F6) : Colors.grey.shade400,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
