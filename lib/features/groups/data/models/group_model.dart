import 'package:isar/isar.dart';

part 'group_model.g.dart';

@Collection()
class GroupModel {
  Id id = Isar.autoIncrement;
  late String firestoreId;
  late String name;
  String description = '';
  String currency = 'USD';
  late String createdBy;
  bool isArchived = false;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
  String? coverImageUrl;

  // Settings as embedded object
  GroupSettings settings = GroupSettings();
}

@Embedded()
class GroupSettings {
  bool allowInvites = true;
  String defaultSplitMethod = 'equal';
  List<String> expenseCategories = [];
}
