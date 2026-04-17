// import '../../domain/entities/group.dart';
// import '../../domain/entities/group_setting.dart';
//
// class GroupModel {
//   String? firestoreId;
//   String? name;
//   String? description;
//   String? currency;
//   String? coverImageUrl;
//   String? createdBy;
//   bool? isArchived;
//   DateTime? createdAt;
//   DateTime? updatedAt;
//   GroupSettingsModel? settings;
//
//
//   GroupModel({
//     this.firestoreId,
//     this.name,
//     this.description,
//     this.currency,
//     this.coverImageUrl,
//     this.createdBy,
//     this.isArchived,
//     this.createdAt,
//     this.updatedAt,
//     this.settings,
//   });
//
//   // Constructor from entity
//   factory GroupModel.fromEntity(GroupEntity entity) => GroupModel(
//     firestoreId: entity.id,
//     name: entity.name,
//     description: entity.description,
//     currency: entity.currency,
//     coverImageUrl: entity.coverImageUrl,
//     createdBy: entity.createdBy,
//     isArchived: entity.isArchived,
//     createdAt: entity.createdAt,
//     updatedAt: entity.updatedAt,
//     settings: GroupSettingsModel.fromEntity(entity.settings),
//   );
//
//   // Convert to map for Firestore
//   Map<String, dynamic> toMap() => {
//     'id': firestoreId,
//     'name': name,
//     'description': description,
//     'currency': currency,
//     'coverImageUrl': coverImageUrl,
//     'createdBy': createdBy,
//     'isArchived': isArchived,
//     'createdAt': createdAt,
//     'updatedAt': updatedAt,
//     'settings': settings?.toMap(),
//   };
//
//   // From Firestore document
//   factory GroupModel.fromMap(Map<String, dynamic> map) => GroupModel(
//     firestoreId: map['id'],
//     name: map['name'],
//     description: map['description'],
//     currency: map['currency'],
//     coverImageUrl: map['coverImageUrl'],
//     createdBy: map['createdBy'],
//     isArchived: map['isArchived'] ?? false,
//     createdAt: map['createdAt'] is DateTime ? map['createdAt'] : null,
//     updatedAt: map['updatedAt'] is DateTime ? map['updatedAt'] : null,
//     settings: map['settings'] != null
//         ? GroupSettingsModel.fromMap(map['settings'])
//         : null,
//   );
// }
//
// class GroupSettingsModel {
//   bool? allowInvites;
//   String? defaultSplitMethod;
//   List<String>? expenseCategories;
//
//   GroupSettingsModel({
//     this.allowInvites,
//     this.defaultSplitMethod,
//     this.expenseCategories,
//   });
//
//   factory GroupSettingsModel.fromEntity(GroupSettingsEntity entity) =>
//       GroupSettingsModel(
//         allowInvites: entity.allowInvites,
//         defaultSplitMethod: entity.defaultSplitMethod,
//         expenseCategories: entity.expenseCategories,
//       );
//
//   Map<String, dynamic> toMap() => {
//     'allowInvites': allowInvites,
//     'defaultSplitMethod': defaultSplitMethod,
//     'expenseCategories': expenseCategories,
//   };
//
//   factory GroupSettingsModel.fromMap(Map<String, dynamic> map) =>
//       GroupSettingsModel(
//         allowInvites: map['allowInvites'],
//         defaultSplitMethod: map['defaultSplitMethod'],
//         expenseCategories: map['expenseCategories'] != null
//             ? List<String>.from(map['expenseCategories'])
//             : [],
//       );
// }



import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/group.dart';
import '../../domain/entities/group_setting.dart';
import 'groups_settings_model.dart';

class GroupModel extends GroupEntity {
  GroupModel({
    required super.id,
    required super.name,
    required super.description,
    required super.coverImageUrl,
    required super.currency,
    required super.createdBy,
    required super.isArchived,
    required super.createdAt,
    required super.updatedAt,
    required super.settings,
    required super.membersCount,
  });

  factory GroupModel.fromEntity(GroupEntity entity) {
    return GroupModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      coverImageUrl: entity.coverImageUrl,
      currency: entity.currency,
      createdBy: entity.createdBy,
      isArchived: entity.isArchived,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      settings: entity.settings is GroupSettingsModel
          ? entity.settings
          : GroupSettingsModel.fromEntity(entity.settings),
      membersCount: entity.membersCount,
    );
  }

  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      coverImageUrl: map['coverImageUrl'] ?? '',
      currency: map['currency'] ?? 'USD',
      createdBy: map['createdBy'] ?? '',
      isArchived: map['isArchived'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      settings: map['settings'] != null
          ? GroupSettingsModel.fromMap(map['settings'])
          : GroupSettingsModel(allowInvites: true, defaultSplitMethod: 'equal', expenseCategories: []),
      membersCount: map['membersCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'coverImageUrl': coverImageUrl,
      'currency': currency,
      'createdBy': createdBy,
      'isArchived': isArchived,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'settings': (settings as GroupSettingsModel).toMap(),
      'membersCount': membersCount,
    };
  }

  GroupModel copyWith({
    String? id,
    String? name,
    String? description,
    String? coverImageUrl,
    String? currency,
    String? createdBy,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
    GroupSettingsEntity? settings,
    int? membersCount,
  }) {
    return GroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      currency: currency ?? this.currency,
      createdBy: createdBy ?? this.createdBy,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      settings: settings ?? this.settings,
      membersCount: membersCount ?? this.membersCount,
    );
  }
}