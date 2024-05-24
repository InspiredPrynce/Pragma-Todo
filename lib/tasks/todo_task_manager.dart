import 'package:pragma_todo/models/todo.dart';
import 'package:hive/hive.dart';

class TodoBoxManager {
    static final Box<Todo> _todoBox = Hive.box<Todo>('todos');

    static List<Todo> getTodos() {
        return _todoBox.values.toList().cast<Todo>();
    }

    static Future<void> addTodo(Todo todo) async {
        await _todoBox.add(todo);
    }

    static Future<void> updateTodoAt(int index, Todo todo) async {
        todo.updateDate = DateTime.now();
        await _todoBox.putAt(index, todo);
    }

    static Future<void> deleteTodoAt(int index) async {
        await _todoBox.deleteAt(index);
    }

    static Future<void> archiveTodoAt(int index, Todo todo) async {
        await _todoBox.putAt(index, todo);
    }

    static Future<void> deleteAllTodos() async {
        await _todoBox.clear();
    }
}
