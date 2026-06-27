import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'groq_service.dart';
import '../providers/groq_provider.dart';
import '../providers/repositories_provider.dart';
import '../repositories/transaction_repository.dart';
import '../models/transaction.dart';

final smsServiceProvider = Provider<SmsService?>((ref) {
  final groqService = ref.watch(groqServiceProvider);
  final transactionRepo = ref.watch(transactionRepositoryProvider);
  
  if (groqService != null && transactionRepo != null) {
    return SmsService(groqService, transactionRepo);
  }
  return null;
});

class SmsService {
  final Telephony telephony = Telephony.instance;
  final GroqService groqService;
  final TransactionRepository transactionRepo;

  SmsService(this.groqService, this.transactionRepo);

  Future<bool> requestPermissions() async {
    final bool? result = await telephony.requestPhoneAndSmsPermissions;
    return result ?? false;
  }

  Future<void> listenToIncomingSms() async {
    final bool hasPermission = await requestPermissions();
    if (!hasPermission) return;

    telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) async {
        final text = message.body;
        if (text == null || text.isEmpty) return;

        final parsedData = _parseBankSms(text);
        if (parsedData != null) {
          // If regex matched, we found a transaction!
          final txn = Transaction()
            ..uuid = const Uuid().v4()
            ..amount = parsedData['amount'] as double
            ..isCredit = parsedData['type'] == 'income'
            ..type = parsedData['type'] as String
            ..categoryId = 'general'
            ..merchantId = parsedData['merchant'] as String?
            ..remark = 'SMS Parse: $text'.substring(0, 50)
            ..date = DateTime.now()
            ..createdAt = DateTime.now();
            
          await transactionRepo.addTransaction(txn);
        } else {
          // Fallback to Groq AI if Regex fails
          final lowerText = text.toLowerCase();
          if (lowerText.contains('debited') || lowerText.contains('spent')) {
            try {
               final aiData = await groqService.parseTransaction(text);
               if (aiData != null && aiData['amount'] != null) {
                  final txn = Transaction()
                    ..uuid = const Uuid().v4()
                    ..amount = double.parse(aiData['amount'].toString())
                    ..isCredit = false
                    ..type = 'expense'
                    ..categoryId = 'general'
                    ..merchantId = aiData['merchant']?.toString()
                    ..remark = 'AI SMS Parse: $text'.substring(0, 50)
                    ..date = DateTime.now()
                    ..createdAt = DateTime.now();
                  
                  await transactionRepo.addTransaction(txn);
               }
            } catch (e) {
              print('Failed to parse SMS with AI: $e');
            }
          }
        }
      },
      listenInBackground: false, 
    );
  }

  /// Open-Source Regex Engine to parse standard Indian Bank SMS
  Map<String, dynamic>? _parseBankSms(String text) {
    // Standard format: "Rs. 1500.00 debited from a/c **1234 on 24-05-23 to VPA merchant@upi"
    final amountRegex = RegExp(r"(?:(?:RS|INR|MRP|Rs)\.?\s?)(\d+(?:\.\d{1,2})?)", caseSensitive: false);
    final merchantRegex = RegExp(r"(?:to|at|info|vpa|Info)\s+([A-Za-z0-9@\s\.\*]+)", caseSensitive: false);
    final debitRegex = RegExp(r"(debited|spent|paid|deducted|withdrawn)", caseSensitive: false);

    if (debitRegex.hasMatch(text)) {
      final amountMatch = amountRegex.firstMatch(text);
      if (amountMatch != null) {
        final amount = double.tryParse(amountMatch.group(1) ?? '');
        final merchantMatch = merchantRegex.firstMatch(text);
        final merchant = merchantMatch != null ? merchantMatch.group(1)?.trim() : 'Unknown Merchant';
        
        return {
          'amount': amount,
          'merchant': merchant,
          'type': 'expense'
        };
      }
    }
    return null;
  }

  Future<List<SmsMessage>> readRecentInbox() async {
    final bool hasPermission = await requestPermissions();
    if (!hasPermission) return [];

    return await telephony.getInboxSms(
      columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
      sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)],
    );
  }
}
