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
  });
}
