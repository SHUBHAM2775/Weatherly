// ============================================================
// splash_screen.dart
// The first screen shown when the app opens.
// Shows logo + animation while fetching weather in background.
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/weather_provider.dart';
import '../l10n/app_localizations.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  String? _statusTextKey;

  @override
  void initState() {
    super.initState();

    // Set up entrance animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();

    // Start loading data after a short delay (lets animation play first)
    Future.delayed(const Duration(milliseconds: 500), _loadData);
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _statusTextKey = 'detectingLocation');

    final provider = context.read<WeatherProvider>();
    await provider.fetchWeatherByLocation();

    if (!mounted) return;

    if (provider.loadingState == LoadingState.success) {
      setState(() => _statusTextKey = 'ready');
      await Future.delayed(const Duration(milliseconds: 300));
    } else {
      // Keep error message as-is since it's dynamic
      setState(() => _statusTextKey = null);
      await Future.delayed(const Duration(seconds: 2));
    }

    if (!mounted) return;

    // Navigate to main app with a smooth fade
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MainScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getStatusText(BuildContext context, String? key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case 'detectingLocation':
        return l10n.detectingLocation;
      case 'ready':
        return l10n.ready;
      default:
        return l10n.startingUp;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        // Beautiful blue gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D47A1),
              Color(0xFF1565C0),
              Color(0xFF42A5F5),
              Color(0xFF80D8FF)
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App icon with scale animation
                  ScaleTransition(
                    scale: _scaleAnim,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withOpacity(0.4), width: 2),
                      ),
                      child: const Icon(
                        Icons.wb_sunny_rounded,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // App name
                  Text(
                    l10n.appName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.appTagline,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.8), fontSize: 15),
                  ),

                  const SizedBox(height: 56),

                  // Loading spinner
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.85)),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Status text (animates between messages)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _getStatusText(context, _statusTextKey),
                      key: ValueKey(_statusTextKey ?? 'starting'), // key = triggers animation
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8), fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
