import 'package:equatable/equatable.dart';
import '../../domain/entities/employee_entity.dart';

enum AuthStatus { initial, loading, success, failure }

class AuthState extends Equatable {
  final AuthStatus status;
  final String serviceNumber;
  final String fullName;
  final String motherName;
  final String nationalId;
  final String? errorMessage;
  final EmployeeEntity? employee;

  final String? serviceNumberError;
  final String? fullNameError;
  final String? motherNameError;
  final String? nationalIdError;

  const AuthState({
    this.status = AuthStatus.initial,
    this.serviceNumber = '',
    this.fullName = '',
    this.motherName = '',
    this.nationalId = '',
    this.errorMessage,
    this.employee,
    this.serviceNumberError,
    this.fullNameError,
    this.motherNameError,
    this.nationalIdError,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? serviceNumber,
    String? fullName,
    String? motherName,
    String? nationalId,
    String? errorMessage,
    EmployeeEntity? employee,
    String? serviceNumberError,
    String? fullNameError,
    String? motherNameError,
    String? nationalIdError,
    bool clearErrorMessage = false,
    bool clearServiceNumberError = false,
    bool clearFullNameError = false,
    bool clearMotherNameError = false,
    bool clearNationalIdError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      serviceNumber: serviceNumber ?? this.serviceNumber,
      fullName: fullName ?? this.fullName,
      motherName: motherName ?? this.motherName,
      nationalId: nationalId ?? this.nationalId,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      employee: employee ?? this.employee,
      serviceNumberError: clearServiceNumberError
          ? null
          : (serviceNumberError ?? this.serviceNumberError),
      fullNameError: clearFullNameError
          ? null
          : (fullNameError ?? this.fullNameError),
      motherNameError: clearMotherNameError
          ? null
          : (motherNameError ?? this.motherNameError),
      nationalIdError: clearNationalIdError
          ? null
          : (nationalIdError ?? this.nationalIdError),
    );
  }

  @override
  List<Object?> get props => [
    status,
    serviceNumber,
    fullName,
    motherName,
    nationalId,
    errorMessage,
    employee,
    serviceNumberError,
    fullNameError,
    motherNameError,
    nationalIdError,
  ];
}
