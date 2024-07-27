import 'package:animated_loading_indicators/animated_loading_indicators.dart';
import 'package:flutter/material.dart';
import 'package:saron/Screens/home_screen/utilization_list.dart';
import 'package:saron/Screens/home_screen/widget/calender_picker.dart';
import 'package:saron/api/daily_consumption_model/daily_consumption.dart';
import 'package:saron/api/daily_consumption_model/daily_consumption_model.dart';
import 'package:saron/api/data/utilization.dart';
import 'package:saron/api/device_model/device.dart';
import 'package:saron/api/load_data/load_devices.dart';
import 'package:saron/main.dart';
import 'package:saron/widgets/custom_button/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final ValueNotifier<DailyConsumptionModel?> dailyConsumptionNotifier =
      ValueNotifier(null);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<int> _selectedDeviceIndex = ValueNotifier(0);
  final ValueNotifier<List<Device>> deviceList = ValueNotifier([]);
  final ValueNotifier<bool> _error = ValueNotifier(false);
  DateTime? startDate;
  DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    _loadDevices();
    return FutureBuilder<String?>(
      future: getName(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final String username = snapshot.data ?? 'User';
          return Column(
            children: [
              _buildHeader(username),
              const SizedBox(height: 5),
              _buildDeviceSelector(),
              const SizedBox(height: 30),
              _buildContent(),
            ],
          );
        }
      },
    );
  }

  Widget _buildHeader(String username) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF5B0569),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "HELLO, ",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  username.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.green,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text(
              "Calculate Your Consumption !!!",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          _buildDeviceList(),
        ],
      ),
    );
  }

  Widget _buildDeviceList() {
    return ValueListenableBuilder(
      valueListenable: deviceList,
      builder: (context, List<Device> devices, _) {
        return devices.isEmpty
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: devices.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: ValueListenableBuilder(
                          valueListenable: _selectedDeviceIndex,
                          builder: (context, int deviceIndex, _) {
                            return CustomButton(
                              btnColor: deviceIndex == index
                                  ? const Color.fromRGBO(27, 94, 32, 1)
                                  : Colors.transparent,
                              text: devices[index].deviceName.toUpperCase(),
                              onClick: () =>
                                  _onDeviceSelected(index, devices[index]),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              );
      },
    );
  }

  Widget _buildDeviceSelector() {
    return ValueListenableBuilder(
      valueListenable: deviceList,
      builder: (context, List<Device> devices, _) {
        return devices.isEmpty
            ? const SizedBox.shrink()
            : ValueListenableBuilder(
                valueListenable: _selectedDeviceIndex,
                builder: (context, int index, _) {
                  return CalendarPicker(
                    initialStartDate: startDate,
                    initialEndDate: endDate,
                    isLoading: (val) => isLoading.value = val,
                    deviceId: devices[index].deviceId,
                    onDateChange: (dailyConsumption, startdate, enddate) {
                      _error.value = false;
                      dailyConsumptionNotifier.value = dailyConsumption;
                      startDate = startdate;
                      endDate = enddate;
                    },
                    onError: (val) => _error.value = val,
                  );
                },
              );
      },
    );
  }

  Widget _buildContent() {
    return ValueListenableBuilder(
      valueListenable: isLoading,
      builder: (context, isLoading, _) {
        return ValueListenableBuilder(
          valueListenable: dailyConsumptionNotifier,
          builder: (context, dailyConsumption, _) {
            return ValueListenableBuilder(
              valueListenable: _error,
              builder: (context, error, _) {
                if (dailyConsumption != null && !isLoading && !error) {
                  print("cjcc${dailyConsumption.totalUnitConsumed}");
                  return _buildConsumptionList(dailyConsumption);
                } else if (isLoading) {
                  return const Expanded(
                    child: Center(
                      child: InfinityCradle(
                        size: 50,
                        color: Colors.green,
                        duration: Duration(seconds: 1),
                      ),
                    ),
                  );
                } else {
                  return _buildMessageWidget();
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _buildConsumptionList(DailyConsumptionModel dailyConsumption) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              _buildConsumptionHeader(dailyConsumption),
              const Divider(thickness: 1, height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: dailyConsumption.dailyConsumption?.length ?? 0,
                  itemBuilder: (context, index) => _buildConsumptionItem(
                    context,
                    dailyConsumption.dailyConsumption![index],
                    index,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConsumptionHeader(DailyConsumptionModel dailyConsumption) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: deviceList,
              builder: (context, List<Device> devices, _) {
                return ValueListenableBuilder(
                  valueListenable: _selectedDeviceIndex,
                  builder: (context, int index, _) {
                    return devices.isEmpty
                        ? const SizedBox.shrink()
                        : Text(
                            "${devices[index].deviceName.toUpperCase()} Consumption",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          );
                  },
                );
              },
            ),
          ),
          Text(
            "${dailyConsumption.totalUnitConsumed?.toStringAsFixed(4) ?? '0.0000'} Units",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsumptionItem(
      BuildContext context, DailyConsumption dailyConsumption, int index) {
    final formattedDate =
        DateFormat('EEE, MMM d yyyy').format(dailyConsumption.date);
    return GestureDetector(
      onTap: () => _navigateToUtilizationList(context, dailyConsumption.date),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.purple[100],
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: Colors.purple[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                formattedDate,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              dailyConsumption.unitConsumed.toStringAsFixed(5),
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.purple[800]),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageWidget() {
    return ValueListenableBuilder(
      valueListenable: deviceList,
      builder: (context, List<Device> devices, _) {
        return ValueListenableBuilder(
          valueListenable: _error,
          builder: (context, bool error, _) {
            if (devices.isEmpty) {
              return _buildCenteredMessage(
                  "Add device....", "assets/images/send_request.png");
            } else {
              return _buildCenteredMessage(
                error
                    ? "Could not send request"
                    : "Select date to send request",
                error
                    ? "assets/images/network_error.png"
                    : "assets/images/send_request.png",
              );
            }
          },
        );
      },
    );
  }

  Widget _buildCenteredMessage(String message, String imagePath) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(imagePath),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        )
      ],
    );
  }

  void _onDeviceSelected(int index, Device device) async {
    _error.value = false;
    _selectedDeviceIndex.value = index;
    if (startDate != null && endDate != null) {
      try {
        isLoading.value = true;
        final dailyConsumption = await UtilizationDB().unitConsumed(
          startDate.toString(),
          endDate.toString(),
          device.deviceId,
        );
        if (dailyConsumption?.totalUnitConsumed != null &&
            dailyConsumption!.totalUnitConsumed! >= 0) {
          dailyConsumptionNotifier.value = dailyConsumption;
        } else {
          _error.value = true;
        }
      } catch (e) {
        _error.value = true;
      } finally {
        isLoading.value = false;
      }
    }
  }

  void _navigateToUtilizationList(BuildContext context, DateTime date) {
    if (deviceList.value.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => UtilizationList(
            date: date,
            deviceId: deviceList.value[_selectedDeviceIndex.value].deviceId,
          ),
        ),
      );
    }
  }

  Future<void> _loadDevices() async {
    final devices = await loadDeviceList();
    deviceList.value = devices;
  }

  Future<String?> getName() async {
    final SharedPreferences sharedPref = await SharedPreferences.getInstance();
    return sharedPref.getString(USERNAME);
  }
}
