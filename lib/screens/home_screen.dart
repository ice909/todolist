import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/todo.dart';
import '../widgets/todo_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Todo> _todos = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // _clearTodos();
    _loadTodos();
  }

  void _clearTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('todos');
  }

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

  void _saveTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String todosString = jsonEncode(_todos.map((e) => e.toJson()).toList());
    await prefs.setString('todos', todosString);
  }

  void _addTodo(String title, String description) {
    if (title.trim().isEmpty) return;
    setState(() {
      _todos.add(Todo(title: title, description: description));
      _titleController.clear();
      _descController.clear();
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

  void _editTodo(int index, String newTitle, String newDesc) {
    if (newTitle.trim().isEmpty) return;
    setState(() {
      _todos[index].title = newTitle;
      _todos[index].description = newDesc;
      _saveTodos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('待办清单')),
      // ...前略
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: '输入待办标题',
                        prefixIcon: Icon(Icons.title),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _descController,
                      decoration: const InputDecoration(
                        labelText: '输入描述（可选）',
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: Container()),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('添加'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => _addTodo(
                            _titleController.text,
                            _descController.text,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _todos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 60, color: Colors.teal[100]),
                        const SizedBox(height: 12),
                        Text('暂无待办事项', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _todos.length,
                    itemBuilder: (context, index) => TodoItem(
                      todo: _todos[index],
                      onToggle: () => _toggleTodo(index),
                      onDelete: () => _removeTodo(index),
                      onEdit: (newTitle, newDesc) =>
                          _editTodo(index, newTitle, newDesc),
                    ),
                  ),
          )
        ],
      ),
      // ...后略
    );
  }
}
