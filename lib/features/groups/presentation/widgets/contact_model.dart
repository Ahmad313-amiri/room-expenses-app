class Contact {
  final String name;
  final String email;
  bool isSelected;

  Contact({
    required this.name,
    required this.email,
    this.isSelected = false,
  });
}
