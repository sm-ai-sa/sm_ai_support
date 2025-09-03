import 'package:flutter/material.dart';

class FadeIn extends StatefulWidget {
  final Widget child;
  final bool isShow;
  final Duration? duration;
  const FadeIn({
    super.key,
    required this.child,
    this.duration,
    this.isShow = true,
  });

  @override
  State<FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> with SingleTickerProviderStateMixin {
  double opacityLevel = 0.0;

  @override
  void initState() {
    super.initState();
    changeOpacity();
  }

  @override
  void didUpdateWidget(FadeIn oldWidget) {
    super.didUpdateWidget(oldWidget);
    changeOpacity();
  }

  void changeOpacity() {
    Future.delayed(Duration.zero, () {
      if (mounted) {
        setState(() {
          opacityLevel = widget.isShow ? 1.0 : 0.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      //* for making widget transparent for clicking if hidden
      ignoring: !widget.isShow,
      child: AnimatedOpacity(
        opacity: opacityLevel,
        duration: widget.duration ?? const Duration(milliseconds: 500),
        child: widget.child,
      ),
    );
  }
}
