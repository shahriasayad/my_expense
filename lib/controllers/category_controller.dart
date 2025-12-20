import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';

class CategoryController extends GetxController {
  final box = Hive.box<CategoryModel>('categories');

  var categories = <CategoryModel>[].obs;
  var incomeCategories = <CategoryModel>[].obs;
  var expenseCategories = <CategoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  void loadCategories() {
    categories.value = box.values.toList();
    incomeCategories.value = categories
        .where((c) => c.type == 'income')
        .toList();
    expenseCategories.value = categories
        .where((c) => c.type == 'expense')
        .toList();
  }

  Future<bool> addCategory(CategoryModel category) async {
    // Check for duplicates
    final exists = categories.any(
      (c) =>
          c.name.toLowerCase() == category.name.toLowerCase() &&
          c.type == category.type,
    );

    if (exists) {
      return false;
    }

    await box.add(category);
    loadCategories();
    return true;
  }

  Future<void> updateCategory(int index, CategoryModel category) async {
    await box.putAt(index, category);
    loadCategories();
  }

  Future<bool> deleteCategory(int index) async {
    final transactionBox = Hive.box<TransactionModel>('transactions');
    final categoryId = box.getAt(index)!.id;

    // Check if category is in use
    final inUse = transactionBox.values.any((t) => t.categoryId == categoryId);

    if (inUse) {
      return false;
    }

    await box.deleteAt(index);
    loadCategories();
    return true;
  }

  CategoryModel? getCategoryById(String id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}
