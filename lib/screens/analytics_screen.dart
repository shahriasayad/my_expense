import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../controllers/transaction_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/settings_controller.dart';
import '../models/transaction_model.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'month';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'By Category'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildOverviewTab(), _buildCategoryTab()],
      ),
    );
  }

  Widget _buildOverviewTab() {
    Get.find<TransactionController>();
    final settingsCtrl = Get.find<SettingsController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period Selector
          Row(
            children: [
              Expanded(child: _buildPeriodButton('Week', 'week')),
              const SizedBox(width: 8),
              Expanded(child: _buildPeriodButton('Month', 'month')),
              const SizedBox(width: 8),
              Expanded(child: _buildPeriodButton('Year', 'year')),
            ],
          ),

          const SizedBox(height: 24),

          // Summary Cards
          Obx(() {
            final transactions = _getFilteredTransactions();
            final income = transactions
                .where((t) => t.type == TransactionType.income)
                .fold(0.0, (sum, t) => sum + t.amount);
            final expense = transactions
                .where((t) => t.type == TransactionType.expense)
                .fold(0.0, (sum, t) => sum + t.amount);

            return Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Income',
                    '${settingsCtrl.currency.value}${income.toStringAsFixed(2)}',
                    Icons.arrow_downward,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Expense',
                    '${settingsCtrl.currency.value}${expense.toStringAsFixed(2)}',
                    Icons.arrow_upward,
                    Colors.red,
                  ),
                ),
              ],
            );
          }),

          const SizedBox(height: 24),

          // Bar Chart
          Text('Spending Trend', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Obx(() => _buildBarChart()),

          const SizedBox(height: 24),

          // Transaction List
          Text(
            'Recent Transactions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Obx(() {
            final transactions = _getFilteredTransactions().take(5).toList();
            return _buildTransactionList(transactions);
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryTab() {
    final transactionCtrl = Get.find<TransactionController>();
    final categoryCtrl = Get.find<CategoryController>();
    final settingsCtrl = Get.find<SettingsController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pie Chart
          Text(
            'Expense by Category',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Obx(() {
            final categoryExpenses = transactionCtrl.getCategoryExpenses();

            if (categoryExpenses.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No expense data available'),
                ),
              );
            }

            return SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: categoryExpenses.entries.map((entry) {
                    final category = categoryCtrl.getCategoryById(entry.key);
                    final color = category != null
                        ? Color(
                            int.parse(category.color.replaceFirst('#', '0xFF')),
                          )
                        : Colors.grey;
                    final total = categoryExpenses.values.reduce(
                      (a, b) => a + b,
                    );
                    final percentage = (entry.value / total * 100);

                    return PieChartSectionData(
                      value: entry.value,
                      title: '${percentage.toStringAsFixed(1)}%',
                      color: color,
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  pieTouchData: PieTouchData(enabled: true),
                ),
              ),
            );
          }),

          const SizedBox(height: 24),

          // Category List
          Text(
            'Category Breakdown',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Obx(() {
            final categoryExpenses = transactionCtrl.getCategoryExpenses();
            final sortedEntries = categoryExpenses.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

            if (sortedEntries.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No data available'),
                ),
              );
            }

            final total = categoryExpenses.values.reduce((a, b) => a + b);

            return Column(
              children: sortedEntries.map((entry) {
                final category = categoryCtrl.getCategoryById(entry.key);
                final percentage = (entry.value / total * 100);
                final color = category != null
                    ? Color(int.parse(category.color.replaceFirst('#', '0xFF')))
                    : Colors.grey;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  category?.icon ?? '❓',
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category?.name ?? 'Unknown',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${percentage.toStringAsFixed(1)}% of total',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${settingsCtrl.currency.value}${entry.value.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, String period) {
    final isSelected = _selectedPeriod == period;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.displayLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    final transactions = _getFilteredTransactions();

    if (transactions.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: Text('No data available')),
      );
    }

    final Map<String, double> dailyExpenses = {};

    for (var t in transactions) {
      if (t.type == TransactionType.expense) {
        final key = DateFormat('MM/dd').format(t.date);
        dailyExpenses[key] = (dailyExpenses[key] ?? 0) + t.amount;
      }
    }

    final sortedKeys = dailyExpenses.keys.toList()..sort();
    final displayKeys = sortedKeys.length > 7
        ? sortedKeys.sublist(sortedKeys.length - 7)
        : sortedKeys;

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (dailyExpenses.values.reduce((a, b) => a > b ? a : b) * 1.2),
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 &&
                      value.toInt() < displayKeys.length) {
                    return Text(
                      displayKeys[value.toInt()].split('/')[1],
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: displayKeys.asMap().entries.map((entry) {
            final value = dailyExpenses[entry.value] ?? 0;
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: value,
                  color: Theme.of(context).primaryColor,
                  width: 16,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTransactionList(List<TransactionModel> transactions) {
    if (transactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No transactions found'),
        ),
      );
    }

    final categoryCtrl = Get.find<CategoryController>();
    final settingsCtrl = Get.find<SettingsController>();

    return Column(
      children: transactions.map((transaction) {
        final category = categoryCtrl.getCategoryById(transaction.categoryId);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: category != null
                    ? Color(
                        int.parse(category.color.replaceFirst('#', '0xFF')),
                      ).withOpacity(0.1)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  category?.icon ?? '❓',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            title: Text(
              category?.name ?? 'Unknown',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(DateFormat('MMM dd, yyyy').format(transaction.date)),
            trailing: Text(
              '${transaction.type == TransactionType.expense ? '-' : '+'}${settingsCtrl.currency.value}${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: transaction.type == TransactionType.expense
                    ? Colors.red
                    : Colors.green,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  List<TransactionModel> _getFilteredTransactions() {
    final transactionCtrl = Get.find<TransactionController>();
    final now = DateTime.now();

    switch (_selectedPeriod) {
      case 'week':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return transactionCtrl.transactions
            .where((t) => t.date.isAfter(weekStart))
            .toList();

      case 'month':
        return transactionCtrl.transactions
            .where((t) => t.date.year == now.year && t.date.month == now.month)
            .toList();

      case 'year':
        return transactionCtrl.transactions
            .where((t) => t.date.year == now.year)
            .toList();

      default:
        return transactionCtrl.transactions;
    }
  }
}
