import 'package:flutter/material.dart';
import 'package:css_mastery_app/core/constants/app_colors.dart';

class PieChart extends StatelessWidget {
  final List<PieChartData> data;
  final String title;
  final double size;

  const PieChart({
    super.key,
    required this.data,
    required this.title,
    this.size = 150,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = data.fold(0.0, (sum, item) => sum + item.value);

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
            Row(
              children: [
                // Pie Chart
                SizedBox(
                  width: size,
                  height: size,
                  child: CustomPaint(
                    painter: PieChartPainter(data, total),
                  ),
                ),
                const SizedBox(width: 16),
                // Legend
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: data.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: item.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.white
                                      : AppColors.nearBlack,
                                ),
                              ),
                            ),
                            Text(
                              '${((item.value / total) * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: item.color,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PieChartData {
  final String label;
  final double value;
  final Color color;

  PieChartData({
    required this.label,
    required this.value,
    required this.color,
  });
}

class PieChartPainter extends CustomPainter {
  final List<PieChartData> data;
  final double total;

  PieChartPainter(this.data, this.total);

  @override
  void paint(Canvas canvas, Size size) {
    double startAngle = -90 * 3.14159 / 180;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    for (var item in data) {
      final sweepAngle = (item.value / total) * 2 * 3.14159;
      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.fill;

      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
