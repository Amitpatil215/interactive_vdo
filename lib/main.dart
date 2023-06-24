import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_preload_videos/Provider/game_controller.dart';
import 'package:flutter_preload_videos/core/constants.dart';
import 'package:flutter_preload_videos/video_page.dart';

import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}


Future createIsolate(String doorNo) async {
  // Set loading to true
  ReceivePort mainReceivePort = ReceivePort();

  Isolate.spawn<SendPort>(getVideosTask, mainReceivePort.sendPort);

  SendPort isolateSendPort = await mainReceivePort.first;

  ReceivePort isolateResponseReceivePort = ReceivePort();

  isolateSendPort.send([doorNo, isolateResponseReceivePort.sendPort]);

  final isolateResponse = await isolateResponseReceivePort.first;
  final _urls = isolateResponse;
}

void getVideosTask(SendPort mySendPort) async {
  ReceivePort isolateReceivePort = ReceivePort();

  mySendPort.send(isolateReceivePort.sendPort);

  await for (var message in isolateReceivePort) {
    if (message is List) {
      final String doorNo = message[0];

      final SendPort isolateResponseSendPort = message[1];

      final List<String> _urls =
          await DataBase.getConnectedDoorVideoUrls(doorNo);

      isolateResponseSendPort.send(_urls);
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
