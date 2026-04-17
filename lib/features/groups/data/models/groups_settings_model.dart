import '../../domain/entities/group_setting.dart';

class GroupSettingsModel extends GroupSettingsEntity {
  GroupSettingsModel({
    required super.allowInvites,
    required super.defaultSplitMethod,
    required super.expenseCategories,
  });

  factory GroupSettingsModel.fromEntity(GroupSettingsEntity entity) {
    return GroupSettingsModel(
      allowInvites: entity.allowInvites,
      defaultSplitMethod: entity.defaultSplitMethod,
      expenseCategories: entity.expenseCategories,
    );
  }

  factory GroupSettingsModel.fromMap(Map<String, dynamic> map) {
    return GroupSettingsModel(
      allowInvites: map['allowInvites'] ?? true,
      defaultSplitMethod: map['defaultSplitMethod'] ?? 'equal',
      expenseCategories: map['expenseCategories'] != null
          ? List<String>.from(map['expenseCategories'])
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'allowInvites': allowInvites,
      'defaultSplitMethod': defaultSplitMethod,
      'expenseCategories': expenseCategories,
    };
  }
}