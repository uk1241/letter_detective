// // Letter model
// class Chapter {
//   final String id;
//   final String chapterType;
//   final String title;
//   final String subtitle;
//   final List<String> introAudios;
//   final List<String> audioList;
//   final List<String> failAudios;
//   final List<String> finishAudios;
//   final List<String> targetWords;
//   final List<List<String>> expectedWords;
//   final String buttonText;

//   Chapter({
//     required this.id,
//     required this.chapterType,
//     required this.title,
//     required this.subtitle,
//     required this.introAudios,
//     required this.audioList,
//     required this.failAudios,
//     required this.finishAudios,
//     required this.targetWords,
//     required this.expectedWords,
//     required this.buttonText,
//   });

//   factory Chapter.fromJson(Map<String, dynamic> json) {
//     return Chapter(
//       id: json['id'],
//       chapterType: json['chapterType'],
//       title: json['title'],
//       subtitle: json['subtitle'],
//       introAudios: List<String>.from(json['introAudios']),
//       audioList: List<String>.from(json['audioList']),
//       failAudios: List<String>.from(json['failAudios']),
//       finishAudios: List<String>.from(json['finishAudios']),
//       targetWords: List<String>.from(json['targetWords']),
//       expectedWords: List<List<String>>.from(
//         json['expectedWords'].map((list) => List<String>.from(list)),
//       ),
//       buttonText: json['buttonText'],
//     );
//   }
// }

// class ContentData {
//   final String topicId;
//   final String topicName;
//   final List<Chapter> chapter;

//   ContentData({required this.topicId, required this.topicName, required this.chapter});

//   factory ContentData.fromJson(Map<String, dynamic> json) {
//     return ContentData(
//       topicId: json['topicId'],
//       topicName: json['topicName'],
//       chapter: List<Chapter>.from(
//         json['chapter'].map((chapter) => Chapter.fromJson(chapter)),
//       ),
//     );
//   }
// }

// class ContentModel {
//   final bool success;
//   final String message;
//   final ContentData data;

//   ContentModel({required this.success, required this.message, required this.data});

//   factory ContentModel.fromJson(Map<String, dynamic> json) {
//     return ContentModel(
//       success: json['success'],
//       message: json['message'],
//       data: ContentData.fromJson(json['data']),
//     );
//   }
// }


// lib/models/game_data.dart
class GameData {
  final bool success;
  final String message;
  final GameContent data;
  final int statusCode;

  GameData({
    required this.success,
    required this.message,
    required this.data,
    required this.statusCode,
  });

  factory GameData.fromJson(Map<String, dynamic> json) {
    return GameData(
      success: json['success'],
      message: json['message'],
      data: GameContent.fromJson(json['data']),
      statusCode: json['statusCode'],
    );
  }
}

class GameContent {
  final String topicId;
  final String topicName;
  final List<Chapter> chapter;

  GameContent({
    required this.topicId,
    required this.topicName,
    required this.chapter,
  });

  factory GameContent.fromJson(Map<String, dynamic> json) {
    return GameContent(
      topicId: json['topicId'],
      topicName: json['topicName'],
      chapter: List<Chapter>.from(json['chapter'].map((x) => Chapter.fromJson(x))),
    );
  }
}

class Chapter {
  final String id;
  final String chapterType;
  final String title;
  final String subtitle;
  final List<String> introAudios;
  final List<String> audioList;
  final List<String> failAudios;
  final List<String> finishAudios;
  final List<String> targetWords;
  final List<List<String>> expectedWords;
  final String buttonText;

  Chapter({
    required this.id,
    required this.chapterType,
    required this.title,
    required this.subtitle,
    required this.introAudios,
    required this.audioList,
    required this.failAudios,
    required this.finishAudios,
    required this.targetWords,
    required this.expectedWords,
    required this.buttonText,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'],
      chapterType: json['chapterType'],
      title: json['title'],
      subtitle: json['subtitle'],
      introAudios: List<String>.from(json['introAudios'].map((x) => x)),
      audioList: List<String>.from(json['audioList'].map((x) => x)),
      failAudios: List<String>.from(json['failAudios'].map((x) => x)),
      finishAudios: List<String>.from(json['finishAudios'].map((x) => x)),
      targetWords: List<String>.from(json['targetWords'].map((x) => x)),
      expectedWords: List<List<String>>.from(json['expectedWords'].map((x) => List<String>.from(x.map((y) => y)))),
      buttonText: json['buttonText'],
    );
  }
}