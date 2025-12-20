import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/transaction_model.dart';
import '../models/budget_model.dart';
import 'transaction_controller.dart';
import 'budget_controller.dart';

class SettingsController extends GetxController {
  final box = Hive.box('settings');

  var isDarkMode = false.obs;
  var currency = '\$'.obs;
  var isPinEnabled = false.obs;
  var isBiometricEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  void loadSettings() {
    isDarkMode.value = box.get('isDarkMode', defaultValue: false);
    currency.value = box.get('currency', defaultValue: '\$');
    isPinEnabled.value = box.get('isPinEnabled', defaultValue: false);
    isBiometricEnabled.value = box.get(
      'isBiometricEnabled',
      defaultValue: false,
    );
  }

  Future<void> toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;
    await box.put('isDarkMode', isDarkMode.value);
  }

  Future<void> setCurrency(String newCurrency) async {
    currency.value = newCurrency;
    await box.put('currency', newCurrency);
  }

  Future<void> togglePin() async {
    isPinEnabled.value = !isPinEnabled.value;
    await box.put('isPinEnabled', isPinEnabled.value);
  }

  Future<void> toggleBiometric() async {
    isBiometricEnabled.value = !isBiometricEnabled.value;
    await box.put('isBiometricEnabled', isBiometricEnabled.value);
  }

  Future<void> wipeAllData() async {
    await Hive.box<TransactionModel>('transactions').clear();
    await Hive.box<BudgetModel>('budgets').clear();

    Get.find<TransactionController>().loadTransactions();
    Get.find<BudgetController>().loadBudgets();
  }
}
