## Project Description 

Download app [here](https://drive.google.com/file/d/1zz6ockr8nkKRn6e_SkpFCCd8Gw0NPXrl/view?usp=sharing)


This project is a Flutter application that allows users to play videos based on their interaction with the app. The app isolates and preloads possible user decisions for faster performance.


https://github.com/Amitpatil215/interactive_vdo/assets/54329870/7e649524-131c-4314-8499-2f76617bfb91

## Preloads possible user decisions
![image](https://github.com/Amitpatil215/interactive_vdo/assets/54329870/ce637110-e90d-4a79-bb67-99197c089680)


## Features

- Play videos based on user interaction
- Isolates and preloads possible user decisions for faster performance

## Installation

1. Clone the repository to your local machine.
2. Open the project in your preferred IDE.
3. Run `flutter pub get` to install dependencies.
4. Run the app using `flutter run`.

## Usage

1. Start the app.
2. The app will start playing the first video.
3. After a certain time, interactive buttons will appear.
4. Click on a button to make a decision.
5. The app will play the next video based on the user's decision.
6. Repeat steps 3-5 until the end of the game.

## Code Overview

The `GameController` class is responsible for maintaining the state of the current playing video, interactive buttons, and the stack of decisions. It also initializes, plays, stops, and disposes video player controllers.

The `startGame` method initializes and plays the first video and preloads the options videos. The `reStartGame` method stops and disposes all video player controllers and starts the game again.

The `changeDoor` method isolates and preloads the related videos and plays the next video. The `goToPreviousDecision` method goes back to the previous decision and plays the previous video.

## Dependencies

- `flutter`
- `video_player`
- `Provider`
- `flutter_isolate`
