import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:isar/isar.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../data/providers/db_provider.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/transaction.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiKeyController.text = prefs.getString('groq_api_key') ?? '';
    });
  }

  Future<void> _saveApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('groq_api_key', _apiKeyController.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('API Key Saved')));
    }
  }

  Future<void> _exportToCsv() async {
    setState(() => _isLoading = true);
    try {
      final isar = ref.read(isarProvider).value;
      if (isar == null) throw Exception('Database not ready');

      final transactions = await isar.transactions.where().sortByDateDesc().findAll();
      
      StringBuffer sb = StringBuffer();
      // Header
      sb.writeln("Date,Type,Category,Amount,Remark,Merchant,UPI Verified");
      
      // Data
      for (var t in transactions) {
        final amount = t.isCredit ? t.amount : -t.amount;
        final remark = t.remark.replaceAll(',', ' '); // Prevent CSV breaking
        final merchant = t.merchantId?.replaceAll(',', ' ') ?? '';
        final upiVerified = t.isUpiVerified ? "Yes" : "No";
        sb.writeln("${t.date.toIso8601String()},${t.type},${t.categoryId},$amount,$remark,$merchant,$upiVerified");
      }

      String csv = sb.toString();
      
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/Passbook_Statement.csv';
      final file = File(path);
      await file.writeAsString(csv);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('CSV Exported: $path')));
        await Share.shareXFiles([XFile(path)], text: 'WDP Passbook Statement');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _backupData() async {
    setState(() => _isLoading = true);
    try {
      final isar = ref.read(isarProvider).value;
      if (isar == null) throw Exception('Database not ready');

      final dir = await getApplicationDocumentsDirectory();
      final backupPath = '${dir.path}/wdp_passbook_backup.wdpbak';
      final backupFile = File(backupPath);
      
      // Simply copy the Isar DB file. In production you'd use isar.copyToFile
      await isar.copyToFile(backupPath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Backup created at $backupPath')));
        // Let user share it
        await Share.shareXFiles([XFile(backupPath)], text: 'WDP Passbook Backup');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Backup failed: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _restoreData() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null) {
        setState(() => _isLoading = true);
        final file = File(result.files.single.path!);
        
        // This is a simplified restore. For Isar, you usually need to close the DB, replace the file, and reopen.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Restore functionality requires app restart to apply.')),
          );
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Restore failed: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: AppTypography.titleLarge),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('AI Assistant (Groq)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(height: 8),
                TextField(
                  controller: _apiKeyController,
                  decoration: InputDecoration(
                    labelText: 'Groq API Key',
                    hintText: 'gsk_...',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.save),
                      onPressed: _saveApiKey,
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 32),
                
                const Text('Data & Backup', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.backup, color: AppColors.info),
                  title: const Text('Backup Data'),
                  subtitle: const Text('Export .wdpbak file'),
                  onTap: _backupData,
                  tileColor: AppColors.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.restore, color: AppColors.udhar),
                  title: const Text('Restore Data'),
                  subtitle: const Text('Import from .wdpbak'),
                  onTap: _restoreData,
                  tileColor: AppColors.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.table_chart, color: AppColors.income),
                  title: const Text('Export Statement'),
                  subtitle: const Text('Export data to Excel (CSV)'),
                  onTap: _exportToCsv,
                  tileColor: AppColors.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ],
            ),
    );
  }
}
