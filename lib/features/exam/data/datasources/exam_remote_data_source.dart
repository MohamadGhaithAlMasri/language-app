import 'dart:convert';
import '../../../../core/network/api_client.dart';
import '../../../../core/security.dart';

abstract class ExamRemoteDataSource {
  Future<List<dynamic>> getQuestions({
    required String language,
    required String serviceNumber,
  });
  Future<void> submitExam(Map<String, dynamic> payload);
  Future<List<dynamic>> fetchResults(String serviceNumber);
}

class ExamRemoteDataSourceImpl implements ExamRemoteDataSource {
  final ApiClient apiClient;

  ExamRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<dynamic>> getQuestions({
    required String language,
    required String serviceNumber,
  }) async {
    final payload = jsonEncode({
      'language': language.toLowerCase(),
      'serviceNumber': serviceNumber.trim(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    
    final encryptedBody = jsonEncode({
      'data': SecurityUtils.encrypt(payload),
    });

    final response = await apiClient.post('/api/questions', data: encryptedBody);
    
    if (response.statusCode == 200) {
      final outerData = response.data;
      final decryptedStr = SecurityUtils.decrypt(outerData['data']);
      final data = jsonDecode(decryptedStr);
      return data['questions'] ?? [];
    } else {
      throw Exception('Failed to get questions');
    }
  }

  @override
  Future<void> submitExam(Map<String, dynamic> payload) async {
    payload['timestamp'] = DateTime.now().millisecondsSinceEpoch;
    final encryptedBody = jsonEncode({
      'data': SecurityUtils.encrypt(jsonEncode(payload)),
    });

    final response = await apiClient.post('/api/submit-exam', data: encryptedBody);
    
    if (response.statusCode != 200 && response.statusCode != 400) {
      throw Exception('Failed to submit exam');
    }
  }

  @override
  Future<List<dynamic>> fetchResults(String serviceNumber) async {
    final payload = jsonEncode({
      'serviceNumber': serviceNumber.trim(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    
    final encryptedBody = jsonEncode({
      'data': SecurityUtils.encrypt(payload),
    });

    final response = await apiClient.post('/api/results', data: encryptedBody);
    
    if (response.statusCode == 200) {
      final outerData = response.data;
      final decryptedStr = SecurityUtils.decrypt(outerData['data']);
      final data = jsonDecode(decryptedStr);
      return data['results'] ?? [];
    } else {
      throw Exception('Failed to fetch results');
    }
  }
}
