// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_consumption_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyConsumptionModel _$DailyConsumptionModelFromJson(
        Map<String, dynamic> json) =>
    DailyConsumptionModel(
      dailyConsumption: (json['dailyConsumption'] as List<dynamic>?)
          ?.map((e) => DailyConsumption.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalUnitConsumed: (json['totalUnitConsumed'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$DailyConsumptionModelToJson(
        DailyConsumptionModel instance) =>
    <String, dynamic>{
      'dailyConsumption': instance.dailyConsumption,
      'totalUnitConsumed': instance.totalUnitConsumed,
    };
