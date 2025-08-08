import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';
import '../services/database_service.dart';
import '../utils/extensions.dart';

class TodoDetailScreen extends StatefulWidget {
  final Todo todo;

  const TodoDetailScreen({Key? key, required this.todo}) : super(key: key);

  @override
  State<TodoDetailScreen> createState() => _TodoDetailScreenState();
}

class _TodoDetailScreenState extends State<TodoDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late Priority _selectedPriority;
  late Category _selectedCategory;
  DateTime? _selectedDueDate;
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo.title);
    _descriptionController = TextEditingController(
      text: widget.todo.description ?? '',
    );
    _selectedPriority = widget.todo.priority;
    _selectedCategory = widget.todo.category;
    _selectedDueDate = widget.todo.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _selectedDueDate = date;
      });
    }
  }

  Future<void> _saveTodo() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a title')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedTodo = widget.todo.copyWith(
        title: _titleController.text.trim(),
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
        priority: _selectedPriority,
        category: _selectedCategory,
        dueDate: _selectedDueDate,
        updatedAt: DateTime.now(),
      );

      await DatabaseService().updateTodo(updatedTodo);
      setState(() => _isEditing = false);
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating todo: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleComplete() async {
    setState(() => _isLoading = true);

    try {
      final updatedTodo = widget.todo.copyWith(
        isCompleted: !widget.todo.isCompleted,
        updatedAt: DateTime.now(),
      );

      await DatabaseService().updateTodo(updatedTodo);
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating todo: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue =
        widget.todo.dueDate != null &&
        widget.todo.dueDate!.isBefore(DateTime.now()) &&
        !widget.todo.isCompleted;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'Task Details'),
        actions: [
          if (!_isEditing) ...[
            IconButton(
              onPressed: _isLoading ? null : _toggleComplete,
              icon: Icon(
                widget.todo.isCompleted
                    ? Icons.check_circle
                    : Icons.check_circle_outline,
                color: widget.todo.isCompleted ? Colors.green : null,
              ),
            ),
            IconButton(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit),
            ),
          ] else ...[
            TextButton(
              onPressed: () => setState(() => _isEditing = false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: _isLoading ? null : _saveTodo,
              child:
                  _isLoading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Text('Save'),
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isEditing) ...[
              Row(
                children: [
                  Checkbox(
                    value: widget.todo.isCompleted,
                    onChanged: (_) => _toggleComplete(),
                  ),
                  Expanded(
                    child: Text(
                      widget.todo.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        decoration:
                            widget.todo.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                        color: widget.todo.isCompleted ? Colors.grey : null,
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.todo.description?.isNotEmpty == true) ...[
                const SizedBox(height: 16),
                Text(
                  widget.todo.description!,
                  style: TextStyle(
                    fontSize: 16,
                    color: widget.todo.isCompleted ? Colors.grey : null,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              _buildInfoCard(),
            ] else ...[
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),
              const Text(
                'Priority',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    Priority.values.map((priority) {
                      return ChoiceChip(
                        selected: _selectedPriority == priority,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedPriority = priority);
                          }
                        },
                        avatar: Icon(
                          priority.icon,
                          size: 16,
                          color: priority.color,
                        ),
                        label: Text(priority.name),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 24),
              const Text(
                'Category',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    Category.values.map((category) {
                      return ChoiceChip(
                        selected: _selectedCategory == category,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedCategory = category);
                          }
                        },
                        avatar: Icon(
                          category.icon,
                          size: 16,
                          color: category.color,
                        ),
                        label: Text(category.name),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 24),
              const Text(
                'Due Date',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDueDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDueDate == null
                            ? 'Select due date (optional)'
                            : DateFormat(
                              'EEEE, MMM dd, yyyy',
                            ).format(_selectedDueDate!),
                      ),
                      const Spacer(),
                      if (_selectedDueDate != null)
                        IconButton(
                          onPressed: () {
                            setState(() => _selectedDueDate = null);
                          },
                          icon: const Icon(Icons.clear),
                        ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (!_isEditing) _buildTimestamps(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    final isOverdue =
        widget.todo.dueDate != null &&
        widget.todo.dueDate!.isBefore(DateTime.now()) &&
        !widget.todo.isCompleted;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: widget.todo.priority.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.todo.priority.icon,
                        size: 16,
                        color: widget.todo.priority.color,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.todo.priority.name,
                        style: TextStyle(
                          color: widget.todo.priority.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: widget.todo.category.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.todo.category.icon,
                        size: 16,
                        color: widget.todo.category.color,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.todo.category.name,
                        style: TextStyle(
                          color: widget.todo.category.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.todo.dueDate != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      isOverdue
                          ? Colors.red.withOpacity(0.2)
                          : Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOverdue ? Icons.warning : Icons.schedule,
                      size: 16,
                      color: isOverdue ? Colors.red : Colors.blue,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${isOverdue ? 'Overdue: ' : 'Due: '}${DateFormat('EEEE, MMM dd, yyyy').format(widget.todo.dueDate!)}',
                      style: TextStyle(
                        color: isOverdue ? Colors.red : Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimestamps() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Timeline',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.add_circle_outline,
                  size: 16,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  'Created: ${DateFormat('MMM dd, yyyy \'at\' HH:mm').format(widget.todo.createdAt)}',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.edit, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Updated: ${DateFormat('MMM dd, yyyy \'at\' HH:mm').format(widget.todo.updatedAt)}',
                ),
              ],
            ),
            if (widget.todo.isCompleted) ...[
              const SizedBox(height: 8),
              const Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Status: Completed'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
