import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import '../../core/constants/app_colors.dart';
import '../../data/providers/db_provider.dart';
import '../../core/widgets/clay_container.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  late VideoPlayerController _controller;
  bool _isVideoInitialized = false;
  bool _isVideoError = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // 1. Start a strict 5-second timer
    final timerFuture = Future.delayed(const Duration(seconds: 5));

    // 2. Start loading the database
    final dbFuture = ref.read(isarProvider.future);

    // 3. Try to initialize the video
    try {
      _controller = VideoPlayerController.asset('assets/videos/splash.mp4');
      await _controller.initialize();
      await _controller.setVolume(0.0);
      await _controller.setLooping(true); // Loop so it doesn't just stop instantly
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }
      await _controller.play();
      FlutterNativeSplash.remove(); // Safely remove native splash NOW that video is ready
    } catch (e) {
      debugPrint("Video Error: $e");
      FlutterNativeSplash.remove(); // Remove anyway if it failed
      if (mounted) {
        setState(() {
          _isVideoError = true;
        });
      }
    }

    // 4. Wait for BOTH database and the 5-second timer to complete
    await Future.wait([dbFuture, timerFuture]);

    // 5. Navigate
    _navigateToHome();
  }

  void _navigateToHome() {
    if (mounted) {
      context.go('/passbook');
    }
  }

  @override
  void dispose() {
    if (!_isVideoError && _isVideoInitialized) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: _isVideoError
            ? _buildLogoFallback()
            : _isVideoInitialized
                ? SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller.value.size.width,
                        height: _controller.value.size.height,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                  )
                : const CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }

  Widget _buildLogoFallback() {
    return ClayContainer(
      width: 150,
      height: 150,
      borderRadius: 40,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
