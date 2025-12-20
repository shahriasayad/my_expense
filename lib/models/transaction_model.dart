import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

enum TransactionType { income, expense }

@HiveType(typeId: 1)
class TransactionModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String categoryId;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String? note;

  @HiveField(5)
  final TransactionType type;

  @HiveField(6)
  final String? receipt; // path to receipt image/pdf

  TransactionModel({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.date,
    this.note,
    required this.type,
    this.receipt,
  });

  TransactionModel copyWith({
    String? id,
    String? categoryId,
    double? amount,
    DateTime? date,
    String? note,
    TransactionType? type,
    String? receipt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
      type: type ?? this.type,
      receipt: receipt ?? this.receipt,
    );
  }

  @override
  String toString() =>
      'TransactionModel(id: $id, categoryId: $categoryId, amount: $amount, date: $date, type: $type)';
}
