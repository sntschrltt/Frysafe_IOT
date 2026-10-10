import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum AppButtonKind { black, orange, outline }

/// large   = full-width page button (Scan for Device, Go to Dashboard...)
/// medium  = bottom-sheet / card buttons (Oil replaced, Yes, Cancel)
/// small   = inline buttons (Pair the Probe, Add)
/// compact = buttons inside a card (Check your oil now)
enum AppButtonSize { large, medium, small, compact }

/// ONE button for the whole app. Same font (DM Sans bold), same corner
/// ratio (radius = height / 3), label always stays on one line.
/// [s] = screen width / 1080.
class AppButton extends StatelessWidget {
  final double s;
  final String label;
  final VoidCallback? onTap;
  final AppButtonKind kind;
  final AppButtonSize size;
  final IconData? icon;

  /// Overrides the fill color of an orange button.
  final Color? color;

  /// null = fill the width the parent gives.
  final double? width;

  const AppButton({
    super.key,
    required this.s,
    required this.label,
    required this.onTap,
    this.kind = AppButtonKind.black,
    this.size = AppButtonSize.large,
    this.icon,
    this.color,
    this.width,
  });

  double get _height => switch (size) {
        AppButtonSize.large => 181,
        AppButtonSize.medium => 120,
        AppButtonSize.small => 80,
        AppButtonSize.compact => 54,
      };

  double get _font => switch (size) {
        AppButtonSize.large => 54,
        AppButtonSize.medium => 40,
        AppButtonSize.small => 36,
        AppButtonSize.compact => 26,
      };

  double get _border => switch (size) {
        AppButtonSize.large => 5,
        AppButtonSize.medium => 4,
        AppButtonSize.small => 3,
        AppButtonSize.compact => 3,
      };

  @override
  Widget build(BuildContext context) {
    final h = _height * s;
    final outline = kind == AppButtonKind.outline;
    final fg = outline ? AppColors.black : Colors.white;
    final bg = switch (kind) {
      AppButtonKind.black => AppColors.black,
      AppButtonKind.orange => color ?? AppColors.brandOrange,
      AppButtonKind.outline => Colors.transparent,
    };
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: width,
        height: h,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: _font * 0.4 * s),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(h / 3),
          border: outline
              ? Border.all(color: AppColors.black, width: _border * s)
              : null,
        ),
        // FittedBox: label never wraps, it shrinks a little if it must.
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[
              Icon(icon, size: _font * 1.3 * s, color: fg),
              SizedBox(width: _font * 0.35 * s),
            ],
            Text(label,
                maxLines: 1,
                softWrap: false,
                style: AppText.dmSans(_font * s,
                    weight: FontWeight.w700, color: fg)),
          ]),
        ),
      ),
    );
  }
}

/// Large black page button.
class AppBlackButton extends StatelessWidget {
  final double s;
  final String label;
  final VoidCallback onTap;
  const AppBlackButton(
      {super.key, required this.s, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => AppButton(
      s: s, label: label, onTap: onTap, kind: AppButtonKind.black);
}

/// Large outlined page button.
class AppOutlineButton extends StatelessWidget {
  final double s;
  final String label;
  final VoidCallback onTap;
  const AppOutlineButton(
      {super.key, required this.s, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => AppButton(
      s: s, label: label, onTap: onTap, kind: AppButtonKind.outline);
}
