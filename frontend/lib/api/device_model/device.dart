import 'package:json_annotation/json_annotation.dart';

part 'device.g.dart';

@JsonSerializable()
class Device {
  @JsonKey(name: 'deviceId')
  int deviceId;

  @JsonKey(name: 'serialNumber')
  String serialNumber;

  @JsonKey(name: 'deviceOn')
  bool deviceOn;

  @JsonKey(name: 'deviceName')
  String deviceName;

  bool tankHigh;
  bool tankLow;
  bool storageHigh;
  bool storageLow;

  Device({
    required this.deviceId,
    required this.serialNumber,
    required this.deviceOn,
    required this.deviceName,
    required this.tankHigh,
    required this.storageHigh,
    required this.tankLow,
    required this.storageLow,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return _$DeviceFromJson(json);
  }

  Map<String, dynamic> toJson() => _$DeviceToJson(this);
}
