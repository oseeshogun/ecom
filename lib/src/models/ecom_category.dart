import 'package:flutter/material.dart';

class EcomCategory {
  final String name;
  final Color color;
  final Icon icon;

  EcomCategory({
    required this.name,
    required this.color,
    required this.icon,
  });

  @override
  bool operator ==(Object other) {
    return other is EcomCategory && other.name.toLowerCase() == name.toLowerCase();
  }

  @override
  int get hashCode => name.hashCode;
}
