class ExpenseModel {
  final int? id;
  final double value;
  final bool isIncome;
  final String? note;
  final String? image;
  final String? createdAt;

  ExpenseModel({
    this.id,
    required this.value,
    required this.isIncome,
  
    this.note,
    this.image,
    this.createdAt,
  });

  

  Map<String, dynamic> toJson() => {
    'note': note,
    'value': value,
    'isIncome': isIncome,
    'image': image,
    'createdAt': createdAt,
  };
}