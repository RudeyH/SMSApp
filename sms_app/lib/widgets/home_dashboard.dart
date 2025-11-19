import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart'; // optional for mini chart preview

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final textColor = isDark ? Colors.white70 : Colors.grey[800];

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [Colors.black, Colors.grey[900]!]
                : [Colors.blueGrey[50]!, Colors.white],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo circle
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    // color: primary.withOpacity(0.1),
                    color: primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Icon(
                    Icons.inventory_2_rounded,
                    size: 64,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  "Stock Management System (SMS)",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  "Product Stock Control & Business Profit Monitoring",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    // color: textColor!.withOpacity(0.8),
                    color: textColor!.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // Decorative divider
                Container(
                  width: 120,
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      // colors: [primary, primary.withOpacity(0.4)],
                      colors: [primary, primary.withValues(alpha: 0.4)],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),

                // Mini trend chart (visual touch)
                Container(
                  height: 140,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    // color: primary.withOpacity(0.05),
                    color: primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: LineChart(
                    LineChartData(
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          color: primary,
                          spots: const [
                            FlSpot(0, 3),
                            FlSpot(1, 3.8),
                            FlSpot(2, 3.2),
                            FlSpot(3, 4.5),
                            FlSpot(4, 4.2),
                            FlSpot(5, 5),
                          ],
                          belowBarData: BarAreaData(
                            show: true,
                            // color: primary.withOpacity(0.2),
                            color: primary.withValues(alpha: 0.2),
                          ),
                          dotData: FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Developer signature
                Text(
                  "Developed by: RAZ & Team",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    // color: textColor.withOpacity(0.7),
                    color: textColor.withValues(alpha: 0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                // const SizedBox(height: 30),
                //
                // // Start button
                // ElevatedButton.icon(
                //   onPressed: () {},
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: primary,
                //     padding:
                //     const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //     elevation: 4,
                //   ),
                //   icon: const Icon(Icons.play_arrow_rounded, size: 22),
                //   label: Text(
                //     "Let’s Get Started",
                //     style: GoogleFonts.poppins(
                //       fontSize: 16,
                //       fontWeight: FontWeight.w500,
                //       color: Colors.white,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
