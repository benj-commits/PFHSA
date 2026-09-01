class Category {
  final int categoryId;
  final String name;
  final String type;

  Category({required this.categoryId, required this.name, required this.type});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['category_id'],
      name: json['name'],
      type: json['type'],
    );
  }
}
