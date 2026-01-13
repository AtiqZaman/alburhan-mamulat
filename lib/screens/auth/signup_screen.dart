import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  
  String _selectedRole = 'salik'; // Default role
  bool _isLoading = false;
  bool _passwordVisible = false;
  bool _mounted = true;

  @override
  void dispose() {
    _mounted = false;
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textDirection: TextDirection.rtl),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textDirection: TextDirection.rtl),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _signup() async {
    print('DEBUG: Signup button pressed');
    
    if (_nameController.text.isEmpty) {
      _showSnackBar('نام درج کریں');
      return;
    }
    if (_emailController.text.isEmpty) {
      _showSnackBar('ای میل درج کریں');
      return;
    }
    if (_passwordController.text.isEmpty) {
      _showSnackBar('پاس ورڈ درج کریں');
      return;
    }
    if (_passwordController.text.length < 6) {
      _showSnackBar('پاس ورڈ کم از کم 6 حروف کا ہونا چاہیے');
      return;
    }

    print('DEBUG: All validations passed, starting signup');
    if (!_mounted) return;
    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      print('DEBUG: Calling signUp with email: ${_emailController.text.trim()}');
      
      String? error = await authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        role: _selectedRole,
      );

      print('DEBUG: SignUp response - Error: $error');
      
      if (!_mounted) return;
      
      setState(() => _isLoading = false);

      if (error == null) {
        print('DEBUG: Signup successful, showing success message');
        _showSuccessSnackBar('✓ اکاؤنٹ کامیابی سے بنایا گیا! براہ کرم لاگ ان کریں');
        
        // Sign out immediately
        try {
          await authService.signOut();
          print('DEBUG: User signed out after signup');
        } catch (e) {
          print('DEBUG: Error signing out: $e');
        }
        
        // Wait 3 seconds then navigate to login
        await Future.delayed(Duration(seconds: 3));
        if (mounted) {
          print('DEBUG: Navigating to login screen');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        }
      } else {
        print('DEBUG: Signup error: $error');
        _showSnackBar(error);
      }
    } catch (e) {
      print('DEBUG: Exception caught in signup: $e');
      if (!_mounted) return;
      
      setState(() => _isLoading = false);
      _showSnackBar('خرابی: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A3A5C),
              Color(0xFF2D5A8C),
              Color(0xFF3D6B9E),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background orbs
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.03),
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                      ),

                      SizedBox(height: 40),

                      // Title
                      Text(
                        'اکاؤنٹ بنائیں',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'NotoNastaliq',
                        ),
                        textDirection: TextDirection.rtl,
                      ),

                      SizedBox(height: 12),

                      Text(
                        'اپنی روحانی سفر شروع کریں',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.7),
                          fontFamily: 'NotoNastaliq',
                        ),
                        textDirection: TextDirection.rtl,
                      ),

                      SizedBox(height: 40),

                      // Role selection
                      Text(
                        'اپنا کردار منتخب کریں',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'NotoNastaliq',
                        ),
                        textDirection: TextDirection.rtl,
                      ),

                      SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        textDirection: TextDirection.rtl,
                        children: [
                          _buildRoleButton('مربی', 'murabi', Color(0xFF8B5CF6)),
                          _buildRoleButton('سالک', 'salik', Color(0xFF10B981)),
                        ],
                      ),

                      SizedBox(height: 40),

                      // Form
                      _buildGlassmorphicTextField(
                        controller: _nameController,
                        label: 'نام',
                        icon: Icons.person_outline,
                      ),

                      SizedBox(height: 16),

                      _buildGlassmorphicTextField(
                        controller: _emailController,
                        label: 'ای میل',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      SizedBox(height: 16),

                      _buildGlassmorphicTextField(
                        controller: _passwordController,
                        label: 'پاس ورڈ',
                        icon: Icons.lock_outlined,
                        obscureText: !_passwordVisible,
                        suffixIcon: _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        onSuffixTap: () {
                          setState(() => _passwordVisible = !_passwordVisible);
                        },
                      ),

                      SizedBox(height: 16),

                      _buildGlassmorphicTextField(
                        controller: _phoneController,
                        label: 'فون نمبر',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),

                      SizedBox(height: 40),

                      // Signup button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: GestureDetector(
                          onTap: _isLoading ? null : () {
                            print('DEBUG: GestureDetector tapped');
                            _signup();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF10B981),
                                  Color(0xFF34D399),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF10B981).withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Center(
                              child: _isLoading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'اکاؤنٹ بنائیں',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontFamily: 'NotoNastaliq',
                                      ),
                                      textDirection: TextDirection.rtl,
                                    ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 24),

                      // Login link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        textDirection: TextDirection.rtl,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Text(
                              'لاگ ان کریں',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.bold,
                                fontFamily: 'NotoNastaliq',
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'پہلے سے اکاؤنٹ ہے؟',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.8),
                              fontFamily: 'NotoNastaliq',
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleButton(String label, String role, Color color) {
    bool isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedRole = role);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? color.withOpacity(0.3)
              : Colors.white.withOpacity(0.05),
          border: Border.all(
            color: isSelected
                ? color.withOpacity(0.6)
                : Colors.white.withOpacity(0.1),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'NotoNastaliq',
              ),
            ),
            if (isSelected)
              Icon(Icons.check, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassmorphicTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontFamily: 'NotoNastaliq',
              ),
              prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7)),
              suffixIcon: suffixIcon != null
                  ? GestureDetector(
                      onTap: onSuffixTap,
                      child: Icon(suffixIcon, color: Colors.white.withOpacity(0.7)),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
          ),
        ),
      ),
    );
  }
}
