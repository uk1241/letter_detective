import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letter_detective/bloc/letter_detective_bloc.dart';
import 'package:letter_detective/bloc/letter_detective_event.dart';
import 'package:letter_detective/bloc/letter_detective_state.dart';
import 'package:letter_detective/models/letter_model.dart'; // Assuming Chapter is defined here
import 'package:lottie/lottie.dart';

class LetterDetectiveGame extends StatefulWidget {
  final Chapter gameChapterData;

  const LetterDetectiveGame({Key? key, required this.gameChapterData})
    : super(key: key);

  @override
  _LetterDetectiveGameState createState() => _LetterDetectiveGameState();
}

class _LetterDetectiveGameState extends State<LetterDetectiveGame>
    with SingleTickerProviderStateMixin {
  // Add AnimationController for tap animation
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Track the letter that was just tapped to apply the animation
  String? _tappedLetterForAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150), // Quick animation
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Function to handle the tap animation
  void _onTapAnimation(String letter) async {
    setState(() {
      _tappedLetterForAnimation = letter;
    });
    await _animationController.forward(from: 0.0);
    setState(() {
      _tappedLetterForAnimation = null; // Clear after animation
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          LetterDetectiveBloc(gameChapterData: widget.gameChapterData)..add(
            GameStarted(
              introAudioUrl: widget.gameChapterData.introAudios.isNotEmpty
                  ? widget.gameChapterData.introAudios.first
                  : '',
              audioList: widget.gameChapterData.audioList,
              targetWords: widget.gameChapterData.targetWords,
              failAudios: widget.gameChapterData.failAudios,
              finishAudios: widget.gameChapterData.finishAudios,
            ),
          ),
      child: Scaffold(
        backgroundColor:
            Colors.transparent, // Set scaffold background to transparent
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF956F), Color(0xFFFFB199)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: BlocConsumer<LetterDetectiveBloc, LetterDetectiveState>(
              listener: (context, state) {
                if (state is GameSummary) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: const Text('Game Over!'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(state.finalMessage),
                            const SizedBox(height: 10),
                            Text(
                              'Total correct: ${state.correctAnswers}/${widget.gameChapterData.audioList.length}',
                            ),
                            Text(
                              'Percentage: ${state.percentage.toStringAsFixed(0)}%',
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              if (state.buttonText == 'Next') {
                                Navigator.of(context).pop();
                              } else {
                                state.onButtonPressed();
                              }
                            },
                            child: Text(state.buttonText),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              builder: (context, state) {
                return Column(
                  children: [
                    // Custom AppBar section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        16.0,
                        0.0,
                        16.0,
                        0.0,
                      ), // Adjust top padding from SafeArea
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_ios,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Review',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () {
                                  // Handle View Demo
                                },
                                child: const Text(
                                  'View Demo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${state.correctAnswers}/10', // Dynamic correct answers
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.star,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ), // Spacing below the custom app bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Activity Progress: Round ${state.currentRound == -1 ? 1 : state.currentRound + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value:
                                (state.currentRound == -1
                                    ? 0
                                    : (state.currentRound + 1)) /
                                widget.gameChapterData.audioList.length,
                            backgroundColor: Colors.white.withOpacity(0.5),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            minHeight: 8, // Make the progress bar a bit thicker
                            borderRadius: BorderRadius.circular(
                              4,
                            ), // Rounded corners for progress bar
                          ),
                          const SizedBox(height: 30), // Increased spacing
                          Center(
                            child: Text(
                              'Tap the letters you hear',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26, // Slightly larger font
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Center(
                            child: Text(
                              state.currentPromptLetter != null
                                  ? 'Find big ${state.currentPromptLetter}'
                                  : '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20, // Slightly larger font
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30), // Spacing before the grid
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.0), // Rounded top-left
                            topRight: Radius.circular(
                              40.0,
                            ), // Rounded top-right
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                30.0,
                                30.0,
                                30.0,
                                20.0,
                              ), // Adjust padding for visual alignment
                              child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 18, // Increased spacing
                                      mainAxisSpacing: 18, // Increased spacing
                                      childAspectRatio: 1.0,
                                    ),
                                itemCount: state.lettersOnGrid.length,
                                itemBuilder: (context, index) {
                                  final letter = state.lettersOnGrid[index];
                                  bool isCurrentlyTapped =
                                      _tappedLetterForAnimation == letter;

                                  return GestureDetector(
                                    onTapDown: (_) {
                                      if (state is GamePlaying &&
                                          state.currentPromptLetter != null) {
                                        _onTapAnimation(letter);
                                      }
                                    },
                                    onTap: () {
                                      context.read<LetterDetectiveBloc>().add(
                                        LetterTapped(letter),
                                      );
                                    },
                                    child: ScaleTransition(
                                      scale: isCurrentlyTapped
                                          ? _scaleAnimation
                                          : const AlwaysStoppedAnimation(1.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors
                                              .white, // Solid white background
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ), // Rounded corners
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(
                                                0.15,
                                              ), // Subtle shadow
                                              spreadRadius: 2,
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            letter,
                                            style: TextStyle(
                                              fontSize: 55, // Larger font size
                                              fontWeight: FontWeight.bold,
                                              color: Colors
                                                  .grey
                                                  .shade700, // Slightly darker grey
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            if (state.showSuccessLottie)
                              Lottie.asset(
                                'assets/lottie/success.json',
                                width: 200,
                                height: 200,
                                fit: BoxFit.contain,
                                repeat: false,
                              ),
                            if (state.feedbackMessage.isNotEmpty &&
                                !state.showSuccessLottie)
                              Positioned(
                                bottom: 20,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    state.feedbackMessage,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
