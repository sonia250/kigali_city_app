import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../services/auth_service.dart';
import '../models/models.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  User? _user;
  AppUser? _appUser;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._authService) {
    _authService.authStateChanges.listen((user) async {
      _user = user;
      if (user != null) {
        _appUser = await _authService.getUserProfile(user.uid);
      } else {
        _appUser = null;
      }
      notifyListeners();
    });
  }

  User? get user => _user;
  AppUser? get appUser => _appUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isEmailVerified => _user?.emailVerified ?? false;

  Future<bool> signIn({required String email, required String password}) async {
    _isLoading = true; _error = null; notifyListeners();
    try {
      await _authService.signIn(email: email, password: password);
      _isLoading = false; notifyListeners(); return true;
    } catch (e) {
      _error = e.toString(); _isLoading = false; notifyListeners(); return false;
    }
  }

  Future<bool> signUp({required String email, required String password, required String displayName}) async {
    _isLoading = true; _error = null; notifyListeners();
    try {
      await _authService.signUp(email: email, password: password, displayName: displayName);
      _isLoading = false; notifyListeners(); return true;
    } catch (e) {
      _error = e.toString(); _isLoading = false; notifyListeners(); return false;
    }
  }

  Future<void> signOut() async { await _authService.signOut(); }
  Future<void> sendVerificationEmail() async { await _authService.sendEmailVerification(); }
  Future<void> reloadUser() async { await _user?.reload(); _user = _authService.currentUser; notifyListeners(); }
}


