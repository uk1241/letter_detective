import 'package:equatable/equatable.dart';

abstract class LetterDetectiveEvent extends Equatable {
  const LetterDetectiveEvent();

  @override
  List<Object> get props => [];
}

class GameStarted extends LetterDetectiveEvent {
  final String introAudioUrl;
  final List<String> audioList;
  final List<String> targetWords;
  final List<String> failAudios;
  final List<String> finishAudios;

  const GameStarted({
    required this.introAudioUrl,
    required this.audioList,
    required this.targetWords,
    required this.failAudios,
    required this.finishAudios,
  });

  @override
  List<Object> get props => [introAudioUrl, audioList, targetWords, failAudios, finishAudios];
}

class PlayIntroAudioCompleted extends LetterDetectiveEvent {}

class PlayPromptAudio extends LetterDetectiveEvent {}

class PromptAudioCompleted extends LetterDetectiveEvent {}

class LetterTapped extends LetterDetectiveEvent {
  final String tappedLetter;

  const LetterTapped(this.tappedLetter);

  @override
  List<Object> get props => [tappedLetter];
}

class FeedbackAudioCompleted extends LetterDetectiveEvent {}

class ResetGame extends LetterDetectiveEvent {}