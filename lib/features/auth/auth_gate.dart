
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/services/auth_service.dart';
import '../home/home_screen.dart';
import '../splash/splash_screen.dart';
import 'email_verification_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return const _AuthErrorScreen();
        }

        final user = snapshot.data;

        // User is not logged in.
        if (user == null) {
          return const SplashScreen();
        }

        // Check the signed-in user's email verification status.
        return _UserStatusGate(
          key: ValueKey(user.uid),
        );
      },
    );
  }
}

class _UserStatusGate extends StatefulWidget {
  const _UserStatusGate({super.key});

  @override
  State<_UserStatusGate> createState() => _UserStatusGateState();
}

class _UserStatusGateState extends State<_UserStatusGate>
    with WidgetsBindingObserver {
  final AuthService _authService = AuthService();

  bool _isLoading = true;
  bool _isVerified = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _checkVerification();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Check again when the app returns to the foreground.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkVerification();
    }
  }

  Future<void> _checkVerification() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final verified = await _authService.checkEmailVerification();

      if (!mounted) return;

      setState(() {
        _isVerified = verified;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage =
            'Unable to check your account status. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_off_rounded,
                  size: 55,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _checkVerification,
                  child: const Text('TRY AGAIN'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_isVerified) {
      return const HomeScreen();
    }

    return const EmailVerificationScreen();
  }
}

class _AuthErrorScreen extends StatelessWidget {
  const _AuthErrorScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Something went wrong while checking your login status. '
            'Please restart the app.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
