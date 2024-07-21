import 'package:flutter/material.dart';
import 'package:saron/Screens/home_screen/widget/CalenderBottomSheet.dart';
import 'package:saron/api/data/utilization.dart';
import 'package:saron/widgets/custom_button/custom_button.dart';
import 'package:saron/widgets/snackbar_message/snackbar_message.dart';

class CalendarPicker extends StatelessWidget {
  final Function(double, DateTime, DateTime) onDateChange;
  final Function(bool) isLoading;
  final Function(bool) onError;
  final int deviceId;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  final ValueNotifier<DateTime?> startDate;
  final ValueNotifier<DateTime?> endDate;

  CalendarPicker({
    super.key,
    required this.onDateChange,
    required this.isLoading,
    required this.deviceId,
    required this.onError,
    required this.initialStartDate,
    required this.initialEndDate,
  })  : startDate = ValueNotifier<DateTime?>(initialStartDate),
        endDate = ValueNotifier<DateTime?>(initialEndDate);

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

  void fetchData(BuildContext ctx) async {
    if (startDate.value != null &&
        endDate.value != null &&
        (startDate.value!.isBefore(endDate.value!) ||
            startDate.value!.isAtSameMomentAs(endDate.value!))) {
      isLoading(true);
      UtilizationDB utilizationDB = UtilizationDB();
      try {
        double unitConsumed = await utilizationDB.unitConsumed(
            startDate.value.toString(), endDate.value.toString(), deviceId);

        if (unitConsumed < 0) {
          onError(true);
        } else {
          onDateChange(unitConsumed, startDate.value!, endDate.value!);
        }
      } catch (e) {
        onError(true);
      } finally {
        isLoading(false);
      }
    } else {
      snackbarMessage(ctx, 'Select Proper Date');
    }
  }
}
