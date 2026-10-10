import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../models/reading.dart';
import '../theme/app_theme.dart';
import '../widgets/header_shell.dart';

/// About FRYSAFE. One scrollable page; the "Understanding Your ODI" link in
/// Step 4 (and the footer links) scroll to the matching section.
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final _howKey = GlobalKey();
  final _odiKey = GlobalKey();
  late final TapGestureRecognizer _odiTap = TapGestureRecognizer()
    ..onTap = () => _goTo(_odiKey);
  double _s = 1, _vh = 800;

  @override
  void dispose() {
    _odiTap.dispose();
    super.dispose();
  }

  void _goTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOutCubic,
      alignment: (290 * _s) / _vh, // land just below the header
    );
  }

  TextStyle _body(double s, {double size = 28, Color color = AppColors.textGray}) =>
      AppText.dmSans(size * s, color: color).copyWith(height: 1.4);

  Widget _pad(double s, Widget w) =>
      Padding(padding: EdgeInsets.fromLTRB(91 * s, 0, 92 * s, 0), child: w);

  Widget _divider(double s, [Key? key]) => Center(
        child: Container(
            key: key, width: 504 * s, height: 3 * s, color: AppColors.high),
      );

  BoxDecoration _card(double s) => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(60 * s),
        border: Border.all(color: AppColors.border, width: 3 * s),
      );

  Widget _step(double s, IconData icon, String n, String title, List<InlineSpan> desc) {
    return _pad(
      s,
      Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(60 * s, 32 * s, 60 * s, 34 * s),
        decoration: _card(s),
        child: Column(children: [
          Container(
            width: 140 * s,
            height: 136 * s,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(20 * s),
              border: Border.all(color: AppColors.border, width: 3 * s),
            ),
            child: Icon(icon, size: 92 * s, color: AppColors.high),
          ),
          SizedBox(height: 23 * s),
          Text('STEP $n',
              style: AppText.dmSans(33 * s,
                  weight: FontWeight.w700, color: AppColors.high)),
          SizedBox(height: 9 * s),
          Text(title, style: AppText.dmSans(36 * s, weight: FontWeight.w700)),
          SizedBox(height: 22 * s),
          Text.rich(TextSpan(style: _body(s), children: desc),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  Widget _legendRow(double s, Severity sev, String range, String text) {
    return Row(children: [
      Container(
        width: 169 * s,
        height: 55 * s,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: sev.color, borderRadius: BorderRadius.circular(10 * s)),
        child: Text(sev.badge,
            style: AppText.dmSans(27 * s,
                weight: FontWeight.w600, color: Colors.white)),
      ),
      SizedBox(width: 24 * s),
      Expanded(
        child: Text.rich(
          TextSpan(children: [
            TextSpan(
                text: range,
                style: AppText.dmSans(29 * s,
                    weight: FontWeight.w600, color: sev.color)),
            TextSpan(text: ' $text', style: AppText.dmSans(29 * s)),
          ]),
          style: const TextStyle(letterSpacing: -0.6),
        ),
      ),
    ]);
  }

  Widget _footer(double s) {
    Widget link(String t, [VoidCallback? onTap]) => GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Text(t, style: AppText.dmSans(24 * s, color: AppColors.textGray)),
        );
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(72 * s, 46 * s, 77 * s, 48 * s),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 3 * s)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Image.asset('assets/images/logo.png',
              height: 58 * s,
              errorBuilder: (_, _, _) => Icon(Icons.shield,
                  size: 50 * s, color: AppColors.brandOrange)),
          SizedBox(width: 10 * s),
          Text('FRYSAFE', style: AppText.dmSans(32 * s, weight: FontWeight.w700)),
        ]),
        SizedBox(height: 14 * s),
        Text('IoT-powered oil quality monitoring\nfor safer, smarter frying.',
            style: _body(s, size: 24)),
        SizedBox(height: 60 * s),
        Wrap(spacing: 38 * s, runSpacing: 16 * s, children: [
          link('Privacy Policy'),
          link('Terms of Service'),
          link('How it Works', () => _goTo(_howKey)),
          link('FAQ'),
          link('Contact'),
          link('ODI', () => _goTo(_odiKey)),
        ]),
        SizedBox(height: 56 * s),
        Container(height: 4 * s, color: AppColors.border),
        SizedBox(height: 30 * s),
        Text('© 2026 FRYSAFE. All rights reserved.',
            style: AppText.dmSans(24 * s, color: AppColors.textGray)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final s = c.maxWidth / 1080;
      _s = s;
      _vh = c.maxHeight;
      final link = TextSpan(
        text: 'Understanding Your ODI',
        recognizer: _odiTap,
        style: const TextStyle(decoration: TextDecoration.underline),
      );
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(top: AppLayout.headerHeight * s),
              child: Column(children: [
                SizedBox(height: 74 * s),
                // intro card
                _pad(
                  s,
                  Container(
                    padding: EdgeInsets.fromLTRB(62 * s, 36 * s, 56 * s, 36 * s),
                    decoration: _card(s),
                    child: Row(children: [
                      Image.asset('assets/images/logo.png',
                          width: 150 * s,
                          height: 205 * s,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => Icon(Icons.shield,
                              size: 150 * s, color: AppColors.brandOrange)),
                      SizedBox(width: 30 * s),
                      Expanded(
                        child: Text.rich(TextSpan(
                          style: AppText.dmSans(29 * s).copyWith(height: 1.36),
                          children: [
                            TextSpan(
                                text: 'FRYSAFE',
                                style: AppText.dmSans(29 * s, weight: FontWeight.w700)),
                            const TextSpan(
                                text:
                                    ' is a device that helps small food businesses check if their cooking oil is still good to use. It checks the condition of the palm cooking oil and helps them know when it is time to replace the oil instead of just guessing.'),
                          ],
                        )),
                      ),
                    ]),
                  ),
                ),
                SizedBox(height: 80 * s),
                _divider(s, _howKey),
                SizedBox(height: 70 * s),
                Text('How FRYSAFE Works',
                    textAlign: TextAlign.center,
                    style: AppText.dmSans(90 * s,
                        weight: FontWeight.w700, letterSpacing: -1.5 * s)),
                SizedBox(height: 22 * s),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 120 * s),
                  child: Text(
                      'Learn how FRYSAFE checks your cooking oil and helps you know when it’s safe to use or time to replace it.',
                      textAlign: TextAlign.center,
                      style: AppText.dmSans(29 * s).copyWith(height: 1.36)),
                ),
                SizedBox(height: 40 * s),
                _step(s, Icons.thermostat, '1', 'Cool the Oil', const [
                  TextSpan(
                      text:
                          'If the oil was recently used, let it cool before testing. If not, proceed to Step 2.'),
                ]),
                SizedBox(height: 37 * s),
                _step(s, Icons.local_drink_outlined, '2', 'Pour the Oil', const [
                  TextSpan(
                      text:
                          'Pour the used or unused oil into the covered testing cup, up to ___ mL.'),
                ]),
                SizedBox(height: 37 * s),
                _step(s, Icons.pin_drop_outlined, '3', 'Insert the Probe', const [
                  TextSpan(text: 'Place the FRYSAFE probe into the cup.'),
                ]),
                SizedBox(height: 37 * s),
                _step(s, Icons.water_drop_outlined, '4', 'Start Measuring', [
                  const TextSpan(
                      text:
                          'Press the button. The LCD will display “Measuring… Please Wait.” Sensor will take the readings. And then, the device combines both readings into the Oil Degradation Index (ODI), a score from 0 to 100. Check the '),
                  link,
                  const TextSpan(text: ' for your reference.'),
                ]),
                SizedBox(height: 37 * s),
                _step(s, Icons.fact_check_outlined, '5', 'View the Result', const [
                  TextSpan(
                      text:
                          'The oil\'s condition is shown on the LCD and LEDs, then sent to this app so you can view it, track your test history, and get replacement reminders.'),
                ]),
                SizedBox(height: 75 * s),
                // Understanding your ODI
                _divider(s, _odiKey),
                SizedBox(height: 47 * s),
                Text('Understanding your ODI',
                    textAlign: TextAlign.center,
                    style: AppText.dmSans(76 * s,
                        weight: FontWeight.w700, letterSpacing: -1.2 * s)),
                SizedBox(height: 20 * s),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 90 * s),
                  child: Text(
                      'These readings are combined into the Oil Degradation Index (ODI), a score from 0 to 100. The result appears on the device\'s LCD and LEDs and is sent to this app in real time.',
                      textAlign: TextAlign.center,
                      style: AppText.dmSans(29 * s).copyWith(height: 1.36)),
                ),
                SizedBox(height: 40 * s),
                _pad(
                  s,
                  Container(
                    padding: EdgeInsets.fromLTRB(56 * s, 41 * s, 30 * s, 54 * s),
                    decoration: _card(s),
                    child: Column(children: [
                      _legendRow(s, Severity.low, '0–24:', 'Oil is still in good condition.'),
                      SizedBox(height: 16 * s),
                      _legendRow(s, Severity.moderate, '25–49:', 'Early signs of breakdown. Use with caution.'),
                      SizedBox(height: 16 * s),
                      _legendRow(s, Severity.high, '50–74:', 'Oil quality is poor. Consider replacing it soon.'),
                      SizedBox(height: 16 * s),
                      _legendRow(s, Severity.veryHigh, '75–100:', 'Oil is unsafe. Replace immediately.'),
                    ]),
                  ),
                ),
                SizedBox(height: 42 * s),
                Padding(
                  padding: EdgeInsets.fromLTRB(108 * s, 0, 100 * s, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text.rich(TextSpan(children: [
                      TextSpan(
                          text: 'Important Note:\n',
                          style: AppText.dmSans(29 * s, weight: FontWeight.w700)),
                      TextSpan(
                          text:
                              'FRYSAFE provides an operational estimate based on color and turbidity only. It does not replace laboratory oil analysis such as Total Polar Materials (TPM) or Free Fatty Acids (FFA) testing.',
                          style: _body(s, size: 26).copyWith(height: 1.3)),
                    ])),
                  ),
                ),
                SizedBox(height: 90 * s),
                _footer(s),
              ]),
            ),
          ),
          // header (same one every page uses)
          AppHeader(
            s: s,
            title: 'ABOUT',
            subtitle: 'How FRYSAFE works & your ODI',
            actionIcon: Icons.close,
            onAction: () => Navigator.of(context).pop(),
          ),
        ]),
      );
    });
  }
}
