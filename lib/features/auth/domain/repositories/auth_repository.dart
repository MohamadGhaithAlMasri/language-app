import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/employee_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, EmployeeEntity>> login({
    required String serviceNumber,
    required String fullName,
    required String motherName,
    required String nationalId,
  });
}
