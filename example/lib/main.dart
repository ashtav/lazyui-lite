import 'package:flutter/material.dart';
import 'package:lazyui_lite/lazyui_lite.dart';

void main() {
  LazyUi.init(icon: IconType.huge);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: LzTheme.light,
      title: 'LazyUi',
      home: const HomeView(),
      builder: LazyUi.builder,
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LzListView(
        children: [],
      ),
    );
  }
}
