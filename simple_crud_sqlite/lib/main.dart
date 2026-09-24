import 'package:flutter/material.dart';
import 'package:simple_crud_sqlite/pages/simple_crud.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: SimpleCrud());
  }
}
