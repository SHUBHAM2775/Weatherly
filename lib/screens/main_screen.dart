// ============================================================
// main_screen.dart
// The shell of the app — holds the bottom navigation bar
// and switches between the 5 main screens.
// ============================================================

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'home_screen.dart';
import 'forecast_screen.dart';
import 'aqi_screen.dart';
import 'map_screen.dart';
import 'travel_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Which tab is currently shown (0 = Home)
  int _currentIndex = 0;

  // The five screens — using IndexedStack keeps them alive when switching
  final List<Widget> _screens = const [
    HomeScreen(),
    ForecastScreen(),
    AqiScreen(),
    MapScreen(),
    TravelScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.home_rounded, Icons.home_outlined, l10n.home),
              _navItem(1, Icons.calendar_month_rounded,
                  Icons.calendar_month_outlined, l10n.forecast),
              _navItem(2, Icons.air_rounded, Icons.air_outlined, l10n.air),
              _navItem(3, Icons.map_rounded, Icons.map_outlined, l10n.map),
              _navItem(
                  4, Icons.flight_rounded, Icons.flight_outlined, l10n.travel),
              _navItem(5, Icons.settings_rounded, Icons.settings_outlined,
                  l10n.settings),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(
      int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final bool isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF0288D1).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : inactiveIcon,
              color:
                  isActive ? const Color(0xFF0288D1) : const Color(0xFF90A4AE),
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? const Color(0xFF0288D1)
                    : const Color(0xFF90A4AE),
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
