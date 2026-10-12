import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../screens/mood_tracker_screen.dart';
import '../screens/journal_screen.dart';
import '../screens/cbt_exercises_screen.dart';

class HomeScreen extends StatefulWidget {
  /// Nama pengguna yang ditampilkan di ucapan beranda.
  final String userName;

  const HomeScreen({super.key, this.userName = 'Teman'});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens = [
    MoodTrackerScreen(
      userName: widget.userName,
      onTabChanged: (index) => setState(() => _selectedIndex = index),
    ),
    const JournalScreen(),
    const CbtExercisesScreen(),
    // CommunityScreen placeholder
    const Center(
      child: Text('Komunitas (dalam pengembangan)', style: TextStyle(color: Colors.grey)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final profileInitial = widget.userName.trim().isEmpty
        ? 'T'
        : widget.userName.trim()[0].toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Stack(
        children: [
          // Background bertema alam & kesegaran
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE5EFE7), // sage lembut segar di atas
                    Color(0xFFF2F7F2), // mint sangat lembut
                    AppColors.cream,   // transisi ke krem hangat di bawah
                  ],
                  stops: [0.0, 0.35, 1.0],
                ),
              ),
            ),
          ),
          // Ornamen motif dedaunan alam lembut di kanan atas & kiri
          Positioned(
            top: -30,
            right: -25,
            child: IgnorePointer(
              child: Icon(
                Icons.eco_rounded,
                size: 210,
                color: AppColors.sageLight.withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            top: 220,
            left: -40,
            child: IgnorePointer(
              child: Icon(
                Icons.park_rounded,
                size: 190,
                color: AppColors.sage.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            right: -20,
            child: IgnorePointer(
              child: Icon(
                Icons.forest_rounded,
                size: 160,
                color: AppColors.mint.withValues(alpha: 0.08),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildGlobalHeader(profileInitial),
                Expanded(
                  child: IndexedStack(index: _selectedIndex, children: _screens),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.borderLight, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.sage,
          unselectedItemColor: AppColors.textMuted,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.psychology_outlined),
              label: 'Check-in',
              activeIcon: Icon(Icons.psychology),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_stories_outlined),
              label: 'Jurnal',
              activeIcon: Icon(Icons.auto_stories),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center_outlined),
              label: 'Coping',
              activeIcon: Icon(Icons.fitness_center),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              label: 'Komunitas',
              activeIcon: Icon(Icons.people),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalHeader(String profileInitial) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.sage,
                  ),
                  child: const Text(
                    'T',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Tenang',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.sagePale,
              border: Border.all(color: AppColors.sageLight, width: 1.5),
            ),
            child: Text(
              profileInitial,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.sageDeep,
              ),
            ),
          ),
        ],
      ),
    );
  }
}