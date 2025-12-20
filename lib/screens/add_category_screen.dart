import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/category_controller.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../utils/app_snackbar.dart';

class AddCategoryScreen extends StatefulWidget {
  final CategoryModel? category;
  final int? index;
  final TransactionType? type;

  const AddCategoryScreen({Key? key, this.category, this.index, this.type})
    : super(key: key);

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  late String _selectedType;
  String _selectedIcon = '💰';
  String _selectedColor = '#4ECDC4';

  final List<String> _icons = [
    '💰',
    '🍔',
    '🚗',
    '🏠',
    '💡',
    '🎬',
    '🛍️',
    '✈️',
    '🏥',
    '📚',
    '🎮',
    '☕',
    '🎵',
    '🏋️',
    '👔',
    '🎨',
    '💼',
    '🎓',
    '🔧',
    '📱',
    '💊',
    '🚌',
    '🏪',
    '🎁',
    '🎲',
  ];

  final List<String> _colors = [
    '#FF6B6B',
    '#4ECDC4',
    '#95E1D3',
    '#F38181',
    '#AA96DA',
    '#5CDB95',
    '#379683',
    '#667EEA',
    '#764BA2',
    '#FFE66D',
    '#FF6B9D',
    '#C44569',
    '#F8B500',
    '#3E64FF',
    '#9B59B6',
  ];

  bool get isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      _nameController.text = widget.category!.name;
      _selectedType = widget.category!.type;
      _selectedIcon = widget.category!.icon;
      _selectedColor = widget.category!.color;
    } else {
      _selectedType = widget.type == TransactionType.income
          ? 'income'
          : 'expense';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Category' : 'Add Category')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Category Name',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Enter category name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter category name';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            Text('Type', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTypeButton(
                    'Expense',
                    'expense',
                    Icons.arrow_upward,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTypeButton(
                    'Income',
                    'income',
                    Icons.arrow_downward,
                    Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Text('Icon', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _icons.map((icon) => _buildIconButton(icon)).toList(),
              ),
            ),

            const SizedBox(height: 24),

            Text('Color', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _colors
                    .map((color) => _buildColorButton(color))
                    .toList(),
              ),
            ),

            const SizedBox(height: 24),

            Text('Preview', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Color(
                        int.parse(_selectedColor.replaceFirst('#', '0xFF')),
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        _selectedIcon,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _nameController.text.isEmpty
                              ? 'Category Name'
                              : _nameController.text,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _selectedType == 'expense' ? 'Expense' : 'Income',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _saveCategory,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                isEditing ? 'Update Category' : 'Save Category',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(
    String label,
    String type,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedType == type;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.1)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(String icon) {
    final isSelected = _selectedIcon == icon;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedIcon = icon;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(child: Text(icon, style: const TextStyle(fontSize: 24))),
      ),
    );
  }

  Widget _buildColorButton(String color) {
    final isSelected = _selectedColor == color;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Color(
                      int.parse(color.replaceFirst('#', '0xFF')),
                    ).withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
      ),
    );
  }

  void _saveCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final categoryCtrl = Get.find<CategoryController>();

    final category = CategoryModel(
      id: isEditing
          ? widget.category!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      icon: _selectedIcon,
      color: _selectedColor,
      type: _selectedType,
    );

    if (isEditing) {
      await categoryCtrl.updateCategory(widget.index!, category);
      Get.back();
      AppSnackBar.showSuccess(
        'Category updated successfully',
        title: 'Updated',
      );
    } else {
      final success = await categoryCtrl.addCategory(category);

      if (success) {
        Get.back();
        AppSnackBar.showSuccess('Category added successfully');
      } else {
        AppSnackBar.showError('Category with this name already exists');
      }
    }
  }
}
