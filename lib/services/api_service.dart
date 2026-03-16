import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task_model.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class ApiService {
  final String _base = kBaseUrl;
  final Future<String?> Function() _getToken;

  ApiService({required Future<String?> Function() getToken})
      : _getToken = getToken;

  Future<Map<String, String>> _headers() async {
    final token = await _getToken();
    return {
      'Content-Type':  'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ── Users ──────────────────────────────────────────────────

  /// Upsert user in the backend DB after Google Sign-In.
  Future<UserModel> upsertUser() async {
    final resp = await http.post(
      Uri.parse('$_base/users'),
      headers: await _headers(),
    );
    _checkStatus(resp);
    final body = _decodeBody(resp.body);
    final userData = body['user'];
    if (userData == null || userData is! Map<String, dynamic>) {
      throw Exception('Invalid user response from server');
    }
    return UserModel.fromJson(userData);
  }

  // ── Tasks ──────────────────────────────────────────────────

  Future<List<TaskModel>> getTasks({
    String? status,
    String? priority,
    String? category,
  }) async {
    final uri = Uri.parse('$_base/tasks').replace(queryParameters: {
      if (status   != null) 'status':   status,
      if (priority != null) 'priority': priority,
      if (category != null) 'category': category,
    });
    final resp = await http.get(uri, headers: await _headers());
    _checkStatus(resp);
    final body = _decodeBody(resp.body);
    final tasksList = body['tasks'];
    if (tasksList == null || tasksList is! List<dynamic>) {
      throw Exception('Invalid tasks list response');
    }
    return tasksList.map((e) => TaskModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<TaskModel> createTask(TaskModel task) async {
    final resp = await http.post(
      Uri.parse('$_base/tasks'),
      headers: await _headers(),
      body: jsonEncode(task.toCreateJson()),
    );
    _checkStatus(resp);
    final body = _decodeBody(resp.body);
    final taskData = body['task'];
    if (taskData == null || taskData is! Map<String, dynamic>) {
      throw Exception('Invalid create task response: missing task');
    }
    return TaskModel.fromJson(taskData);
  }

  Future<TaskModel> updateTask(TaskModel task) async {
    final resp = await http.put(
      Uri.parse('$_base/tasks/${task.id}'),
      headers: await _headers(),
      body: jsonEncode(task.toJson()),
    );
    _checkStatus(resp);
    final body = _decodeBody(resp.body);
    final taskData = body['task'];
    if (taskData == null || taskData is! Map<String, dynamic>) {
      throw Exception('Invalid update task response');
    }
    return TaskModel.fromJson(taskData);
  }

  Future<void> deleteTask(int id) async {
    final resp = await http.delete(
      Uri.parse('$_base/tasks/$id'),
      headers: await _headers(),
    );
    _checkStatus(resp);
  }

  Future<Map<String, dynamic>> getStats() async {
    final resp = await http.get(
      Uri.parse('$_base/tasks/stats'),
      headers: await _headers(),
    );
    _checkStatus(resp);
    final body = _decodeBody(resp.body);
    final statsData = body['stats'];
    if (statsData == null || statsData is! Map<String, dynamic>) {
      throw Exception('Invalid stats response');
    }
    return statsData;
  }

  // ── Helpers ────────────────────────────────────────────────
  Map<String, dynamic> _decodeBody(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Invalid JSON response from server');
    }
  }

  void _checkStatus(http.Response resp) {
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      String message = 'API error ${resp.statusCode}';
      try {
        final body = _decodeBody(resp.body);
        message = body['error']?.toString() ?? message;
      } catch (_) {}
      throw Exception(message);
    }
  }
}
