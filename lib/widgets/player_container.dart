import 'dart:async';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:simple_music_player/data/fixtures/lyrics.dart';
import 'package:simple_music_player/resources/assets.dart';
import 'package:simple_music_player/resources/colors.dart';
import 'package:simple_music_player/resources/sizes.dart';
import 'package:simple_music_player/widgets/player_controls.dart';
import 'package:simple_music_player/widgets/player_lyrics.dart';
import 'package:simple_music_player/widgets/player_timeline.dart';

class PlayerContainer extends StatefulWidget {
  final double panPercent;
  final Function(double) panUpdateCallback;
  final ScrollController scaffoldScrollController;
  final StreamController closeStreamController;

  PlayerContainer({
    this.panPercent,
    @required this.panUpdateCallback,
    @required this.scaffoldScrollController,
    @required this.closeStreamController,
  });

  @override
  _PlayerContainerState createState() => _PlayerContainerState();
}

class _PlayerContainerState extends State<PlayerContainer>
    with SingleTickerProviderStateMixin {
  final minAlbulmArtWidth = 50.0;
  final dragAutoCompletePercent = 0.35;

  double startDragY;
  double startDragPercent;
  double dragDistance;
  double dragPercent;
  DragDirection dragDirection = DragDirection.none;

  Tween<double> dragAutoCompleteAnimationTween;
  AnimationController dragAutoCompleteAnimationController;
  CurvedAnimation curvedAnimation;

  @override
  void initState() {
    dragAutoCompleteAnimationController =
        AnimationController(duration: Duration(milliseconds: 220), vsync: this)
          ..addListener(() {
            widget.panUpdateCallback(
                dragAutoCompleteAnimationTween.evaluate(curvedAnimation));
          })
          ..addStatusListener((AnimationStatus status) {
            if (status == AnimationStatus.completed) {
              dragDirection = DragDirection.none;
              dragAutoCompleteAnimationTween = null;
            }
          });

    curvedAnimation = CurvedAnimation(
        parent: dragAutoCompleteAnimationController, curve: Curves.easeOut);

    widget.closeStreamController.stream.listen((data) {
      _animateContainer(false);
    });
  }

  @override
  void dispose() {
    dragAutoCompleteAnimationController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    if (widget.scaffoldScrollController.offset !=
        widget.scaffoldScrollController.position.minScrollExtent) return;

    startDragY = details.globalPosition.dy;
    startDragPercent = widget.panPercent;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (widget.scaffoldScrollController.offset !=
        widget.scaffoldScrollController.position.minScrollExtent) return;

    if (startDragY != null) {
      dragDistance = details.globalPosition.dy - startDragY;

      if (dragDistance > 0 && startDragPercent == 0)
        dragDirection = DragDirection.down;
      else if (dragDistance < 0 && startDragPercent == 1)
        dragDirection = DragDirection.up;
      else
        dragDirection = DragDirection.none;

      final fullDragHeight = context.size.height - 100;

      dragPercent = dragDistance / fullDragHeight;
      final double total = (startDragPercent + dragPercent).clamp(0.0, 1.0);

      widget.panUpdateCallback(total);
    }
  }

  void _onPanEnd(DragEndDetails dragEndDetails) {
    if (widget.scaffoldScrollController.offset !=
        widget.scaffoldScrollController.position.minScrollExtent) return;

    if (dragDirection == DragDirection.down) {
      _animateContainer(
          dragPercent.abs() >= dragAutoCompletePercent ? false : true);
    } else if (dragDirection == DragDirection.up) {
      _animateContainer(
          dragPercent.abs() >= dragAutoCompletePercent ? true : false);
    }
    startDragY = null;
    startDragPercent = null;
  }

  void _animateContainer(open) {
    if ((open && widget.panPercent == 0.0) ||
        (!open && widget.panPercent == 1.0)) return;

    final double scrollTop =
        widget.scaffoldScrollController.position.minScrollExtent;

    if (widget.scaffoldScrollController.offset != scrollTop) {
      widget.scaffoldScrollController.animateTo(
        scrollTop,
        duration: Duration(milliseconds: 100),
        curve: Curves.easeInOut,
      );
    }
    // calculate duraction based on distance to end
    final distanceToEnd = (widget.panPercent - (open ? 0.0 : 1.0)).abs();
    dragAutoCompleteAnimationController.duration =
        Duration(milliseconds: (250 * distanceToEnd).clamp(100, 250).round());

    dragAutoCompleteAnimationTween =
        Tween(begin: widget.panPercent, end: open ? 0.0 : 1.0);
    dragAutoCompleteAnimationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragStart: _onPanStart,
      onVerticalDragUpdate: _onPanUpdate,
      onVerticalDragEnd: _onPanEnd,
      onTap: () => _animateContainer(true),
      child: Container(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Transform.translate(
              offset: Offset(0, 250.0 * widget.panPercent),
              child: Opacity(
                opacity: (1 - 2 * widget.panPercent).clamp(0.0, 1.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: primary,
                      ),
                      onPressed: () => _animateContainer(false),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: AppSpace.md + 20, bottom: AppSpace.md),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                            text: '',
                            style: TextStyle(
                              color: primary,
                              fontWeight: FontWeight.w700,
                              fontSize: AppFont.md,
                            ),
                            children: <TextSpan>[
                              TextSpan(text: 'Cheap Thrills\n'),
                              TextSpan(
                                  text: 'Sia',
                                  style: TextStyle(
                                      color: secondaryText,
                                      fontSize: AppFont.md - 3,
                                      height: 1.5)),
                            ]),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.more_vert,
                        color: primary,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(0, -110 * widget.panPercent),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpace.sm),
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final width = constraints.maxWidth;
                    return Row(
                      children: <Widget>[
                        Container(
                          width: lerpDouble(
                              width, minAlbulmArtWidth, widget.panPercent),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: ExactAssetImage(SIA),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(5.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromRGBO(50, 50, 50, 0.4),
                                    blurRadius: 25,
                                    offset: Offset(7.0, 12.0),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(child: Text(' ')),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(0, 200 * widget.panPercent),
              child: Padding(
                padding: EdgeInsets.only(
                  left: AppSpace.sm,
                  top: AppSpace.md,
                  right: AppSpace.sm,
                ),
                child: Column(
                  children: <Widget>[
                    PlayerLyrics(lyrics: siaLyrics),
                    PlayerTimeline(),
                    PlayerControls(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum DragDirection {
  up,
  down,
  none,
}
