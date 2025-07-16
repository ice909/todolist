import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // 用于序列化
import '../models/todo.dart';
import '../widgets/todo_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Todo> _todos = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  // 读取
  void _loadTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? todosString = prefs.getString('todos');
    if (todosString != null) {
      List todosJson = jsonDecode(todosString);
      setState(() {
        _todos.clear();
        _todos.addAll(todosJson.map((e) => Todo.fromJson(e)));
      });
    }
  }

  // 保存
  void _saveTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String todosString = jsonEncode(_todos.map((e) => e.toJson()).toList());
    await prefs.setString('todos', todosString);
  }

  void _addTodo(String title) {
    if (title.trim().isEmpty) return;
    setState(() {
      _todos.add(Todo(title: title));
      _controller.clear();
      _saveTodos();
    });
  }

  void _toggleTodo(int index) {
    setState(() {
      _todos[index].isDone = !_todos[index].isDone;
      _saveTodos();
    });
  }

  void _removeTodo(int index) {
    setState(() {
      _todos.removeAt(index);
      _saveTodos();
    });
  }

  void _editTodo(int index, String newTitle) {
    if (newTitle.trim().isEmpty) return;
    setState(() {
      _todos[index].title = newTitle;
      _saveTodos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ToDo List')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(labelText: '输入待办事项'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addTodo(_controller.text),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _todos.length,
              itemBuilder: (context, index) => TodoItem(
                todo: _todos[index],
                onToggle: () => _toggleTodo(index),
                onDelete: () => _removeTodo(index),
                onEdit: (newTitle) => _editTodo(index, newTitle),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
