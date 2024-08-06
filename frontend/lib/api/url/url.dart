class Url {
  String baseUrl = "https://electricity-water-monitoring.onrender.com/";

  String login = "api/auth/login";
  String signup = "api/auth/signup";
  String forgetPassword = "api/auth/forget-password";
  String resetPassword = "api/auth/reset-password";
  String deleteAccount = "api/auth/delete-account";

  String addDevice = "api/user-device/add-device";
  String removeDevice = "api/user-device/remove-device";
  String changeDeviceName = "api/user-device/change-devicename";
  String getDevice = "api/user-device/get-devices";

  String fetchUnitConsumed = "api/utilization/unit-consumed";
  String fetchUtilization = "api/utilization/history";
}
