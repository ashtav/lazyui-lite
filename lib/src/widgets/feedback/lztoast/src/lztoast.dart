import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lazyui_lite/lazyui_lite.dart';

import 'loading.dart';
import 'notifier.dart';
import 'overlay_entry.dart';
import 'overlay_progress.dart';

ToastPlacement _defaultPlacement = ToastPlacement.bottom;
Duration _defaultDuration = 2.s;
double _defaultRadius = 5;
int _defaultMaxLength = 80;

/// Configuration options for LzToast messages.
class LzToastConfig {
  /// The placement of the toast message on the screen.
  ToastPlacement? placement;

  /// The duration for which the toast message will be displayed.
  Duration? duration;

  /// The radius of the toast message corners.
  double radius = 5;

  /// Creates a LzToastConfig instance with optional configuration parameters.
  LzToastConfig({this.placement, this.duration, this.radius = 5});

  /// Sets the default configuration options for LzToast messages.
  static void set(
      {ToastPlacement? placement,
      Duration? duration,
      double? radius,
      int? maxLength}) {
    _defaultPlacement = placement ?? _defaultPlacement;
    _defaultDuration = duration ?? _defaultDuration;
    _defaultRadius = radius ?? _defaultRadius;
    _defaultMaxLength = maxLength ?? _defaultMaxLength;
  }
}

final _notifier = ToastNotifier();

/// A class for displaying toast messages on the screen.

class LzToast {
  /// Background color for the toast message (defaults to null for transparency).
  Color? backgroundColor;

  /// Internal reference to the overlay entry used for displaying the toast.
  LzToastOverlayEntry? overlayEntry;

  /// Private constructor to enforce singleton pattern.
  LzToast._internal(); // Use factory constructor instead

  /// Singleton instance of `LzToast`.
  static final LzToast instance = LzToast._internal();

  /// init LazyLoading
  static TransitionBuilder init({TransitionBuilder? builder}) {
    _notifier.toastMaxLength = _defaultMaxLength;

    return (BuildContext context, Widget? child) {
      return builder == null
          ? LzToastOverlay(child: child)
          : builder(context, LzToastOverlay(child: child));
    };
  }

  /// Getter for accessing the default configuration for `LzToast`.

  static LzToastConfig get config => LzToastConfig(
        /// Default placement for the toast message (likely a value from LzToastPlacement enum).
        placement: _defaultPlacement,

        /// Default duration for which the toast message is displayed.
        duration: _defaultDuration,

        /// Default corner radius for the toast message background.
        radius: _defaultRadius,
      );

  /// Displays a toast message with the specified parameters.
  static void show(String? message,
      {IconData? icon,
      Duration? duration,
      int? maxLength,
      Color? backgroundColor,
      Color? textColor,
      ToastPlacement? placement,
      bool dismissOnTap = false,
      double? radius}) {
    _notifier.dismiss();
    _notifier.showToast(message,
        icon: icon,
        duration: duration,
        placement: placement,
        maxLength: maxLength,
        backgroundColor: backgroundColor,
        textColor: textColor,
        dismissOnTap: dismissOnTap,
        radius: radius);
  }

  /// Displays an error toast message with the specified parameters.
  static void error(String? message,
      {IconData? icon,
      Duration? duration,
      int? maxLength,
      ToastPlacement? placement,
      bool dismissOnTap = false}) {
    _notifier.dismiss();
    _notifier.showToast(message,
        icon: icon,
        duration: duration,
        placement: placement,
        maxLength: maxLength,
        backgroundColor: Colors.red.withValues(alpha: .8));
  }

  /// Displays a warning toast message with the specified parameters.
  static void warning(String? message,
      {IconData? icon,
      Duration? duration,
      int? maxLength,
      ToastPlacement? placement,
      bool dismissOnTap = false}) {
    _notifier.dismiss();
    _notifier.showToast(message,
        icon: icon,
        duration: duration,
        placement: placement,
        maxLength: maxLength,
        backgroundColor: Colors.orange.withValues(alpha: .8));
  }

  /// Displays a success toast message with the specified parameters.
  static void success(String? message,
      {IconData? icon,
      Duration? duration,
      int? maxLength,
      ToastPlacement? placement,
      bool dismissOnTap = false}) {
    _notifier.dismiss();
    _notifier.showToast(message,
        icon: icon,
        duration: duration,
        placement: placement,
        maxLength: maxLength,
        backgroundColor: Colors.green.withValues(alpha: .8));
  }

  /// Displays an overlay with the given message.
  ///
  /// Returns a future that completes after the specified duration, if provided.
  static Future<T> overlay<T>(String message,
      {Duration? duration,
      bool dismissOnTap = false,
      void Function()? then,
      void Function()? onCancel,
      Future<T> Function()? future}) async {
    _notifier.dismiss();

    if (duration != null && future == null) {
      _notifier.showOverlay(message,
          dismissOnTap: dismissOnTap, onCancel: onCancel);
      _notifier.overlayTimer = Timer(duration, () {
        _notifier.dismiss();
        then?.call();
      });

      return Future.delayed(duration);
    }

    if (future != null) {
      _notifier.showOverlay(message,
          dismissOnTap: dismissOnTap, onCancel: onCancel);

      return future().then((value) {
        _notifier.dismiss();
        then?.call();
        return value;
      });
    }

    _notifier.showOverlay(message,
        dismissOnTap: dismissOnTap, onCancel: onCancel);
    return null as T;
  }

  /// Displays an overlay with a progress indicator.
  ///
  /// If [progress] function is provided, the overlay's progress will be updated accordingly.
  static overlayProgress(String message,
      {bool percentage = false,
      double Function()? progress,
      void Function()? then,
      void Function()? onCancel}) async {
    _notifier.dismiss();

    if (progress != null) {
      bool hasChanged = false;
      _notifier.setProgress(0);

      _notifier.overlayTimer?.cancel();
      _notifier.overlayTimer = Timer.periodic(200.ms, (_) {
        double value = progress();
        _notifier.setProgress(value);

        if (value >= 100 || (hasChanged && value == 0)) {
          _notifier.setProgress(100);
          _notifier.overlayTimer?.cancel();

          _notifier.overlayTimer = Utils.timer(() {
            _notifier.progress = 0;
            _notifier.dismiss(); // it has include canceling the timer
            then?.call();
          }, 200.ms);
        }

        hasChanged = value > 0;
      });
    }

    _notifier.showOverlay(message,
        isProgress: true, showPercentage: percentage, onCancel: onCancel);
  }

  /// Dismisses any active toast messages or overlays.
  static void dismiss([Duration? duration]) {
    if (duration != null) {
      Future.delayed(duration, () {
        _notifier.dismiss();
      });
      return;
    }

    _notifier.dismiss();
  }
}

/// A widget responsible for displaying the toast message on the screen.
class LzToastWidget extends StatelessWidget {
  /// Creates a new instance of `LzToastWidget`.
  const LzToastWidget({super.key});

  @override
  Widget build(BuildContext context) {
    Map<ToastPlacement, AlignmentGeometry> positions = {
      ToastPlacement.top: AlignmentDirectional.topCenter,
      ToastPlacement.center: AlignmentDirectional.center,
      ToastPlacement.bottom: AlignmentDirectional.bottomCenter,
    };

    Widget overlayContent = _notifier.watch((state) => Stack(
          alignment: AlignmentDirectional.center,
          children: [
            state.overlay
                ? BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: SizedBox(
                      width: context.width,
                      height: context.height,
                    ),
                  )
                : const None(),
            AnimatedSwitcher(
                duration: 130.ms,
                transitionBuilder:
                    (Widget child, Animation<double> animation) =>
                        FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                child: state.overlay
                    ? ZoomIn(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                // margin: Ei.only(b: context.viewInsets.bottom + 50, others: 50),
                                padding: Ei.sym(v: 20, h: 20),
                                decoration: BoxDecoration(
                                    borderRadius: Br.radius(
                                        state.radius ?? _defaultRadius),
                                    color: Colors.black.withValues(alpha: .8)),
                                child: Column(
                                  children: [
                                    state.isProgress
                                        ? Stack(
                                            alignment:
                                                AlignmentDirectional.center,
                                            children: [
                                                ...2.generate((index) {
                                                  return CircularSlider(
                                                    value: index == 0
                                                        ? state.progress ?? 0
                                                        : 100,
                                                    color: [
                                                      Colors.white,
                                                      Colors.white12
                                                    ][index],
                                                  );
                                                }),
                                                if (state.showPercentage)
                                                  Poslign(
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                        '${state.progress?.toStringAsFixed(0)}%',
                                                        style: LazyUi.font
                                                            .copyWith(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 14)),
                                                  )
                                              ])
                                        : Container(
                                            constraints: const BoxConstraints(
                                                maxWidth: 40),
                                            child: const LzLoader(
                                                color: Colors.white, size: 40)),
                                    Textr(
                                      state.overlayMessage,
                                      style: LazyUi.font
                                          .copyWith(color: Colors.white),
                                      margin: Ei.only(t: 15),
                                    ),
                                  ],
                                ).min.center,
                              ),
                            ],
                          ),
                        ).onTap(() {
                          if (state.dismissOnTap) {
                            _notifier.dismiss();
                          }
                        }),
                      )
                    : const None()),
            state.overlay && state.onCancel != null
                ? Poslign(
                    alignment: Alignment.bottomCenter,
                    child: InkTouch(
                      onTap: () {
                        _notifier.dismiss();
                        state.onCancel?.call();
                      },
                      padding: Ei.sym(v: 11, h: 55),
                      radius: Br.radius(50),
                      margin: Ei.only(b: 20),
                      child: Textr(
                        'Cancel',
                        style: LazyUi.font.copyWith(
                            color: Colors.white,
                            fontWeight: Fw.bold,
                            letterSpacing: 2),
                      ),
                    ))
                : const None()
          ],
        ));

    Widget toastContent = _notifier.watch((state) {
      final position = positions[state.toastPlacement ?? _defaultPlacement]!;

      return Stack(
        alignment: position,
        children: [
          AnimatedOpacity(
            duration: 150.ms,
            opacity: state.toast ? 1 : 0,
            child: AnimatedSwitcher(
                switchInCurve: Curves.linearToEaseOut,
                switchOutCurve: Curves.easeOutBack,
                duration: 350.ms,
                transitionBuilder:
                    (Widget child, Animation<double> animation) =>
                        ScaleTransition(
                          scale: animation,
                          child: child,
                        ),
                child: state.toast
                    ? IgnorePointer(
                        key: ValueKey(state.toastMessage),
                        child: Container(
                          margin: Ei.only(
                              b: MediaQuery.of(context).viewInsets.bottom + 50,
                              others: 50),
                          padding: Ei.sym(v: 10, h: 20),
                          decoration: BoxDecoration(
                              borderRadius:
                                  Br.radius(state.radius ?? _defaultRadius),
                              color: state.toastBackgroundColor ??
                                  Colors.black.withValues(alpha: .8)),
                          child: AnimatedSwitcher(
                              duration: 350.ms,
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                              child: Textr(
                                state.toastMessage.length > state.toastMaxLength
                                    ? '${state.toastMessage.substring(0, state.toastMaxLength)}...'
                                    : state.toastMessage,
                                style: LazyUi.font.copyWith(
                                    color:
                                        state.toastTextColor ?? Colors.white),
                                textAlign: state.toastIcon == null
                                    ? Ta.center
                                    : Ta.start,
                                icon: state.toastIcon,
                                key: UniqueKey(),
                              )),
                        ))
                    : const None()),
          )
        ],
      );
    });

    return Stack(
      fit: StackFit.expand,
      children: [
        // backdrop for overlay
        _notifier.watch((state) => state.overlay
            ? AnimatedOpacity(
                duration: 150.ms,
                opacity: state.backdrop ? 1 : 0,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black.withValues(alpha: .5),
                ))
            : const None()),

        // overlay & toast content
        overlayContent,
        toastContent
      ],
    );
  }
}
