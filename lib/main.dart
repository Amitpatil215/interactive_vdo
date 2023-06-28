import 'dart:convert';
import 'dart:developer';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:flutter_preload_videos/Provider/game_controller.dart';
import 'package:flutter_preload_videos/core/constants.dart';
import 'package:flutter_preload_videos/model/door.dart';
import 'package:flutter_preload_videos/video_page.dart';

import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

Future createIsolate(String doorNo) async {
  // Set loading to true
  ReceivePort mainReceivePort = ReceivePort();

  FlutterIsolate.spawn<SendPort>(getVideosTask, mainReceivePort.sendPort);

  SendPort isolateSendPort = await mainReceivePort.first;

  final List<Door> _connectedDoors = await DataBase.getConnectedDoors(doorNo);
  for (var door in _connectedDoors) {
    ReceivePort isolateResponseReceivePort = ReceivePort();
    isolateSendPort
        .send([door.videoId, door.doorNo, isolateResponseReceivePort.sendPort]);
    final filepath = await isolateResponseReceivePort.first;

    log("Loaded from isolates ${door.doorNo} -> $filepath");
  }
}

@pragma('vm:entry-point')
void getVideosTask(SendPort mySendPort) async {
  ReceivePort isolateReceivePort = ReceivePort();

  mySendPort.send(isolateReceivePort.sendPort);

  await for (var message in isolateReceivePort) {
    if (message is List) {
      final String url = message[0];
      final String doorNo = message[1];

      final SendPort isolateResponseSendPort = message[2];

      var file = await DefaultCacheManager().getSingleFile(url);
      isolateResponseSendPort.send(file.path);
    }
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: VideoPage(),
      ),
    );
  }
}
