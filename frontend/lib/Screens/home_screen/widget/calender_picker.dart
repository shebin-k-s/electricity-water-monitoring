import 'package:flutter/material.dart';
import 'package:saron/Screens/home_screen/widget/CalenderBottomSheet.dart';
import 'package:saron/api/daily_consumption_model/daily_consumption.dart';
import 'package:saron/api/daily_consumption_model/daily_consumption_model.dart';
import 'package:saron/api/data/utilization.dart';
import 'package:saron/widgets/custom_button/custom_button.dart';
import 'package:saron/widgets/snackbar_message/snackbar_message.dart';

class CalendarPicker extends StatelessWidget {
  final Function(DailyConsumptionModel, DateTime, DateTime) onDateChange;
  final Function(bool) isLoading;
  final Function(bool) onError;
  final int deviceId;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

   ValueNotifier<DateTime?> startDate = ValueNotifier(DateTime(2024-02-20));
   ValueNotifier<DateTime?> endDate = ValueNotifier(DateTime.now());

  CalendarPicker({
    super.key,
    required this.onDateChange,
    required this.isLoading,
    required this.deviceId,
    required this.onError,
    required this.initialStartDate,
    required this.initialEndDate,
  }) 
  //  : startDate = ValueNotifier<DateTime?>(initialStartDate),
  //       endDate = ValueNotifier<DateTime?>(initialEndDate)
        ;

  Future<void> _selectStartDate(BuildContext context) async {
    CalendarBottomSheet(
      context: context,
      label: "Select Start Date",
      initialDate: startDate.value ?? DateTime.now(),
      onDateSelected: (date) {
        startDate.value = date;
      },
    );
  }

  Future<void> _selectEndDate(BuildContext context) async {
    CalendarBottomSheet(
      context: context,
      label: "Select End Date",
      initialDate: endDate.value ?? DateTime.now(),
      onDateSelected: (date) {
        endDate.value = date;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ValueListenableBuilder(
                valueListenable: startDate,
                builder: (context, date, child) {
                  return CustomButton(
                    btnColor: Colors.transparent,
                    text: date != null
                        ? '${date.day}/${date.month}/${date.year}'
                        : 'Start Date',
                    onClick: () => _selectStartDate(context),
                  );
                },
              ),
              ValueListenableBuilder(
                valueListenable: endDate,
                builder: (context, date, child) {
                  return CustomButton(
                    btnColor: Colors.transparent,
                    text: date != null
                        ? '${date.day}/${date.month}/${date.year}'
                        : 'End Date',
                    onClick: () => _selectEndDate(context),
                  );
                },
              ),
              CustomButton(
                btnColor: Colors.transparent,
                text: "Submit",
                onClick: () => fetchData(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> fetchData(BuildContext context) async {
    if (startDate.value == null || endDate.value == null) {
      _showSnackbar(context, 'Please select both start and end dates');
      return;
    }

    if (startDate.value!.isAfter(endDate.value!)) {
      _showSnackbar(context, 'Start date must be before or equal to end date');
      return;
    }

    isLoading(true);
    try {
      DailyConsumptionModel? dailyConsumption =
          await UtilizationDB().unitConsumed(
        startDate.value.toString(),
        endDate.value.toString(),
        deviceId,
      );
      if (dailyConsumption == null) {
        onError(true);
      } else {
        onDateChange(dailyConsumption, startDate.value!, endDate.value!);
      }
    } catch (e) {
      onError(true);
      _showSnackbar(context, 'Error fetching data: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }
}

void _showSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
