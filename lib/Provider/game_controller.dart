import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_preload_videos/core/constants.dart';
import 'package:flutter_preload_videos/main.dart';
import 'package:flutter_preload_videos/model/door.dart';
import 'package:video_player/video_player.dart';

class GameController extends ChangeNotifier {
  late Door currentDoor;
  bool _showInteractiveButtons = false;
  List<Door> decsionStack = [];
  Map<String, VideoPlayerController> previousVideoPlayerControllers = {};
  GameController() {
    currentDoor = DataBase.doorsDB.firstWhere((door) => door.doorNo == "Kid");
  }
  //getter
  bool get showInteractiveButtons => _showInteractiveButtons;
  //setter
  set showInteractiveButtons(bool value) {
    _showInteractiveButtons = value;
    notifyListeners();
  }

  //get list of connected doors
  List<Door> get connectedDoors {
    return DataBase.doorsDB
        .where((door) => currentDoor.connectedDoorNos.contains(door.doorNo))
        .toList();
  }

  // make decision for interactive button based on current time of video
  void makeDecisionForInteractiveButton(int currentTime) {
    if (currentTime >= currentDoorInteractiveButtonShowTime &&
        !showInteractiveButtons) {
      showInteractiveButtons = true;
    } else if (currentTime < currentDoorInteractiveButtonShowTime &&
        showInteractiveButtons) {
      showInteractiveButtons = false;
    }
  }

  // get current doors  interactive show times
  int get currentDoorInteractiveButtonShowTime {
    return currentDoor.showInteractiveButtonAfterSeconds;
  }

  Future startGame() async {
    /// Initialize 1st video
    currentDoor = DataBase.doorsDB.firstWhere((door) => door.doorNo == "Kid");
    await _initializeControllerAtIndex(currentDoor.videoId, currentDoor.doorNo);

    /// Play 1st video
    _playControllerAtIndex(currentDoor.doorNo);
    decsionStack.add(currentDoor);

    /// Initialize options video
    await Future.forEach(connectedDoors, (Door door) async {
      await _initializeControllerAtIndex(door.videoId, door.doorNo);
    });
  }

  Future reStartGame() async {
    _stopControllerAtIndex(currentDoor.doorNo);
    await Future.forEach(connectedDoors, (Door door) async {
      await _disposeControllerAtIndex(door.doorNo);
    });

    //dispose all the decisions from stack
    await Future.forEach(decsionStack, (Door door) async {
      await _disposeControllerAtIndex(door.doorNo);
    });
    decsionStack.clear();
    previousVideoPlayerControllers.clear();
    await startGame();
  }

  // go to previous descison
  void goToPreviousDecision() {
    _stopControllerAtIndex(currentDoor.doorNo);
    if (decsionStack.length > 1) {
      decsionStack.removeLast();
      currentDoor = decsionStack.last;
      decsionStack.removeLast();
      _playNext(currentDoor.doorNo);
      notifyListeners();
    }
  }

  //change door
  Future changeDoor(String doorNo) async {
    createIsolate(doorNo);
    _playNext(doorNo);
  }

  Future _playNext(String doorNo) async {
    /// Stop [index - 1] controller
    _stopControllerAtIndex(currentDoor.doorNo);

    await Future.forEach(connectedDoors, (Door door) async {
      //dispose controller other than seelcted one and previous one
      if (door.doorNo != doorNo && door.doorNo != currentDoor.doorNo)
        await _disposeControllerAtIndex(door.doorNo);
    });

    currentDoor = DataBase.doorsDB.firstWhere((door) => door.doorNo == doorNo);
    decsionStack.add(currentDoor);
    _playControllerAtIndex(doorNo);

    /// Initialize [index + 1] controller
    /// Initialize options video
    await Future.forEach(connectedDoors, (Door door) async {
      await _initializeControllerAtIndex(door.videoId, door.doorNo);
    });
  }

  Future _initializeControllerAtIndex(String videoUrl, String doorNo) async {
    /// Create new controller
    final VideoPlayerController _controller = VideoPlayerController.network(
      videoUrl,
    );

    /// Add to [controllers] list
    previousVideoPlayerControllers[doorNo] = _controller;

    /// Initialize
    await _controller.initialize();

    log('🚀🚀🚀 INITIALIZED $doorNo');
    notifyListeners();
  }

  void _playControllerAtIndex(String doorNo) {
    /// Get controller at [index]
    VideoPlayerController? _controller = previousVideoPlayerControllers[doorNo];

    //if null then initialize
    if (_controller == null) {
      _initializeControllerAtIndex(
          DataBase.doorsDB.firstWhere((door) => door.doorNo == doorNo).videoId,
          doorNo);
      _controller = previousVideoPlayerControllers[doorNo];
    }

    /// Play controller
    _controller!.play();

    log('🚀🚀🚀 PLAYING $doorNo');
  }

  void _stopControllerAtIndex(String doorNo) {
    /// Get controller at [index]
    final VideoPlayerController _controller =
        previousVideoPlayerControllers[doorNo]!;

    /// Pause
    _controller.pause();

    /// Reset postiton to beginning
    _controller.seekTo(const Duration());

    log('🚀🚀🚀 STOPPED $String doorNo');
  }

  Future _disposeControllerAtIndex(String doorNo) async {
    /// Get controller at [index]
    final VideoPlayerController? _controller =
        previousVideoPlayerControllers[doorNo];

    /// Dispose controller
    await _controller?.dispose();

    if (_controller != null) {
      previousVideoPlayerControllers.remove(doorNo);
    }

    log('🚀🚀🚀 DISPOSED $String doorNo');
  }
}
