import 'package:flutter/material.dart';
import 'database_service.dart';

class AuthProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  
  Map<String, dynamic>? _currentUser;
  String? _userRole; // 'admin', 'teacher', 'student'

  Map<String, dynamic>? get currentUser => _currentUser;
  String? get userRole => _userRole;
  bool get isLoggedIn => _currentUser != null;

  Future<bool> loginAdmin(String username, String password) async {
    try {
      final admin = await _dbService.getAdmin(username, password);
      if (admin != null) {
        _currentUser = admin;
        _userRole = 'admin';
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error logging in admin: $e');
      return false;
    }
  }

  Future<bool> loginTeacher(String username, String password) async {
    try {
      final teacher = await _dbService.getTeacher(username, password);
      if (teacher != null) {
        _currentUser = teacher;
        _userRole = 'teacher';
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error logging in teacher: $e');
      return false;
    }
  }

  Future<bool> loginStudent(String username, String password) async {
    try {
      final student = await _dbService.getStudent(username, password);
      if (student != null) {
        _currentUser = student;
        _userRole = 'student';
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error logging in student: $e');
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    _userRole = null;
    notifyListeners();
  }
}
