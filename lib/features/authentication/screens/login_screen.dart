
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../navigation/main_navigation.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _hidePassword = true;
  bool _busy = false;

  static const Color background = Color(0xFFF4F8F5);
  static const Color darkGreen = Color(0xFF123F35);
  static const Color mint = Color(0xFFBDEBD9);
  static const Color muted = Color(0xFF71847C);
  static const Color borderColor = Color(0xFFE1EAE4);

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _message(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: darkGreen,
        ),
      );
  }

  Future<void> _signIn() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _busy = true);

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text,
      );

      if (!mounted) return;

      if (credential.user == null) {
        _message('Unable to sign in. Please try again.');
        return;
      }

      Navigator.pushNamedAndRemoveUntil(
        context,
        MainNavigation.routeName,
            (route) => false,
      );
    } on FirebaseAuthException catch (e, stackTrace) {
      debugPrint('Login error: ${e.code} - ${e.message}');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      switch (e.code) {
        case 'invalid-email':
          _message('Please enter a valid email address.');
          break;
        case 'user-not-found':
        case 'invalid-credential':
        case 'wrong-password':
          _message('Incorrect email or password.');
          break;
        case 'user-disabled':
          _message('This account has been disabled.');
          break;
        case 'too-many-requests':
          _message('Too many attempts. Please try again later.');
          break;
        case 'network-request-failed':
          _message('Network error. Check your internet connection.');
          break;
        case 'operation-not-allowed':
          _message('Email/password login is not enabled in Firebase.');
          break;
        default:
          _message(
            'Login failed (${e.code}). '
                '${e.message ?? 'Please try again.'}',
          );
      }
    } catch (e, stackTrace) {
      debugPrint('Unexpected login error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        _message('Unable to sign in. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _forgotPassword() async {
    final email = _email.text.trim();

    if (email.isEmpty ||
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      _message('Enter your email address first to reset your password.');
      return;
    }

    setState(() => _busy = true);

    try {
      await _auth.sendPasswordResetEmail(email: email);

      if (mounted) {
        _message(
          'Password reset instructions have been sent if the account exists.',
        );
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Password reset error: ${e.code} - ${e.message}');

      if (!mounted) return;

      switch (e.code) {
        case 'invalid-email':
          _message('Please enter a valid email address.');
          break;
        case 'user-not-found':
          _message('No account was found for that email address.');
          break;
        case 'network-request-failed':
          _message('Network error. Check your internet connection.');
          break;
        default:
          _message('Unable to send reset email (${e.code}).');
      }
    } catch (e) {
      debugPrint('Unexpected password reset error: $e');

      if (mounted) {
        _message('Unable to send the reset email. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 26,
              vertical: 30,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildBrand(),

                    const SizedBox(height: 46),

                    const Text(
                      'Welcome back',
                      style: TextStyle(
                        fontSize: 38,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.2,
                        color: Color(0xFF172720),
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Sign in to continue to Finova.',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: muted,
                      ),
                    ),

                    const SizedBox(height: 34),

                    _fieldLabel('Email address'),
                    const SizedBox(height: 9),

                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      enabled: !_busy,
                      autofillHints: const [AutofillHints.email],
                      decoration: _inputDecoration(
                        hint: 'you@example.com',
                        icon: Icons.mail_outline_rounded,
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';

                        if (email.isEmpty) {
                          return 'Enter your email address.';
                        }

                        if (!RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        ).hasMatch(email)) {
                          return 'Enter a valid email address.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 22),

                    _fieldLabel('Password'),
                    const SizedBox(height: 9),

                    TextFormField(
                      controller: _password,
                      obscureText: _hidePassword,
                      enabled: !_busy,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) {
                        if (!_busy) _signIn();
                      },
                      decoration: _inputDecoration(
                        hint: 'Enter your password',
                        icon: Icons.lock_outline_rounded,
                      ).copyWith(
                        suffixIcon: IconButton(
                          tooltip: _hidePassword
                              ? 'Show password'
                              : 'Hide password',
                          onPressed: _busy
                              ? null
                              : () {
                            setState(() {
                              _hidePassword = !_hidePassword;
                            });
                          },
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: muted,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter your password.';
                        }
                        return null;
                      },
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _busy ? null : _forgotPassword,
                        style: TextButton.styleFrom(
                          foregroundColor: darkGreen,
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 4,
                          ),
                        ),
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      height: 58,
                      child: FilledButton(
                        onPressed: _busy ? null : _signIn,
                        style: FilledButton.styleFrom(
                          backgroundColor: darkGreen,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                          darkGreen.withAlpha(140),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: _busy
                            ? const SizedBox(
                          height: 23,
                          width: 23,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                            : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Sign in',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 9),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 26),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Flexible(
                          child: Text(
                            "Don't have an account?",
                            style: TextStyle(
                              color: muted,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _busy
                              ? null
                              : () {
                            Navigator.pushNamed(
                              context,
                              RegisterScreen.routeName,
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: darkGreen,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
                          ),
                          child: const Text(
                            'Create account',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          size: 16,
                          color: muted,
                        ),
                        SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            'Your financial journey, thoughtfully managed.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrand() {
    return Row(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: mint,
            borderRadius: BorderRadius.circular(17),
            boxShadow: [
              BoxShadow(
                color: darkGreen.withAlpha(18),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(
            Icons.account_balance_wallet_rounded,
            color: darkGreen,
            size: 29,
          ),
        ),
        const SizedBox(width: 13),
        const Text(
          'Finova',
          style: TextStyle(
            color: darkGreen,
            fontSize: 27,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: const Icon(
            Icons.shield_outlined,
            color: darkGreen,
            size: 21,
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xFF263D33),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF9AA9A1),
        fontSize: 15,
      ),
      prefixIcon: Icon(icon, color: darkGreen, size: 22),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 17,
        vertical: 19,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(
          color: darkGreen,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.5,
        ),
      ),
    );
  }
}
