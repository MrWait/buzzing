import 'dart:math';

import 'package:buzzing/common/style/buzzing_style.dart';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

class Mole extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MoleState();
}

class _MoleState extends State<Mole> {
  final List<MolePaticle> particles = [];
  bool _moleIsVisible = false;

  @override
  void initState() {
    _restartMole();
    Future.delayed(1200.milliseconds, () {
      _hitMole();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(width: 100, height: 100, child: _buildMole());
  }

  Widget _buildMole() {
    _manageParticleLifecycle();
    return LoopAnimationBuilder();
  }

  Widget _mole() {
    return Container(
        decoration: BoxDecoration(
            color: BuzzingColors.primaryValue,
            borderRadius: BorderRadius.circular(50)));
  }

  _hitMole() {
    Iterable.generate(50).forEach((i) => particles.add(MolePaticle()));
  }

  void _restartMole() {
    var respawnTime = (2000 + Random().nextInt(1500)).milliseconds;
    await Future.delayed(respawnTime);
    _setMoleVisible(true);

    var timeVisible = (500 + Random().nextInt(1500)).milliseconds;
    await Future.delayed(timeVisible);
    _setMoleVisible(false);
    _restartMole();
  }

  _manageParticleLifecycle() {
    particles.removeWhere((particle) {
      return particle.progress() == 1;
    });
  }

  _setMoleVisible(bool visible) {
    setState(() {
      _moleIsVisible = visible;
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}

enum _MoleProps { x, y, scale }

class MolePaticle {
  late Animatable<int> tween;
  late Duration startTime;
  final duration = 600.milliseconds;

  MoleParticle() {
    final random = Random();
    final x = (100 + 200) * random.nextDouble() * (random.nextBool() ? 1 : -1);
    final y = (100 + 200) * random.nextDouble() * (random.nextBool() ? 1 : -1);

  }

  Widget buildWidget() {

  }

  double progress() {
    return (((DateTime.now().duration() - startTime) / duration))
    .clamp(0.0, 1.0)
    .toDouble();
}
}
