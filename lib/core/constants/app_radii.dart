import 'package:flutter/material.dart';

/// Stitch Shape Geometry & Corner Radius Tokens.
class AppRadii {
  static const double compact     = 10.0;
  static const double control     = 14.0;
  static const double card        = 18.0;
  static const double hero        = 24.0;
  static const double pill        = 9999.0;

  static const BorderRadius compactRadius = BorderRadius.all(Radius.circular(compact));
  static const BorderRadius controlRadius = BorderRadius.all(Radius.circular(control));
  static const BorderRadius cardRadius    = BorderRadius.all(Radius.circular(card));
  static const BorderRadius heroRadius    = BorderRadius.all(Radius.circular(hero));
  static const BorderRadius pillRadius    = BorderRadius.all(Radius.circular(pill));
}

