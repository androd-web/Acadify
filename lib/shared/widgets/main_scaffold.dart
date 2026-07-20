import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/models/user_model.dart';
import 'custom_navigation_bar.dart';

class MainScaffold extends StatefulWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/student-dashboard') || location.startsWith('/teacher-dashboard') || location.startsWith('/admin-dashboard')) {
      return 0;
    }
    if (location.startsWith('/courses') || location.startsWith('/teacher-courses') || location.startsWith('/admin-announcements')) {
      return 1;
    }
    if (location.startsWith('/grades') || location.startsWith('/teacher-grade-entry') || location.startsWith('/admin-users')) {
      return 2;
    }
    if (location.startsWith('/schedule') || location.startsWith('/teacher-schedule') || location.startsWith('/settings')) {
      return 3;
    }
    if (location.startsWith('/profile') || location.startsWith('/teacher-profile') || location.startsWith('/admin-profile')) {
      return 4;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context, UserRole role) {
    switch (role) {
      case UserRole.student:
        switch (index) {
          case 0: context.go('/student-dashboard'); break;
          case 1: context.go('/courses'); break;
          case 2: context.go('/grades'); break;
          case 3: context.go('/schedule'); break;
          case 4: context.go('/profile'); break;
        }
        break;
      case UserRole.teacher:
        switch (index) {
          case 0: context.go('/teacher-dashboard'); break;
          case 1: context.go('/teacher-courses'); break;
          case 2: context.go('/teacher-grade-entry'); break;
          case 3: context.go('/teacher-schedule'); break;
          case 4: context.go('/teacher-profile'); break;
        }
        break;
      case UserRole.admin:
        switch (index) {
          case 0: context.go('/admin-dashboard'); break;
          case 1: context.go('/admin-announcements'); break;
          case 2: context.go('/admin-users'); break;
          case 3: context.go('/settings'); break;
          case 4: context.go('/admin-profile'); break;
        }
        break;
    }
  }

  List<CustomBottomNavItem> _getNavItems(UserRole role, BuildContext context) {
    switch (role) {
      case UserRole.student:
        return [
          CustomBottomNavItem(icon: Icons.home_rounded, label: 'Accueil'),
          CustomBottomNavItem(icon: Icons.menu_book_rounded, label: 'Cours'),
          CustomBottomNavItem(icon: Icons.grade_rounded, label: 'Notes'),
          CustomBottomNavItem(icon: Icons.calendar_month_rounded, label: 'Planning'),
          CustomBottomNavItem(icon: Icons.person_rounded, label: 'Profil'),
        ];
      case UserRole.teacher:
        return [
          CustomBottomNavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
          CustomBottomNavItem(icon: Icons.book_rounded, label: 'Mes Cours'),
          CustomBottomNavItem(icon: Icons.edit_note_rounded, label: 'Notes'),
          CustomBottomNavItem(icon: Icons.event_note_rounded, label: 'Planning'),
          CustomBottomNavItem(icon: Icons.person_rounded, label: 'Profil'),
        ];
      case UserRole.admin:
        return [
          CustomBottomNavItem(icon: Icons.admin_panel_settings_rounded, label: 'Admin'),
          CustomBottomNavItem(icon: Icons.campaign_rounded, label: 'Annonces'),
          CustomBottomNavItem(icon: Icons.people_rounded, label: 'Users'),
          CustomBottomNavItem(icon: Icons.settings_rounded, label: 'Settings'),
          CustomBottomNavItem(icon: Icons.person_rounded, label: 'Profil'),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final userBox = Hive.box('userBox');
    final String roleStr = userBox.get('role', defaultValue: 'student');
    final UserRole role = UserRole.values.firstWhere(
      (e) => e.toString().split('.').last == roleStr,
      orElse: () => UserRole.student,
    );

    return Scaffold(
      body: Stack(
        children: [
          widget.child,
          CustomNavigationBar(
            currentIndex: _calculateSelectedIndex(context),
            items: _getNavItems(role, context),
            onTap: (index) => _onItemTapped(index, context, role),
          ),
        ],
      ),
    );
  }
}
