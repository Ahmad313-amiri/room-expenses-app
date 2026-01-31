class Participant {
  final String id;
  final String name;

  bool isIncluded;
  double percent;
  double customAmount;

  Participant({
    required this.id,
    required this.name,
    this.isIncluded = true,
    this.percent = 0,
    this.customAmount = 0,
  });
}
