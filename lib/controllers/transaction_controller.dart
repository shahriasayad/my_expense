import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/transaction_model.dart';

class TransactionController extends GetxController {
  final box = Hive.box<TransactionModel>('transactions');

  var transactions = <TransactionModel>[].obs;
  var filteredTransactions = <TransactionModel>[].obs;
  var searchQuery = ''.obs;
  var selectedCategory = ''.obs;
  var startDate = Rx<DateTime?>(null);
  var endDate = Rx<DateTime?>(null);

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  void loadTransactions() {
    transactions.value = box.values.toList();
    transactions.sort((a, b) => b.date.compareTo(a.date));
    applyFilters();
  }

  void applyFilters() {
    var filtered = transactions.toList();

    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((t) {
        final amount = t.amount.toString();
        final note = t.note?.toLowerCase() ?? '';
        final query = searchQuery.value.toLowerCase();
        return amount.contains(query) || note.contains(query);
      }).toList();
    }

    if (selectedCategory.value.isNotEmpty) {
      filtered = filtered
          .where((t) => t.categoryId == selectedCategory.value)
          .toList();
    }

    // Date range filter
    if (startDate.value != null) {
      filtered = filtered
          .where(
            (t) =>
                t.date.isAfter(startDate.value!) ||
                t.date.isAtSameMomentAs(startDate.value!),
          )
          .toList();
    }

    if (endDate.value != null) {
      filtered = filtered
          .where(
            (t) => t.date.isBefore(endDate.value!.add(const Duration(days: 1))),
          )
          .toList();
    }

    filteredTransactions.value = filtered;
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await box.add(transaction);
    loadTransactions();
  }

  Future<void> updateTransaction(
    int index,
    TransactionModel transaction,
  ) async {
    await box.putAt(index, transaction);
    loadTransactions();
  }

  Future<void> deleteTransaction(int index) async {
    await box.deleteAt(index);
    loadTransactions();
  }

  // Analytics methods
  double get totalBalance {
    double income = 0;
    double expense = 0;

    for (var t in transactions) {
      if (t.type == TransactionType.income) {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }

    return income - expense;
  }

  double get totalIncome {
    return transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }
  double get totalExpense {
    return transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }
  double getTodayExpense() {
    final today = DateTime.now();
    return transactions
        .where(
          (t) =>
              t.type == TransactionType.expense &&
              t.date.year == today.year &&
              t.date.month == today.month &&
              t.date.day == today.day,
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }
  double getWeekExpense() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    return transactions
        .where(
          (t) => t.type == TransactionType.expense && t.date.isAfter(weekStart),
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getMonthExpense() {
    final now = DateTime.now();

    return transactions
        .where(
          (t) =>
              t.type == TransactionType.expense &&
              t.date.year == now.year &&
              t.date.month == now.month,
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }
  Map<String, double> getCategoryExpenses() {
    final Map<String, double> categoryMap = {};
    for (var t in transactions) {
      if (t.type == TransactionType.expense) {
        categoryMap[t.categoryId] = (categoryMap[t.categoryId] ?? 0) + t.amount;
      }
    }
    return categoryMap;
  }
  List<TransactionModel> getTransactionsByPeriod(String period) {
    final now = DateTime.now();
    switch (period) {
      case 'today':
        return transactions
            .where(
              (t) =>
                  t.date.year == now.year &&
                  t.date.month == now.month &&
                  t.date.day == now.day,
            )
            .toList();
      case 'week':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return transactions.where((t) => t.date.isAfter(weekStart)).toList();

      case 'month':
        return transactions
            .where((t) => t.date.year == now.year && t.date.month == now.month)
            .toList();
      default:
        return transactions;
    }
  }
  void clearFilters() {
    searchQuery.value = '';
    selectedCategory.value = '';
    startDate.value = null;
    endDate.value = null;
    applyFilters();
  }
}
