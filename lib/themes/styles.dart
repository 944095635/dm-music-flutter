import 'package:flutter/material.dart';
import 'package:flutter_lyric/core/lyric_style.dart';

class LyricStylesEx {
  static final dark = LyricStyle(
    textStyle: TextStyle(fontSize: 16, color: Colors.white30),
    activeStyle: TextStyle(fontSize: 22, color: Colors.white),
    translationStyle: TextStyle(
      fontSize: 12,
      color: Colors.white70,
    ),
    lineTextAlign: TextAlign.center,
    lineGap: 26,
    translationLineGap: 10,
    contentAlignment: CrossAxisAlignment.center,
    contentPadding: EdgeInsets.only(
      top: 500,
      left: 20,
      right: 20,
      bottom: 20,
    ),
    selectionAnchorPosition: 0.48,
    fadeRange: FadeRange(top: 250, bottom: 250),
    selectedColor: Colors.white,
    selectedTranslationColor: Colors.white,
    scrollDuration: Duration(milliseconds: 240),
    scrollDurations: {
      500: Duration(milliseconds: 500),
      1000: Duration(milliseconds: 1000),
    },
    enableSwitchAnimation: false,
    selectionAutoResumeMode: SelectionAutoResumeMode.selecting,
    selectionAutoResumeDuration: Duration(milliseconds: 320),
    activeAutoResumeDuration: Duration(milliseconds: 3000),
    activeHighlightColor: const Color.fromARGB(255, 208, 174, 255),
    switchEnterDuration: Duration(milliseconds: 300),
    switchExitDuration: Duration(milliseconds: 500),
    switchEnterCurve: Curves.easeOutBack,
    switchExitCurve: Curves.easeOutQuint,
    selectionAlignment: MainAxisAlignment.center,
  );

  static final light = LyricStyle(
    textStyle: TextStyle(
      fontSize: 16,
      color: Color.fromARGB(255, 207, 187, 236),
    ),
    activeStyle: TextStyle(fontSize: 22, color: Colors.white),
    translationStyle: TextStyle(
      fontSize: 12,
      color: Colors.white70,
    ),
    lineTextAlign: TextAlign.center,
    lineGap: 26,
    translationLineGap: 10,
    contentAlignment: CrossAxisAlignment.center,
    contentPadding: EdgeInsets.only(
      top: 500,
      left: 20,
      right: 20,
      bottom: 20,
    ),
    selectionAnchorPosition: 0.48,
    fadeRange: FadeRange(top: 250, bottom: 250),
    selectedColor: Colors.white,
    selectedTranslationColor: Colors.white,
    scrollDuration: Duration(milliseconds: 240),
    scrollDurations: {
      500: Duration(milliseconds: 500),
      1000: Duration(milliseconds: 1000),
    },
    enableSwitchAnimation: false,
    selectionAutoResumeMode: SelectionAutoResumeMode.selecting,
    selectionAutoResumeDuration: Duration(milliseconds: 320),
    activeAutoResumeDuration: Duration(milliseconds: 3000),
    activeHighlightColor: const Color.fromARGB(255, 208, 174, 255),
    switchEnterDuration: Duration(milliseconds: 300),
    switchExitDuration: Duration(milliseconds: 500),
    switchEnterCurve: Curves.easeOutBack,
    switchExitCurve: Curves.easeOutQuint,
    selectionAlignment: MainAxisAlignment.center,
  );
}
