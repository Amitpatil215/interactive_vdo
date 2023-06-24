class Door {
  String doorNo;
  String videoId;
  List<String> connectedDoorNos;
  int showInteractiveButtonAfterSeconds;

  Door({
    required this.doorNo,
    required this.videoId,
    required this.connectedDoorNos,
    required this.showInteractiveButtonAfterSeconds,
  });
}
