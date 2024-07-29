import 'package:flutter/material.dart';
import 'package:saron/api/data/auth.dart';
import 'package:saron/widgets/snackbar_message/snackbar_message.dart';

class ForgetPasswordScreen extends StatelessWidget {
  ForgetPasswordScreen({Key? key, this.email}) : super(key: key) {
    _emailController.text = email ?? "";
  }

  final String? email;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _tokenController = TextEditingController();
  final ValueNotifier<bool> _emailValidated = ValueNotifier(false);
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 40,
                ),
                const Icon(
                  Icons.lock_reset,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Reset Password',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 48),
                Form(
                  key: _formKey,
                  child: ValueListenableBuilder(
                    valueListenable: _emailValidated,
                    builder: (context, emailValidated, _) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildTextField(
                            controller: _emailController,
                            label: 'Email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            readOnly: emailValidated,
                          ),
                          const SizedBox(height: 16),
                          if (emailValidated) ...[
                            _buildTextField(
                              controller: _tokenController,
                              label: 'Token',
                              icon: Icons.security,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _passwordController,
                              label: 'New Password',
                              icon: Icons.lock_outline,
                              obscureText: true,
                            ),
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
                          const SizedBox(height: 32),
                          ValueListenableBuilder(
                            valueListenable: _isLoading,
                            builder: (context, isLoading, _) {
                              return ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () => resetPassword(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                child: isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : Text(
                                        emailValidated
                                            ? 'RESET PASSWORD'
                                            : 'SEND TOKEN',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              );
                            },
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      readOnly: readOnly,
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

  void resetPassword(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _isLoading.value = true;

      final email = _emailController.text;
      final password = _passwordController.text;
      final token = _tokenController.text;
      String errorMessage;

      if (_emailValidated.value) {
        final statusCode = await AuthDB().resetPassword(email, token, password);
        if (statusCode == 200) {
          errorMessage = "Password changed successfully";
          Navigator.of(context).pop();
        } else if (statusCode == 404) {
          errorMessage = "User doesn't exist";
        } else if (statusCode == 401) {
          errorMessage = "Invalid or Expired Token";
        } else {
          errorMessage = "Internal server error";
        }
      } else {
        final statusCode = await AuthDB().forgetPassword(email);
        if (statusCode == 200) {
          errorMessage = "Reset token sent to your Email";
          _emailValidated.value = true;
        } else if (statusCode == 500) {
          errorMessage = "Failed to send reset password email";
        } else if (statusCode == 404) {
          errorMessage = "Email doesn't belong to any user";
        } else {
          errorMessage = "Internal server error";
        }
      }

      snackbarMessage(context, errorMessage, false);
      _isLoading.value = false;
    }
  }
}
