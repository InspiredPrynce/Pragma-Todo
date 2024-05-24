import 'package:pragma_todo/models/todo.dart';
import 'package:pragma_todo/tasks/todo_task_manager.dart';
import 'package:flutter/material.dart';

class TodoStats extends StatelessWidget {
    const TodoStats(List<Todo> todos, {super.key});

    @override
    Widget build(BuildContext context) {
        return FutureBuilder(
            future: _getTodoStats(),
            builder: (context, AsyncSnapshot<Map<String, int>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(); // Display a loading indicator while fetching data
                } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}'); // Display an error message if fetching data fails
                } else {
                    // Once data is fetched successfully, display stats cards
                    return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                            Expanded(child: _buildStatCard(snapshot.data!['all']!, Icons.list, true, Colors.blue)),
                            Expanded(child: _buildStatCard(snapshot.data!['completed']!, Icons.check, true, Colors.green)),
                            Expanded(child: _buildStatCard(snapshot.data!['uncompleted']!, Icons.timer, false, Colors.orangeAccent)),
                            Expanded(child: _buildStatCard(snapshot.data!['archived']!, Icons.archive, false, Colors.grey)),
                        ],
                    );
                }
            },
        );
    }

    // Method to count completed and uncompleted todos
    Future<Map<String, int>> _getTodoStats() async {
        List<Todo> todos = TodoBoxManager.getTodos();
        int allCount = todos.length;
        int archivedCount = todos.where((todo) => todo.isArchived).length;
        int completedCount = todos.where((todo) => todo.isCompleted).length;
        int uncompletedCount = todos.where((todo) => !todo.isCompleted).length;
        return {'archived': archivedCount, 'all': allCount, 'completed': completedCount, 'uncompleted': uncompletedCount};
    }

    // Widget to display stats card
    Widget _buildStatCard(int count, IconData icon, bool completed, Color color) {
        return Card(
            color: color,
            elevation: 4,
            child: Padding(
                padding: const EdgeInsets.all(10).copyWith(right: 0),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                        Expanded(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Text(
                                        count.toString(),
                                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w100, color: Colors.white),
                                    ),
                                ],
                            ),
                        ),
                        const SizedBox(width: 10), // Add spacing between count text and icon
                        Opacity(
                            opacity: 0.2,
                            child: Icon(
                                icon,
                                size: 45, // Adjust size as needed
                                color: Colors.white,
                            ),
                        ),
                    ],
                ),
            ),
        );
    }



}
