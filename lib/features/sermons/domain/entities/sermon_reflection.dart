// Kingdom Heir — Sermon Reflection
//
// Q&A-style engagement: the user answers a reflection prompt drawn from
// the sermon's topic.

import 'package:equatable/equatable.dart';

class SermonReflection extends Equatable {
  const SermonReflection({
    required this.id,
    required this.sermonId,
    required this.question,
    required this.answer,
    required this.createdAt,
  });

  factory SermonReflection.fromJson(Map<String, dynamic> json) =>
      SermonReflection(
        id: json['id'] as String,
        sermonId: json['sermon_id'] as String,
        question: json['question'] as String,
        answer: json['answer'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  final String id;
  final String sermonId;
  final String question;
  final String answer;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'sermon_id': sermonId,
        'question': question,
        'answer': answer,
        'created_at': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, sermonId, question, answer, createdAt];
}
