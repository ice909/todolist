class Todo {
  String title;
  String description;
  bool isDone;

  Todo({required this.title, required this.description, this.isDone = false});

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'isDone': isDone,
  };

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
    title: json['title'] ?? "",
    description: (json['description'] ?? "") as String, // 保证不是null
    isDone: json['isDone'] ?? false,
  );
}
