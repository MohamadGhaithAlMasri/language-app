import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/employee_entity.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(const AuthState()) {
    on<LoginFieldChanged>(_onLoginFieldChanged);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<ExamCompletedEvent>(_onExamCompleted);
  }

  void _onLoginFieldChanged(LoginFieldChanged event, Emitter<AuthState> emit) {
    emit(
      state.copyWith(
        serviceNumber: event.serviceNumber,
        fullName: event.fullName,
        motherName: event.motherName,
        nationalId: event.nationalId,
        clearServiceNumberError: event.serviceNumber != null,
        clearFullNameError: event.fullName != null,
        clearMotherNameError: event.motherName != null,
        clearNationalIdError: event.nationalId != null,
        clearErrorMessage: true,
        status: AuthStatus.initial,
      ),
    );
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    bool hasError = false;
    String? serviceError;
    String? nameError;
    String? motherError;
    String? nationalError;

    if (state.serviceNumber.trim().isEmpty) {
      serviceError = 'يرجى إدخال الرقم الوظيفي';
      hasError = true;
    }

    if (state.fullName.trim().isEmpty) {
      nameError = 'يرجى إدخال الاسم الكامل';
      hasError = true;
    }

    if (state.motherName.trim().isEmpty) {
      motherError = 'يرجى إدخال اسم الأم الكامل';
      hasError = true;
    }

    if (state.nationalId.trim().isEmpty) {
      nationalError = 'يرجى إدخال الرقم الوطني';
      hasError = true;
    } else if (state.nationalId.trim().length != 11) {
      nationalError = 'يجب أن يتكون الرقم الوطني من 11 خانة';
      hasError = true;
    }

    if (hasError) {
      emit(
        state.copyWith(
          serviceNumberError: serviceError,
          fullNameError: nameError,
          motherNameError: motherError,
          nationalIdError: nationalError,
          status: AuthStatus.failure,
        ),
      );
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading, clearErrorMessage: true));

    final result = await authRepository.login(
      serviceNumber: state.serviceNumber,
      fullName: state.fullName,
      motherName: state.motherName,
      nationalId: state.nationalId,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (employee) =>
          emit(state.copyWith(status: AuthStatus.success, employee: employee)),
    );
  }

  void _onExamCompleted(ExamCompletedEvent event, Emitter<AuthState> emit) {
    if (state.employee != null) {
      final currentCompleted = List<String>.from(state.employee!.completedExams);
      if (!currentCompleted.contains(event.language)) {
        currentCompleted.add(event.language);
      }
      
      final updatedEmployee = EmployeeEntity(
        serviceNumber: state.employee!.serviceNumber,
        allowedLanguages: state.employee!.allowedLanguages,
        completedExams: currentCompleted,
        allResults: state.employee!.allResults,
      );
      
      emit(state.copyWith(employee: updatedEmployee));
    }
  }
}
