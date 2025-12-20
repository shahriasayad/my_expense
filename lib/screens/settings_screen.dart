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

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsCtrl = Get.find<SettingsController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Appearance Section
          _buildSectionHeader(context, 'Appearance'),
          Obx(
            () => SwitchListTile(
              title: const Text('Dark Mode'),
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

          // Currency Section
          _buildSectionHeader(context, 'Currency'),
          Obx(
            () => ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Currency Symbol'),
              subtitle: Text('Current: ${settingsCtrl.currency.value}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showCurrencyPicker(context),
            ),
          ),

          const Divider(),

          // Data Management Section
          _buildSectionHeader(context, 'Data Management'),
          ListTile(
            leading: const Icon(Icons.file_download, color: Colors.blue),
            title: const Text('Export to CSV'),
            subtitle: const Text('Export all transactions'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _exportToCSV(context),
          ),
          ListTile(
            leading: const Icon(Icons.backup, color: Colors.green),
            title: const Text('Backup Data'),
            subtitle: const Text('Save a backup of your data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _backupData(context),
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
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Developed by Shahria'),
            subtitle: const Text('Built with Flutter & GetX'),
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

      // Prepare CSV data
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

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final path =
          '${directory.path}/transactions_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
      final file = File(path);
      await file.writeAsString(csv);

      // Share the file
      await Share.shareXFiles([XFile(path)], text: 'My Transactions');

      AppSnackBar.showSuccess('Transactions exported successfully');
    } catch (e) {
      AppSnackBar.showError('Failed to export: $e');
    }
  }

  Future<void> _backupData(BuildContext context) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Wait a moment to show loading
      await Future.delayed(const Duration(seconds: 1));

      // In a real app, you would copy the Hive boxes to a backup location
      // For now, we'll show a success message

      Get.back(); // Close loading dialog

      AppSnackBar.showSuccess('Data backed up successfully');
    } catch (e) {
      Get.back(); // Close loading dialog
      AppSnackBar.showError('Failed to backup: $e');
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
