import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TodoScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<Map<String, dynamic>> tasks = [];
  bool _isDarkMode = false;
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _toggleTask(int index) {
    setState(() {
      tasks[index]['completed'] = !tasks[index]['completed'];
      _saveTasks();
    });
  }

  List<Map<String, dynamic>> get _filteredTasks {
    if (_searchQuery.isEmpty) {
      return tasks;
    }
    return tasks.where((task) {
      final title = task['title'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return title.contains(query);
    }).toList();
  }

  void _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tasks', jsonEncode(tasks));
  }

  void _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksData = prefs.getString('tasks');

    if (tasksData != null) {
      await Future.delayed(Duration(milliseconds: 500));

      setState(() {
        tasks = List<Map<String, dynamic>>.from(
          jsonDecode(tasksData).map((item) => Map<String, dynamic>.from(item)),
        );
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAddTaskDialog(BuildContext context) {
    TextEditingController taskController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _isDarkMode ? Colors.grey[800] : Colors.white,
        title: Text(
          'Add new task',
          style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
        ),
        content: TextField(
          controller: taskController,
          decoration: InputDecoration(
            hintText: 'Add task here',
            border: OutlineInputBorder(),
            filled: _isDarkMode,
            fillColor: _isDarkMode ? Colors.grey[700] : null,
            hintStyle: TextStyle(color: _isDarkMode ? Colors.grey[400] : null),
          ),
          style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: _isDarkMode ? Colors.grey[400] : Colors.blue,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (taskController.text.isNotEmpty) {
                setState(() {
                  tasks.add({
                    'title': taskController.text,
                    'completed': false,
                    'id': DateTime.now().millisecondsSinceEpoch,
                  });
                  _saveTasks();
                });
                Navigator.pop(context);
              }
            },
            child: Text('Add'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isDarkMode ? Colors.blue[700] : Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.white,
      appBar: AppBar(
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: _isDarkMode
                ? Colors.grey[700]
                : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search in Tasks',
              hintStyle: TextStyle(
                color: _isDarkMode ? Colors.grey[400] : Colors.white70,
              ),
              border: InputBorder.none,
              icon: Icon(
                Icons.search,
                color: _isDarkMode ? Colors.grey[400] : Colors.white70,
              ),
            ),
            style: TextStyle(color: _isDarkMode ? Colors.white : Colors.white),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        backgroundColor: _isDarkMode ? Colors.grey[800] : Colors.blue,
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode, color: _isDarkMode ? Colors.white : Colors.black,),
            onPressed: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 16,
                      color: _isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Search results indicator
                if (_searchQuery.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      '${_filteredTasks.length} Search results "$_searchQuery"',
                      style: TextStyle(
                        color: _isDarkMode
                            ? Colors.grey[400]
                            : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),

                // Tasks list
                Expanded(
                  child: tasks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.task,
                                size: 64,
                                color: _isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No tasks added yet.',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: _isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              Text(
                                'Press + to add new task!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredTasks.length,
                          itemBuilder: (context, index) {
                            final task = _filteredTasks[index];
                            final originalIndex = tasks.indexWhere(
                              (t) => t['id'] == task['id'],
                            );

                            return Card(
                              margin: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              color: _isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.white,
                              child: ListTile(
                                leading: IconButton(
                                  icon: Icon(
                                    task['completed']
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: task['completed']
                                        ? Colors.green
                                        : (_isDarkMode
                                              ? Colors.grey[400]
                                              : Colors.grey),
                                  ),
                                  onPressed: () {
                                    _toggleTask(originalIndex);
                                  },
                                ),
                                title: Text(
                                  task['title'],
                                  style: TextStyle(
                                    decoration: task['completed']
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: _isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      tasks.removeAt(originalIndex);
                                      _saveTasks();
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context);
        },
        child: Icon(Icons.add),
        backgroundColor: _isDarkMode ? Colors.blue[700] : Colors.blue,
      ),
    );
  }
}
