import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PebbleLoadingAnimation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250.0,
      height: 250.0,
      child: Shimmer.fromColors(
        child: Image.asset('assets/images/pebblelogowhite.png'),
        baseColor: Colors.transparent,
        highlightColor: Colors.white,
      ),
    );
  }
}
