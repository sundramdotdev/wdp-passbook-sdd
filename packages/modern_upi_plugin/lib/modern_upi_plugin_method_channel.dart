import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'modern_upi_plugin_platform_interface.dart';

class MethodChannelModernUpiPlugin extends ModernUpiPluginPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('modern_upi_plugin');

  @override
  Future<String?> startTransaction({
    String? app,
    required String receiverUpiId,
    required String receiverName,
    String? transactionRefId,
    String? transactionNote,
    required double amount,
  }) async {
    final response = await methodChannel.invokeMethod<String>(
      'startTransaction',
      {
        'app': app,
        'receiverUpiId': receiverUpiId,
        'receiverName': receiverName,
        'transactionRefId': transactionRefId,
        'transactionNote': transactionNote,
        'amount': amount.toStringAsFixed(2),
      },
    );
    return response;
  }
}
