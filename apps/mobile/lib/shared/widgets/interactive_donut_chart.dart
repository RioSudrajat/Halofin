import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';

class ChartData {
  final String label;
  final double value;
  final Color color;

  ChartData(this.label, this.value, this.color);
}

class InteractiveDonutChart extends StatefulWidget {
  final List<ChartData> data;
  final String centerTitle;
  final String centerAmount;

  const InteractiveDonutChart({
    super.key,
    required this.data,
    required this.centerTitle,
    required this.centerAmount,
  });

  @override
  State<InteractiveDonutChart> createState() => _InteractiveDonutChartState();
}

class _InteractiveDonutChartState extends State<InteractiveDonutChart> {
  int _touchedIndex = -1;
  double _rotationAngle = -math.pi / 2; // Start from -90 degrees equivalent



  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {

        return GestureDetector(
          onPanStart: (details) {
            // Can initialize drag state here if needed
          },
          onPanUpdate: (details) {
            // This is simplified. For true rotation drag, we need delta.
            // But a simple drag distance multiplier works fine for aesthetic swipe
            setState(() {
              _rotationAngle += details.delta.dx * 0.01 + details.delta.dy * 0.01;
            });
          },
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Shadow for 3D effect
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      spreadRadius: 5,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
              ),
              Transform.rotate(
                angle: _rotationAngle,
                child: SizedBox(
                  height: 250,
                  width: 250,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              _touchedIndex = -1;
                              return;
                            }
                            _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      startDegreeOffset: 0,
                      sectionsSpace: 2,
                      centerSpaceRadius: 50,
                      sections: widget.data.asMap().entries.map((entry) {
                        final i = entry.key;
                        final data = entry.value;
                        final isTouched = i == _touchedIndex;
                        final radius = isTouched ? 45.0 : 35.0; // Pop-out effect

                        return PieChartSectionData(
                          color: data.color,
                          value: data.value,
                          title: '', // We use badge instead
                          radius: radius,
                          badgeWidget: Transform.rotate(
                            angle: -_rotationAngle, // counter-rotate badges to stay upright
                            child: _buildBadge(data.label, isTouched),
                          ),
                          badgePositionPercentageOffset: 1.4, // Push outside
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              // Center Text Plate
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.centerTitle, style: textTheme.labelSmall?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 10)),
                    const SizedBox(height: 2),
                    Text(widget.centerAmount, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadge(String label, bool isTouched) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: isTouched ? 1.5 : 0.5),
        boxShadow: [
          if (isTouched)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade400, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }
}
