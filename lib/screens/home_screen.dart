
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../screens/mood_tracker_screen.dart';
import '../screens/journal_screen.dart';
import '../screens/cbt_exercises_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({
    super.key,
    this.userName = 'Teman',
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens = [
    MoodTrackerScreen(
      userName: widget.userName,
      onTabChanged: (index) {
        if (index >= 0 && index < 4) {
          setState(() => _selectedIndex = index);
        }
      },
    ),
    const JournalScreen(),
    const CbtExercisesScreen(),
    const Center(
      child: Text(
        'Komunitas (dalam pengembangan)',
        style: TextStyle(color: Colors.grey),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final trimmedName = widget.userName.trim();
    final profileInitial =
        trimmedName.isEmpty ? 'T' : trimmedName[0].toUpperCase();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _buildGlobalHeader(profileInitial),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: _screens,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildCustomNavBar(),
    );
  }

  // =========================================================
  // FLOATING NATURE NAVIGATION BAR
  // =========================================================

  Widget _buildCustomNavBar() {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F9F2),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: const Color(0xFFDCE6D4),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF536F51).withValues(alpha: 0.09),
              blurRadius: 22,
              spreadRadius: 0,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: _navItem(
                  0,
                  Icons.spa_outlined,
                  Icons.spa_rounded,
                  'Check-in',
                ),
              ),
              Expanded(
                child: _navItem(
                  1,
                  Icons.menu_book_outlined,
                  Icons.menu_book_rounded,
                  'Jurnal',
                ),
              ),
              Expanded(
                child: _navItem(
                  2,
                  Icons.self_improvement_outlined,
                  Icons.self_improvement_rounded,
                  'Coping',
                ),
              ),
              Expanded(
                child: _navItem(
                  3,
                  Icons.people_outline_rounded,
                  Icons.people_rounded,
                  'Komunitas',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final isSelected = _selectedIndex == index;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: GestureDetector(
        onTap: () {
          if (_selectedIndex != index) {
            setState(() => _selectedIndex = index);
          }
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(
            vertical: 5,
            horizontal: 1,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFE5EEDD)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFD5E3CB)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                width: 36,
                height: 30,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFD5E5CB)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: animation,
                        child: child,
                      ),
                    );
                  },
                  child: Icon(
                    isSelected ? activeIcon : icon,
                    key: ValueKey('$index-$isSelected'),
                    size: 22,
                    color: isSelected
                        ? const Color(0xFF527451)
                        : const Color(0xFF91A099),
                  ),
                ),
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                style: TextStyle(
                  fontSize: 10.5,
                  height: 1.2,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF527451)
                      : const Color(0xFF84938B),
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.visible,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                width: isSelected ? 12 : 0,
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0xFF71966D),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // GLOBAL HEADER
  // =========================================================

  Widget _buildGlobalHeader(String profileInitial) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF7FA184),
            ),
            child: const Icon(
              Icons.spa_rounded,
              color: Colors.white,
              size: 21,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Tenang',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: AppColors.textDark,
              ),
            ),
          ),
          Container(
            width: 39,
            height: 39,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE7F0E1),
              border: Border.all(
                color: const Color(0xFFA8C49C),
                width: 1.4,
              ),
            ),
            child: Text(
              profileInitial,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF527451),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
