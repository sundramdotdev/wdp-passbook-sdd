import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/transaction.dart';
import '../models/merchant.dart';
import '../models/udhar_entry.dart';
import '../models/budget.dart';
import '../models/category.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    final dir = await getApplicationDocumentsDirectory();
    if (Isar.instanceNames.isEmpty) {
      final isar = await Isar.open(
        [
          TransactionSchema,
          MerchantSchema,
          UdharEntrySchema,
          BudgetSchema,
          CategorySchema
        ],
        directory: dir.path,
      );
      
      // Seed categories on first launch
      await _seedCategories(isar);
      return isar;
    }
    return Future.value(Isar.getInstance());
  }

  Future<void> _seedCategories(Isar isar) async {
    final count = await isar.categorys.count();
    if (count == 0) {
      final defaultCategories = [
        Category()
          ..uuid = 'cat_food'
          ..emoji = '🍔'
          ..name = 'Food'
          ..colorHex = '#F97316'
          ..isDefault = true
          ..keywords = ['burger', 'maggi', 'chai', 'pizza', 'momos', 'khana', 'biryani', 'sandwich', 'dosa', 'cold drink', 'juice', 'milk']
          ..createdAt = DateTime.now(),
        Category()
          ..uuid = 'cat_edu'
          ..emoji = '📚'
          ..name = 'Education'
          ..colorHex = '#60A5FA'
          ..isDefault = true
          ..keywords = ['photocopy', 'print', 'book', 'notes', 'pen', 'pencil', 'xerox', 'assignment']
          ..createdAt = DateTime.now(),
        Category()
          ..uuid = 'cat_travel'
          ..emoji = '🚗'
          ..name = 'Travel'
          ..colorHex = '#A78BFA'
          ..isDefault = true
          ..keywords = ['auto', 'cab', 'bus', 'rickshaw', 'petrol', 'train', 'metro', 'ola', 'uber', 'rapido']
          ..createdAt = DateTime.now(),
        Category()
          ..uuid = 'cat_medical'
          ..emoji = '💊'
          ..name = 'Medical'
          ..colorHex = '#F87171'
          ..isDefault = true
          ..keywords = ['dawa', 'medicine', 'tablet', 'doctor', 'hospital', 'pharmacy']
          ..createdAt = DateTime.now(),
        Category()
          ..uuid = 'cat_fun'
          ..emoji = '🎮'
          ..name = 'Fun'
          ..colorHex = '#34D399'
          ..isDefault = true
          ..keywords = ['movie', 'game', 'outing', 'party', 'cinema', 'hangout', 'mall']
          ..createdAt = DateTime.now(),
        Category()
          ..uuid = 'cat_shopping'
          ..emoji = '🛒'
          ..name = 'Shopping'
          ..colorHex = '#FBBF24'
          ..isDefault = true
          ..keywords = ['clothes', 'shoes', 'bag', 'shirt', 'jeans', 'footwear']
          ..createdAt = DateTime.now(),
        Category()
          ..uuid = 'cat_hostel'
          ..emoji = '🏠'
          ..name = 'Hostel'
          ..colorHex = '#6EE7B7'
          ..isDefault = true
          ..keywords = ['mess', 'rent', 'laundry', 'room', 'hostel', 'warden']
          ..createdAt = DateTime.now(),
        Category()
          ..uuid = 'cat_utils'
          ..emoji = '⚡'
          ..name = 'Utilities'
          ..colorHex = '#93C5FD'
          ..isDefault = true
          ..keywords = ['mobile recharge', 'wifi', 'internet', 'electricity', 'recharge', 'jio', 'airtel', 'vi']
          ..createdAt = DateTime.now(),
        Category()
          ..uuid = 'cat_others'
          ..emoji = '🎁'
          ..name = 'Others'
          ..colorHex = '#9CA3AF'
          ..isDefault = true
          ..keywords = []
          ..createdAt = DateTime.now(),
      ];

      await isar.writeTxn(() async {
        await isar.categorys.putAll(defaultCategories);
      });
    }
  }
}
