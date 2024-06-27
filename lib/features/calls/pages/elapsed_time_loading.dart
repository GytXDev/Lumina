import 'package:flutter/material.dart';

import '../../../colors/coloors.dart';
import '../../../languages/app_translations.dart';

class ElapsedTimeLoadingWidget extends StatefulWidget {
  const ElapsedTimeLoadingWidget({super.key});

  @override
  State<ElapsedTimeLoadingWidget> createState() =>
      _ElapsedTimeLoadingWidgetState();
}

class ElapsedTimeWidget extends StatelessWidget {
  final String elapsedTime;

  const ElapsedTimeWidget({super.key, required this.elapsedTime});

  @override
  Widget build(BuildContext context) {
    return Text(
      elapsedTime,
      style: const TextStyle(fontSize: 20, color: Coolors.greyDark),
    );
  }
}

class _ElapsedTimeLoadingWidgetState extends State<ElapsedTimeLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Text(
          AppLocalizations.of(context).translate('calling') + _getLoadingDots(),
          style: const TextStyle(fontSize: 20, color: Coolors.greyDark),
        );
      },
    );
  }

  String _getLoadingDots() {
    final int dotsCount = (_controller.value * 4).floor() % 4;
    return List<String>.generate(dotsCount, (index) => '.').join();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
