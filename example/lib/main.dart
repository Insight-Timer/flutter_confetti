import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

void main() => runApp(const ConfettiSample());

class ConfettiSample extends StatelessWidget {
  const ConfettiSample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Confetti',
        home: Scaffold(
          backgroundColor: Colors.grey[900],
          body: MyApp(),
        ));
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 10));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// A custom Path to paint stars.
  Path drawStar(Size size) {
    // Method to convert degree to radians
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step), halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          InsightConfetti(confettiController: _controller),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              children: [
                TextButton(
                  onPressed: () => _controller.play(),
                  child: Text('Play'),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => _controller.pause(),
                  child: Text('Pause'),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class InsightConfetti extends StatefulWidget {
  const InsightConfetti({
    Key? key,
    required this.confettiController,
    this.color,
  }) : super(key: key);

  static ConfettiController defaultConfettiController() {
    return ConfettiController(duration: const Duration(seconds: 3));
  }

  final ConfettiController confettiController;
  final Color? color;

  @override
  State<InsightConfetti> createState() => _InsightConfettiState();
}

class _InsightConfettiState extends State<InsightConfetti> {
  late List<ConfettiController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(10, (_) => widget.confettiController.copyWith());
    widget.confettiController.addListener(() {
      switch (widget.confettiController.state) {
        case ConfettiControllerState.playing:
          _controllers.forEach((controller) => controller.play());
          break;
        case ConfettiControllerState.paused:
          _controllers.forEach((controller) => controller.pause());
          break;
        case ConfettiControllerState.stopped:
          _controllers.forEach((controller) => controller.stop());
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _controllers
          .mapIndexed(
            (index, controller) => Expanded(
              child: Container(
                child: _buildConfettiLane(controller: controller),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildConfettiLane({required ConfettiController controller}) {
    final confettiColor = Colors.yellow;
    return ConfettiWidget(
      confettiController: controller,
      blastDirection: pi / 2,
      particleDrag: 0.01,
      emissionFrequency: 0.05,
      numberOfParticles: 3,
      gravity: 0.01,
      shouldLoop: false,
      colors: [
        confettiColor,
        confettiColor.withOpacity(0.5),
        confettiColor.withOpacity(0.8),
      ],
      createParticlePath: _createParticlePath,
    );
  }

  Path _createParticlePath(Size size) {
    final width = size.width * 0.6;
    final height = size.height * 0.4;
    final pathShape = Path()
      ..moveTo(0, 0)
      ..lineTo(-width, 0)
      ..lineTo(-width, height)
      ..lineTo(0, height)
      ..close();
    return pathShape;
  }
}
