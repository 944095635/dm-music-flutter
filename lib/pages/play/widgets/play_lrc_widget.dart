import 'dart:async';
import 'package:dm_music/models/music_lrc.dart';
import 'package:dm_music/services/play_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 歌词组件
class PlayLrcWidget extends StatefulWidget {
  const PlayLrcWidget(this.lrc, {super.key});

  final MusicLrc? lrc;

  @override
  State<PlayLrcWidget> createState() => _PlayLrcWidgetState();
}

class _PlayLrcWidgetState extends State<PlayLrcWidget> {
  /// 订阅播放进度
  StreamSubscription? subMusicPosition;

  final ScrollController _scrollController = ScrollController();

  /// 当前行
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    if (widget.lrc != null) {
      List lines = widget.lrc!.line;
      PlayService playService = Get.find();
      if (widget.lrc != null) {
        //监听进度变化
        subMusicPosition = playService.listenMusicPosition((
          Duration newPosition,
          double newProgress,
        ) {
          int newIndex = -1;
          for (int i = 0; i < lines.length; i++) {
            if (lines[i].start <= newPosition.inMilliseconds) {
              newIndex = i;
            } else {
              break;
            }
          }

          if (newIndex != _currentIndex) {
            setState(() {
              _currentIndex = newIndex;
            });
            _scrollToCurrentLine();
          }
        });
      }
    }
  }

  void _scrollToCurrentLine() {
    if (_currentIndex >= 0) {
      final double scrollPosition = _currentIndex * 60.0;
      _scrollController.animateTo(
        scrollPosition,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    subMusicPosition?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lrc == null) {
      return SizedBox.shrink();
    }
    return ListView.builder(
      padding: EdgeInsets.only(
        left: 40,
        top: 300,
        right: 20,
        bottom: 80,
      ),
      itemExtent: 60,
      controller: _scrollController,
      itemCount: widget.lrc!.line.length,
      itemBuilder: (context, index) {
        MusicLrcLine line = widget.lrc!.line[index];
        final isActive = index == _currentIndex;
        return Text(
          line.value,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white30,
            fontSize: isActive ? 18 : 15,
            fontWeight: FontWeight.w600,
          ),
        );
      },
    );
  }
}
