import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class AnimatedBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tween = MovieTween()
      ..scene(
              begin: const Duration(milliseconds: 0),
              end: const Duration(milliseconds: 3000))
          .tween(
              'color1',
              Tween<Color>(
                  begin: Color(0xffd38312), end: Colors.lightBlue.shade900))
      ..scene(
              begin: const Duration(milliseconds: 0),
              end: const Duration(milliseconds: 3000))
          .tween(
              'color2',
              Tween<Color>(
                  begin: Color(0xffA83279), end: Colors.blue.shade600));
    return MirrorAnimationBuilder<Movie>(
        tween: tween,
        duration: tween.duration,
        builder: (context, value, child) {
          return Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                value.get('color1'),
                value.get('color2'),
              ])));
        });
  }
}
