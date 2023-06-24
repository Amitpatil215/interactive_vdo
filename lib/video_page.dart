import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_preload_videos/Provider/game_controller.dart';
import 'package:flutter_preload_videos/widgets/interactive_grid_widget.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class VideoPage extends StatefulWidget {
  const VideoPage();

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  @override
  void initState() {
    Provider.of<GameController>(context, listen: false).startGame();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Consumer<GameController>(
        builder: (context, gameController, _) {
          VideoPlayerController _controller =
              gameController.previousVideoPlayerControllers[
                  gameController.currentDoor.doorNo]!;

          _controller.addListener(() async {
            Duration? pos = await _controller.position;
            if (pos != null)
              gameController.makeDecisionForInteractiveButton(pos.inSeconds);
          });
          return Stack(
            children: [
              VideoWidget(
                isLoading: false,
                controller: gameController.previousVideoPlayerControllers[
                    gameController.currentDoor.doorNo]!,
              ),
              Positioned(
                  bottom: height * 0.2,
                  left: width * 0.04,
                  child: InterractiveElements(height: height, width: width)),
              Positioned(
                  right: width * 0.02,
                  child: PlayPauseButton(controller: _controller)),
              Positioned(
                bottom: 1,
                child: SizedBox(
                  height: 20,
                  width: width,
                  child: VideoProgressIndicator(
                    _controller,
                    allowScrubbing: true,
                    colors: VideoProgressColors(
                      playedColor: Colors.red,
                      bufferedColor: Colors.grey,
                      backgroundColor: Colors.black.withOpacity(0.5),
                    ),
                    padding: EdgeInsets.all(5),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

/// Custom Feed Widget consisting video
class VideoWidget extends StatelessWidget {
  const VideoWidget({
    Key? key,
    required this.isLoading,
    required this.controller,
  });

  final bool isLoading;
  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: VideoPlayer(controller)),
        AnimatedCrossFade(
          alignment: Alignment.bottomCenter,
          sizeCurve: Curves.decelerate,
          duration: const Duration(milliseconds: 400),
          firstChild: Padding(
            padding: const EdgeInsets.all(10.0),
            child: CupertinoActivityIndicator(
              color: Colors.white,
              radius: 8,
            ),
          ),
          secondChild: const SizedBox(),
          crossFadeState:
              isLoading ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        ),
      ],
    );
  }
}

class PlayPauseButton extends StatefulWidget {
  const PlayPauseButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final VideoPlayerController controller;

  @override
  State<PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<PlayPauseButton> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 50),
      reverseDuration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: () {
          if (widget.controller.value.isPlaying) {
            widget.controller.pause();
          } else {
            widget.controller.play();
          }
          setState(() {});
        },
        child: Container(
          child: Icon(
            widget.controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.black,
            size: 50.0,
            semanticLabel: 'Play',
          ),
        ),
      ),
    );
  }
}
