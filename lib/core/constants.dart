// Customize
import 'package:flutter_preload_videos/model/door.dart';

class DataBase {
  static List<Door> doorsDB = [
    Door(
      doorNo: "Kid",
      videoId:
          "https://assets.mixkit.co/videos/preview/mixkit-little-girl-next-to-baskets-of-easter-eggs-48596-large.mp4",
      connectedDoorNos: ["Baloon", "Chocolate"], //  baloon or chocolate
      showInteractiveButtonAfterSeconds: const Duration(seconds: 5).inSeconds,
    ),
    Door(
      doorNo: "Baloon",
      videoId:
          "https://assets.mixkit.co/videos/preview/mixkit-eastern-egg-picnic-in-the-garden-48599-large.mp4",

      connectedDoorNos: ["Men", "Women"], //  Men or women
      showInteractiveButtonAfterSeconds: 5,
    ),
    Door(
      doorNo: "Chocolate", //chocolate
      videoId:
          "https://assets.mixkit.co/videos/preview/mixkit-little-girl-laying-in-the-grass-enjoying-a-chocolate-bunny-49069-large.mp4",
      connectedDoorNos: ["Dance", "Soccer"], // dance or soccer
      showInteractiveButtonAfterSeconds: 5,
    ),
    Door(
      doorNo: "Men", //men
      videoId:
          "https://assets.mixkit.co/videos/preview/mixkit-man-runs-past-ground-level-shot-32809-large.mp4",
      connectedDoorNos: ["Soccer", "Podcast"], // soccer or  Podcast
      showInteractiveButtonAfterSeconds: 5,
    ),
    Door(
      doorNo: "Women", // women
      videoId:
          "https://assets.mixkit.co/videos/preview/mixkit-woman-running-above-the-camera-on-a-running-track-32807-large.mp4",
      connectedDoorNos: ["Paint", "Dance"], // paint or dance
      showInteractiveButtonAfterSeconds: 5,
    ),
    Door(
      doorNo: "Paint", //paint
      videoId:
          "https://assets.mixkit.co/videos/preview/mixkit-artist-working-in-her-studio-5175-large.mp4",
      connectedDoorNos: ["Kid", "Chocolate"], //  kid or chocolate
      showInteractiveButtonAfterSeconds: 5,
    ),
    Door(
      doorNo: "Dance", // dance
      videoId:
          "https://assets.mixkit.co/videos/preview/mixkit-woman-in-a-floral-shirt-dancing-1228-large.mp4",
      connectedDoorNos: ["Paint", "Baloon"], // paint or balloon
      showInteractiveButtonAfterSeconds: 5,
    ),
    Door(
      doorNo: "Soccer", //soccer
      videoId:
          "https://assets.mixkit.co/videos/preview/mixkit-talented-soccer-player-juggling-the-ball-42540-large.mp4",
      connectedDoorNos: ["Checkmate"], // Checkmate
      showInteractiveButtonAfterSeconds: 5,
    ),
    Door(
      doorNo: "Podcast", //podcast
      videoId:
          "https://assets.mixkit.co/videos/preview/mixkit-man-talking-in-front-of-a-radio-station-microphone-2963-large.mp4",
      connectedDoorNos: ["Checkmate"], // Checkmate
      showInteractiveButtonAfterSeconds: 5,
    ),
    Door(
      doorNo: "Checkmate", //Checkmate
      videoId:
          "https://assets.mixkit.co/videos/preview/mixkit-very-close-view-of-a-wooden-chess-49734-large.mp4",
      connectedDoorNos: [],
      showInteractiveButtonAfterSeconds: 5,
    ),
  ];

  //get list of connected door videoUrls from doorNo
  static List<String> getConnectedDoorVideoUrls(String doorNo) {
    return doorsDB
        .where((door) => door.doorNo == doorNo)
        .map((door) => door.videoId)
        .toList();
  }
}
