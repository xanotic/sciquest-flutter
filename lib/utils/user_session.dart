import '../models/user.dart';

class UserSession {
  static final UserSession instance = UserSession._init();
  UserSession._init();

  User? _currentUser;
  User? get currentUser => _currentUser;

  void setUser(User user) {
    _currentUser = user;
  }

  void clearUser() {
    _currentUser = null;
  }

  bool get isLoggedIn => _currentUser != null;
}
