import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class LetterDetectiveState extends Equatable {
  final int currentRound;
  final int correctAnswers;
  final int incorrectAttemptsThisRound;
  final String? currentPromptLetter;
  final String feedbackMessage;
  final bool showSuccessLottie;
  final String? highlightedLetter;
  final List<String> lettersOnGrid;
  final String gameSubtitle;

  const LetterDetectiveState({
    this.currentRound = 0,
    this.correctAnswers = 0,
    this.incorrectAttemptsThisRound = 0,
    this.currentPromptLetter,
    this.feedbackMessage = '',
    this.showSuccessLottie = false,
    this.highlightedLetter,
    this.lettersOnGrid = const [],
    this.gameSubtitle = '',
  });

  @override
  List<Object?> get props => [
        currentRound,
        correctAnswers,
        incorrectAttemptsThisRound,
        currentPromptLetter,
        feedbackMessage,
        showSuccessLottie,
        highlightedLetter,
        lettersOnGrid,
        gameSubtitle,
      ];
}

class GameInitial extends LetterDetectiveState {
  const GameInitial({
    super.currentRound,
    super.correctAnswers,
    super.incorrectAttemptsThisRound,
    super.currentPromptLetter,
    super.feedbackMessage,
    super.showSuccessLottie,
    super.highlightedLetter,
    super.lettersOnGrid,
    super.gameSubtitle,
  });
}

class GamePlaying extends LetterDetectiveState {
  const GamePlaying({
    required super.currentRound,
    required super.correctAnswers,
    required super.incorrectAttemptsThisRound,
    required super.currentPromptLetter,
    required super.feedbackMessage,
    required super.showSuccessLottie,
    required super.highlightedLetter,
    required super.lettersOnGrid,
    required super.gameSubtitle,
  });
}

class GameFeedback extends LetterDetectiveState {
  const GameFeedback({
    required super.currentRound,
    required super.correctAnswers,
    required super.incorrectAttemptsThisRound,
    required super.currentPromptLetter,
    required super.feedbackMessage,
    required super.showSuccessLottie,
    required super.highlightedLetter,
    required super.lettersOnGrid,
    required super.gameSubtitle,
  });
}

class GameSummary extends LetterDetectiveState {
  final double percentage;
  final String finalMessage;
  final String buttonText;
  final VoidCallback onButtonPressed;

  const GameSummary({
    required super.currentRound,
    required super.correctAnswers,
    required super.incorrectAttemptsThisRound,
    required super.currentPromptLetter,
    required super.feedbackMessage,
    required super.showSuccessLottie,
    required super.highlightedLetter,
    required super.lettersOnGrid,
    required super.gameSubtitle,
    required this.percentage,
    required this.finalMessage,
    required this.buttonText,
    required this.onButtonPressed,
  });

  @override
  List<Object?> get props => [
        ...super.props,
        percentage,
        finalMessage,
        buttonText,
        onButtonPressed,
      ];
}