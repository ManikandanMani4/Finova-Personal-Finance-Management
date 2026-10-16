
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../navigation/main_navigation.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = '/register';

  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  bool _busy = false;
  bool _acceptedTerms = false;

  static const Color navy = Color(0xFFF4F8F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cyan = Color(0xFF123F35);
  static const Color blue = Color(0xFF258BFF);

  static const Color mainText = Color(0xFF172923);
  static const Color secondaryText = Color(0xFF64786F);
  static const Color hintText = Color(0xFF91A39A);
  static const Color labelText = Color(0xFF334B43);

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  InputDecoration _decoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF91A39A),
        fontSize: 15,
      ),      prefixIcon: Icon(icon, color: cyan),
      suffixIcon: suffix,
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide(color: Colors.white.withAlpha(20)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: cyan, width: 1.5),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: surface,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      _showMessage('Please accept the terms to continue.');
      return;
    }

    setState(() => _busy = true);

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text,
      );

      final user = credential.user;

      if (user != null) {
        await user.updateDisplayName(_name.text.trim());
      }

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        MainNavigation.routeName,
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message = 'An account already exists with this email.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'weak-password':
          message = 'Choose a stronger password.';
          break;
        case 'operation-not-allowed':
          message = 'Email registration is not enabled in Firebase.';
          break;
        case 'network-request-failed':
          message = 'Check your internet connection.';
          break;
        default:
          message = e.message ?? 'Registration failed. Please try again.';
      }

      _showMessage(message);
    } catch (_) {
      if (mounted) {
        _showMessage('Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: _glow(250, const Color(0xFF087EAA)),
          ),
          Positioned(
            top: 350,
            right: -160,
            child: _glow(280, const Color(0xFF5427B8)),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () => Navigator.maybePop(context),
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        Center(
                          child: Container(
                            width: 126,
                            height: 126,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const SweepGradient(
                                colors: [
                                  cyan,
                                  blue,
                                  Color(0xFF983BFF),
                                  Color(0xFFFFD166),
                                  cyan,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: cyan.withAlpha(40),
                                  blurRadius: 30,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: navy,
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/finova_logo.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.account_balance_wallet_rounded,
                                    color: cyan,
                                    size: 58,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Center(
                          child: Text(
                            'JOIN FINOVA',
                            style: const TextStyle(
                              color: Color(0xFF172923),
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 3,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Center(
                          child: Text(
                            'Build better money habits, starting today.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF64786F),
                              fontSize: 14,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        _label('FULL NAME'),
                        const SizedBox(height: 9),

                        TextFormField(
                          controller: _name,
                          textCapitalization: TextCapitalization.words,
                          autofillHints: const [AutofillHints.name],
                          style: const TextStyle(color: Color(0xFF172923)),                         decoration: _decoration(
                            hint: 'Enter your full name',
                            icon: Icons.person_outline_rounded,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Name is required';
                            }
                            if (value.trim().length < 2) {
                              return 'Enter at least 2 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        _label('EMAIL ADDRESS'),
                        const SizedBox(height: 9),

                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          style: const TextStyle(
                            color: Color(0xFF64786F),                          ),                          decoration: _decoration(
                            hint: 'you@example.com',
                            icon: Icons.alternate_email_rounded,
                          ),
                          validator: (value) {
                            final email = value?.trim() ?? '';
                            if (email.isEmpty) {
                              return 'Email is required';
                            }
                            if (!RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            ).hasMatch(email)) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        _label('PASSWORD'),
                        const SizedBox(height: 9),

                        TextFormField(
                          controller: _password,
                          obscureText: _hidePassword,
                          autofillHints: const [AutofillHints.newPassword],
                          style: const TextStyle(color: Colors.white),
                          decoration: _decoration(
                            hint: 'Create a password',
                            icon: Icons.lock_outline_rounded,
                            suffix: IconButton(
                              onPressed: () => setState(
                                    () => _hidePassword = !_hidePassword,
                              ),
                              icon: Icon(
                                _hidePassword
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: Colors.white54,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            if (value.length < 8) {
                              return 'Use at least 8 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        _label('CONFIRM PASSWORD'),
                        const SizedBox(height: 9),

                        TextFormField(
                          controller: _confirmPassword,
                          obscureText: _hideConfirmPassword,
                          style: const TextStyle(color: Colors.white),
                          decoration: _decoration(
                            hint: 'Re-enter your password',
                            icon: Icons.verified_user_outlined,
                            suffix: IconButton(
                              onPressed: () => setState(
                                    () => _hideConfirmPassword =
                                !_hideConfirmPassword,
                              ),
                              icon: Icon(
                                _hideConfirmPassword
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: Colors.white54,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _password.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        CheckboxListTile(
                          value: _acceptedTerms,
                          onChanged: (value) => setState(
                                () => _acceptedTerms = value ?? false,
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          activeColor: const Color(0xFF123F35),
                          checkColor: Colors.white,
                          title: const Text(
                            'I agree to the Terms and Privacy Policy.',
                            style: TextStyle(
                              color: Color(0xFF123F35),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        Container(
                          height: 58,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(17),
                            gradient: const LinearGradient(
                              colors: [cyan, blue],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: blue.withAlpha(45),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _busy ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              disabledBackgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(17),
                              ),
                            ),
                            child: _busy
                                ? const SizedBox(
                              height: 23,
                              width: 23,
                              child: CircularProgressIndicator(
                                color: navy,
                                strokeWidth: 2.5,
                              ),
                            )
                                : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Create account',
                                  style: TextStyle(
                                    color: navy,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: navy,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text(
                              'Already have an account? ',
                              style: const TextStyle(
                                color: Color(0xFF64786F),
                              ),                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  LoginScreen.routeName,
                                );
                              },
                              child: const Text(
                                'Sign in',
                                style: TextStyle(
                                  color: cyan,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        const Center(
                          child: Text(
                            'YOUR MONEY. YOUR FUTURE.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF64786F),
                              fontSize: 10,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF172923),
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _glow(double size, Color color) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(30),
              blurRadius: 100,
              spreadRadius: 40,
            ),
          ],
        ),
      ),
    );
  }
}
