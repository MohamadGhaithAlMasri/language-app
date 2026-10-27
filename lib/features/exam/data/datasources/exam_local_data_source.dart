import 'package:shared_preferences/shared_preferences.dart';

abstract class ExamLocalDataSource {
  Future<void> savePendingResult(String resultData);
  Future<List<String>> getPendingResults();
  Future<void> removePendingResult(String resultData);
}

class ExamLocalDataSourceImpl implements ExamLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const _pendingKey = 'pending_exams';

  ExamLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<String>> getPendingResults() async {
    return sharedPreferences.getStringList(_pendingKey) ?? [];
  }

  @override
  Future<void> savePendingResult(String resultData) async {
    final pending = await getPendingResults();
    pending.add(resultData);
    await sharedPreferences.setStringList(_pendingKey, pending);
  }

  @override
  Future<void> removePendingResult(String resultData) async {
    final pending = await getPendingResults();
    pending.remove(resultData);
    await sharedPreferences.setStringList(_pendingKey, pending);
  }
}
