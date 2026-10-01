import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppBlackButton extends StatelessWidget {
  final double s;
  final String label;
  final VoidCallback onTap;
  const AppBlackButton(
      {super.key, required this.s, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 181 * s,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: AppColors.black,
              borderRadius: BorderRadius.circular(60 * s)),
          child: Text(label, style: AppText.arial(56 * s, color: Colors.white)),
        ),
      );
}

class AppOutlineButton extends StatelessWidget {
  final double s;
  final String label;
  final VoidCallback onTap;
  const AppOutlineButton(
      {super.key, required this.s, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 181 * s,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(60 * s),
            border: Border.all(color: AppColors.black, width: 5 * s),
          ),
          child: Text(label, style: AppText.arial(56 * s)),
        ),
      );
}
