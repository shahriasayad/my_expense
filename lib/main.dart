import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_expense/models/transaction_model.dart';
import 'package:my_expense/models/category_model.dart';
import 'package:my_expense/models/budget_model.dart';
import 'package:my_expense/controllers/transaction_controller.dart';
import 'package:my_expense/controllers/category_controller.dart';
import 'package:my_expense/controllers/budget_controller.dart';
import 'package:my_expense/controllers/settings_controller.dart';
import 'package:my_expense/utils/app_theme.dart';
import 'package:my_expense/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Adapters
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(CategoryModelAdapter());
  Hive.registerAdapter(BudgetModelAdapter());
  Hive.registerAdapter(TransactionTypeAdapter());

  await Hive.openBox<TransactionModel>('transactions');
  await Hive.openBox<CategoryModel>('categories');
  await Hive.openBox<BudgetModel>('budgets');
  await Hive.openBox('settings');

  final catBox = Hive.box<CategoryModel>('categories');
  if (catBox.isEmpty) {
    await _initDefaultCategories();
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

Future<void> _initDefaultCategories() async {
  final box = Hive.box<CategoryModel>('categories');

  final defaultCategories = [
    CategoryModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Food & Dining',
      icon: '🍔',
      color: '#FF6B6B',
      type: 'expense',
    ),
    CategoryModel(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      name: 'Transportation',
      icon: '🚗',
      color: '#4ECDC4',
      type: 'expense',
    ),
    CategoryModel(
      id: (DateTime.now().millisecondsSinceEpoch + 2).toString(),
      name: 'Shopping',
      icon: '🛍️',
      color: '#95E1D3',
      type: 'expense',
    ),
    CategoryModel(
      id: (DateTime.now().millisecondsSinceEpoch + 3).toString(),
      name: 'Entertainment',
      icon: '🎬',
      color: '#F38181',
      type: 'expense',
    ),
    CategoryModel(
      id: (DateTime.now().millisecondsSinceEpoch + 4).toString(),
      name: 'Bills & Utilities',
      icon: '💡',
      color: '#AA96DA',
      type: 'expense',
    ),
    CategoryModel(
      id: (DateTime.now().millisecondsSinceEpoch + 5).toString(),
      name: 'Salary',
      icon: '💰',
      color: '#5CDB95',
      type: 'income',
    ),
    CategoryModel(
      id: (DateTime.now().millisecondsSinceEpoch + 6).toString(),
      name: 'Investment',
      icon: '📈',
      color: '#379683',
      type: 'income',
    ),
  ];

  for (var cat in defaultCategories) {
    await box.add(cat);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SettingsController());
    Get.put(CategoryController());
    Get.put(TransactionController());
    Get.put(BudgetController());

    final settingsCtrl = Get.find<SettingsController>();

    return Obx(
      () => GetMaterialApp(
        title: 'Premium Expense Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: settingsCtrl.isDarkMode.value
            ? ThemeMode.dark
            : ThemeMode.light,
        home: const SplashScreen(),
        defaultTransition: Transition.fade,
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
