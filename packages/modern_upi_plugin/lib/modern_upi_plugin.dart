import 'modern_upi_plugin_platform_interface.dart';

enum UpiPaymentStatus { SUCCESS, SUBMITTED_SUCCESS, FAILURE, nullResponse }

class UpiResponse {
  final String transactionId;
  final String responseCode;
  final String approvalRefNo;
  final UpiPaymentStatus status;
  final String transactionRefId;
  final String rawResponse;

  UpiResponse(String responseString)
      : rawResponse = responseString,
        transactionId = _extractValue(responseString, 'txnId'),
        responseCode = _extractValue(responseString, 'responseCode'),
        approvalRefNo = _extractValue(responseString, 'ApprovalRefNo'),
        status = _parseStatus(_extractValue(responseString, 'Status')),
        transactionRefId = _extractValue(responseString, 'txnRef');

  static String _extractValue(String response, String key) {
    try {
      final parts = response.split('&');
      for (final part in parts) {
        if (part.toLowerCase().startsWith('${key.toLowerCase()}=')) {
          return part.substring(key.length + 1);
        }
      }
    } catch (_) {}
    return '';
  }

  static UpiPaymentStatus _parseStatus(String statusStr) {
    if (statusStr.toUpperCase() == 'SUCCESS') return UpiPaymentStatus.SUCCESS;
    if (statusStr.toUpperCase() == 'FAILURE') return UpiPaymentStatus.FAILURE;
    if (statusStr.toUpperCase() == 'SUBMITTED') return UpiPaymentStatus.SUBMITTED_SUCCESS;
    return UpiPaymentStatus.nullResponse;
  }
}

class ModernUpiPlugin {
  Future<UpiResponse> startTransaction({
    String? app,
    required String receiverUpiId,
    required String receiverName,
    String? transactionRefId,
    String? transactionNote,
    required double amount,
  }) async {
    final response = await ModernUpiPluginPlatform.instance.startTransaction(
      app: app,
      receiverUpiId: receiverUpiId,
      receiverName: receiverName,
      transactionRefId: transactionRefId,
      transactionNote: transactionNote,
      amount: amount,
    );
    return UpiResponse(response ?? '');
  }
}
