import 'package:json_annotation/json_annotation.dart';

part 'daily_consumption.g.dart';

@JsonSerializable()
class DailyConsumption {
  DateTime date;
  double unitConsumed;

  DailyConsumption({required this.date, required this.unitConsumed});

  factory DailyConsumption.fromJson(Map<String, dynamic> json) {
    return _$DailyConsumptionFromJson(json);
  }

  Map<String, dynamic> toJson() => _$DailyConsumptionToJson(this);
}
