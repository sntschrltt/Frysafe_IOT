import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/header_shell.dart';

/// Placeholder: send your About design and I'll build it.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final s = c.maxWidth / 1080;
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(children: [
          Center(
              child: Text('About\n(coming soon)',
                  textAlign: TextAlign.center,
                  style: AppText.arial(20, color: AppColors.textGray))),
          PageHeader(s: s, title: 'ABOUT', subtitle: 'FrySafe'),
        ]),
      );
    });
  }
}
