// lib/features/auth/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/services/auth_service.dart';
import '../../../core/models/user_model.dart';
import '../../../shared/widgets/hireme_app_bar.dart';

enum UserRole { worker, customer }

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  UserRole _selectedRole = UserRole.worker;
  bool _obscurePassword = true;
  bool _agreedToTerms = false;
  bool _isLoading = false;

  // Progress step (1 of 4 — just registration step)
  final int _currentStep = 1;
  final int _totalSteps = 4;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the Terms of Service and Privacy Policy.')),
      );
      return;
    }
    setState(() => _isLoading = true);

    try {
      final phone = _phoneCtrl.text.trim();
      final password = _passwordCtrl.text;
      final name = _nameCtrl.text.trim();
      final role = _selectedRole == UserRole.worker ? 'worker' : 'customer';

      // Since phone auth requires OTP, we map phone to a dummy email for easy testing
      final email = phone.contains('@') ? phone : "$phone@hireme.com";

      final authService = AuthService();

      // 🔴 FIX #2: Use credential.user!.uid — guaranteed non-null immediately after signUp.
      // authService.currentUserId reads _auth.currentUser?.uid which can be null in a race.
      final credential = await authService.signUpWithEmail(email: email, password: password);
      final uid = credential.user!.uid;

      // Create the user profile in Firestore
      // 🔴 FIX #3 (partial): createdAt is now handled via FieldValue.serverTimestamp() in toFirestore()
      final userModel = UserModel(
        uid: uid,
        name: name,
        phone: phone,
        email: email,
        role: role,
        createdAt: DateTime.now(), // local value — only used for display; Firestore gets serverTimestamp
      );
      await authService.createUserProfile(userModel);

      if (mounted) {
        setState(() => _isLoading = false);
        context.go(role == 'worker' ? '/worker/home' : '/customer/home');
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException during registration: [${e.code}] ${e.message}');
      if (mounted) {
        setState(() => _isLoading = false);
        final message = switch (e.code) {
          'email-already-in-use' => 'This phone number is already registered. Please log in.',
          'weak-password' => 'Password is too weak. Use at least 8 characters.',
          'network-request-failed' => 'No internet connection. Please check your network.',
          'operation-not-allowed' => 'Email/Password sign-in is not enabled in Firebase Console.',
          _ => 'Registration failed: [${e.code}] ${e.message}',
        };
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e, stack) {
      debugPrint('Registration error: $e\n$stack');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const HireMeAppBar(modeLabel: 'Worker Mode'),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 448),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                clipBehavior: Clip.hardEdge,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Progress Bar ─────────────────────────────────────
                    _ProgressBar(current: _currentStep, total: _totalSteps),

                    // ── Content ──────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),

                          // Title
                          Text(
                            'Join HireMe',
                            style: Theme.of(context).textTheme.displayMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Select your path to continue.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          // ── Role Toggle ───────────────────────────────
                          _RoleToggle(
                            selectedRole: _selectedRole,
                            onChanged: (r) => setState(() => _selectedRole = r),
                          ),
                          const SizedBox(height: 24),

                          // ── Form ──────────────────────────────────────
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Full Name
                                _IconLabelField(
                                  label: 'Full Name',
                                  hint: 'Rahul Sharma',
                                  controller: _nameCtrl,
                                  icon: Icons.person_outline_rounded,
                                  keyboardType: TextInputType.name,
                                  validator: (v) =>
                                      v == null || v.trim().isEmpty ? 'Enter your full name' : null,
                                ),
                                const SizedBox(height: 16),

                                // Phone Number
                                _PhoneField(controller: _phoneCtrl),
                                const SizedBox(height: 16),

                                // Password
                                _IconLabelField(
                                  label: 'Password',
                                  hint: '••••••••',
                                  controller: _passwordCtrl,
                                  icon: Icons.lock_outline_rounded,
                                  obscureText: _obscurePassword,
                                  suffixAction: () =>
                                      setState(() => _obscurePassword = !_obscurePassword),
                                  suffixIcon: _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  validator: (v) => v == null || v.length < 8
                                      ? 'Password must be at least 8 characters'
                                      : null,
                                ),
                                const SizedBox(height: 16),

                                // Terms checkbox
                                _TermsRow(
                                  value: _agreedToTerms,
                                  onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
                                ),
                                const SizedBox(height: 20),

                                // Submit button
                                _RegisterButton(
                                  isLoading: _isLoading,
                                  onPressed: _handleRegister,
                                ),
                              ],
                            ),
                          ),

                          // ── Log in link ───────────────────────────────
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account?',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => context.go('/login'),
                                child: const Text(
                                  'Log in',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],
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

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  final int current;
  final int total;

  const _ProgressBar({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(height: 4, color: AppColors.surfaceDim),
        FractionallySizedBox(
          widthFactor: current / total,
          child: Container(
            height: 4,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(2),
                bottomRight: Radius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RoleToggle extends StatelessWidget {
  final UserRole selectedRole;
  final ValueChanged<UserRole> onChanged;

  const _RoleToggle({required this.selectedRole, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sliderWidth = (constraints.maxWidth - 4 * 2) / 2;
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              // Animated sliding indicator
              AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: selectedRole == UserRole.worker
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Container(
                  width: sliderWidth,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
              // Buttons row
              Row(
                children: [
                  Expanded(
                    child: _ToggleButton(
                      label: 'I want to Work',
                      isSelected: selectedRole == UserRole.worker,
                      onTap: () => onChanged(UserRole.worker),
                    ),
                  ),
                  Expanded(
                    child: _ToggleButton(
                      label: 'I want to Hire',
                      isSelected: selectedRole == UserRole.customer,
                      onTap: () => onChanged(UserRole.customer),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleButton({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 40,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
            ),
            child: Text(label, textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}

class _IconLabelField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final VoidCallback? suffixAction;
  final IconData? suffixIcon;

  const _IconLabelField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.suffixAction,
    this.suffixIcon,
  });

  @override
  State<_IconLabelField> createState() => _IconLabelFieldState();
}

class _IconLabelFieldState extends State<_IconLabelField> {
  late final FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()
      ..addListener(() => setState(() => _isFocused = _focusNode.hasFocus));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label above
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            widget.label,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurface,
            ),
          ),
        ),
        // Input field
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: _isFocused ? 0 : 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.onSurface,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surfaceContainerLowest,
              hintText: widget.hint,
              hintStyle: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                color: AppColors.outline,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.error),
              ),
              prefixIcon: Icon(widget.icon, size: 20, color: AppColors.outline),
              suffixIcon: widget.suffixAction != null
                  ? GestureDetector(
                      onTap: widget.suffixAction,
                      child: Icon(widget.suffixIcon, size: 20, color: AppColors.outline),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _PhoneField extends StatefulWidget {
  final TextEditingController controller;

  const _PhoneField({required this.controller});

  @override
  State<_PhoneField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<_PhoneField> {
  late final FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()
      ..addListener(() => setState(() => _isFocused = _focusNode.hasFocus));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            'Phone Number',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurface,
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isFocused ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              // Country code prefix
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceDim,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  border: Border(
                    right: BorderSide(color: Color(0x1F000000), width: 1),
                  ),
                ),
                child: const Text(
                  '+91',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              // Phone input
              Expanded(
                child: TextFormField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter phone number';
                    if (v.length != 10) return 'Enter valid 10-digit number';
                    return null;
                  },
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    color: AppColors.onSurface,
                  ),
                  decoration: const InputDecoration(
                    hintText: '98765 43210',
                    hintStyle: TextStyle(color: AppColors.outline, fontSize: 14),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TermsRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _TermsRow({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom checkbox
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: value ? AppColors.primary : AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: value
                ? const Icon(Icons.check_rounded, color: AppColors.white, size: 14)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                  height: 1.4,
                ),
                children: [
                  TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _RegisterButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: AppColors.onPrimaryContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: isLoading ? 0 : 3,
        ),
        child: isLoading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.onPrimaryContainer,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Processing...',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onPrimaryContainer,
                    ),
                  ),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Create Account',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: AppColors.onPrimaryContainer,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.onPrimaryContainer),
                ],
              ),
      ),
    );
  }
}
