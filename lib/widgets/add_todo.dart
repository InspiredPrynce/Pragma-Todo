import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pragma_todo/models/todo.dart';
import 'package:pragma_todo/tasks/todo_task_manager.dart';

class AddTodoScreen extends StatefulWidget {
    final Todo? initialTodo;

    const AddTodoScreen({super.key, this.initialTodo});

    @override
    _AddTodoScreenState createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _descriptionController = TextEditingController();
    DateTime? _selectedDateTime;

    @override
    void initState() {
        super.initState();
        if (widget.initialTodo != null) {
            _titleController.text = widget.initialTodo!.title;
            _descriptionController.text = widget.initialTodo!.description;
            _selectedDateTime = widget.initialTodo!.completionTime;
        }
    }

    Future<void> _selectDateTime(BuildContext context) async {
        final DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
            final TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
            );
            if (pickedTime != null) {
                setState(() {
                    _selectedDateTime = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                    );
                });
            }
        }
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
                title: Text(widget.initialTodo == null ? 'Add Todo' : 'Edit Todo'),
            ),
            body: SingleChildScrollView(
                child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            TextField(
                                controller: _titleController,
                                decoration: InputDecoration(
                                    labelText: 'Title',
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                    ),
                                ),
                            ),
                            const SizedBox(height: 16.0),
                            TextField(
                                controller: _descriptionController,
                                decoration: InputDecoration(
                                    labelText: 'Description',
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                    ),
                                ),
                                maxLines: null, // Allow multiple lines
                            ),
                            const SizedBox(height: 16.0),
                            Container(
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.blue),
                                    borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: ListTile(
                                    title: Text(_selectedDateTime == null
                                        ? 'Select Date and Time'
                                        : DateFormat('yyyy-MM-dd – kk:mm').format(_selectedDateTime!)),
                                    trailing: const Icon(Icons.calendar_today),
                                    onTap: () => _selectDateTime(context),
                                ),
                            ),
                            const SizedBox(height: 16.0),
                            ElevatedButton(
                                onPressed: () {
                                    String title = _titleController.text.trim();
                                    String description = _descriptionController.text.trim();
                                    if (title.isNotEmpty && description.isNotEmpty && _selectedDateTime != null) {
                                        if (widget.initialTodo == null) {
                                            // Add new todo
                                            Todo newTodo = Todo(
                                                title: title,
                                                description: description,
                                                completionTime: _selectedDateTime!,
                                            );
                                            TodoBoxManager.addTodo(newTodo);
                                        } else {
                                            // Edit existing todo
                                            Todo updatedTodo = Todo(
                                                title: title,
                                                description: description,
                                                completionTime: _selectedDateTime!,
                                            );
                                            TodoBoxManager.updateTodoAt(TodoBoxManager.getTodos().indexOf(widget.initialTodo!), updatedTodo);
                                        }
                                        Navigator.pop(context);
                                    }
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue, // Change button color to blue
                                ),
                                child: const Text(
                                    'Save',
                                    style: TextStyle(
                                        color: Colors.white, // Change text color to white
                                        fontWeight: FontWeight.bold, // Make text bolder
                                    ),
                                ),
                            ),
                        ],
                    ),
                ),
            ),
        );
    }
}
