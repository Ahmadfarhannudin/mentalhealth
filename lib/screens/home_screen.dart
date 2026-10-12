import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../screens/mood_tracker_screen.dart';
import '../screens/journal_screen.dart';
import '../screens/cbt_exercises_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const MoodTrackerScreen(),
    const JournalScreen(),
    const CbtExercisesScreen(),
    // CommunityScreen placeholder
    const Center(
      child: Text('Komunitas (dalam pengembangan)', style: TextStyle(color: Colors.grey)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: _screens[_selectedIndex],
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
}