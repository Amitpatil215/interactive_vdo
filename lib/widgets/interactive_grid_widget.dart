import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_preload_videos/Provider/game_controller.dart';
import 'package:provider/provider.dart';

class InterractiveElements extends StatelessWidget {
  const InterractiveElements({
    required this.height,
    required this.width,
  });

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(builder: (context, gameController, _) {
      List<String> options =
          gameController.connectedDoors.map((door) => door.doorNo).toList();
      if (gameController.decsionStack.length > 1) {
        options.add("Go Back");
      }

      options.add("Restart");
      bool isShowInteractiveButtons = gameController.showInteractiveButtons;
      return isShowInteractiveButtons
          ? Center(
              child: ConstrainedBox(
                constraints:
                    MediaQuery.of(context).orientation == Orientation.landscape
                        ? BoxConstraints(
                            maxHeight: height * 0.4,
                            maxWidth: width * 0.7,
                          )
                        : BoxConstraints(
                            maxHeight: height * 0.4,
                            maxWidth: width * 0.9,
                          ),
                child: Container(
                  // color: Colors.black.withOpacity(0.5),
                  color: Colors.transparent,
                  child: MyGridView(
                    options: options,
                  ),
                ),
              ),
              // color: Colors.black.withOpacity(0.5),
            )
          : const SizedBox();
    });
  }
}

class MyGridView extends StatelessWidget {
  const MyGridView({required this.options});
  final List<String> options;
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: (options.length / 2).ceil(),
      childAspectRatio: 1.1,
      children: List.generate(options.length, (index) {
        return GestureDetector(
          onTap: () {
            log('Card ${options[index]} tapped!');
            Provider.of<GameController>(context, listen: false)
                .showInteractiveButtons = false;
            if (options[index] == "Restart") {
              Provider.of<GameController>(context, listen: false).reStartGame();
              return;
            }
            if (options[index] == "Go Back") {
              Provider.of<GameController>(context, listen: false)
                  .goToPreviousDecision();
              return;
            }
            Provider.of<GameController>(context, listen: false)
                .changeDoor(options[index]);
          },
          child: Card(
            color: Colors.black.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Center(
              child: Text(
                options[index],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
