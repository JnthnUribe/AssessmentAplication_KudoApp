import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'screens/ranking_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/kudo_background.dart';

void main() {
  runApp(const KudoApp());
}

class KudoApp extends StatelessWidget {
  const KudoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KUDO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020205),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3B82F6),
          secondary: Color(0xFF3B82F6),
          surface: Color(0xFF020205),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
        ),
        textTheme: GoogleFonts.dmSansTextTheme(
          Theme.of(context)
              .textTheme
              .apply(bodyColor: Colors.white, displayColor: Colors.white),
        ).copyWith(
          titleLarge: GoogleFonts.sen(fontWeight: FontWeight.w800),
          titleMedium: GoogleFonts.sen(fontWeight: FontWeight.w700),
          titleSmall: GoogleFonts.sen(fontWeight: FontWeight.w700),
          headlineLarge: GoogleFonts.sen(fontWeight: FontWeight.w800),
          headlineMedium: GoogleFonts.sen(fontWeight: FontWeight.w800),
          headlineSmall: GoogleFonts.sen(fontWeight: FontWeight.w800),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF020205),
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: const CardThemeData(
          color: Colors.transparent, // Uses glassmorphism
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withAlpha(25),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withAlpha(50)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withAlpha(50)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFFFFFF), width: 1.5),
          ),
          hintStyle: TextStyle(color: Colors.white.withAlpha(128)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A1A1A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ).copyWith(
            side: WidgetStateProperty.resolveWith<BorderSide>((states) {
              if (states.contains(WidgetState.hovered) ||
                  states.contains(WidgetState.pressed)) {
                return const BorderSide(color: Color(0xFF646CFF));
              }
              return BorderSide.none;
            }),
          ),
        ),
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    RankingScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: KudoBackground(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: KeyedSubtree(
            key: ValueKey<int>(_selectedIndex),
            child: _screens[_selectedIndex],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF020205).withAlpha(180),
          border: Border(
            top: BorderSide(
              color: Colors.white.withAlpha(25),
              width: 1,
            ),
          ),
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: NavigationBar(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              indicatorColor: const Color(0xFF3B82F6).withAlpha(35),
              selectedIndex: _selectedIndex,
              animationDuration: const Duration(milliseconds: 400),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.rocket_launch_outlined, size: 22),
                  selectedIcon: Icon(
                    Icons.rocket_launch,
                    color: Color(0xFF3B82F6),
                    size: 24,
                  ),
                  label: 'Proyectos',
                ),
                NavigationDestination(
                  icon: Icon(Icons.emoji_events_outlined, size: 22),
                  selectedIcon: Icon(
                    Icons.emoji_events,
                    color: Color(0xFF3B82F6),
                    size: 24,
                  ),
                  label: 'Ranking',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded, size: 22),
                  selectedIcon: Icon(
                    Icons.person_rounded,
                    color: Color(0xFF3B82F6),
                    size: 24,
                  ),
                  label: 'Perfil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
