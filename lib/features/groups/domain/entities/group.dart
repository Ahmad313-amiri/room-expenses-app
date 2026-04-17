import 'group_setting.dart';

class GroupEntity {
  final String id;
  final String name;
  final String description;
  final String coverImageUrl;
  final String currency;
  final String createdBy;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final GroupSettingsEntity settings;
  final int membersCount;

  GroupEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.coverImageUrl,
    required this.currency,
    required this.createdBy,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
    required this.settings,
    required this.membersCount ,
  });
  GroupEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? coverImageUrl,
    String? currency,
    String? createdBy,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
    GroupSettingsEntity?settings,
    int? membersCount,
  }) {
    return GroupEntity(
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
