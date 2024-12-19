import 'package:flutter/material.dart';
import 'package:buzzing/widget/particle/particle_model.dart';
import 'package:simple_animations/simple_animations.dart';

class ParticlePainter extends CustomPainter {
  List<ParticleModel> particles;
  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withAlpha(50);
    particles.forEach((particle) {
      final progress = particle.progress();
      final Movie animation = particle.tween.transform(progress);
      final position = Offset(
          animation.get('x') * size.width, animation.get('y') * size.height);
      canvas.drawCircle(position, size.width * 0.2 * particle.size, paint);
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
