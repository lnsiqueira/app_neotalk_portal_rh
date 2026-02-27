class Benefit {
  final String id;
  final String name;
  final String category;
  final String subcategory;
  final String status;
  final String icon;
  final String description;
  final String? action;

  // Novos campos para a página detalhada
  final String? planName;
  final String? dependents;
  final String? dueDate;
  final String? monthlyValue;
  final String? cardNumber;
  final String? dailyValue;
  final String? nextRecharge;
  final List<String>? actions;

  Benefit({
    required this.id,
    required this.name,
    required this.category,
    required this.subcategory,
    required this.status,
    required this.icon,
    required this.description,
    this.action,
    this.planName,
    this.dependents,
    this.dueDate,
    this.monthlyValue,
    this.cardNumber,
    this.dailyValue,
    this.nextRecharge,
    this.actions,
  });

  factory Benefit.fromJson(Map<String, dynamic> json) {
    return Benefit(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      subcategory: json['subcategory'] as String? ?? '',
      status: json['status'] as String? ?? 'INATIVO',
      icon: json['icon'] as String? ?? 'default',
      description: json['description'] as String? ?? '',
      action: json['action'] as String?,
      planName: json['planName'] as String?,
      dependents: json['dependents'] as String?,
      dueDate: json['dueDate'] as String?,
      monthlyValue: json['monthlyValue'] as String?,
      cardNumber: json['cardNumber'] as String?,
      dailyValue: json['dailyValue'] as String?,
      nextRecharge: json['nextRecharge'] as String?,
      actions: json['actions'] != null
          ? List<String>.from(json['actions'] as List)
          : null,
    );
  }
}
