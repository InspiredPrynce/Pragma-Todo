import 'package:pragma_todo/models/todo.dart';
import 'package:pragma_todo/tasks/todo_task_manager.dart';
import 'package:pragma_todo/widgets/add_todo.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:pragma_todo/widgets/todo_stats.dart';

class ToDoPage extends StatefulWidget {
    const ToDoPage({super.key});

    @override
    _ToDoPageState createState() => _ToDoPageState();
}

class _ToDoPageState extends State<ToDoPage> with SingleTickerProviderStateMixin {

    late TabController _tabController;
    String _searchQuery = '';

    @override
    void initState() {
        super.initState();
        _tabController = TabController(length: 4, vsync: this, initialIndex: 1);
    }

    Future<void> _deleteAllTodos() async {
        await TodoBoxManager.deleteAllTodos();
        _refreshTodoList();
    }

    Future<void> _refreshTodoList() async {
        TodoBoxManager.getTodos();
        setState(() {

        });
    }

    List<Todo> _filterTodos(List<Todo> todos, bool Function(Todo) condition) {
        return todos.where((todo) {
            final matchesSearchQuery = _searchQuery.isEmpty ||
                todo.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                todo.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                DateFormat('EEE, MMM d, yyyy h:mm a').format(todo.completionTime).contains(_searchQuery);
            return matchesSearchQuery && condition(todo);
        }).toList();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: Colors.grey[300],
            appBar: AppBar(
                title: Text('My Todo List', style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w600),),
                elevation: 0,
                backgroundColor: Colors.transparent,
                actions: [
                    Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red
                            ),
                            icon: const Icon(Icons.delete_forever, color: Colors.white),
                            onPressed: _deleteAllTodos,
                            label: const Text("Clear Tasks", style: TextStyle(color: Colors.white)),
                        ),
                    ),
                ],
            ),
            body: Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                    children: [
                        TodoStats(TodoBoxManager.getTodos()),
                        const SizedBox(height: 10),
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                                decoration: InputDecoration(
                                    labelText: 'Search',
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    prefixIcon: const Icon(Icons.search),
                                ),
                                onChanged: (query) {
                                    setState(() {
                                        _searchQuery = query;
                                    });
                                },
                            ),
                        ),
                        TabBar(
                            controller: _tabController,
                            isScrollable: true,
                            tabAlignment: TabAlignment.center,
                            labelStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold
                            ),
                            tabs: const [
                                Tab(icon: Icon(Icons.archive)),
                                Tab(text: 'All Tasks'),
                                Tab(text: 'Completed Tasks'),
                                Tab(text: 'Pending Tasks'),
                            ],
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                            child: TabBarView(
                                controller: _tabController,
                                children: [
                                    _buildTodoList((todo) => todo.isArchived),
                                    _buildTodoList((todo) => true),
                                    _buildTodoList((todo) => todo.isCompleted),
                                    _buildTodoList((todo) => !todo.isCompleted)
                                ],
                            ),
                        ),
                    ],
                ),
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: () async {
                    final result = await showModalBottomSheet<Todo>(
                        context: context,
                        builder: (BuildContext context) {
                            return const AddTodoScreen();
                        },
                    );

                    if (result != null) {
                        _refreshTodoList();
                    }
                },
                backgroundColor: Colors.blueGrey,
                child: const Icon(Icons.add, color: Colors.white),
            ),
        );
    }

    Widget _buildTodoList(bool Function(Todo) condition) {
        return ValueListenableBuilder(
            valueListenable: Hive.box<Todo>('todos').listenable(),
            builder: (context, Box<Todo> todoBox, _) {
                List<Todo> todos = TodoBoxManager.getTodos();
                todos = _filterTodos(todos, condition);

                return RefreshIndicator(
                    onRefresh: _refreshTodoList,
                    child: todos.isEmpty
                        ? _buildEmptyList(context)
                        : ListView.builder(
                        itemCount: todos.length,
                        itemBuilder: (context, index) {
                            Todo todo = todos[index];
                            return GestureDetector(
                                onTap: () => _showTodoDetailsBottomSheet(context, todo, index),
                                onDoubleTap: () => _editTodo(context, todo, index),
                                onLongPress: () {
                                    setState(() {
                                        Todo updatedTodo = Todo(
                                            title: todo.title,
                                            description: todo.description,
                                            isCompleted: todo.isCompleted,
                                            isArchived: !todo.isArchived,
                                            completionTime: todo.completionTime,
                                        );
                                        TodoBoxManager.archiveTodoAt(index, updatedTodo);
                                        String message = todo.isArchived ? 'Todo unarchived' : 'Todo archived';
                                        _buildToast(message, Colors.grey);
                                    });
                                },
                                child: Dismissible(
                                    key: Key(todo.title),
                                    background: Container(
                                        color: todo.isCompleted ? Colors.grey : Colors.green,
                                        alignment: Alignment.centerLeft,
                                        padding: const EdgeInsets.symmetric(horizontal: 20),
                                        child: Icon(
                                            todo.isCompleted ? Icons.undo : Icons.check,
                                            color: Colors.white,
                                            size: 30,
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
                                        }
                                        else if (direction == DismissDirection.startToEnd) {
                                            setState(() {
                                                Todo updatedTodo = Todo(
                                                    title: todo.title,
                                                    description: todo.description,
                                                    isCompleted: !todo.isCompleted,
                                                    completionTime: todo.completionTime,
                                                );
                                                TodoBoxManager.updateTodoAt(index, updatedTodo);
                                                _buildToast("Task has been updated", Colors.blue);
                                            });
                                            return false;
                                        }
                                        return false;
                                    },
                                    onDismissed: (direction) {
                                        if (direction == DismissDirection.endToStart) {
                                            TodoBoxManager.deleteTodoAt(index);
                                            _buildToast("Task has been deleted", Colors.red);
                                        }
                                    },
                                    child: Card(
                                        elevation: 4,
                                        color: todo.isCompleted ? Colors.grey[300] : Colors.white,
                                        child: ListTile(
                                            title: Column(
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
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Text(
                                                        _truncateDescription(todo.description),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                    ),
                                                ],
                                            ),
                                            subtitle: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                    Text(
                                                        DateFormat('EEE, MMM d, yyyy h:mm a').format(todo.updateDate),
                                                        style: const TextStyle(
                                                            fontStyle: FontStyle.italic
                                                        ),
                                                    ),
                                                    todo.isArchived ?
                                                    const Badge(
                                                        backgroundColor: Colors.grey,
                                                        label: Text("Archived"),
                                                    ) : const SizedBox(),
                                                ],
                                            ),
                                        ),
                                    ),
                                ),
                            );
                        },
                    ),
                );
            },
        );
    }

    String _truncateDescription(String description) {
        const int maxCharacters = 50; // Maximum characters to display before truncating
        if (description.length > maxCharacters) {
            return '${description.substring(0, maxCharacters)}...';
        }
        return description;
    }

    Future<void> _showTodoDetailsBottomSheet(BuildContext context, Todo todo, index) async {
        return showModalBottomSheet(
            context: context,
            builder: (context) {
                return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        ListTile(
                            title: Text(
                                todo.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold
                                )
                            ),
                            subtitle: Text(todo.description),
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                        const SizedBox(height: 20),
                        Column(
                            children: [
                                ElevatedButton(
                                    onPressed: () {
                                        setState(() {
                                            todo.isCompleted = !todo.isCompleted;
                                            TodoBoxManager.updateTodoAt(index, todo);
                                        });
                                        Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: todo.isCompleted ? Colors.grey : Colors.green,
                                        minimumSize: const Size(double.infinity, 48),
                                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                    ),
                                    child: Text(
                                        todo.isCompleted ? 'Mark as Undone' : 'Mark as Done',
                                        style: const TextStyle(color: Colors.white),
                                    ),
                                ),
                                ElevatedButton(
                                    onPressed: () {
                                        TodoBoxManager.deleteTodoAt(index);
                                        Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        minimumSize: const Size(double.infinity, 48),
                                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                    ),
                                    child: const Text(
                                        'Delete Task',
                                        style: TextStyle(color: Colors.white),
                                    ),
                                ),
                            ],
                        )
                    ],
                );
            },
        );
    }

    void _editTodo(BuildContext context, Todo todo, index) async {
        final result = await showModalBottomSheet<Todo>(
            context: context,
            builder: (BuildContext context) {
                return AddTodoScreen(initialTodo: todo); // Pass the initial todo to the AddTodoScreen for editing
            },
        );

        if (result != null) {
            // Update the todo if changes were saved
            setState(() {
                // Update todo properties
                todo.title = result.title;
                todo.description = result.description;
                todo.completionTime = result.completionTime;

                // Update the todo in the database
                TodoBoxManager.updateTodoAt(index, todo);
            });
        }
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

    _buildToast(message, color){
        return Fluttertoast.showToast(
            msg: message,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: color,
            textColor: Colors.white,
            fontSize: 16.0,
        );
    }
}
