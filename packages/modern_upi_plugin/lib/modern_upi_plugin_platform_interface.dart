import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'modern_upi_plugin_method_channel.dart';

abstract class ModernUpiPluginPlatform extends PlatformInterface {
  ModernUpiPluginPlatform() : super(token: _token);

  static final Object _token = Object();
  static ModernUpiPluginPlatform _instance = MethodChannelModernUpiPlugin();

  static ModernUpiPluginPlatform get instance => _instance;
  static set instance(ModernUpiPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> startTransaction({
    String? app,
    required String receiverUpiId,
    required String receiverName,
    String? transactionRefId,
    String? transactionNote,
    required double amount,
  }) {
    throw UnimplementedError('startTransaction() has not been implemented.');
  }
}
