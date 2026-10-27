import 'package:equatable/equatable.dart';

class QuestionEntity extends Equatable {
  final int id;
  final String text;
  final String keyword;
  final List<String> options;
  final int correctOptionIndex;

  const QuestionEntity({
    required this.id,
    required this.text,
    required this.keyword,
    required this.options,
    required this.correctOptionIndex,
  });

  factory QuestionEntity.fromJson(Map<String, dynamic> json) {
    return QuestionEntity(
      id: json['id'] ?? 0,
      text: json['text'] ?? '',
      keyword: json['keyword'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctOptionIndex: json['correctOptionIndex'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, text, keyword, options, correctOptionIndex];
}
