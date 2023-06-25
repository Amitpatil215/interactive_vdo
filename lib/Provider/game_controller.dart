import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_preload_videos/core/constants.dart';
import 'package:flutter_preload_videos/main.dart';
import 'package:flutter_preload_videos/model/door.dart';
import 'package:video_player/video_player.dart';

class GameController extends ChangeNotifier {
  /// Maintains the state of the current playing video
  late Door currentDoor;

  /// Maintains the state of interactive buttons
  /// after specific time of video, it will be true
  bool _showInteractiveButtons = false;

  // Maintains the stack of decisions
  List<Door> decsionStack = [];

  /// Maintains the list of previous video player controllers
  /// It will be used to dispose the controllers as well as used to
  /// preload the videos
  Map<String, VideoPlayerController> previousVideoPlayerControllers = {};

  /// Constructor
  GameController() {
    currentDoor = DataBase.doorsDB.firstWhere((door) => door.doorNo == "Kid");
  }
  /// getter
  bool get showInteractiveButtons => _showInteractiveButtons;

  /// setter
  set showInteractiveButtons(bool value) {
    _showInteractiveButtons = value;
    notifyListeners();
  }

  /// get list of connected doors
  List<Door> get connectedDoors {
    return DataBase.doorsDB
        .where((door) => currentDoor.connectedDoorNos.contains(door.doorNo))
        .toList();
  }

  /// make decision for interactive button based on current time of video
  void makeDecisionForInteractiveButton(int currentTime) {
    if (currentTime >= currentDoorInteractiveButtonShowTime &&
        !showInteractiveButtons) {
      showInteractiveButtons = true;
    } else if (currentTime < currentDoorInteractiveButtonShowTime &&
        showInteractiveButtons) {
      showInteractiveButtons = false;
    }
  }

  /// get current doors  interactive show times
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

  /// Go to previous decision
  /// 1. Stop current controller
  /// 2. Dispose current controller
  /// 3. Remove current controller from [controllers] list
  /// 4. Get previous controller
  /// 5. Play previous controller
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

  /// Change door
  /// Ran into isolate cause we want to schedule all the
  /// related videos to be loaded in background
  Future changeDoor(String doorNo) async {
    createIsolate(doorNo);
    _playNext(doorNo);
  }

  /// Play next video
  /// 1. Stop current controller
  /// 2. Get next controller
  /// 3. Play next controller
  /// 4. Initialize next controller
  Future _playNext(String doorNo) async {
    _stopControllerAtIndex(currentDoor.doorNo);

    await Future.forEach(connectedDoors, (Door door) async {
      //dispose controller other than seelcted one and previous one
      if (door.doorNo != doorNo && door.doorNo != currentDoor.doorNo)
        await _disposeControllerAtIndex(door.doorNo);
    });

    currentDoor = DataBase.doorsDB.firstWhere((door) => door.doorNo == doorNo);
    decsionStack.add(currentDoor);
    _playControllerAtIndex(doorNo);

    /// Initialize options video
    await Future.forEach(connectedDoors, (Door door) async {
      await _initializeControllerAtIndex(door.videoId, door.doorNo);
    });
  }

  /// Initialize controller at [doorNo]
  /// 1. Create new controller
  /// 2. Add to [controllers] list
  /// 3. Initialize
  /// 4. Notify listeners
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

  /// Play controller at [doorNo]
  /// 1. Get controller at [doorNo]
  /// 2. Play controller

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

  /// Stop controller at [doorNo]
  /// 1. Get controller at [doorNo]
  /// 2. Pause controller
  /// 3. Reset position to beginning

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

  /// Dispose controller at [doorNo]
  /// 1. Get controller at [doorNo]
  /// 2. Dispose controller
  /// 3. Remove controller from [controllers] list

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
