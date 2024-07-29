import 'package:flutter/material.dart';
import 'package:saron/api/data/device.dart';
import 'package:saron/widgets/snackbar_message/snackbar_message.dart';

class AddDevice extends StatefulWidget {
  const AddDevice({super.key});

  @override
  _AddDeviceState createState() => _AddDeviceState();
}

class _AddDeviceState extends State<AddDevice> {
  final TextEditingController serialNumberController = TextEditingController();
  final TextEditingController deviceIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<String> _errorMessage = ValueNotifier("");

  final FocusNode _serialNumberFocus = FocusNode();
  final FocusNode _deviceIdFocus = FocusNode();
  bool isLoading = false;

  @override
  void dispose() {
    serialNumberController.dispose();
    deviceIdController.dispose();
    _serialNumberFocus.dispose();
    _deviceIdFocus.dispose();
    _errorMessage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(child: _buildForm(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
            'Add New Device',
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

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          _buildTextField(
            controller: deviceIdController,
            label: 'Device ID',
            icon: Icons.devices,
            focusNode: _deviceIdFocus,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: serialNumberController,
            label: 'Serial Number',
            icon: Icons.qr_code,
            focusNode: _serialNumberFocus,
          ),
          const SizedBox(height: 16),
          _buildErrorMessage(),
          const SizedBox(height: 24),
          _buildButtons(context),
        ],
      ),
    );
  }

  Widget _buildTextField({
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
        textInputAction: TextInputAction.next,
        keyboardType: controller == deviceIdController
            ? TextInputType.number
            : TextInputType.text,
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

  Widget _buildErrorMessage() {
    return ValueListenableBuilder(
      valueListenable: _errorMessage,
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

  Widget _buildButtons(BuildContext context) {
    return isLoading
        ? const Center(
            child: SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(),
            ),
          )
        : Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
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
                  onPressed: () => _addDevice(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B9A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Add',
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

  void _addDevice(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      setState(() {
        isLoading = true;
      });
      _errorMessage.value = "";

      String serialNumber = serialNumberController.text;
      String deviceId = deviceIdController.text;

      final statusCode = await DeviceDB().addDevice(serialNumber, deviceId);
      if (statusCode == 200) {
        await DeviceDB().getDevices();
        Navigator.of(context).pop(true);
        snackbarMessage(context, "Device added successfully");
      } else if (statusCode == 400) {
        Navigator.of(context).pop(false);
        snackbarMessage(context, "Device already added to the user");
      } else if (statusCode == 204) {
        _errorMessage.value = "Device not found";
      } else if (statusCode == 404) {
        _errorMessage.value = "User not found";
      } else {
        _errorMessage.value = "Internal server error";
      }
      setState(() {
        isLoading = false;
      });
    }
  }
}
