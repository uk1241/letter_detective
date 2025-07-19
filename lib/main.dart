import 'package:flutter/material.dart';
import 'package:letter_detective/models/letter_model.dart';
import 'package:letter_detective/screens/letter_detective_game.dart';
import 'package:letter_detective/services/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Letter Detective',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder<GameData?>(
        future: _fetchGameData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            print('Snapshot Error: ${snapshot.error}');
            return Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')),
            );
          } else if (snapshot.hasData && snapshot.data != null) {
            final gameData = snapshot.data!;
            final chapterData = gameData.data.chapter.firstWhere(
                (chap) => chap.chapterType == 'activity' && chap.title == 'Letter Detective',
                orElse: () => gameData.data.chapter.first);

            
            return LetterDetectiveGame(gameChapterData: chapterData);
          } else {
            return const Scaffold(
              body: Center(child: Text('No game data found or failed to load.')),
            );
          }
        },
      ),
    );
  }

  Future<GameData?> _fetchGameData() async {
    try {
      String? accessToken = await ApiService.fetchAccessToken();
      if (accessToken != null) {
        GameData? content = await ApiService.fetchContent(accessToken);
        return content;
      } else {
        print("Access token is null. Cannot fetch content.");
        return null;
      }
    } catch (e) {
      print("Error in _fetchGameData: $e");
      return null;
    }
  }
}