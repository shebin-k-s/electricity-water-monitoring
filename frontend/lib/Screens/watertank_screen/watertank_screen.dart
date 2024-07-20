import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:saron/api/device_model/device.dart';
import 'package:saron/api/load_data/load_devices.dart';
import 'package:saron/socket/socket.dart';
import 'dart:math' as math;

import 'package:saron/widgets/custom_button/custom_button.dart';

class WaterTankScreen extends StatelessWidget {
  WaterTankScreen({super.key, required this.socketManager});

  final SocketManager socketManager;

  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<int> _selectedDeviceIndex = ValueNotifier(0);
  final ValueNotifier<List<Device>> deviceList = ValueNotifier([]);

  void listenTankStatus() async {
    socketManager.setTankStatusListener((data) async {
      final String currentDeviceListJson = jsonEncode(deviceList.value);
      List<Device> newDeviceList = await loadDeviceList();
      String newDeviceListJson = jsonEncode(newDeviceList);
      int i = 0;
      while (currentDeviceListJson == newDeviceListJson && i <= 10) {
        await Future.delayed(const Duration(seconds: 1));

        newDeviceList = await loadDeviceList();
        newDeviceListJson = jsonEncode(newDeviceList);
        i++;
      }
      isLoading.value = true;
      deviceList.value = newDeviceList;
      isLoading.value = false;
    });
  }

  Future<void> loadDevices() async {
    isLoading.value = true;
    deviceList.value = await loadDeviceList();
    isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        await loadDevices();
        listenTankStatus();
      },
    );

    return RefreshIndicator(
      onRefresh: () => loadDevices(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: ValueListenableBuilder(
              valueListenable: isLoading,
              builder: (context, loading, child) {
                if (loading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (deviceList.value.isEmpty) {
                  return const Center(
                    child: Text(
                      'No devices found. Please add a device.',
                      style: TextStyle(fontSize: 18, color: Colors.red),
                    ),
                  );
                } else {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 50,
                        child: ValueListenableBuilder(
                          valueListenable: deviceList,
                          builder: (context, devices, child) {
                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: devices.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: ValueListenableBuilder(
                                    valueListenable: _selectedDeviceIndex,
                                    builder: (context, selectedIndex, child) {
                                      return CustomButton(
                                        btnColor: selectedIndex == index
                                            ? const Color.fromRGBO(
                                                27, 94, 32, 1)
                                            : Colors.transparent,
                                        text: devices[index]
                                            .deviceName!
                                            .toUpperCase(),
                                        onClick: () {
                                          _selectedDeviceIndex.value = index;
                                        },
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 32.0,
                            right: 32,
                            top: 16,
                          ),
                          child: ValueListenableBuilder(
                            valueListenable: _selectedDeviceIndex,
                            builder: (context, selectedIndex, child) {
                              final selectedDevice =
                                  deviceList.value[selectedIndex];

                              double upperTankLevel = selectedDevice.tankHigh
                                  ? 1.0
                                  : (selectedDevice.tankLow ? 0.5 : 0.0);
                              double lowerTankLevel = selectedDevice.storageHigh
                                  ? 1.0
                                  : (selectedDevice.storageLow ? 0.5 : 0.0);

                              return Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  WaterTankWidget(
                                    label:
                                        'Upper Tank of ${selectedDevice.deviceName}',
                                    initialLevel: upperTankLevel,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      WaterTankWidget(
                                        label:
                                            'Lower Tank of ${selectedDevice.deviceName}',
                                        initialLevel: lowerTankLevel,
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

class WaterTankWidget extends StatefulWidget {
  final String label;
  final double initialLevel;

  const WaterTankWidget(
      {super.key, required this.label, required this.initialLevel});

  @override
  _WaterTankWidgetState createState() => _WaterTankWidgetState();
}

class _WaterTankWidgetState extends State<WaterTankWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _fillAnimationController;
  late Animation<double> _fillAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _fillAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fillAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(
          parent: _fillAnimationController, curve: Curves.easeInOut),
    );

    _updateFillAnimation();
  }

  void _updateFillAnimation() {
    _fillAnimation =
        Tween<double>(begin: _fillAnimation.value, end: widget.initialLevel)
            .animate(
      CurvedAnimation(
          parent: _fillAnimationController, curve: Curves.easeInOut),
    );
    _fillAnimationController
      ..reset()
      ..forward();
  }

  @override
  void didUpdateWidget(WaterTankWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialLevel != widget.initialLevel) {
      _updateFillAnimation();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fillAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        AnimatedBuilder(
          animation: Listenable.merge(
              [_animationController, _fillAnimationController]),
          builder: (context, child) {
            return CustomPaint(
              size: const Size(200, 200),
              painter: TankPainter(
                level: _fillAnimation.value,
                animation: _animationController.value,
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        AnimatedBuilder(
          animation: _fillAnimationController,
          builder: (context, child) {
            return Text(
              '${(_fillAnimation.value * 100).toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 16),
            );
          },
        ),
      ],
    );
  }
}

class TankPainter extends CustomPainter {
  final double level;
  final double animation;

  TankPainter({required this.level, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final double borderWidth = 4.0;
    final double cornerRadius = 20.0;

    // Draw tank background
    final bgPaint = Paint()
      ..color = Colors.grey[100]!
      ..style = PaintingStyle.fill;

    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(borderWidth / 2, borderWidth / 2, size.width - borderWidth,
          size.height - borderWidth),
      Radius.circular(cornerRadius),
    );
    canvas.drawRRect(bgRect, bgPaint);

    // Calculate water height
    final waterHeight = (size.height - 2 * borderWidth) * level;
    final waterTop = size.height - waterHeight - borderWidth;

    // Create clip for water
    final clipPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(borderWidth, borderWidth, size.width - 2 * borderWidth,
            size.height - 2 * borderWidth),
        Radius.circular(cornerRadius - borderWidth / 2),
      ));

    canvas.save();
    canvas.clipPath(clipPath);

    // Draw water
    final waterPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.blue[300]!, Colors.blue[700]!],
        stops: [0.0, 1.0],
      ).createShader(Rect.fromLTWH(0, waterTop, size.width, waterHeight));

    final waterPath = Path();
    waterPath.moveTo(0, size.height);

    // Create continuous floating effect
    final waveHeight = 4.0;
    final waveCount = 2;
    for (var i = 0; i <= size.width + 10; i++) {
      final x = i.toDouble();
      final normalizedX = x / size.width;
      final y = waterTop +
          math.sin((normalizedX * waveCount + animation) * 2 * math.pi) *
              waveHeight;
      waterPath.lineTo(x, y);
    }

    waterPath.lineTo(size.width, size.height);
    waterPath.close();

    canvas.drawPath(waterPath, waterPaint);

    // Draw bubbles
    drawBubbles(canvas, size, waterTop, waterHeight);

    // Draw subtle water surface shine
    final shinePaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawPath(waterPath, shinePaint);

    canvas.restore();

    // Draw tank border
    final borderPaint = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawRRect(bgRect, borderPaint);
  }

  void drawBubbles(
      Canvas canvas, Size size, double waterTop, double waterHeight) {
    final random = math.Random(animation.toInt());

    for (var i = 0; i < 10; i++) {
      final bubbleX = random.nextDouble() * size.width;
      final bubbleY = waterTop + random.nextDouble() * waterHeight;
      final bubbleRadius = random.nextDouble() * 2 + 0.5;

      final bubbleGradient = RadialGradient(
        center: const Alignment(-0.5, -0.5),
        radius: 0.9,
        colors: [Colors.white.withOpacity(0.8), Colors.white.withOpacity(0.1)],
      );

      final bubblePaint = Paint()
        ..shader = bubbleGradient.createShader(Rect.fromCircle(
            center: Offset(bubbleX, bubbleY), radius: bubbleRadius));

      canvas.drawCircle(Offset(bubbleX, bubbleY), bubbleRadius, bubblePaint);
    }
  }

  @override
  bool shouldRepaint(covariant TankPainter oldDelegate) {
    return oldDelegate.level != level || oldDelegate.animation != animation;
  }
}
