

import '../../../home/presentation/pages/activity_page.dart';

class GroupBalanceService {
  static Map<String, double> calculate({
    required List<ExpenseWithDebts> expenses,
    required List<Map<String, dynamic>> settlements,
  }) {
    final Map<String, double> balance = {};

    // =========================
    // 1. EXPENSES
    // =========================
    for (final expense in expenses) {
      final payer = expense.payerId;
      final amount = expense.amount;

      // payer gets +money
      balance[payer] = (balance[payer] ?? 0) + amount;

      // each debtor loses money
      for (final debt in expense.debts) {
        balance[debt.debtorId] =
            (balance[debt.debtorId] ?? 0) - debt.amount;
      }
    }

    // =========================
    // 2. SETTLEMENTS
    // =========================
    for (final s in settlements) {
      final from = s['from'];
      final to = s['to'];
      final amount = (s['amount'] ?? 0).toDouble();

      balance[from] = (balance[from] ?? 0) - amount;
      balance[to] = (balance[to] ?? 0) + amount;
    }

    return balance;
  }
}