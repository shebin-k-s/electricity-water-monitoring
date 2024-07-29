import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:saron/api/daily_consumption_model/daily_consumption_model.dart';
import 'package:saron/api/get_all_utilization/get_all_utilization.dart';
import 'package:saron/api/url/url.dart';
import 'package:saron/api/utilization_model/utilization_model.dart';
import 'package:saron/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UtilizationResult {
  final List<UtilizationModel> utilization;
  final int statusCode;

  UtilizationResult(this.utilization, this.statusCode);
}

abstract class ApiCalls {
  Future<UtilizationResult> history(
      String startDate, String endDate, int deviceId);
  Future<DailyConsumptionModel?> unitConsumed(
      String startDate, String endDate, int deviceId);
}

class UtilizationDB extends ApiCalls {
  final Dio dio = Dio();
  final Url url = Url();
  late SharedPreferences _sharedPref;
  late String _token;
  bool _initialized = false;

  UtilizationDB() {
    _initialize();
  }

  Future<void> _initialize() async {
    _sharedPref = await SharedPreferences.getInstance();
    _token = _sharedPref.getString(TOKEN) ?? '';
    dio.options = BaseOptions(
      baseUrl: url.baseUrl,
      responseType: ResponseType.plain,
      headers: {
        "authorization": _token,
      },
    );
    _initialized = true;
  }

  @override
  Future<UtilizationResult> history(
      String startDate, String endDate, int deviceId) async {
    if (!_initialized) {
      await _initialize();
    }
    try {
      final result = await dio.get(
          '${url.fetchUtilization}?startDate=$startDate&endDate=$endDate&deviceId=$deviceId');

      if (result.data != null) {
        final resultAsJson = jsonDecode(result.data);
        final getUtilization = GetAllUtilization.fromJson(resultAsJson);
        return UtilizationResult(
            getUtilization.utilization, result.statusCode!);
      } else {
        return UtilizationResult([], result.statusCode!);
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        return UtilizationResult([], e.response!.statusCode!);
      } else {
        return UtilizationResult([], -1);
      }
    }
  }

  @override
  Future<DailyConsumptionModel?> unitConsumed(
      String startDate, String endDate, int deviceId) async {
    if (!_initialized) {
      await _initialize();
    }
    try {
      final result = await dio.get(
          '${url.fetchUnitConsumed}?startDate=$startDate&endDate=$endDate&deviceId=$deviceId');

      if (result.data != null) {
        final resultAsJson = jsonDecode(result.data);
        final dailyConsumption = DailyConsumptionModel.fromJson(resultAsJson);

        return dailyConsumption;
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        rethrow;
      }
    }
    return null;
  }
}
