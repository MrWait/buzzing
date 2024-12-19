import 'dart:math';

import 'package:buzzing/widget/particle/particle_model.dart';
import 'package:buzzing/widget/particle/particle_painter.dart';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

class ParticleWidget extends StatefulWidget {
  final int numberOfParticles;

  ParticleWidget(this.numberOfParticles);

  @override
  _ParticlesWidgetState createState() => _ParticlesWidgetState();
}

class _ParticlesWidgetState extends State<ParticleWidget>
    with WidgetsBindingObserver {
  final Random random = Random();
  final List<ParticleModel> particles = [];

  @override
  void initState() {
    // loop for number of particles times
    widget.numberOfParticles.times(() => particles.add(ParticleModel(random)));
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      particles.forEach((particle) {
        particle.restart();
        particle.shuffle();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoopAnimationBuilder<int>(
        builder: (context, child, dynamic _) {
          _simulateParticles();
          return CustomPaint(painter: ParticlePainter(particles));
        },
        tween: ConstantTween(1),
        duration: Duration(milliseconds: 3000));
  }

  _simulateParticles() {
    particles
        .forEach((particle) => particle.checkIfParticleNeedsToBeRestarted());
  }
}
