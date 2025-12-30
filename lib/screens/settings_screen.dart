import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../controllers/settings_controller.dart';
import '../controllers/transaction_controller.dart';
import '../controllers/category_controller.dart';
import '../models/transaction_model.dart';
import '../utils/app_snackbar.dart';
import '../utils/responsive_layout.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsCtrl = Get.find<SettingsController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveLayout.getResponsiveVerticalPadding(context),
        ),
        children: [
      
          _buildSectionHeader(context, 'Appearance'),
          Obx(
            () => SwitchListTile(
              title: Text(
                'Dark Mode',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              subtitle: const Text('Switch between light and dark theme'),
              secondary: Icon(
                settingsCtrl.isDarkMode.value
                    ? Icons.dark_mode
                    : Icons.light_mode,
              ),
              value: settingsCtrl.isDarkMode.value,
              onChanged: (value) => settingsCtrl.toggleTheme(),
            ),
          ),

          const Divider(),

          _buildSectionHeader(context, 'Currency'),
          Obx(
            () => ListTile(
              leading: const Icon(Icons.attach_money),
              title: Text(
                'Currency Symbol',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              subtitle: Text('Current: ${settingsCtrl.currency.value}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showCurrencyPicker(context),
            ),
          ),

          const Divider(),

        
          _buildSectionHeader(context, 'Data Management'),
          ListTile(
            leading: const Icon(Icons.file_download, color: Colors.blue),
            title: const Text('Export to CSV'),
            subtitle: const Text('Export all transactions'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _exportToCSV(context),
          ),

          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Wipe All Data'),
            subtitle: const Text('Delete all transactions and budgets'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showWipeDataDialog(context),
          ),

          const Divider(),

          _buildSectionHeader(context, 'About'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
          const ListTile(
            leading: Icon(Icons.code),
            title: Text('Developed by Shahria'),
            subtitle: Text('Built with Flutter & GetX'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context) {
    final currencies = [
      {'symbol': '\$', 'name': 'US Dollar'},
      {'symbol': '€', 'name': 'Euro'},
      {'symbol': '£', 'name': 'British Pound'},
      {'symbol': '¥', 'name': 'Japanese Yen'},
      {'symbol': '₹', 'name': 'Indian Rupee'},
      {'symbol': '৳', 'name': 'Bangladeshi Taka'},
      {'symbol': 'R\$', 'name': 'Brazilian Real'},
      {'symbol': 'C\$', 'name': 'Canadian Dollar'},
      {'symbol': 'A\$', 'name': 'Australian Dollar'},
      {'symbol': '¥', 'name': 'Chinese Yuan'},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final settingsCtrl = Get.find<SettingsController>();

        return ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: currencies.length,
          itemBuilder: (context, index) {
            final currency = currencies[index];
            return Obx(
              () => RadioListTile<String>(
                title: Text('${currency['symbol']} - ${currency['name']}'),
                value: currency['symbol']!,
                groupValue: settingsCtrl.currency.value,
                onChanged: (value) {
                  settingsCtrl.setCurrency(value!);
                  Navigator.pop(context);
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _exportToCSV(BuildContext context) async {
    try {
      final transactionCtrl = Get.find<TransactionController>();
      final categoryCtrl = Get.find<CategoryController>();

   
      List<List<dynamic>> rows = [
        ['Date', 'Type', 'Category', 'Amount', 'Note'],
      ];

      for (var transaction in transactionCtrl.transactions) {
        final category = categoryCtrl.getCategoryById(transaction.categoryId);
        rows.add([
          DateFormat('yyyy-MM-dd').format(transaction.date),
          transaction.type == TransactionType.expense ? 'Expense' : 'Income',
          category?.name ?? 'Unknown',
          transaction.amount,
          transaction.note ?? '',
        ]);
      }

      String csv = const ListToCsvConverter().convert(rows);
      final directory = await getApplicationDocumentsDirectory();
      final path =
          '${directory.path}/transactions_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
      final file = File(path);
      await file.writeAsString(csv);


      await Share.shareXFiles([XFile(path)], text: 'My Transactions');

      AppSnackBar.showSuccess('Transactions exported successfully');
    } catch (e) {
      AppSnackBar.showError('Failed to export: $e');
    }
  }

  void _showWipeDataDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Wipe All Data'),
        content: const Text(
          'This will permanently delete all your transactions and budgets. This action cannot be undone.\n\nAre you absolutely sure?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              _confirmWipeData(context);
            },
            child: const Text(
              'Continue',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmWipeData(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text(
          'Final Confirmation',
          style: TextStyle(color: Colors.red),
        ),
        content: const Text('Type "DELETE" to confirm data wipe.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final controller = TextEditingController();

              Get.back();
              Get.dialog(
                AlertDialog(
                  title: const Text('Enter DELETE'),
                  content: TextField(
                    controller: controller,
                    decoration: const InputDecoration(hintText: 'Type DELETE'),
                    textCapitalization: TextCapitalization.characters,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (controller.text == 'DELETE') {
                          final settingsCtrl = Get.find<SettingsController>();
                          await settingsCtrl.wipeAllData();

                          Get.back();
                          AppSnackBar.showSuccess('All data has been wiped');
                        } else {
                          AppSnackBar.showError('Incorrect confirmation text');
                        }
                      },
                      child: const Text(
                        'Delete Everything',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Proceed', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
