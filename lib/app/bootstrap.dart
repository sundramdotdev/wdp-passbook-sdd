import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

/// Bootstraps the WDP Passbook application with required dependencies,
/// error handling, and platform configurations.
Future<void> bootstrap() async {
  // 1. Ensure Flutter bindings are ready
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // 2. Preserve native splash until app is ready
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 3. Set device orientation preferences
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 4. Catch and log Flutter framework errors cleanly
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exceptionAsString()}');
  };

  // 5. Run the root application wrapped in ProviderScope
  runApp(
    const ProviderScope(
      child: WdpApp(),
    ),
  );

  // 6. Remove native splash once initial frame renders
  WidgetsBinding.instance.addPostFrameCallback((_) {
    FlutterNativeSplash.remove();
  });
}
