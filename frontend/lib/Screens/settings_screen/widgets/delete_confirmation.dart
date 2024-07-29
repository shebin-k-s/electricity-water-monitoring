import 'package:flutter/material.dart';
import 'package:saron/Screens/auth_screen/auth_screen.dart';
import 'package:saron/api/data/auth.dart';
import 'package:saron/main.dart';
import 'package:saron/widgets/snackbar_message/snackbar_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeleteConfirmation {
  static void show(BuildContext context) {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final ValueNotifier<String> errorMessage = ValueNotifier("");
    final ValueNotifier<bool> isLoading = ValueNotifier(false);
    final FocusNode passwordFocusNode = FocusNode();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: const BoxDecoration(
              color: Color(0xFFF0F4F8),
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildForm(
                    context,
                    passwordFocusNode,
                    passwordController,
                    formKey,
                    errorMessage,
                    isLoading,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      decoration: const BoxDecoration(
        color: Color(0xFF6A1B9A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Confirm Deletion',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildForm(
      BuildContext context,
      FocusNode passwordFocusNode,
      TextEditingController passwordController,
      GlobalKey<FormState> formKey,
      ValueNotifier<String> errorMessage,
      ValueNotifier<bool> isLoading) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          _buildTextField(
            controller: passwordController,
            label: 'Password',
            icon: Icons.lock,
            focusNode: passwordFocusNode,
          ),
          const SizedBox(height: 16),
          _buildErrorMessage(errorMessage),
          const SizedBox(height: 24),
          _buildButtons(
            context,
            passwordController,
            formKey,
            errorMessage,
            isLoading,
          ),
        ],
      ),
    );
  }

  static Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required FocusNode focusNode,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        textInputAction: TextInputAction.done,
        obscureText: label == 'Password',
        style: const TextStyle(color: Colors.black87, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF6A1B9A),
            fontSize: 16,
          ),
          prefixIcon: Icon(icon, color: const Color(0xFF6A1B9A)),
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
            borderSide: const BorderSide(color: Color(0xFF6A1B9A), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        },
      ),
    );
  }

  static Widget _buildErrorMessage(ValueNotifier<String> errorMessage) {
    return ValueListenableBuilder(
      valueListenable: errorMessage,
      builder: (context, value, child) {
        if (value.isNotEmpty) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  static Widget _buildButtons(
    BuildContext context,
    TextEditingController passwordController,
    GlobalKey<FormState> formKey,
    ValueNotifier<String> errorMessage,
    ValueNotifier<bool> isLoading,
  ) {
    return ValueListenableBuilder(
      valueListenable: isLoading,
      builder: (context, value, child) {
        if (value) {
          return const Center(
            child: SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFF6A1B9A),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      FocusScope.of(context).unfocus();

                      errorMessage.value = "";
                      isLoading.value = true;
                      final statusCode =
                          await AuthDB().deleteAccount(passwordController.text);
                      if (statusCode == 200) {
                        final SharedPreferences sharedPref =
                            await SharedPreferences.getInstance();
                        await sharedPref.remove(TOKEN);
                        await sharedPref.remove(EMAIL);
                        await sharedPref.remove(USERNAME);
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (ctx) => AuthScreen(),
                          ),
                          (route) => false,
                        );
                        snackbarMessage(
                            context, "Account Deleted Successfully");
                      } else if (statusCode == 401) {
                        errorMessage.value = "Incorrect password";
                      } else if (statusCode == 404) {
                        errorMessage.value = "User not found";
                      } else {
                        errorMessage.value = "Internal server error";
                      }
                      isLoading.value = false;
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B9A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
