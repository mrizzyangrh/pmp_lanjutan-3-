import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

enum ViewState { initial, loading, loaded, empty, error }

class DataProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // TODO 1: simpan _state, _users, _errorMessage + getter-nya di sini.
  ViewState _state = ViewState.initial;
  List<UserModel> _users = [];
  String _errorMessage = '';

  ViewState get state => _state;
  List<UserModel> get users => _users;
  String get errorMessage => _errorMessage;

  Future<void> loadUsers({String? token}) async {
    _state = ViewState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await _apiService.fetchUsers(token: token);
      if (result.isEmpty) {
        _state = ViewState.empty;
      } else {
        _users = result;
        _state = ViewState.loaded;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _state = ViewState.error;
    }
    notifyListeners();
  }
}
