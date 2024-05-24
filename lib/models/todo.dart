class Todo {
    String title;
    String description;
    bool isCompleted;
    bool isArchived;
    DateTime creationDate;
    DateTime updateDate;
    DateTime completionTime;

    Todo({
        required this.title,
        required this.description,
        this.isCompleted = false,
        this.isArchived = false,
        DateTime? creationDate,
        DateTime? updateDate,
        DateTime? completionTime,
    })  : creationDate = creationDate ?? DateTime.now(),
            updateDate = updateDate ?? DateTime.now(),
            completionTime = completionTime ?? DateTime.now().add(const Duration(hours: 1));
}
