import 'package:tr_guide/models/user.dart';
import 'package:flutter/material.dart';
import 'package:tr_guide/services/auth_service.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  final AuthService _authMethods = AuthService();

  User get getUser =>
      _user!; // Null olabileceğini belirttik//tekrar bak User? _user; olabilir

  Future<void> refreshUser() async {
    User user = await _authMethods.getUserDetails();
    _user = user;
    notifyListeners();
  }
}
