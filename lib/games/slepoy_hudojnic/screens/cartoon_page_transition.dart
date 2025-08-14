import 'dart:ui';
import 'package:flutter/material.dart';

class CartoonPageRoute extends PageRouteBuilder {
  final Widget page;

  CartoonPageRoute({required this.page})
      : super(
          transitionDuration: const Duration(milliseconds: 900),
          reverseTransitionDuration: const Duration(milliseconds: 900),
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final blurIn = Tween<double>(begin: 0.0, end: 10.0).animate(
              CurvedAnimation(
                  parent: secondaryAnimation, curve: Curves.easeOut),
            );

            final blurOut = Tween<double>(begin: 10.0, end: 0.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeIn),
            );

            final fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeIn),
            );

            final fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
              CurvedAnimation(
                  parent: secondaryAnimation, curve: Curves.easeOut),
            );

            return Stack(
              children: [
                // Исходный экран — уходит в блюр и исчезает
                BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: blurIn.value,
                    sigmaY: blurIn.value,
                  ),
                  child: Opacity(
                    opacity: fadeOut.value,
                    child: Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
                // Новый экран — появляется с блюром и проявляется
                BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: blurOut.value,
                    sigmaY: blurOut.value,
                  ),
                  child: Opacity(
                    opacity: fadeIn.value,
                    child: child,
                  ),
                ),
              ],
            );
          },
        );
}
