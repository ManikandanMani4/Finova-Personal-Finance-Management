
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../theme/finova_theme.dart';
import '../../dashboard/screens/dashboard_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
    required this.name,
    required this.email,
    required this.password,
  });

  static const String routeName = '/otp';

  final String verificationId;
  final String phoneNumber;
  final String name;
  final String email;
  final String password;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _busy = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _busy = true);

    try {
      final phoneCredential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _otpController.text.trim(),
      );

      // Create the email/password account.
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: widget.email.trim(),
        password: widget.password,
      );

      final user = userCredential.user;

      if (user == null) {
        throw StateError('Unable to create your account.');
      }

      try {
        // Link the verified phone number to the new account.
        await user.linkWithCredential(phoneCredential);

        await user.updateDisplayName(widget.name.trim());

        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': widget.name.trim(),
          'email': widget.email.trim(),
          'phone': widget.phoneNumber,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        await user.reload();

        if (!mounted) return;

        Navigator.pushNamedAndRemoveUntil(
          context,
          DashboardScreen.routeName,
              (route) => false,
        );
      } catch (_) {
        // If profile creation or phone linking fails, avoid leaving
        // a partially created account when possible.
        try {
          await user.delete();
        } catch (_) {
          // Deletion may fail if Firebase requires recent authentication.
        }
        rethrow;
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      switch (e.code) {
        case 'invalid-verification-code':
          _showMessage('Incorrect OTP. Please try again.');
          break;
        case 'session-expired':
          _showMessage('OTP expired. Please request a new code.');
          break;
        case 'email-already-in-use':
          _showMessage('This email is already registered.');
          break;
        case 'credential-already-in-use':
        case 'phone-number-already-exists':
          _showMessage('This phone number is already linked to an account.');
          break;
        case 'weak-password':
          _showMessage('Choose a stronger password.');
          break;
        case 'network-request-failed':
          _showMessage('Check your internet connection.');
          break;
        default:
          _showMessage('Verification failed (${e.code}). Please try again.');
      }
    } catch (e) {
      debugPrint('OTP verification error: $e');
      if (mounted) {
        _showMessage('Unable to complete registration. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify phone number'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: FinovaTheme.blue,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.verified_user_outlined,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Verify your OTP',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: FinovaTheme.navy,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Enter the 6-digit verification code sent to '
                          '${widget.phoneNumber}.',
                      style: const TextStyle(
                        fontSize: 15,
                        color: FinovaTheme.muted,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _otpController,
                      enabled: !_busy,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      autofillHints: const [AutofillHints.oneTimeCode],
                      decoration: const InputDecoration(
                        labelText: '6-digit OTP',
                        prefixIcon: Icon(Icons.sms_outlined),
                        border: OutlineInputBorder(),
                        counterText: '',
                      ),
                      validator: (value) {
                        if (value == null ||
                            !RegExp(r'^\d{6}$').hasMatch(value.trim())) {
                          return 'Enter the 6-digit OTP.';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) {
                        if (!_busy) _verifyOtp();
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 54,
                      child: FilledButton(
                        onPressed: _busy ? null : _verifyOtp,
                        child: _busy
                            ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Text(
                          'Verify & Create Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
    );
  }
}
