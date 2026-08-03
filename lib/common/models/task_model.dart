class TaskModel {
  final String id;
  final String title;
  final String category;
  final String status; // 'Pending', 'In Progress', 'Completed'
  final String priority;
  final String worker;

  TaskModel({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    required this.priority,
    required this.worker,
  });
}