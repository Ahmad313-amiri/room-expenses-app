import '../../domain/enums/groups_status.dart';
import '../models/group_model.dart';


class GroupLocalDataSource {
  List<GroupModel> getGroups() {
    return [
      GroupModel(
        name: 'Apt 4B Roommates',
        description: 'Last expense: Utility Bill',
        amount: -45,
        status: GroupStatus.owe,
        iconKey: 'home',
      ),
      GroupModel(
        name: 'Europe Summer 24',
        description: 'Active 2 days ago',
        amount: 165.5,
        status: GroupStatus.owed,
        iconKey: 'public',
      ),
      GroupModel(
        name: 'Friday Dinners',
        description: 'All expenses settled',
        amount: 0,
        status: GroupStatus.settled,
        iconKey: 'restaurant',
      ),
    ];
  }
}
