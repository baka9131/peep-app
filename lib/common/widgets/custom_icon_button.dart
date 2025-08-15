import 'package:flutter/material.dart';
import 'package:peep/ui/core/themes/app_styles.dart';

class FullIconButton extends StatelessWidget {
  const FullIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.color,
  });

  final Widget icon;
  final String? tooltip;
  final Color? color;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      highlightColor: kColorTransparent,
      onPressed: onPressed,
      tooltip: tooltip,
      color: color,
      icon: icon,
    );
  }
}

class MidIconButton extends StatelessWidget {
  const MidIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.color,
  });

  final Widget icon;
  final String? tooltip;
  final Color? color;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      highlightColor: kColorTransparent,
      onPressed: onPressed,
      tooltip: tooltip,
      color: color,
      icon: Padding(padding: const EdgeInsets.all(8.0), child: icon),
    );
  }
}

class LowIconButton extends StatelessWidget {
  const LowIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.color,
  });

  final Widget icon;
  final String? tooltip;
  final Color? color;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: IconButton(
        constraints: const BoxConstraints(),
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        highlightColor: kColorTransparent,
        onPressed: onPressed,
        tooltip: tooltip,
        color: color,
        icon: icon,
      ),
    );
  }
}
