import 'package:flutter/material.dart';


class EcomCategory {
  final String name;
  final Color color;
  final Icon icon;
  final int index;
  final bool restricted;

  EcomCategory({
    required this.name,
    required this.color,
    required this.icon,
    required this.index,
    required this.restricted,
  });

  @override
  bool operator ==(Object other) {
    return other is EcomCategory && other.name.toLowerCase() == name.toLowerCase();
  }

  @override
  int get hashCode => name.hashCode;
}
