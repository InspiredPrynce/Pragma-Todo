import 'package:pragma_todo/models/todo.dart';
import 'package:pragma_todo/tasks/todo_task_manager.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class AnimatedToDoList extends StatefulWidget {
    const AnimatedToDoList(bool Function(Todo) condition, {super.key});

    @override
    _AnimatedToDoListState createState() => _AnimatedToDoListState();
}

class _AnimatedToDoListState extends State<AnimatedToDoList> {
    @override
    Widget build(BuildContext context) {
        return ValueListenableBuilder(
            valueListenable: Hive.box<Todo>('todos').listenable(),
            builder: (context, Box<Todo> todoBox, _) {
                List<Todo> todos = TodoBoxManager.getTodos();

                // Sort todos with completed ones at the end
                todos.sort((a, b) {
                    if (a.isCompleted == b.isCompleted) {
                        return 0;
                    }
                    return a.isCompleted ? 1 : -1;
                });

                return todos.isEmpty ? _buildEmptyList(context) : ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                        Todo todo = todos[index];
                        return Dismissible(
                            key: Key(todo.title),
                            background: Container(
                                color: todo.isCompleted ? Colors.grey : Colors.green,
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Icon(
                                    todo.isCompleted ? Icons.undo : Icons.check,
                                    color: Colors.white,
                                    size: 30
                                ),
                            ),
                            secondaryBackground: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: const Icon(Icons.delete, color: Colors.white, size: 30),
                            ),
                            confirmDismiss: (direction) async {
                                if (direction == DismissDirection.endToStart) {
                                    return await _confirmDelete(context);
                                } else if (direction == DismissDirection.startToEnd) {
                                    setState(() {
                                        Todo updatedTodo = Todo(
                                            title: todo.title,
                                            description: todo.description,
                                            isCompleted: !todo.isCompleted,
                                        );
                                        TodoBoxManager.updateTodoAt(index, updatedTodo);
                                    });
                                    return false;
                                }
                                return false;
                            },
                            onDismissed: (direction) {
                                if (direction == DismissDirection.endToStart) {
                                    TodoBoxManager.deleteTodoAt(index);
                                }
                            },
                            child: Card(
                                elevation: 4,
                                color: todo.isCompleted ? Colors.grey[350] : Colors.white,
                                child: Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    child: ListTile(
                                        title: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                                Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                        Row(
                                                            children: [
                                                                const Icon(Icons.access_time, size: 16, color: Colors.blueGrey),
                                                                const SizedBox(width: 4),
                                                                Text(
                                                                    DateFormat('EEE, MMM d, yyyy h:mm a').format(todo.completionTime),
                                                                    style: Theme.of(context).textTheme.displaySmall!.copyWith(
                                                                        fontSize: 14,
                                                                        color: Colors.blueGrey,
                                                                    ),
                                                                ),
                                                            ],
                                                        ),
                                                        const SizedBox(height: 8),
                                                        Text(
                                                            todo.title,
                                                            style: TextStyle(
                                                                decoration: todo.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                                                                fontWeight: FontWeight.bold
                                                            )
                                                        )
                                                    ],
                                                ),
                                            ],
                                        ),
                                        subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                                Text(todo.description),
                                                const SizedBox(height: 13),
                                                Text(
                                                    DateFormat.yMMMMEEEEd().format(todo.updateDate),
                                                    style: const TextStyle(
                                                        fontStyle: FontStyle.italic
                                                    ),
                                                )
                                            ],
                                        ),
                                    ),
                                ),
                            ),
                        );
                    },
                );
            },
        );
    }

    Future<bool> _confirmDelete(BuildContext context) async {
        return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
                title: const Text('Delete Todo'),
                content: const Text('Are you sure you want to delete this todo?'),
                actions: <Widget>[
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                    ),
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Delete'),
                    ),
                ],
            ),
        ) ?? false;
    }

    _buildEmptyList(context){
        return Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                    const Icon(Icons.hourglass_empty, size: 80, color: Colors.grey),
                    const SizedBox(height: 30),
                    Text(
                        'Todo list is empty',
                        style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                        width: 200,
                        child: Text(
                            'You have not added any task so far, use the button below to begin.',
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.grey[600]),
                        ),
                    ),
                ],
            ),
        );
    }
}
