import 'package:get/get.dart';

import 'package:my_expense/controllers/settings_controller.dart';
import '../models/transaction_model.dart';
import 'transaction_controller.dart';
import 'category_controller.dart';

class RecurringTransaction {
  final String id;
  final String categoryId;
  final double amount;
  final String frequency; 
  final String? note;
  final DateTime createdDate;
  final bool isActive;

  RecurringTransaction({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.frequency,
    this.note,
    required this.createdDate,
    this.isActive = true,
  });
}


class AdvancedBudgetController extends GetxController {
  late final TransactionController _transactionCtrl;
  late final CategoryController _categoryCtrl;

  var recurringTransactions = <RecurringTransaction>[].obs;

  var monthlyBudgetGoal = 0.0.obs;
  var yearlyBudgetGoal = 0.0.obs;
  var savingsGoal = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _transactionCtrl = Get.find<TransactionController>();
    _categoryCtrl = Get.find<CategoryController>();
    loadBudgetGoals();
  }

  void saveBudgetGoals({
    required double monthly,
    required double yearly,
    required double savings,
  }) {
    monthlyBudgetGoal.value = monthly;
    yearlyBudgetGoal.value = yearly;
    savingsGoal.value = savings;

  
    Get.find<SettingsController>();

  }

  void loadBudgetGoals() {
  
    monthlyBudgetGoal.value = 0.0;
    yearlyBudgetGoal.value = 0.0;
    savingsGoal.value = 0.0;
  }

 
  void addRecurringTransaction(RecurringTransaction transaction) {
    recurringTransactions.add(transaction);

  }

 
  void removeRecurringTransaction(String id) {
    recurringTransactions.removeWhere((t) => t.id == id);
  }


  double getProjectedMonthlyExpense() {
    final now = DateTime.now();
    final currentMonth = now.month;

    final actualExpenses = _transactionCtrl.transactions
        .where(
          (t) =>
              t.date.month == currentMonth &&
              t.date.year == now.year &&
              t.type == TransactionType.expense,
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    double recurringExpenses = 0.0;
    for (var recurring in recurringTransactions) {
      if (!recurring.isActive) continue;

      switch (recurring.frequency) {
        case 'daily':
          recurringExpenses += recurring.amount * 30;
          break;
        case 'weekly':
          recurringExpenses += recurring.amount * 4.3;
          break;
        case 'monthly':
          recurringExpenses += recurring.amount;
          break;
        case 'yearly':
          recurringExpenses += recurring.amount / 12;
          break;
      }
    }

    return actualExpenses + recurringExpenses;
  }


  Map<String, double> getMonthlyBudgetVsActual() {
    final now = DateTime.now();
    final currentMonth = now.month;

    final actualExpense = _transactionCtrl.transactions
        .where(
          (t) =>
              t.date.month == currentMonth &&
              t.date.year == now.year &&
              t.type == TransactionType.expense,
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    final remaining = monthlyBudgetGoal.value - actualExpense;

    return {
      'budgeted': monthlyBudgetGoal.value,
      'actual': actualExpense,
      'remaining': remaining,
      'percentUsed': monthlyBudgetGoal.value == 0
          ? 0
          : (actualExpense / monthlyBudgetGoal.value) * 100,
    };
  }


  double getSavingsRate() {
    final now = DateTime.now();
    final currentYear = now.year;

    final yearlyIncome = _transactionCtrl.transactions
        .where(
          (t) => t.date.year == currentYear && t.type == TransactionType.income,
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    final yearlyExpense = _transactionCtrl.transactions
        .where(
          (t) =>
              t.date.year == currentYear && t.type == TransactionType.expense,
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    if (yearlyIncome == 0) return 0;
    return ((yearlyIncome - yearlyExpense) / yearlyIncome) * 100;
  }

  Map<String, double> getSpendingForecast() {
    final last30Days = _transactionCtrl.transactions
        .where(
          (t) =>
              t.date.isAfter(DateTime.now().subtract(const Duration(days: 30))) &&
              t.type == TransactionType.expense,
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    final averageDaily = last30Days / 30;
    final projectedMonthly = averageDaily * 30;

    return {
      'dailyAverage': averageDaily,
      'projectedMonthly': projectedMonthly,
      'variance':
          projectedMonthly - _getLastMonthExpense(), 
    };
  }

  double _getLastMonthExpense() {
    final now = DateTime.now();
    final lastMonth = now.month == 1 ? 12 : now.month - 1;
    final lastYear = now.month == 1 ? now.year - 1 : now.year;

    return _transactionCtrl.transactions
        .where(
          (t) =>
              t.date.month == lastMonth &&
              t.date.year == lastYear &&
              t.type == TransactionType.expense,
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }


  Map<String, Map<String, dynamic>> getCategoryBudgetBreakdown() {
    final categoryExpenses = _transactionCtrl.getCategoryExpenses();
    final breakdown = <String, Map<String, dynamic>>{};

    categoryExpenses.forEach((categoryId, expense) {
      final category = _categoryCtrl.getCategoryById(categoryId);
      if (category != null) {
        final totalCategoryBudget = monthlyBudgetGoal.value / 10; // Equal split
        final percentOfBudget = totalCategoryBudget == 0
            ? 0
            : (expense / totalCategoryBudget) * 100;

        breakdown[categoryId] = {
          'categoryName': category.name,
          'icon': category.icon,
          'spent': expense,
          'budget': totalCategoryBudget,
          'percentUsed': percentOfBudget,
          'remaining': totalCategoryBudget - expense,
        };
      }
    });

    return breakdown;
  }


  List<String> getBudgetAlerts() {
    final alerts = <String>[];
    final budgetVsActual = getMonthlyBudgetVsActual();

    if (budgetVsActual['percentUsed']! > 100) {
      alerts.add(
        'Budget exceeded by \$${(budgetVsActual['actual']! - budgetVsActual['budgeted']!).toStringAsFixed(2)}',
      );
    } else if (budgetVsActual['percentUsed']! > 80) {
      alerts.add(
        'Budget usage at ${budgetVsActual['percentUsed']!.toStringAsFixed(0)}%. Be careful with spending!',
      );
    }

    final savingsRate = getSavingsRate();
    if (savingsRate < 10) {
      alerts.add(
        'Savings rate is low (${savingsRate.toStringAsFixed(0)}%). Consider reducing expenses.',
      );
    }

    return alerts;
  }
}

