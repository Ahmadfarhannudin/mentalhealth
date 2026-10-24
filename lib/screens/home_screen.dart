import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';
import '../core/ui/components.dart';
import 'chat_ai_screen.dart';
import 'cbt_exercises_screen.dart';
import 'journal_screen.dart';
import 'mood_tracker_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({super.key, this.userName = 'Teman'});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late String _userName = widget.userName;

  late List<Widget> _screens = _buildScreens();

  List<Widget> _buildScreens() => [
    MoodTrackerScreen(
      userName: _userName,
      onTabChanged: (index) {
        if (index >= 0 && index < 4) {
          setState(() => _selectedIndex = index);
        }
      },
    ),
    const JournalScreen(),
    const CbtExercisesScreen(),
    const ChatAiScreen(),
  ];

  Future<void> _openProfile() async {
    final draft = await ProfileSheet.show(context, name: _userName);
    if (!mounted || draft == null || draft.name == _userName) return;
    setState(() {
      _userName = draft.name;
      _screens = _buildScreens();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profil tersimpan. Sapaan sekarang: ${draft.name}.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(name: _userName, onProfile: _openProfile),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth > 680
                      ? 680.0
                      : constraints.maxWidth;
                  return Center(
                    child: SizedBox(
                      width: width,
                      height: constraints.maxHeight,
                      child: IndexedStack(
                        index: _selectedIndex,
                        children: _screens,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _Navigation(
        selected: _selectedIndex,
        onSelect: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String name;
  final VoidCallback onProfile;

  const _Header({required this.name, required this.onProfile});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Space.page,
            Space.md,
            Space.page,
            Space.sm,
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: AppColors.forest,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  size: 19,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: Space.md),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Tenang', style: AppText.titleLarge),
                    SizedBox(height: 1),
                    Text('Ruang amanmu', style: AppText.caption),
                  ],
                ),
              ),
              const SizedBox(width: Space.sm),
              _ProfileButton(name: name, onPressed: onProfile),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileButton extends StatelessWidget {
  final String name;
  final VoidCallback onPressed;

  const _ProfileButton({required this.name, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final letter = trimmed.isEmpty ? '?' : trimmed.characters.first.toUpperCase();

    return Semantics(
      button: true,
      label: 'Buka profil',
      child: Material(
        key: const Key('profileButton'),
        color: AppColors.forestPale,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: Text(
                letter,
                style: AppText.titleSmall.copyWith(color: AppColors.forestDeep),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Navigation extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;

  const _Navigation({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: SafeArea(
        top: false,
        child: NavigationBar(
          selectedIndex: selected,
          onDestinationSelected: onSelect,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.today_outlined),
              selectedIcon: Icon(Icons.today_rounded),
              label: 'Check-in',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book_rounded),
              label: 'Jurnal',
            ),
            NavigationDestination(
              icon: Icon(Icons.self_improvement_outlined),
              selectedIcon: Icon(Icons.self_improvement_rounded),
              label: 'Latihan',
            ),
            NavigationDestination(
              icon: Icon(Icons.forum_outlined),
              selectedIcon: Icon(Icons.forum_rounded),
              label: 'Teman',
            ),
          ],
        ),
      ),
    );
  }
}
