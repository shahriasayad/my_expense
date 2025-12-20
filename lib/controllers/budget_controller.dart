import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/budget_model.dart';
import '../models/transaction_model.dart';
import 'transaction_controller.dart';

class BudgetController extends GetxController {
  late final TransactionController _transactionCtrl;
  final box = Hive.box<BudgetModel>('budgets');

  var budgets = <BudgetModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _transactionCtrl = Get.find<TransactionController>();
    loadBudgets();
  }

  void loadBudgets() {
    budgets.value = box.values.toList();
  }

  Future<void> addBudget(BudgetModel budget) async {
    await box.add(budget);
    loadBudgets();
  }

  Future<void> updateBudget(int index, BudgetModel budget) async {
    await box.putAt(index, budget);
    loadBudgets();
  }

  Future<void> deleteBudget(int index) async {
    await box.deleteAt(index);
    loadBudgets();
  }

  double getSpentAmount(BudgetModel budget) {
    final now = DateTime.now();
    DateTime startDate = budget.createdDate;

    if (budget.period == 'weekly') {
     
      final daysSinceStart = now.difference(startDate).inDays;
      final weeksPassed = (daysSinceStart / 7).floor();
      startDate = budget.createdDate.add(Duration(days: weeksPassed * 7));
    } else {
 
      startDate = DateTime(now.year, now.month, 1);
    }

    final endDate = budget.period == 'weekly'
        ? startDate.add(const Duration(days: 7))
        : DateTime(now.year, now.month + 1, 0);

    return _transactionCtrl.transactions
        .where(
          (t) =>
              t.categoryId == budget.categoryId &&
              t.type == TransactionType.expense &&
              t.date.isAfter(startDate) &&
              t.date.isBefore(endDate),
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getBudgetProgress(BudgetModel budget) {
    final spent = getSpentAmount(budget);
    return (spent / budget.limit).clamp(0.0, 1.0);
  }

  bool isBudgetExceeded(BudgetModel budget) {
    return getSpentAmount(budget) > budget.limit;
  }

  bool isBudgetNearLimit(BudgetModel budget) {
    final progress = getBudgetProgress(budget);
    return progress >= 0.8 && progress < 1.0;
  }
}
