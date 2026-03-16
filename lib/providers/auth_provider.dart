import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final ApiService  _apiService;

  AuthStatus  _status = AuthStatus.initial;
  UserModel?  _user;
  String?     _error;
  Completer<void>? _signInCompleter;
  static const Duration _signInTimeout = Duration(seconds: 25);

  AuthStatus get status     => _status;
  UserModel? get user       => _user;
  String?    get error      => _error;
  bool       get isLoggedIn => _status == AuthStatus.authenticated;

  AuthProvider({
    required AuthService authService,
    required ApiService  apiService,
  })  : _authService = authService,
        _apiService  = apiService {
    // Listen to Firebase auth changes
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _status = AuthStatus.unauthenticated;
      _user   = null;
    } else {
      _status = AuthStatus.loading;
      notifyListeners();
      try {
        _user   = await _apiService.upsertUser();
        _status = AuthStatus.authenticated;
      } catch (e) {
        _status = AuthStatus.unauthenticated;
        _error  = 'Profile sync failed: ${e.toString().replaceFirst('Exception: ', '')}';
        _user   = null;
        // Optionally sign out from Firebase if backend sync fails to keep states consistent
        await _authService.signOut();
      }
      _signInCompleter?.complete();
      _signInCompleter = null;
    }
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    try {
      _status = AuthStatus.loading;
      _error  = null;
      _signInCompleter = Completer<void>();
      notifyListeners();
      await _authService.signInWithGoogle();
      // Wait for auth state listener to run and set authenticated (after backend upsertUser)
      await _signInCompleter!.future.timeout(
        _signInTimeout,
        onTimeout: () {
          _signInCompleter?.complete();
          _signInCompleter = null;
          final u = _authService.currentUser;
          if (u != null) {
            _user = UserModel(
              id: u.uid,
              googleId: u.uid,
              name: u.displayName ?? 'User',
              email: u.email ?? '',
              profilePicture: u.photoURL,
              createdAt: DateTime.now(),
            );
            _status = AuthStatus.authenticated;
          }
        },
      );
      notifyListeners();
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _error  = e.toString().replaceFirst('Exception: ', '');
      _signInCompleter = null;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
