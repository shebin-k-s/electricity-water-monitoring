import 'dart:ffi';

import 'package:animated_loading_indicators/animated_loading_indicators.dart';
import 'package:flutter/material.dart';
import 'package:saron/Screens/home_screen/utilization_list.dart';
import 'package:saron/Screens/home_screen/widget/calender_picker.dart';
import 'package:saron/api/data/utilization.dart';
import 'package:saron/api/device_model/device.dart';
import 'package:saron/api/load_data/load_devices.dart';
import 'package:saron/main.dart';
import 'package:saron/widgets/custom_button/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final ValueNotifier<double> _unitConsumed = ValueNotifier(0);
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  final ValueNotifier<int> _selectedDeviceIndex = ValueNotifier(0);
  final ValueNotifier<List<Device>> deviceList = ValueNotifier([]);
  bool _error = false;

  // DateTime? _startDate = null;
  // DateTime? _endDate = null;

  DateTime? _startDate = DateTime.now();
  DateTime? _endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getName(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final String? username = snapshot.data;
          return Column(
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF5B0569),
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(30)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 40,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "HELLO, ",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            username!.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        "Calculate Your Consumption !!!",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: SizedBox(
                        height: 50,
                        child: ValueListenableBuilder(
                          valueListenable: deviceList,
                          builder: (context, device, child) {
                            if (device.isNotEmpty) {
                              return ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: ValueListenableBuilder(
                                      valueListenable: _selectedDeviceIndex,
                                      builder: (context, deviceIndex, child) {
                                        return CustomButton(
                                          btnColor: deviceIndex == index
                                              ? const Color.fromRGBO(
                                                  27, 94, 32, 1)
                                              : Colors.transparent,
                                          text: device[index]
                                              .deviceName
                                              .toUpperCase(),
                                          onClick: () async {
                                            _error = false;
                                            _selectedDeviceIndex.value = index;
                                            if (_startDate != null &&
                                                _endDate != null) {
                                              try {
                                                _isLoading.value = true;
                                                double unitConsumed =
                                                    await UtilizationDB()
                                                        .unitConsumed(
                                                  _startDate.toString(),
                                                  _endDate.toString(),
                                                  device[index].deviceId,
                                                );
                                                if (unitConsumed < 0) {
                                                  _error = true;
                                                } else {
                                                  _unitConsumed.value =
                                                      unitConsumed;
                                                }
                                              } catch (e) {
                                                _error = true;
                                              } finally {
                                                _isLoading.value = false;
                                              }
                                            }
                                          },
                                        );
                                      },
                                    ),
                                  );
                                },
                                itemCount: device.length,
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              ValueListenableBuilder(
                valueListenable: _selectedDeviceIndex,
                builder: (context, index, child) {
                  if (deviceList.value.isNotEmpty) {
                    return CalendarPicker(
                        initialStartDate: _startDate,
                        initialEndDate: _endDate,
                        isLoading: (val) => _isLoading.value = val,
                        deviceId: deviceList.value[index].deviceId,
                        onDateChange: (unit, startDate, endDate) {
                          _error = false;
                          _unitConsumed.value = unit;
                          _startDate = startDate;
                          _endDate = endDate;
                        },
                        onError: (val) {
                          _error = val;
                        });
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              const SizedBox(height: 30),
              ValueListenableBuilder(
                valueListenable: _isLoading,
                builder: (context, value, child) {
                  if (_startDate != null && !value && !_error) {
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
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "${deviceList.value[_selectedDeviceIndex.value].deviceName.toUpperCase()} Consumption",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "${_unitConsumed.value.toStringAsFixed(2)} Units",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(thickness: 1, height: 1),
                              Expanded(
                                child: ListView.builder(
                                  itemBuilder: (context, index) {
                                    final date =
                                        _startDate!.add(Duration(days: index));
                                    final formattedDate =
                                        DateFormat('EEE, MMM d yyyy')
                                            .format(date);
                                    return InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (ctx) => UtilizationList(
                                              date: date,
                                              deviceId: deviceList
                                                  .value[_selectedDeviceIndex
                                                      .value]
                                                  .deviceId,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 24,
                                              backgroundColor:
                                                  Colors.purple[100],
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
                                            Icon(Icons.chevron_right,
                                                color: Colors.purple[800]),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  itemCount:
                                      _endDate!.difference(_startDate!).inDays +
                                          1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else if (value) {
                    return const Expanded(
                        child: Center(
                            child: InfinityCradle(
                      size: 50,
                      color: Colors.green,
                      duration: Duration(seconds: 1),
                    )));
                  } else {
                    if (deviceList.value.isEmpty) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/send_request.png",
                          ),
                          const Text(
                            "Add device....",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      );
                    } else {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            _error
                                ? "assets/images/network_error.png"
                                : "assets/images/send_request.png",
                          ),
                          Text(
                            _error
                                ? "Could not send request"
                                : "Select date to send request",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      );
                    }
                  }
                },
              ),
            ],
          );
        }
      },
    );
  }

  Future<String?> getName() async {
    final SharedPreferences _sharedPref = await SharedPreferences.getInstance();
    deviceList.value = await loadDeviceList();

    return _sharedPref.getString(USERNAME);
  }
}
