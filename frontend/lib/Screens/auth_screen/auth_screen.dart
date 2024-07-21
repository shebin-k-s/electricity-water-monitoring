import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saron/Screens/auth_screen/forgetpassword_screen.dart';
import 'package:saron/Screens/main_sceen/main_screen.dart';
import 'package:saron/api/data/auth.dart';
import 'package:saron/api/data/device.dart';
import 'package:saron/widgets/snackbar_message/snackbar_message.dart';

class AuthScreen extends StatelessWidget {
  AuthScreen({Key? key}) : super(key: key);

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController(text: "sshebi71@gmail.com");
  final _passwordController = TextEditingController(text: "12345");
  final _confirmPasswordController = TextEditingController();
  final ValueNotifier<bool> signUp = ValueNotifier(false);
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 24),
                  ValueListenableBuilder(
                    valueListenable: signUp,
                    builder: (context, isSignUp, _) {
                      return Text(
                        isSignUp ? 'Create Account' : 'Welcome Back',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 48),
                  Form(
                    key: _formKey,
                    child: ValueListenableBuilder(
                      valueListenable: signUp,
                      builder: (context, isSignUp, _) {
                        return Column(
                          children: [
                            if (isSignUp) ...[
                              _buildTextField(
                                controller: _usernameController,
                                label: 'Username',
                                icon: Icons.person_outline,
                              ),
                              const SizedBox(height: 16),
                            ],
                            _buildTextField(
                              controller: _emailController,
                              label: 'Email',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _passwordController,
                              label: 'Password',
                              icon: Icons.lock_outline,
                              obscureText: true,
                            ),
                            if (isSignUp) ...[
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _confirmPasswordController,
                                label: 'Confirm Password',
                                icon: Icons.lock_outline,
                                obscureText: true,
                                validator: (value) {
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                            ],
                            if (!isSignUp) ...[
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) => ForgetPasswordScreen()),
                                  ),
                                  child: const Text(
                                    'Forgot Password?',
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 32),
                            ValueListenableBuilder(
                              valueListenable: _isLoading,
                              builder: (context, isLoading, _) {
                                return ElevatedButton(
                                  onPressed:
                                      isLoading ? null : () => login(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    minimumSize:
                                        const Size(double.infinity, 50),
                                  ),
                                  child: isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white)
                                      : Text(
                                          isSignUp ? 'SIGN UP' : 'LOG IN',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isSignUp
                                      ? 'Already have an account? '
                                      : "Don't have an account? ",
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                TextButton(
                                  onPressed: () => signUp.value = !isSignUp,
                                  child: Text(
                                    isSignUp ? 'Log In' : 'Sign Up',
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.white10,
      ),
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            if (label == 'Email' &&
                !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
    );
  }

  void login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _isLoading.value = true;
      final email = _emailController.text;
      final password = _passwordController.text;
      final username = _usernameController.text;
      String errorMessage;

      if (signUp.value) {
        if (_passwordController.text != _confirmPasswordController.text) {
          errorMessage = "Passwords do not match";
        } else {
          final statusCode =
              await AuthDB().userSignup(username, email, password);
          if (statusCode == 201) {
            errorMessage = "Account created successfully";
            signUp.value = false;
          } else if (statusCode == 400) {
            errorMessage = "Email already exists";
          } else {
            errorMessage = "Internal server error";
          }
        }
      } else {
        final statusCode = await AuthDB().userLogin(email, password);
        if (statusCode == 200) {
          await DeviceDB().getDevices();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => MainScreen()),
          );
          return;
        } else if (statusCode == 404) {
          errorMessage = "Email doesn't exist";
        } else if (statusCode == 401) {
          errorMessage = "Incorrect Password";
        } else {
          errorMessage = "Internal server error";
        }
      }

      snackbarMessage(context, errorMessage);
      _isLoading.value = false;
    }
  }
}
