import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';


import '../../features/expenses/data/model/isar/expense_isar.dart';

class IsarService {
  static Isar? _isar;

  static Future<Isar> openIsar() async {
    if (_isar != null) return _isar!;

    final dir = await getApplicationDocumentsDirectory();

    _isar = await Isar.open(
      [ExpenseIsarSchema],
      directory: dir.path,
      inspector: true,
    );

    return _isar!;
  }
}
