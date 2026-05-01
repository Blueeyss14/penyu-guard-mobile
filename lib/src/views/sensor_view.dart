import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyu_guard/src/controller/sensor_controller.dart';
import 'package:penyu_guard/src/res/custom_color.dart';
import 'package:penyu_guard/src/views/history_view.dart';

_TurbidityInfo _turbidityInfo(double ntu) {
  if (ntu <= 25) {
    return _TurbidityInfo(
      'Clear',
      'Kondisi air jernih',
      CustomColors.primary,
      ntu / 25,
    );
  }
  if (ntu <= 100) {
    return _TurbidityInfo(
      'Cloudy',
      'Air mulai keruh',
      CustomColors.warning,
      ntu / 100,
    );
  }
  return _TurbidityInfo('Turbid', 'Air sangat keruh', CustomColors.danger, 1.0);
}

_PhInfo _phInfo(double ph) {
  if (ph < 6.5) {
    return _PhInfo(
      'Acidic',
      'Kondisi air asam',
      CustomColors.danger,
      (ph / 14).clamp(0, 1),
    );
  }
  if (ph <= 7.5) {
    return _PhInfo(
      'Neutral',
      'Kondisi pH normal',
      CustomColors.primary,
      (ph / 14).clamp(0, 1),
    );
  }
  return _PhInfo(
    'Alkaline',
    'Kondisi air basa',
    CustomColors.warning,
    (ph / 14).clamp(0, 1),
  );
}

class _TurbidityInfo {
  final String label, desc;
  final Color color;
  final double progress;
  _TurbidityInfo(this.label, this.desc, this.color, this.progress);
}

class _PhInfo {
  final String label, desc;
  final Color color;
  final double progress;
  _PhInfo(this.label, this.desc, this.color, this.progress);
}

class SensorView extends StatelessWidget {
  const SensorView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(SensorController());

    return Scaffold(
      backgroundColor: CustomColors.background,
      body: SafeArea(
        child: Obx(() {
          final turbInfo = _turbidityInfo(ctrl.turbidity.value);
          final phInfo = _phInfo(ctrl.ph.value);

          return RefreshIndicator(
            color: CustomColors.primary,
            onRefresh: ctrl.fetchData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(
                    isConnected: ctrl.isConnected.value,
                    isLoading: ctrl.isLoading.value,
                  ),
                  const SizedBox(height: 28),
                  _SensorCard(
                    title: 'Turbidity (NTU)',
                    value: ctrl.isConnected.value
                        ? ctrl.turbidity.value.toStringAsFixed(2)
                        : '--',
                    statusLabel: ctrl.isConnected.value ? turbInfo.label : '-',
                    statusDesc: ctrl.isConnected.value
                        ? turbInfo.desc
                        : 'Menunggu data...',
                    statusColor: ctrl.isConnected.value
                        ? turbInfo.color
                        : CustomColors.grey,
                    progress: ctrl.isConnected.value ? turbInfo.progress : 0,
                    progressColor: ctrl.isConnected.value
                        ? turbInfo.color
                        : CustomColors.grey,
                    icon: const Icon(
                      Icons.water_drop_outlined,
                      size: 28,
                      color: CustomColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SensorCard(
                    title: 'pH Level',
                    value: ctrl.isConnected.value
                        ? ctrl.ph.value.toStringAsFixed(2)
                        : '--',
                    statusLabel: ctrl.isConnected.value ? phInfo.label : '-',
                    statusDesc: ctrl.isConnected.value
                        ? phInfo.desc
                        : 'Menunggu data...',
                    statusColor: ctrl.isConnected.value
                        ? phInfo.color
                        : CustomColors.grey,
                    progress: ctrl.isConnected.value ? phInfo.progress : 0,
                    progressColor: ctrl.isConnected.value
                        ? phInfo.color
                        : CustomColors.grey,
                    icon: const Icon(
                      Icons.science_outlined,
                      size: 28,
                      color: CustomColors.primary,
                    ),
                  ),
                  if (ctrl.errorMessage.value.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _ErrorBanner(message: ctrl.errorMessage.value),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(() => const HistoryView());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Lihat History Mingguan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // if (ctrl.lastUpdated.value.isNotEmpty) ...[
                  //   const SizedBox(height: 16),
                  //   Center(
                  //     child: Text(
                  //       'Update terakhir: ${ctrl.lastUpdated.value}',
                  //       style: const TextStyle(
                  //         color: CustomColors.grey,
                  //         fontSize: 12,
                  //       ),
                  //     ),
                  //   ),
                  // ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool isConnected;
  final bool isLoading;
  const _Header({required this.isConnected, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'PenyuGuard',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: CustomColors.navy,
            letterSpacing: -0.5,
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isConnected
                ? CustomColors.primaryLight
                : CustomColors.dangerLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isConnected
                  ? CustomColors.primary.withOpacity(0.3)
                  : CustomColors.danger.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              isLoading
                  ? SizedBox(
                      width: 8,
                      height: 8,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: isConnected
                            ? CustomColors.primary
                            : CustomColors.danger,
                      ),
                    )
                  : Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isConnected
                            ? CustomColors.primary
                            : CustomColors.danger,
                        shape: BoxShape.circle,
                      ),
                    ),
              const SizedBox(width: 6),
              Text(
                isConnected ? 'Connected' : 'Disconnected',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isConnected
                      ? CustomColors.primary
                      : CustomColors.danger,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SensorCard extends StatelessWidget {
  final String title, value, statusLabel, statusDesc;
  final Color statusColor, progressColor;
  final double progress;
  final Widget icon;

  const _SensorCard({
    required this.title,
    required this.value,
    required this.statusLabel,
    required this.statusDesc,
    required this.statusColor,
    required this.progress,
    required this.progressColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: CustomColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: CustomColors.navy.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: CustomColors.grey,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: CustomColors.navy,
                    height: 1,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  statusDesc,
                  style: const TextStyle(
                    fontSize: 13,
                    color: CustomColors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          _CircularGauge(progress: progress, color: progressColor, child: icon),
        ],
      ),
    );
  }
}

class _CircularGauge extends StatelessWidget {
  final double progress;
  final Color color;
  final Widget child;
  const _CircularGauge({
    required this.progress,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: CustomPaint(
        painter: _GaugePainter(progress: progress, color: color),
        child: Center(child: child),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final Color color;
  _GaugePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 6;
    const strokeWidth = 6.0;
    const startAngle = pi * 0.75;
    const sweepFull = pi * 1.5;

    final trackPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepFull,
      false,
      trackPaint,
    );

    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepFull * progress.clamp(0.0, 1.0),
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.progress != progress || old.color != color;
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: CustomColors.dangerLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CustomColors.danger.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded, color: CustomColors.danger, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: CustomColors.danger, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
