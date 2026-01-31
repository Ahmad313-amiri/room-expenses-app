import '../../domain/entities/group.dart';


class GroupModel extends Group {
  GroupModel({
    required super.name,
    required super.description,
    required super.amount,
    required super.status,
    required super.iconKey,
  });
}
