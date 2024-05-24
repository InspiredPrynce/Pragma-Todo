import 'package:pragma_todo/models/todo.dart';
import 'package:hive/hive.dart';

class TodoAdapter extends TypeAdapter<Todo> {
    @override
    final int typeId = 0;

    @override
    Todo read(BinaryReader reader) {
        return Todo(
            title: reader.readString(),
            description: reader.readString(),
            isCompleted: reader.readBool(),
            completionTime: DateTime.parse(reader.readString()),
            creationDate: DateTime.parse(reader.readString()),
            updateDate: DateTime.parse(reader.readString()),
        );
    }

    @override
    void write(BinaryWriter writer, Todo obj) {
        writer.writeString(obj.title);
        writer.writeString(obj.description);
        writer.writeBool(obj.isCompleted);
        writer.writeString(obj.completionTime.toIso8601String());
        writer.writeString(obj.creationDate.toIso8601String());
        writer.writeString(obj.updateDate.toIso8601String());
    }
}
