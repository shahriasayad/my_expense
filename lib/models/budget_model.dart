import 'package:hive/hive.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 3)
class BudgetModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String categoryId;

  @HiveField(2)
  final double limit;

  @HiveField(3)
  final String period; 
  @HiveField(4)
  final DateTime createdDate;

  @HiveField(5)
  final bool isActive;

  BudgetModel({
    required this.id,
    required this.categoryId,
    required this.limit,
    required this.period,
    required this.createdDate,
    this.isActive = true,
  });

  BudgetModel copyWith({
    String? id,
    String? categoryId,
    double? limit,
    String? period,
    DateTime? createdDate,
    bool? isActive,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      limit: limit ?? this.limit,
      period: period ?? this.period,
      createdDate: createdDate ?? this.createdDate,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() =>
      'BudgetModel(id: $id, categoryId: $categoryId, limit: $limit, period: $period)';
}
