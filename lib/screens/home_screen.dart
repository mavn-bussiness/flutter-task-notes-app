import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_item.dart';
import '../helpers/database_helper.dart';
import '../providers/theme_provider.dart';
import './add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<TaskItem> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future _loadTasks() async {
    setState(() => _isLoading = true);
    var tasks = await DatabaseHelper.instance.getAllTasks();
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  Future _deleteTask(int? id) async {
    if (id == null) return;
    await DatabaseHelper.instance.delete(id);
    _loadTasks();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task deleted')),
    );
  }

  Future _toggleTaskCompletion(TaskItem task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    await DatabaseHelper.instance.update(updatedTask);
    _loadTasks();
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks & Notes'),
        elevation: 2,
      ),
      body: Column(
        children: [
          // Theme Switch
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle app theme'),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
            secondary: Icon(
              themeProvider.isDarkMode 
                ? Icons.dark_mode 
                : Icons.light_mode,
            ),
          ),
          const Divider(),
          
          // Welcome Message
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'My Tasks & Notes',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Task List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _tasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.task_alt, size: 64, 
                              color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No tasks yet!',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap + to add your first task',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _tasks.length,
                        itemBuilder: (context, index) {
                          final task = _tasks[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8, 
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: Checkbox(
                                value: task.isCompleted,
                                onChanged: (value) => _toggleTaskCompletion(task),
                              ),
                              title: Text(
                                task.title,
                                style: TextStyle(
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(task.description),
                                  const SizedBox(height: 4),
                                  Chip(
                                    label: Text(
                                      task.priority,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                    backgroundColor: _getPriorityColor(
                                      task.priority,
                                    ),
                                    padding: EdgeInsets.zero,
                                    materialTapTargetSize: 
                                      MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteTask(task.id),
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          );
          _loadTasks(); // Refresh list after returning
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
