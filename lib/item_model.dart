// lib/item_model.dart

class Item {
  int? id;
  String name;
  double? buyingPrice; // Now optional
  double? sellingPrice; // Now optional
  double? wholesalePrice; // Now optional
  double? maintenanceCost; // New optional field
  DateTime createdAt; // New required field
  DateTime updatedAt; // New required field

  Item({
    this.id,
    required this.name,
    this.buyingPrice,
    this.sellingPrice,
    this.wholesalePrice,
    this.maintenanceCost,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert an Item object into a Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'buyingPrice': buyingPrice,
      'sellingPrice': sellingPrice,
      'wholesalePrice': wholesalePrice,
      'maintenanceCost': maintenanceCost,
      // Store dates as ISO 8601 strings, a standard and readable format.
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create an Item object from a Map.
  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      name: map['name'],
      buyingPrice: map['buyingPrice'],
      sellingPrice: map['sellingPrice'],
      wholesalePrice: map['wholesalePrice'],
      maintenanceCost: map['maintenanceCost'],
      // Parse the string back to a DateTime object.
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
