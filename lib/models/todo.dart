class Todo {
  String title;
  bool isDone;

  Todo({required this.title, this.isDone = false});

  // 序列化
  Map<String, dynamic> toJson() => {'title': title, 'isDone': isDone};

  // 反序列化
  factory Todo.fromJson(Map<String, dynamic> json) =>
      Todo(title: json['title'], isDone: json['isDone']);
}
