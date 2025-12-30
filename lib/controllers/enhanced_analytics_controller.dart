import 'package:get/get.dart';
import '../models/transaction_model.dart';
import 'transaction_controller.dart';
import 'category_controller.dart';


class EnhancedAnalyticsController extends GetxController {
  late final TransactionController _transactionCtrl;
  late final CategoryController _categoryCtrl;


  var monthlyAverageSpendings = 0.0.obs;
  var yearlyTotal = 0.0.obs;
  var highestSpendingMonth = ''.obs;
  var highestSpendingCategory = ''.obs;
  var spendingTrend = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _transactionCtrl = Get.find<TransactionController>();
    _categoryCtrl = Get.find<CategoryController>();
    calculateEnhancedMetrics();

    // Recalculate whenever transactions change
    ever(_transactionCtrl.transactions, (_) {
      calculateEnhancedMetrics();
    });
  }

  void calculateEnhancedMetrics() {
    _calculateMonthlyAverage();
    _calculateYearlyTotal();
    _findHighestSpendingMonth();
    _findHighestSpendingCategory();
    _calculateSpendingTrend();
  }

  void _calculateMonthlyAverage() {
    final now = DateTime.now();
    final currentYear = now.year;

    final monthlyData = <int, double>{};

    for (var transaction in _transactionCtrl.transactions) {
      if (transaction.date.year == currentYear &&
          transaction.type == TransactionType.expense) {
        final month = transaction.date.month;
        monthlyData[month] = (monthlyData[month] ?? 0) + transaction.amount;
      }
    }

    if (monthlyData.isEmpty) {
      monthlyAverageSpendings.value = 0.0;
    } else {
      final total = monthlyData.values.reduce((a, b) => a + b);
      monthlyAverageSpendings.value = total / monthlyData.length;
    }
  }

  /// Calculate total spending for the current year
  void _calculateYearlyTotal() {
    final now = DateTime.now();
    final currentYear = now.year;

    final total = _transactionCtrl.transactions
        .where(
          (t) =>
              t.date.year == currentYear && t.type == TransactionType.expense,
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    yearlyTotal.value = total;
  }


  void _findHighestSpendingMonth() {
    final now = DateTime.now();
    final currentYear = now.year;

    final monthlyData = <int, double>{};

    for (var transaction in _transactionCtrl.transactions) {
      if (transaction.date.year == currentYear &&
          transaction.type == TransactionType.expense) {
        final month = transaction.date.month;
        monthlyData[month] = (monthlyData[month] ?? 0) + transaction.amount;
      }
    }

    if (monthlyData.isEmpty) {
      highestSpendingMonth.value = 'N/A';
      return;
    }

    int maxMonth = 1;
    double maxAmount = 0.0;

    monthlyData.forEach((month, amount) {
      if (amount > maxAmount) {
        maxAmount = amount;
        maxMonth = month;
      }
    });

    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    highestSpendingMonth.value = monthNames[maxMonth - 1];
  }

  void _findHighestSpendingCategory() {
    final categoryExpenses = _transactionCtrl.getCategoryExpenses();

    if (categoryExpenses.isEmpty) {
      highestSpendingCategory.value = 'N/A';
      return;
    }

    String maxCategoryId = '';
    double maxAmount = 0.0;

    categoryExpenses.forEach((categoryId, amount) {
      if (amount > maxAmount) {
        maxAmount = amount;
        maxCategoryId = categoryId;
      }
    });

    final category = _categoryCtrl.getCategoryById(maxCategoryId);
    highestSpendingCategory.value =
        category?.name ?? 'Unknown ${maxCategoryId.substring(0, 5)}';
  }


  void _calculateSpendingTrend() {
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;


    final currentMonthTotal = _transactionCtrl.transactions
        .where(
          (t) =>
              t.date.year == currentYear &&
              t.date.month == currentMonth &&
              t.type == TransactionType.expense,
        )
        .fold(0.0, (sum, t) => sum + t.amount);


    final prevMonth = currentMonth == 1 ? 12 : currentMonth - 1;
    final prevYear = currentMonth == 1 ? currentYear - 1 : currentYear;
    final prevMonthTotal = _transactionCtrl.transactions
        .where(
          (t) =>
              t.date.year == prevYear &&
              t.date.month == prevMonth &&
              t.type == TransactionType.expense,
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    if (prevMonthTotal == 0) {
      spendingTrend.value = 0.0;
    } else {
      spendingTrend.value =
          ((currentMonthTotal - prevMonthTotal) / prevMonthTotal) * 100;
    }
  }


  Map<int, double> getSpendingByDayOfWeek() {
    final dayData = <int, double>{};

    for (var transaction in _transactionCtrl.transactions) {
      if (transaction.type == TransactionType.expense) {
        final dayOfWeek = transaction.date.weekday % 7; // Convert to 0-6
        dayData[dayOfWeek] = (dayData[dayOfWeek] ?? 0) + transaction.amount;
      }
    }

    return dayData;
  }

  Map<String, dynamic> getSpendingStats({
    required int days,
    required String currencySymbol,
  }) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));

    final periodTransactions = _transactionCtrl.transactions
        .where(
          (t) => t.date.isAfter(startDate) && t.type == TransactionType.expense,
        )
        .toList();

    if (periodTransactions.isEmpty) {
      return {'total': 0.0, 'average': 0.0, 'max': 0.0, 'min': 0.0, 'count': 0};
    }

    final amounts = periodTransactions.map((t) => t.amount).toList();
    final total = amounts.fold(0.0, (sum, amount) => sum + amount);

    return {
      'total': total,
      'average': total / periodTransactions.length,
      'max': amounts.reduce((a, b) => a > b ? a : b),
      'min': amounts.reduce((a, b) => a < b ? a : b),
      'count': periodTransactions.length,
    };
  }


  List<Map<String, dynamic>> getCategoryTrend(
    String categoryId, {
    required int months,
  }) {
    final now = DateTime.now();
    final trends = <Map<String, dynamic>>[];

    for (int i = months - 1; i >= 0; i--) {
      final targetDate = DateTime(now.year, now.month - i, 1);
      final monthStart = targetDate;
      final monthEnd = DateTime(targetDate.year, targetDate.month + 1, 0);

      final categoryTotal = _transactionCtrl.transactions
          .where(
            (t) =>
                t.categoryId == categoryId &&
                t.type == TransactionType.expense &&
                t.date.isAfter(monthStart) &&
                t.date.isBefore(monthEnd),
          )
          .fold(0.0, (sum, t) => sum + t.amount);

      trends.add({
        'month': targetDate.month,
        'year': targetDate.year,
        'total': categoryTotal,
      });
    }

    return trends;
  }
  Map<String, double> getFinancialSummary({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final periodTransactions = _transactionCtrl.transactions
        .where((t) => t.date.isAfter(startDate) && t.date.isBefore(endDate))
        .toList();

    final income = periodTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);

    final expense = periodTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    return {
      'income': income,
      'expense': expense,
      'net': income - expense,
      'savingsRate': income == 0 ? 0 : ((income - expense) / income) * 100,
    };
  }
}
