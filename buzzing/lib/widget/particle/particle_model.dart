import 'dart:math';

import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

enum ParticleOffsetProps { x, y }

class ParticleModel {
  late MovieTween tween;
  late double size;
  late Duration duration;
  late Duration startTime;
  Random random;

  ParticleModel(this.random) {
    restart();
    shuffle();
  }

  restart() {
    final startPosition = Offset(-0.2 + 1.4 * random.nextDouble(), 1.2);
    final endPosition = Offset(-0.2 + 1.4 * random.nextDouble(), -0.2);
    // TODO
    tween = MovieTween()
      ..scene().tween(
          'x', Tween<double>(begin: startPosition.dx, end: startPosition.dy))
      ..scene().tween(
          'y', Tween<double>(begin: endPosition.dx, end: endPosition.dy));
    duration = 3000.milliseconds + random.nextInt(6000).milliseconds;
    startTime = DateTime.now().duration();
    size = 0.2 + random.nextDouble() * 0.4;
  }

  void shuffle() {
    startTime -= (this.random.nextDouble() * duration.inMilliseconds)
        .round()
        .milliseconds;
  }

  checkIfParticleNeedsToBeRestarted() {
    if (progress() == 1.0) {
      restart();
    }
  }

  double progress() {
    return ((DateTime.now().duration() - startTime) / duration)
        .clamp(0.0, 1.0)
        .toDouble();
  }
}
