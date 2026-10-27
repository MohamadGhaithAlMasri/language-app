import 'dart:convert';
import '../../../../core/network/api_client.dart';
import '../../../../core/security.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login({
    required String serviceNumber,
    required String fullName,
    required String motherName,
    required String nationalId,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> login({
    required String serviceNumber,
    required String fullName,
    required String motherName,
    required String nationalId,
  }) async {
    final payload = jsonEncode({
      'serviceNumber': serviceNumber.trim(),
      'fullName': fullName.trim(),
      'motherName': motherName.trim(),
      'nationalId': nationalId.trim(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    
    final encryptedBody = jsonEncode({
      'data': SecurityUtils.encrypt(payload),
    });

    final response = await apiClient.post('/api/login', data: encryptedBody);
    
    if (response.statusCode == 200) {
      final outerData = response.data;
      final decryptedStr = SecurityUtils.decrypt(outerData['data']);
      return jsonDecode(decryptedStr);
    } else {
      throw Exception('Failed to login');
    }
  }
}
