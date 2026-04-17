import '../../data/model/payment_model.dart';
import '../../data/model/setelment_model.dart';

class CalculateGroupSettlementUseCase {
  List<Settlement> call({
    required List<Payment> payments,
    required List<String> participants,
    required String splitMethod, // 'Equally', 'Percentage', 'Custom'
    Map<String, double>? customShares,
    Map<String, double>? percentages,
  }) {
    final Map<String, double> paidMap = {};
    for (var p in payments) {
      paidMap[p.userId] = (paidMap[p.userId] ?? 0) + p.amount;
    }

    final totalAmount = payments.fold(0.0, (sum, p) => sum + p.amount);

    final Map<String, double> owedMap = {};
    switch (splitMethod) {
      case 'Equally':
        final share = totalAmount / participants.length;
        for (var user in participants) owedMap[user] = share;
        break;
      case 'Percentage':
        for (var user in participants) {
          final percent = percentages?[user] ?? 0;
          owedMap[user] = totalAmount * (percent / 100);
        }
        break;
      case 'Custom':
        for (var user in participants) {
          owedMap[user] = customShares?[user] ?? 0;
        }
        break;
    }

    final Map<String, double> balances = {};
    for (var user in participants) {
      final paid = paidMap[user] ?? 0;
      final owed = owedMap[user] ?? 0;
      balances[user] = paid - owed;
    }

    final debtors = <MapEntry<String, double>>[];
    final creditors = <MapEntry<String, double>>[];
    balances.forEach((user, balance) {
      if (balance < -0.01) debtors.add(MapEntry(user, -balance));
      if (balance > 0.01) creditors.add(MapEntry(user, balance));
    });

    final settlements = <Settlement>[];
    int i = 0, j = 0;
    while (i < debtors.length && j < creditors.length) {
      final debtor = debtors[i];
      final creditor = creditors[j];
      final amount = debtor.value < creditor.value ? debtor.value : creditor.value;
      settlements.add(Settlement(debtor.key, creditor.key, amount));
      debtors[i] = MapEntry(debtor.key, debtor.value - amount);
      creditors[j] = MapEntry(creditor.key, creditor.value - amount);
      if (debtors[i].value.abs() < 0.01) i++;
      if (creditors[j].value.abs() < 0.01) j++;
    }
    return settlements;
  }
}