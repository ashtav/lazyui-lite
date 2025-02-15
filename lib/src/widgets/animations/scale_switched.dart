part of '../widget.dart';

/// A widget that animates the scaling and switching of its child widget.
///
/// The `ScaleSwitched` widget is used for creating smooth transitions when switching
/// between different child widgets. It animates the scale transformation of its child
/// widget when the `child` property changes.
class ScaleSwitched extends StatelessWidget {
  /// The child widget to be animated.
  final Widget? child;

  /// The total duration of the scaling animation.
  final Duration? duration;

  /// The alignment of the scaling transformation.
  final Alignment alignment;

  /// Creates a `ScaleSwitched` widget.
  ///
  /// The [child] is the widget to be animated when switching.
  /// The [duration] specifies the total duration of the scaling animation.
  /// The [alignment] sets the alignment of the scaling transformation (default is centerLeft).
  ///
  /// Example usage:
  /// ```dart
  /// notifier.watch((state) => ScaleSwitched(
  ///   duration: 150.ms,
  ///   child: state.toggle ? Text('First Wdiget', key: UniqueKey()) : Text('Second Widget', key: UniqueKey()),
  /// ))
  /// ```
  const ScaleSwitched({
    super.key,
    this.child,
    this.duration,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration ?? const Duration(milliseconds: 250),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(
          scale: animation,
          alignment: alignment,
          child: child,
        );
      },
      child: child,
    );
  }
}
