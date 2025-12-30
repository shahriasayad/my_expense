import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/transaction_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/settings_controller.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../utils/app_snackbar.dart';
import 'add_transaction_screen.dart';
import 'analytics_screen.dart';
import 'categories_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardTab(),
    const AnalyticsScreen(),
    const CategoriesScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      floatingActionButton: null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category),
            label: 'Categories',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class DashboardTab extends StatelessWidget {
  const DashboardTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final transactionCtrl = Get.find<TransactionController>();
    final categoryCtrl = Get.find<CategoryController>();
    final settingsCtrl = Get.find<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchSheet(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          transactionCtrl.loadTransactions();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Card
              Obx(
                () => _buildBalanceCard(context, transactionCtrl, settingsCtrl),
              ),

              const SizedBox(height: 20),

              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => _buildSummaryCard(
                        context,
                        'Today',
                        transactionCtrl.getTodayExpense(),
                        Icons.today,
                        Colors.blue,
                        settingsCtrl.currency.value,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(
                      () => _buildSummaryCard(
                        context,
                        'Week',
                        transactionCtrl.getWeekExpense(),
                        Icons.date_range,
                        Colors.purple,
                        settingsCtrl.currency.value,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => _buildSummaryCard(
                        context,
                        'Month',
                        transactionCtrl.getMonthExpense(),
                        Icons.calendar_month,
                        Colors.orange,
                        settingsCtrl.currency.value,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(
                      () => _buildSummaryCard(
                        context,
                        'Total',
                        transactionCtrl.totalExpense,
                        Icons.attach_money,
                        Colors.red,
                        settingsCtrl.currency.value,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),

                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () =>
                            Get.to(() => const AddTransactionScreen()),
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => _showSearchSheet(context),
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Obx(() {
                final transactions = transactionCtrl.transactions
                    .take(10)
                    .toList();

                if (transactions.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No transactions yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  key: const ValueKey('transactions_list'),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    final category = categoryCtrl.getCategoryById(
                      transaction.categoryId,
                    );

                    return _buildTransactionTile(
                      context,
                      transaction,
                      category,
                      index,
                      settingsCtrl.currency.value,
                      key: ValueKey(transaction.id),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(
    BuildContext context,
    TransactionController ctrl,
    SettingsController settings,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Balance',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '${settings.currency.value}${ctrl.totalBalance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBalanceItem(
                'Income',
                '${settings.currency.value}${ctrl.totalIncome.toStringAsFixed(2)}',
                Icons.arrow_downward,
                Colors.greenAccent,
              ),
              _buildBalanceItem(
                'Expense',
                '${settings.currency.value}${ctrl.totalExpense.toStringAsFixed(2)}',
                Icons.arrow_upward,
                Colors.redAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceItem(
    String label,
    String amount,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Text(
              amount,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    double amount,
    IconData icon,
    Color color,
    String currency,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
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
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$currency${amount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(
    BuildContext context,
    TransactionModel transaction,
    CategoryModel? category,
    int index,
    String currency, {
    Key? key,
  }) {
    final transactionCtrl = Get.find<TransactionController>();

    return Card(
      key: key,
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('MMM dd, yyyy').format(transaction.date)),
            if (transaction.note != null && transaction.note!.isNotEmpty)
              Text(
                transaction.note!,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Text(
          '${transaction.type == TransactionType.expense ? '-' : '+'}$currency${transaction.amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: transaction.type == TransactionType.expense
                ? Colors.red
                : Colors.green,
          ),
        ),
        onTap: () {
          Get.to(
            () => AddTransactionScreen(transaction: transaction, index: index),
          );
        },
        onLongPress: () {
          _showDeleteDialog(context, index, transactionCtrl);
        },
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    int index,
    TransactionController ctrl,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text(
          'Are you sure you want to delete this transaction?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ctrl.deleteTransaction(index);
              Get.back();
              AppSnackBar.showSuccess(
                'Transaction deleted successfully',
                title: 'Deleted',
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSearchSheet(BuildContext context) {
    Get.bottomSheet(
      const TransactionSearchSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class TransactionSearchSheet extends StatelessWidget {
  const TransactionSearchSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final transactionCtrl = Get.find<TransactionController>();
    final categoryCtrl = Get.find<CategoryController>();
    final settingsCtrl = Get.find<SettingsController>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Search and Filters
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search transactions...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    transactionCtrl.searchQuery.value = value;
                    transactionCtrl.applyFilters();
                  },
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Obx(
                        () => ChoiceChip(
                          label: const Text('All Categories'),
                          selected:
                              transactionCtrl.selectedCategory.value.isEmpty,
                          onSelected: (selected) {
                            if (selected) {
                              transactionCtrl.selectedCategory.value = '';
                              transactionCtrl.applyFilters();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      ...categoryCtrl.categories.map(
                        (cat) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Obx(
                            () => ChoiceChip(
                              label: Text('${cat.icon} ${cat.name}'),
                              selected:
                                  transactionCtrl.selectedCategory.value ==
                                  cat.id,
                              onSelected: (selected) {
                                transactionCtrl.selectedCategory.value =
                                    selected ? cat.id : '';
                                transactionCtrl.applyFilters();
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

         
          Expanded(
            child: Obx(() {
              final transactions = transactionCtrl.filteredTransactions;

              if (transactions.isEmpty) {
                return const Center(child: Text('No transactions found'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  final category = categoryCtrl.getCategoryById(
                    transaction.categoryId,
                  );
                  final realIndex = transactionCtrl.transactions.indexOf(
                    transaction,
                  );

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: category != null
                              ? Color(
                                  int.parse(
                                    category.color.replaceFirst('#', '0xFF'),
                                  ),
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
                      subtitle: Text(
                        DateFormat('MMM dd, yyyy').format(transaction.date),
                      ),
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
                      onTap: () {
                        Get.back();
                        Get.to(
                          () => AddTransactionScreen(
                            transaction: transaction,
                            index: realIndex,
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
