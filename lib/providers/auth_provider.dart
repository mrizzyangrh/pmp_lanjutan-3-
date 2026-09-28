import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _token;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;

  Future<bool> login(String email, String password) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (email.trim().isEmpty || password.length < 6) {
      return false;
    }

    _isAuthenticated = true;
    _token = null;
    notifyListeners();
    return true;
  }

  void logout() {
    _isAuthenticated = false;
    _token = null;
    notifyListeners();
  }
}
