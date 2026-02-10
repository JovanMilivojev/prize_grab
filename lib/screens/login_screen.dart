import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../widgets/winter_background.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import 'adminscreen.dart';
import 'main_menu.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const route = '/login';

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  bool isLogin = true;
  // kljuc za validaciju
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  final user = TextEditingController();

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  bool _loading = false;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    user.dispose();
    super.dispose();
  }

  //Klik na login
  Future<void> submit() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final emailValue = email.text.trim().toLowerCase();
    final passwordValue = password.text;
    final usernameValue = user.text.trim();

    setState(() => _loading = true);

    if (!isLogin && usernameValue.length < 3) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username min 3 karaktera')),
        );
      }
      if (mounted) {
        setState(() => _loading = false);
      }
      return;
    }

    try {
      if (isLogin) {
        await _authService.signIn(email: emailValue, password: passwordValue);

        final uid = _authService.currentUser?.uid;
        if (uid == null) {
          throw Exception('Nedostaje UID nakon prijave.');
        }

        final profile = await _userService.getUserProfile(
          uid,
          email: emailValue,
        );
        if (profile.banned) {
          await _authService.signOut();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Banovan si.')),
          );
          return;
        }

        int bonusAmount = 0;
        try {
          bonusAmount = await _userService.claimDailyBonus(uid: uid);
        } catch (_) {}

        if (!mounted) return;

        if (bonusAmount > 0) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Daily bonus +$bonusAmount!')));
        }

        if (profile.role == 'admin') {
          Navigator.pushReplacementNamed(context, AdminScreen.route);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login uspesan')),
          );
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Navigator.pushReplacementNamed(context, MainMenuScreen.route);
          }
        }
      } else {
        final credential = await _authService.register(
          email: emailValue,
          password: passwordValue,
        );

        final uid = credential.user?.uid;
        if (uid == null) {
          throw Exception('Neuspesna registracija (nedostaje UID).');
        }

        try {
          await _userService
              .createUserProfile(
                uid: uid,
                email: emailValue,
                username: usernameValue,
              )
              .timeout(const Duration(seconds: 8));
        } on TimeoutException {
          _userService.createUserProfile(
            uid: uid,
            email: emailValue,
            username: usernameValue,
          );
        }

        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Nalog kreiran')));

        Navigator.pushReplacementNamed(context, MainMenuScreen.route);
      }
    } on FirebaseAuthException catch (e) {
      final message = _mapAuthMessage(e);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        final message = e.message ?? e.code;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Greska u bazi: $message')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Greska: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String _mapAuthMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email je vec registrovan.';
      case 'invalid-email':
        return 'Email nije validan.';
      case 'weak-password':
        return 'Lozinka je preslaba (min 6).';
      case 'user-not-found':
        return 'Ne postoji nalog za ovaj email.';
      case 'wrong-password':
        return 'Pogresna lozinka.';
      default:
        return 'Auth greska: ${e.message ?? e.code}';
    }
  }

  // gost nema nalog , gameScreen ruta
  Future<void> continueAsGuest() async {
    try {
      await _authService.signOut();
    } catch (_) {}
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, MainMenuScreen.route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WinterBackground(
        child: Stack(
          children: [
            /// BACK DUGME (gore levo)
            Positioned(
              left: 12,
              top: 12,
              child: Material(
                color: Colors.white.withOpacity(0.85),
                shape: const CircleBorder(),
                elevation: 6,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.arrow_back, color: Color(0xFF1565C0)),
                  ),
                ),
              ),
            ),

            // Login / Register forma
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 24,
                          color: Colors.black26,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// LOGIN / REGISTER TAB
                        Segment(
                          leftText: 'Login',
                          rightText: 'Register',
                          isLeftSelected: isLogin,
                          onChanged: (v) => setState(() => isLogin = v),
                        ),
                        const SizedBox(height: 18),

                        // Forma (polja i validacija)
                        Form(
                          key: formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // USERNAME samo kad je Register tab
                              if (!isLogin) ...[
                                const Label('Username'),
                                IcyField(
                                  controller: user,
                                  hint: 'Enter your username',
                                  validator: (v) {
                                    if ((v ?? '').trim().length < 3) {
                                      return 'Username min 3 karaktera';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                              ],

                              // email
                              const Label('Email'),
                              IcyField(
                                controller: email,
                                hint: 'Enter your email',
                                keyboardType: TextInputType.emailAddress,
                                showClear: true,
                                validator: (v) {
                                  final value = (v ?? '').trim();
                                  if (value.isEmpty) return 'Email je obavezan';
                                  if (!value.contains('@')) {
                                    return 'Unesi validan email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),

                              // password
                              const Label('Password'),
                              IcyField(
                                controller: password,
                                hint: 'Enter your password',
                                obscureText: true,
                                validator: (v) {
                                  final value = (v ?? '');
                                  if (value.isEmpty)
                                    return 'Lozinka je obavezna';
                                  if (value.length < 6) {
                                    return 'Lozinka min 6 karaktera';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 18),

                              // GLAVNO FUGME: LOGIN/CREATE ACC
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _loading ? null : submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4FC3F7),
                                    foregroundColor: Colors.white,
                                    elevation: 10,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: Text(
                                    _loading
                                        ? 'Please wait...'
                                        : (isLogin
                                              ? 'Login'
                                              : 'Create Account'),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              // Continue as Guest link
                              TextButton(
                                onPressed: continueAsGuest,
                                child: const Text(
                                  'Continue as Guest',
                                  style: TextStyle(
                                    color: Color(0xFF1E88E5),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// POMOCNI WIDGETI

class Segment extends StatelessWidget {
  const Segment({
    super.key,
    required this.leftText,
    required this.rightText,
    required this.isLeftSelected,
    required this.onChanged,
  });

  final String leftText;
  final String rightText;
  final bool isLeftSelected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegBtn(
              text: leftText,
              selected: isLeftSelected,
              onTap: () => onChanged(true),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SegBtn(
              text: rightText,
              selected: !isLeftSelected,
              onTap: () => onChanged(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegBtn extends StatelessWidget {
  const _SegBtn({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF4FC3F7) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF1565C0),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class Label extends StatelessWidget {
  const Label(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF1565C0),
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class IcyField extends StatefulWidget {
  const IcyField({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.validator,
    this.obscureText = false,
    this.showClear = false,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final bool showClear;

  @override
  State<IcyField> createState() => _IcyFieldState();
}

class _IcyFieldState extends State<IcyField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChange);
    super.dispose();
  }

  void _onTextChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.isNotEmpty;
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      obscureText: widget.obscureText,
      enableInteractiveSelection: true,
      readOnly: false,
      decoration: InputDecoration(
        hintText: widget.hint,
        filled: true,
        fillColor: const Color(0xFFF3F3F3),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: widget.showClear && hasText
            ? IconButton(
                onPressed: () => widget.controller.clear(),
                icon: const Icon(Icons.clear),
                color: const Color(0xFF94A3B8),
                tooltip: 'Clear',
              )
            : null,
      ),
    );
  }
}
