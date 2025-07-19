// lib/bloc/letter_detective_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:letter_detective/bloc/letter_detective_event.dart';
import 'package:letter_detective/bloc/letter_detective_state.dart';
import 'package:letter_detective/models/letter_model.dart';
import 'dart:math'; // Import for Random

class LetterDetectiveBloc extends Bloc<LetterDetectiveEvent, LetterDetectiveState> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Chapter gameChapterData;
  late List<String> _lettersOnGrid; // This list will be shuffled
  final Random _random = Random(); // Random instance for shuffling

  LetterDetectiveBloc({required this.gameChapterData})
      : super(
          GameInitial(
            lettersOnGrid: _extractUniqueLettersFromExpectedWords(gameChapterData.expectedWords),
            gameSubtitle: gameChapterData.subtitle,
          ),
        ) {
    _lettersOnGrid = _extractUniqueLettersFromExpectedWords(gameChapterData.expectedWords);
    _lettersOnGrid.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    on<GameStarted>(_onGameStarted);
    on<PlayIntroAudioCompleted>(_onPlayIntroAudioCompleted);
    on<PlayPromptAudio>(_onPlayPromptAudio);
    on<PromptAudioCompleted>(_onPromptAudioCompleted);
    on<LetterTapped>(_onLetterTapped);
    on<FeedbackAudioCompleted>(_onFeedbackAudioCompleted);
    on<ResetGame>(_onResetGame);

    _audioPlayer.onPlayerComplete.listen((event) {
      if (state.currentRound == -1) {
        add(PlayIntroAudioCompleted());
      } else if (state is GamePlaying) {
        // If prompt audio just finished, we don't shuffle immediately
        // Shuffling happens after a correct answer leading to a new round
        add(PromptAudioCompleted());
      } else if (state is GameFeedback) {
        add(FeedbackAudioCompleted());
      }
    });
  }

  static List<String> _extractUniqueLettersFromExpectedWords(
    List<List<String>> expectedWords,
  ) {
    Set<String> uniqueLetters = {};
    for (var sublist in expectedWords) {
      for (var letter in sublist) {
        uniqueLetters.add(letter);
      }
    }
    return uniqueLetters.toList();
  }

  // New method to shuffle letters
  void _shuffleLetters() {
    _lettersOnGrid.shuffle(_random);
  }

  void _onGameStarted(GameStarted event, Emitter<LetterDetectiveState> emit) async {
    _shuffleLetters(); // Initial shuffle when game starts
    if (event.introAudioUrl.isNotEmpty) {
      try {
        await _audioPlayer.setSourceUrl(event.introAudioUrl);
        await _audioPlayer.resume();
        emit(
          GamePlaying(
            currentRound: -1, // Special state for intro audio
            correctAnswers: 0,
            incorrectAttemptsThisRound: 0,
            lettersOnGrid: List.of(_lettersOnGrid), // Emit a copy
            gameSubtitle: gameChapterData.subtitle,
            currentPromptLetter: null,
            feedbackMessage: '',
            showSuccessLottie: false,
            highlightedLetter: null,
          ),
        );
      } catch (e) {
        print('Error playing intro audio: $e');
        _startNextRound(emit); // Skip intro if error
      }
    } else {
      _startNextRound(emit);
    }
  }

  void _onPlayIntroAudioCompleted(PlayIntroAudioCompleted event, Emitter<LetterDetectiveState> emit) {
    _startNextRound(emit);
  }

  void _onPlayPromptAudio(PlayPromptAudio event, Emitter<LetterDetectiveState> emit) async {
    if (state.currentRound < gameChapterData.audioList.length) {
      String promptAudioUrl = gameChapterData.audioList[state.currentRound];
      try {
        await _audioPlayer.setSourceUrl(promptAudioUrl);
        await _audioPlayer.resume();
      } catch (e) {
        print('Error playing prompt audio: $e');
        // If audio fails, proceed to next round after a delay
        await Future.delayed(const Duration(milliseconds: 500));
        _startNextRound(emit);
      }
    }
  }

  void _onPromptAudioCompleted(PromptAudioCompleted event, Emitter<LetterDetectiveState> emit) {
    // The game remains in GamePlaying state, waiting for user input.
  }

  void _onLetterTapped(LetterTapped event, Emitter<LetterDetectiveState> emit) async {
    if (state.currentPromptLetter == null || _audioPlayer.state == PlayerState.playing) {
      return; // Ignore tap if no prompt or audio is playing
    }

    print('Tapped: ${event.tappedLetter}, Expected: ${state.currentPromptLetter}');


    if (event.tappedLetter == state.currentPromptLetter) {
      // Correct answer logic
      if (state.incorrectAttemptsThisRound == 0) {
        // Correct on first tap
        emit(
          GameFeedback(
            currentRound: state.currentRound,
            correctAnswers: state.correctAnswers + 1,
            incorrectAttemptsThisRound: 0,
            currentPromptLetter: state.currentPromptLetter,
            feedbackMessage: '',
            showSuccessLottie: true,
            highlightedLetter: null,
            lettersOnGrid: List.of(_lettersOnGrid),
            gameSubtitle: gameChapterData.subtitle,
          ),
        );
        print('Correct on first tap. Correct answers: ${state.correctAnswers + 1}');
        await Future.delayed(const Duration(seconds: 1));
        _startNextRound(emit); // This will include shuffling
      } else {
        // Correct after incorrect attempts
        emit(
          GameFeedback(
            currentRound: state.currentRound,
            correctAnswers: state.correctAnswers,
            incorrectAttemptsThisRound: 0,
            currentPromptLetter: state.currentPromptLetter,
            feedbackMessage: 'That\'s it!',
            showSuccessLottie: false,
            highlightedLetter: null,
            lettersOnGrid: List.of(_lettersOnGrid),
            gameSubtitle: gameChapterData.subtitle,
          ),
        );
        print('Correct after incorrect attempts.');
        await Future.delayed(const Duration(milliseconds: 1000));
        _startNextRound(emit); // This will include shuffling
      }
    } else {
      // Incorrect answer logic
      int newIncorrectAttempts = state.incorrectAttemptsThisRound + 1;
      print('Incorrect attempt. Attempts this round: $newIncorrectAttempts');

      if (newIncorrectAttempts == 1) {
        emit(
          GameFeedback(
            currentRound: state.currentRound,
            correctAnswers: state.correctAnswers,
            incorrectAttemptsThisRound: newIncorrectAttempts,
            currentPromptLetter: state.currentPromptLetter,
            feedbackMessage: 'Oops, try again!',
            showSuccessLottie: false,
            highlightedLetter: null,
            lettersOnGrid: List.of(_lettersOnGrid),
            gameSubtitle: gameChapterData.subtitle,
          ),
        );
        String? oopsAudio = gameChapterData.failAudios.firstWhere(
          (audioUrl) => audioUrl.contains('Oops_try_again.mp3'),
          orElse: () => '',
        );
        if (oopsAudio.isNotEmpty) {
          await _playFeedbackAudio(oopsAudio);
        } else {
          print('Warning: "Oops, try again!" audio not found in failAudios.');
        }
      } else {
        emit(
          GameFeedback(
            currentRound: state.currentRound,
            correctAnswers: state.correctAnswers,
            incorrectAttemptsThisRound: newIncorrectAttempts,
            currentPromptLetter: state.currentPromptLetter,
            feedbackMessage:
                'This is ${state.currentPromptLetter}. Let’s remember it for next time!',
            showSuccessLottie: false,
            highlightedLetter: state.currentPromptLetter,
            lettersOnGrid: List.of(_lettersOnGrid),
            gameSubtitle: gameChapterData.subtitle,
          ),
        );
        String? specificFailAudio;
        String targetWordForAudio = gameChapterData.targetWords[state.currentRound];
        String searchKey = targetWordForAudio
            .replaceAll(' ', '+')
            .toLowerCase();

        specificFailAudio = gameChapterData.failAudios.firstWhere(
          (audioUrl) => audioUrl.toLowerCase().contains(searchKey),
          orElse: () => '',
        );

        if (specificFailAudio.isNotEmpty) {
          await _playFeedbackAudio(specificFailAudio);
        } else {
          print(
            'Warning: Specific fail audio for "${state.currentPromptLetter}" (searchKey: "$searchKey") not found. Playing a generic one if available.',
          );
          String? genericFeedback = gameChapterData.failAudios
              .firstWhere(
                (audio) =>
                    audio.contains('remember+it+for+next+time') ||
                    audio.contains('This+is'),
                orElse: () => '',
              );
          if (genericFeedback.isNotEmpty) {
            await _playFeedbackAudio(genericFeedback);
          } else {
            print('Warning: No generic "this is X" feedback audio found.');
          }
        }
        await Future.delayed(const Duration(seconds: 2));
        _startNextRound(emit); // This will include shuffling
      }
    }
  }

  void _onFeedbackAudioCompleted(FeedbackAudioCompleted event, Emitter<LetterDetectiveState> emit) {
    if (state.incorrectAttemptsThisRound > 0 && state.feedbackMessage == 'Oops, try again!') {
      // Stay on the same round, waiting for another attempt
      emit(
        GamePlaying(
          currentRound: state.currentRound,
          correctAnswers: state.correctAnswers,
          incorrectAttemptsThisRound: state.incorrectAttemptsThisRound,
          currentPromptLetter: state.currentPromptLetter,
          feedbackMessage: '',
          showSuccessLottie: false,
          highlightedLetter: null,
          lettersOnGrid: List.of(_lettersOnGrid), // Maintain current shuffled state
          gameSubtitle: gameChapterData.subtitle,
        ),
      );
    } else {
      // Move to next round after more significant feedback or correct answer
      // The startNextRound already handles shuffling for these cases
      _startNextRound(emit);
    }
  }

  void _onResetGame(ResetGame event, Emitter<LetterDetectiveState> emit) {
    // Re-extract and sort initial letters, then shuffle for a fresh start
    _lettersOnGrid = _extractUniqueLettersFromExpectedWords(gameChapterData.expectedWords);
    _lettersOnGrid.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    _shuffleLetters(); // Shuffle for the new game

    emit(
      GameInitial(
        lettersOnGrid: List.of(_lettersOnGrid),
        gameSubtitle: gameChapterData.subtitle,
      ),
    );
    add(
      GameStarted(
        introAudioUrl: gameChapterData.introAudios.isNotEmpty
            ? gameChapterData.introAudios.first
            : '',
        audioList: gameChapterData.audioList,
        targetWords: gameChapterData.targetWords,
        failAudios: gameChapterData.failAudios,
        finishAudios: gameChapterData.finishAudios,
      ),
    );
  }

  Future<void> _playFeedbackAudio(String audioUrl) async {
    try {
      await _audioPlayer.setSourceUrl(audioUrl);
      await _audioPlayer.resume();
    } catch (e) {
      print('Error playing feedback audio: $e');
    }
  }

  void _startNextRound(Emitter<LetterDetectiveState> emit) async {
    int nextRound = state.currentRound + 1;
    if (nextRound < gameChapterData.audioList.length && nextRound < gameChapterData.targetWords.length) {
      _shuffleLetters(); // Shuffle letters for the new round
      String targetWord = gameChapterData.targetWords[nextRound];
      String currentPromptLetter = targetWord.split(' ').last;
      emit(
        GamePlaying(
          currentRound: nextRound,
          correctAnswers: state.correctAnswers,
          incorrectAttemptsThisRound: 0,
          currentPromptLetter: currentPromptLetter,
          feedbackMessage: '',
          showSuccessLottie: false,
          highlightedLetter: null,
          lettersOnGrid: List.of(_lettersOnGrid), // Emit the shuffled list
          gameSubtitle: gameChapterData.subtitle,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 500));
      add(PlayPromptAudio());
    } else {
      _showPostGameSummary(emit);
    }
  }

  void _showPostGameSummary(Emitter<LetterDetectiveState> emit) {
    double percentage = (gameChapterData.audioList.isEmpty
            ? 0
            : (state.correctAnswers / gameChapterData.audioList.length)) *
        100;
    String finalMessage;
    String audioToPlayUrl;
    String buttonText;
    late void Function() onButtonPressed;

    print(
      'Showing post-game summary. Correct: ${state.correctAnswers}, Total: ${gameChapterData.audioList.length}, Percentage: $percentage',
    );

    if (percentage >= 80) {
      finalMessage =
          'You did amazing, Letter Detective! You\'re ready for the next game! Let’s keep learning together.';
      audioToPlayUrl = gameChapterData.finishAudios.firstWhere(
        (audio) => audio.contains('ready_for_the_next_game.mp3'),
        orElse: () => gameChapterData.finishAudios.isNotEmpty
            ? gameChapterData.finishAudios.last
            : '',
      );
      buttonText = 'Next';
      onButtonPressed = () {
        // This will be handled by the UI poping the screen
      };
    } else {
      finalMessage =
          'Great effort! Let’s practice these letters a little more together so you can become a Super Letter Detective!';
      audioToPlayUrl = gameChapterData.finishAudios.firstWhere(
        (audio) => audio.contains(
          'Great_effort_Let%E2%80%99s_practice_these_letters.mp3',
        ),
        orElse: () => gameChapterData.finishAudios.isNotEmpty
            ? gameChapterData.finishAudios.first
            : '',
      );
      buttonText = 'Try Again';
      onButtonPressed = () {
        add(ResetGame());
      };
    }

    if (audioToPlayUrl.isNotEmpty) {
      _playFeedbackAudio(audioToPlayUrl);
    } else {
      print('Warning: Finish audio URL not found for post-game summary.');
    }

    emit(
      GameSummary(
        currentRound: state.currentRound,
        correctAnswers: state.correctAnswers,
        incorrectAttemptsThisRound: state.incorrectAttemptsThisRound,
        currentPromptLetter: state.currentPromptLetter,
        feedbackMessage: '',
        showSuccessLottie: false,
        highlightedLetter: null,
        lettersOnGrid: List.of(_lettersOnGrid), // Use the current (possibly shuffled) grid
        gameSubtitle: gameChapterData.subtitle,
        percentage: percentage,
        finalMessage: finalMessage,
        buttonText: buttonText,
        onButtonPressed: onButtonPressed,
      ),
    );
  }

  @override
  Future<void> close() {
    _audioPlayer.dispose();
    print('AudioPlayer disposed in Bloc.');
    return super.close();
  }
}