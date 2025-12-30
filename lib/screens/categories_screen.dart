import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../controllers/category_controller.dart';
import '../models/transaction_model.dart';
import '../utils/app_snackbar.dart';
import '../utils/responsive_layout.dart';
import 'add_category_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Categories'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Expense'),
              Tab(text: 'Income'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCategoryList(context, TransactionType.expense),
            _buildCategoryList(context, TransactionType.income),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Get.to(() => const AddCategoryScreen()),
          icon: const Icon(Icons.add),
          label: const Text('Add Category'),
        ),
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context, TransactionType type) {
    final categoryCtrl = Get.find<CategoryController>();

    return Obx(() {
      final categories = type == TransactionType.expense
          ? categoryCtrl.expenseCategories
          : categoryCtrl.incomeCategories;

      if (categories.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.category_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No categories yet',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(
          ResponsiveLayout.getResponsiveHorizontalPadding(context),
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final color = Color(
            int.parse(category.color.replaceFirst('#', '0xFF')),
          );
          final realIndex = categoryCtrl.categories.indexOf(category);

          return Card(
            margin: EdgeInsets.only(
              bottom: ResponsiveLayout.getResponsiveGap(context),
            ),
            child: ListTile(
              leading: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    category.icon,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              title: Text(
                category.name,
                style: TextStyle(
                  fontSize: ResponsiveLayout.getResponsiveFontSize(
                    context,
                    mobileSize: 14,
                    tabletSize: 16,
                    desktopSize: 18,
                  ),
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                type == TransactionType.expense ? 'Expense' : 'Income',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () {
                      Get.to(
                        () => AddCategoryScreen(
                          category: category,
                          index: realIndex,
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                    onPressed: () => _showDeleteDialog(context, realIndex),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  void _showDeleteDialog(BuildContext context, int index) {
    final categoryCtrl = Get.find<CategoryController>();

    Get.dialog(
      AlertDialog(
        title: const Text('Delete Category'),
        content: const Text(
          'Are you sure you want to delete this category? Categories in use cannot be deleted.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final success = await categoryCtrl.deleteCategory(index);
              Get.back();

              if (success) {
                AppSnackBar.showSuccess(
                  'Category deleted successfully',
                  title: 'Deleted',
                );
              } else {
                AppSnackBar.showError(
                  'This category is being used in existing transactions.',
                  title: 'Cannot delete category',
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
