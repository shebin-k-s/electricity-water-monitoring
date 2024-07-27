import 'package:json_annotation/json_annotation.dart';

import 'daily_consumption.dart';

part 'daily_consumption_model.g.dart';

@JsonSerializable()
class DailyConsumptionModel {
  List<DailyConsumption>? dailyConsumption;
  double? totalUnitConsumed;

  DailyConsumptionModel({this.dailyConsumption, this.totalUnitConsumed});

  factory DailyConsumptionModel.fromJson(Map<String, dynamic> json) {
    return _$DailyConsumptionModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$DailyConsumptionModelToJson(this);
}
