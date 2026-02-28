class GroupSettingsEntity {
  final bool allowInvites;
  final String defaultSplitMethod;
  final List<String> expenseCategories;

  GroupSettingsEntity({
    required this.allowInvites,
    required this.defaultSplitMethod,
    required this.expenseCategories,
  });
}
