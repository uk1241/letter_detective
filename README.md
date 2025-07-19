# Letter Detective Game

This is a Flutter-based "Letter Detective" game application designed to help users identify and tap specific letters they hear. The game features an engaging user interface with smooth animations and clear feedback, built with Flutter and BLoC for state management.

## Features

  * **Interactive Letter Grid:** A 3x3 grid displaying various letters for the user to interact with.
  * **Audio-Based Prompts:** The game provides audio cues, prompting the user to find and tap specific letters.
  * **Dynamic UI Updates:** Utilizes BLoC (Business Logic Component) for robust state management, ensuring the UI updates seamlessly based on game progress and user interactions.
  * **Tap Animations:** Smooth scaling animation on letter taps for a responsive user experience.
  * **Progress Tracking:** Displays activity progress (current round) and score (correct answers).
  * **Game Summary:** Provides a summary at the end of the game, including correct answers, percentage, and a final message.
  * **Lottie Animations:** Integrates Lottie animations for success feedback (e.g., when a correct letter is tapped).
  * **Customizable Content:** Designed to be driven by `Chapter` data, allowing for easy configuration of different game rounds, audio lists, target words, and feedback audios.
  * **Modern UI:** Features a clean and visually appealing design with gradients, rounded corners, and subtle shadows.

## Technologies Used

  * **Flutter:** The UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.
  * **BLoC (Bloc Library):** A popular state management solution for Flutter, providing a predictable and testable way to manage application states.
  * **`lottie` package:** For rendering After Effects animations exported as JSON (used for success animations).
  * **`audioplayers` (assumed):** While not explicitly in the provided code, a package like `audioplayers` would be used for playing the game's audio prompts and feedback.

## Project Structure (Key Files)

  * `lib/main.dart`: Entry point of the Flutter application.
  * `lib/screens/letter_detective_game.dart`: The main UI of the game, including the letter grid and game controls.
  * `lib/bloc/letter_detective_bloc.dart`: The BLoC responsible for handling the game's business logic and state.
  * `lib/bloc/letter_detective_event.dart`: Defines the events that trigger state changes in the BLoC.
  * `lib/bloc/letter_detective_state.dart`: Defines the different states of the game.
  * `lib/models/letter_model.dart`: Contains data models like `Chapter`, which define the game's content and structure.
  * `assets/lottie/success.json`: Lottie animation file for success feedback.

## Getting Started

### Prerequisites

  * Flutter SDK installed.
  * An IDE like VS Code or Android Studio with Flutter plugin.

### Installation

1.  **Clone the repository:**

    ```bash
    git clone <repository_url_here>
    cd letter_detective_game
    ```

2.  **Install dependencies:**

    ```bash
    flutter pub get
    ```

3.  **Run the application:**

    ```bash
    flutter run
    ```

## How to Play

The game will present a grid of letters and play an audio prompt. Your task is to listen carefully to the audio (e.g., "Find big S") and tap on the corresponding letter displayed in the grid. The game will provide visual and audio feedback on whether your tap was correct or incorrect.

## Customization

The game's content is driven by the `Chapter` model. To create new game rounds or modify existing ones:

1.  **Modify `lib/models/letter_model.dart`**: Ensure your `Chapter` model correctly defines `introAudios`, `audioList`, `targetWords`, `failAudios`, and `finishAudios`.

2.  **Update Game Data**: When instantiating `LetterDetectiveGame`, pass in a `Chapter` object with your desired game data. For example:

    ```dart
    // Example of how you might pass game data
    Chapter myGameChapter = Chapter(
      introAudios: ['assets/audio/intro_sound.mp3'],
      audioList: ['assets/audio/find_s.mp3', 'assets/audio/find_p.mp3'],
      targetWords: ['S', 'P'],
      failAudios: ['assets/audio/try_again.mp3'],
      finishAudios: ['assets/audio/good_job.mp3'],
    );

    // In your navigation or route:
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LetterDetectiveGame(gameChapterData: myGameChapter),
      ),
    );
    ```

3.  **Add Assets:** Ensure all audio files (MP3, OGG, etc.) and Lottie JSON files used in your `Chapter` data are correctly placed in the `assets/audio/` and `assets/lottie/` directories respectively, and referenced in your `pubspec.yaml` file.

    ```yaml
    flutter:
      uses-material-design: true
      assets:
        - assets/audio/
        - assets/lottie/
    ```

## Contributing

Feel free to fork the repository, make improvements, and submit pull requests.

## License

[Specify your project's license here, e.g., MIT License, Apache 2.0, etc.]