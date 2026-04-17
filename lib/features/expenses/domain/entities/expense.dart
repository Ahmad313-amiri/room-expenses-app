enum ExpenseScope { personal, group }

class Expense {
  final String id;
  final double amount;
  final String description;
  final DateTime date;
  final String createdBy;
  final String groupId;
  final ExpenseScope scope;
  final bool isDeleted;

  //   // userId -> amount paid   // userId -> amount should pay
  final Map<String, double> paidBy;
  final Map<String, double> split;

  const Expense({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.createdBy,
    required this.scope,
    required this.groupId,
    this.isDeleted = false,
    required this.paidBy,
    required this.split,
  });

  Expense copyWith({
    String? id,
    double? amount,
    String? description,
    DateTime? date,
    String? createdBy,
    String? groupId,
    ExpenseScope? scope,
    bool? isDeleted,
    Map<String, double>? paidBy,
    Map<String, double>? split,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      createdBy: createdBy ?? this.createdBy,
      groupId: groupId ?? this.groupId,
      scope: scope ?? this.scope,
      isDeleted: isDeleted ?? this.isDeleted,
      paidBy: paidBy ?? this.paidBy,
      split: split ?? this.split,
    );
  }
}