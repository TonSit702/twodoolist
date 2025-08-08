import '../models/todo.dart';
import 'package:flutter/material.dart';

extension PriorityExtension on Priority {
  String get name {
    switch (this) {
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
      case Priority.urgent:
        return 'Urgent';
    }
  }

  Color get color {
    switch (this) {
      case Priority.low:
        return Colors.green;
      case Priority.medium:
        return Colors.orange;
      case Priority.high:
        return Colors.red;
      case Priority.urgent:
        return Colors.purple;
    }
  }

  IconData get icon {
    switch (this) {
      case Priority.low:
        return Icons.keyboard_arrow_down;
      case Priority.medium:
        return Icons.remove;
      case Priority.high:
        return Icons.keyboard_arrow_up;
      case Priority.urgent:
        return Icons.priority_high;
    }
  }
}

extension CategoryExtension on Category {
  String get name {
    switch (this) {
      case Category.work:
        return 'Work';
      case Category.personal:
        return 'Personal';
      case Category.shopping:
        return 'Shopping';
      case Category.health:
        return 'Health';
      case Category.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case Category.work:
        return Icons.work;
      case Category.personal:
        return Icons.person;
      case Category.shopping:
        return Icons.shopping_cart;
      case Category.health:
        return Icons.health_and_safety;
      case Category.other:
        return Icons.category;
    }
  }

  Color get color {
    switch (this) {
      case Category.work:
        return Colors.blue;
      case Category.personal:
        return Colors.green;
      case Category.shopping:
        return Colors.orange;
      case Category.health:
        return Colors.red;
      case Category.other:
        return Colors.grey;
    }
  }
}
