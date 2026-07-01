import 'package:flutter/material.dart';
import 'package:css_mastery_app/core/constants/app_colors.dart';

class BarChart extends StatelessWidget {
  final List<BarChartData> data;
  final String title;
  final double height;
  final Color? barColor;
  final bool showValues;

  const BarChart({
    super.key,
    required this.data,
    required this.title,
    this.height = 200,
    this.barColor,
    this.showValues = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maxValue = data.isEmpty
        ? 1
        : data.map((d) => d.value).reduce((a, b) => a > b ? a : b);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: height,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: data.map((item) {
                  final percentage = maxValue > 0 ? item.value / maxValue : 0;
                  final color = barColor ?? item.color ?? AppColors.primaryBlue;

                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (showValues)
                          Text(
                            item.value.toString(),
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark
                                  ? AppColors.mediumGray
                                  : AppColors.darkGray,
                            ),
                          ),
                        const SizedBox(height: 2),
                        Container(
                          height: percentage * (height - 30),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                color,
                                color.withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                          width: 20,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark
                                ? AppColors.mediumGray
                                : AppColors.darkGray,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BarChartData {
  final String label;
  final double value;
  final Color? color;

  BarChartData({
    required this.label,
    required this.value,
    this.color,
  });
}
