import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginFieldChanged extends AuthEvent {
  final String? serviceNumber;
  final String? fullName;
  final String? motherName;
  final String? nationalId;

  const LoginFieldChanged({
    this.serviceNumber,
    this.fullName,
    this.motherName,
    this.nationalId,
  });

  @override
  List<Object?> get props => [serviceNumber, fullName, motherName, nationalId];
}

class LoginSubmitted extends AuthEvent {
  const LoginSubmitted();
}

class ExamCompletedEvent extends AuthEvent {
  final String language;

  const ExamCompletedEvent(this.language);

  @override
  List<Object?> get props => [language];
}
