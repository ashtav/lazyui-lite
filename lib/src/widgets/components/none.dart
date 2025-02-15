part of '../widget.dart';

/// None is a convenient shortcut for creating an empty, zero-sized box using [SizedBox.shrink()].
/// It allows you to quickly create a widget that takes up no space in your layout.

class None extends StatelessWidget {
  /// Create widget
  const None({super.key});

  @override
  Widget build(BuildContext context) => SizedBox.shrink(key: key);
}
