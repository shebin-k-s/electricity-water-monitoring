import 'package:flutter/material.dart';
import 'package:saron/Screens/usage_screen/widgets/usage_card/usage_card.dart';
import 'package:saron/api/data/utilization.dart';
import 'package:saron/api/utilization_model/utilization_model.dart';
import 'package:intl/intl.dart';

class UtilizationList extends StatelessWidget {
  final ValueNotifier<List<UtilizationModel>> utilizationList =
      ValueNotifier([]);
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  final DateTime date;
  final int deviceId;
  final double totalUnits;

  UtilizationList({
    Key? key,
    required this.date,
    required this.deviceId,
    required this.totalUnits,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMMM d, yyyy').format(date);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadData();
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: ValueListenableBuilder(
        valueListenable: _isLoading,
        builder: (context, bool isLoading, child) {
          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(formattedDate),
              if (isLoading)
                const SliverFillRemaining(
                  child: Center(
                      child:
                          CircularProgressIndicator(color: Colors.tealAccent)),
                )
              else if (utilizationList.value.isEmpty)
                _buildEmptyState()
              else
                _buildUtilizationList(),
            ],
          );
        },
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(String formattedDate) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: Colors.black,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            color: Colors.black,
          ),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[800]!),
          ),
          child: Text(
            formattedDate,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  SliverList _buildUtilizationList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == 0) {
            return _buildSummaryCard();
          }
          final utilization = utilizationList.value[index - 1];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: UsageCard(
              deviceName: utilization.deviceName!,
              startTime: getTime(utilization.startDate!),
              endTime: getTime(utilization.endDate!),
              unitConsumed: utilization.unitConsumed!.toString(),
              duration: timeUsed(utilization.startDate!, utilization.endDate!),
            ),
          );
        },
        childCount: utilizationList.value.length + 1,
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Summary',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Total Units Consumed: ${totalUnits} units',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            Text(
              'Number of Usages: ${utilizationList.value.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverFillRemaining _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/no_data.png',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 16),
            const Text(
              "Excellent! Today's usage is nil,\nsaving energy effectively.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadData() async {
    utilizationList.value.clear();
    _isLoading.value = true;
    final data = await UtilizationDB().history(
      date.toString(),
      date.toString(),
      deviceId,
    );

    if (data.statusCode == 200) {
      utilizationList.value = data.utilization;
    }
    _isLoading.value = false;
  }

  String getTime(String date) {
    DateTime statTime = DateTime.parse(date);
    String formattedTime = DateFormat('h:mm:ss a').format(statTime);
    return formattedTime;
  }

  String timeUsed(String startTimeString, String endTimeString) {
    DateTime startTime = DateTime.parse(startTimeString);
    DateTime endTime = DateTime.parse(endTimeString);

    Duration difference = endTime.difference(startTime);

    int hours = difference.inHours;
    int minutes = difference.inMinutes.remainder(60);
    int seconds = difference.inSeconds.remainder(60);

    String formattedTime = '';

    if (hours > 0) {
      formattedTime += '${hours} hours';
    }

    if (minutes > 0) {
      if (formattedTime.isNotEmpty) {
        formattedTime += ', ';
      }
      formattedTime += '${minutes} minutes';
    }

    if (seconds > 0) {
      if (formattedTime.isNotEmpty) {
        formattedTime += ', ';
      }
      formattedTime += '${seconds} seconds';
    }

    return formattedTime;
  }
}
