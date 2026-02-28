// MODIFIED: اضافه شدن متدهای مورد نیاز برای مدیریت اعضا و خرج‌ها
import '../entities/group.dart';
import '../entities/member_entity.dart';


abstract class GroupRepository {
  // گروه‌ها
  Future<void> createGroup(GroupEntity group);
  Future<List<GroupEntity>> getGroups({String? userId});
  Future<GroupEntity?> getGroupById(String id);
  Future<void> archiveGroup(String groupId);
  Future<void> updateGroup(GroupEntity group);


  Future<void> addMember(String groupId, MemberEntity member);
  Future<void> removeMember(String groupId, String userId);
  Future<List<MemberEntity>> getMembers(String groupId);

  // // خرج‌ها (در صورت نیاز)
  // Future<void> addExpense(String groupId, ExpenseEntity expense);
  // Future<List<ExpenseEntity>> getExpenses(String groupId);
}



