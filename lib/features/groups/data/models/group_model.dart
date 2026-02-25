import 'package:isar/isar.dart';
import '../../domain/entities/group.dart';
import '../../domain/entities/group_setting.dart';

part 'group_model.g.dart';

@Collection()
class GroupModel {
  Id id = Isar.autoIncrement;
  String firestoreId = '';
  String name = '';
  String currency = 'USD';
  String createdBy = '';
  String description = '';
  bool isArchived = false;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
  String? coverImageUrl;
  bool isSynced = false;

  GroupSettings settings = GroupSettings();

  // تبدیل به Entity برای استفاده در UI
  GroupEntity toEntity() {
    return GroupEntity(
      id: firestoreId,
      name: name,
      description: description,
      coverImageUrl: coverImageUrl ?? '',
      currency: currency,
      createdBy: createdBy,
      isArchived: isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt,
      settings: GroupSettingsEntity(
        allowInvites: settings.allowInvites,
        defaultSplitMethod: settings.defaultSplitMethod,
        expenseCategories: settings.expenseCategories,
      ),
    );
  }

  // ساخت مدل از روی Entity برای ذخیره در دیتابیس
  static GroupModel fromEntity(GroupEntity entity) {
    return GroupModel()
      ..firestoreId = entity.id
      ..name = entity.name
      ..description = entity.description
      ..currency = entity.currency
      ..createdBy = entity.createdBy
      ..isArchived = entity.isArchived
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt
      ..coverImageUrl = entity.coverImageUrl
      ..settings = (GroupSettings()
        ..allowInvites = entity.settings.allowInvites
        ..defaultSplitMethod = entity.settings.defaultSplitMethod
        ..expenseCategories = entity.settings.expenseCategories);
  }
}

@Embedded()
class GroupSettings {
  bool allowInvites = true;
  String defaultSplitMethod = 'equal';
  List<String> expenseCategories = [];
}