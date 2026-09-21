class WorkOrderStatusModel {
  final int? id;
  final String? name;
  final String colour;

  WorkOrderStatusModel({
    this.id,
    this.name,
    required this.colour,
  });

  factory WorkOrderStatusModel.fromJson(Map<String, dynamic> json) {
    return WorkOrderStatusModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      colour: json['colour'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'colour': colour,
    };
  }
}