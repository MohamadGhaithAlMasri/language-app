import 'package:equatable/equatable.dart';

class LanguageEntity extends Equatable {
  final String name;
  final String level;

  const LanguageEntity({
    required this.name,
    required this.level,
  });

  factory LanguageEntity.fromJson(Map<String, dynamic> json) {
    return LanguageEntity(
      name: json['name'] ?? '',
      level: json['level'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'level': level,
    };
  }

  @override
  List<Object?> get props => [name, level];
}
