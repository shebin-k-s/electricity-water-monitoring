// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_consumption.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyConsumption _$DailyConsumptionFromJson(Map<String, dynamic> json) =>
    DailyConsumption(
      date: DateTime.parse(json['date'] as String),
      unitConsumed: (json['unitConsumed'] as num).toDouble(),
    );

Map<String, dynamic> _$DailyConsumptionToJson(DailyConsumption instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'unitConsumed': instance.unitConsumed,
    };
