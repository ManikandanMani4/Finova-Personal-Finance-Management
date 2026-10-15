
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../theme/finova_theme.dart';
import '../models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const String routeName = '/profile';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  bool _editing = false;
  bool _saving = false;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _incomeController = TextEditingController();

  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = _auth.currentUser;

    if (user == null) return;

    try {
      final snapshot =
      await _firestore.collection('users').doc(user.uid).get();

      if (!mounted) return;

      final data = snapshot.data() ?? <String, dynamic>{};

      final profile = UserProfile.fromMap(user.uid, {
        ...data,
        'name': data['name'] ?? user.displayName ?? '',
        'email': data['email'] ?? user.email ?? '',
        'phoneNumber': data['phoneNumber'] ?? user.phoneNumber ?? '',
      });

      setState(() {
        _profile = profile;
        _nameController.text = profile.name;
        _phoneController.text = profile.phoneNumber;
        _incomeController.text =
            profile.monthlyIncome.toStringAsFixed(0);
      });
    } catch (e) {
      if (!mounted) return;
      _message('Unable to load your profile. Please try again.');
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = _auth.currentUser;

    if (user == null) {
      _message('Please sign in again.');
      return;
    }

    final oldProfile = _profile;

    if (oldProfile == null) return;

    final updatedProfile = oldProfile.copyWith(
      name: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      monthlyIncome:
      double.tryParse(_incomeController.text.trim()) ?? 0,
    );

    setState(() => _saving = true);

    try {
      await _firestore.collection('users').doc(user.uid).set(
        updatedProfile.toMap(),
        SetOptions(merge: true),
      );

      await user.updateDisplayName(updatedProfile.name);

      if (!mounted) return;

      setState(() {
        _profile = updatedProfile;
        _editing = false;
      });

      _message('Profile updated successfully.');
    } catch (e) {
      if (!mounted) return;
      _message('Unable to save profile. Please try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          'Are you sure you want to sign out of Finova?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _auth.signOut();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (profile != null)
            IconButton(
              tooltip: _editing ? 'Cancel editing' : 'Edit profile',
              onPressed: _saving
                  ? null
                  : () {
                setState(() {
                  _editing = !_editing;

                  if (!_editing) {
                    _nameController.text = profile.name;
                    _phoneController.text = profile.phoneNumber;
                    _incomeController.text =
                        profile.monthlyIncome.toStringAsFixed(0);
                  }
                });
              },
              icon: Icon(
                _editing ? Icons.close_rounded : Icons.edit_rounded,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: profile == null
            ? Center(
          child: _auth.currentUser == null
              ? const Text('Please sign in to view your profile.')
              : const CircularProgressIndicator(),
        )
            : RefreshIndicator(
          onRefresh: _loadProfile,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF2563EB),
                      Color(0xFF1D4ED8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: Colors.white,
                      backgroundImage:
                      profile.photoUrl != null &&
                          profile.photoUrl!.isNotEmpty
                          ? NetworkImage(profile.photoUrl!)
                          : null,
                      child: profile.photoUrl == null ||
                          profile.photoUrl!.isEmpty
                          ? const Icon(
                        Icons.person_rounded,
                        size: 48,
                        color: FinovaTheme.blue,
                      )
                          : null,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      profile.name.isEmpty
                          ? 'Finova User'
                          : profile.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 23,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      profile.email,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified_user_rounded,
                          size: 17,
                          color: Colors.white,
                        ),
                        SizedBox(width: 7),
                        Text(
                          'Finova account',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),

              const Text(
                'Personal information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: FinovaTheme.navy,
                ),
              ),
              const SizedBox(height: 16),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _profileField(
                      label: 'Full name',
                      controller: _nameController,
                      icon: Icons.person_outline_rounded,
                      enabled: _editing,
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Enter your name.';
                        }
                        return null;
                      },
                    ),
                    _profileField(
                      label: 'Email address',
                      initialValue: profile.email,
                      icon: Icons.email_outlined,
                      enabled: false,
                    ),
                    _profileField(
                      label: 'Phone number',
                      controller: _phoneController,
                      icon: Icons.phone_outlined,
                      enabled: _editing,
                      keyboardType: TextInputType.phone,
                    ),
                    _profileField(
                      label: 'Monthly income (₹)',
                      controller: _incomeController,
                      icon: Icons.currency_rupee_rounded,
                      enabled: _editing,
                      keyboardType:
                      const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        final amount = double.tryParse(
                          value?.trim() ?? '',
                        );

                        if (amount == null ||
                            !amount.isFinite ||
                            amount < 0) {
                          return 'Enter a valid income amount.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              if (_editing) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _saving ? null : _saveProfile,
                    style: FilledButton.styleFrom(
                      backgroundColor: FinovaTheme.blue,
                    ),
                    child: _saving
                        ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 28),

              const Text(
                'Account settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: FinovaTheme.navy,
                ),
              ),
              const SizedBox(height: 12),

              _settingTile(
                Icons.lock_outline_rounded,
                'Reset password',
                'Send a password reset email',
                    () async {
                  if (profile.email.isEmpty) {
                    _message('No email address is available.');
                    return;
                  }

                  try {
                    await _auth.sendPasswordResetEmail(
                      email: profile.email,
                    );
                    if (mounted) {
                      _message('Password reset email requested.');
                    }
                  } on FirebaseAuthException catch (e) {
                    if (mounted) {
                      _message(
                        e.code == 'invalid-email'
                            ? 'The email address is invalid.'
                            : 'Unable to send reset email.',
                      );
                    }
                  }
                },
              ),
              _settingTile(
                Icons.logout_rounded,
                'Sign out',
                'Sign out of your Finova account',
                _signOut,
                color: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileField({
    required String label,
    TextEditingController? controller,
    String? initialValue,
    required IconData icon,
    required bool enabled,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        initialValue: controller == null ? initialValue : null,
        enabled: enabled,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: FinovaTheme.blue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          filled: !enabled,
          fillColor: enabled ? null : Colors.grey.withAlpha(15),
        ),
      ),
    );
  }

  Widget _settingTile(
      IconData icon,
      String title,
      String subtitle,
      VoidCallback onTap, {
        Color color = FinovaTheme.blue,
      }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withAlpha(35)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
