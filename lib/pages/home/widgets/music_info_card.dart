import 'dart:ui';

import 'package:dm_music/models/music.dart';
import 'package:dm_music/pages/home/widgets/music_info.dart';
import 'package:flutter/material.dart';

class MusicInfoCard extends StatelessWidget {
  const MusicInfoCard(this.music, {super.key});

  final Music? music;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    BorderRadius topBorderRadius = BorderRadius.vertical(
      top: Radius.circular(20),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: topBorderRadius,
        boxShadow: [
          BoxShadow(
            blurRadius: 5,
            //color: const Color.fromARGB(255, 255, 0, 0),
            //color: const Color.fromRGBO(60, 60, 60, 0.8),
            color: theme.colorScheme.onSurface.withAlpha(30),
            blurStyle: BlurStyle.outer,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 15,
            sigmaY: 15,
          ),
          child: Container(
            padding: const EdgeInsets.only(
              top: 24,
              left: 20,
              right: 20,
            ),
            alignment: Alignment.topCenter,
            decoration: BoxDecoration(
              borderRadius: topBorderRadius,
              border: Border(
                top: const BorderSide(
                  color: Color.fromRGBO(255, 255, 255, 0.65),
                ),
              ),
              color: theme.bottomSheetTheme.modalBackgroundColor,
            ),
            child: music != null ? MusicInfo(music!) : null,
          ),
        ),
      ),
    );
  }
}
