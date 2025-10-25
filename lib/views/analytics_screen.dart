// analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:uee_project/controllers/report_controller.dart';
import 'package:uee_project/models/report_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final ReportController _reportController = Get.find();
  bool _isGeneratingPdf = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Analytics Dashboard',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: colorScheme.primary,
          ),
        ),
        backgroundColor: isDark ? Colors.grey[800] : Colors.white,
        elevation: 0,
        actions: [
          _isGeneratingPdf
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  onPressed: _generatePdfReport,
                  icon: Icon(Icons.download_rounded, color: colorScheme.primary),
                  tooltip: 'Download PDF Report',
                ),
        ],
      ),
      body: StreamBuilder<List<ReportModel>>(
        stream: _reportController.getAllReports(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorState();
          }

          final reports = snapshot.data ?? [];

          if (reports.isEmpty) {
            return _buildEmptyState();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Statistics
                _buildSummaryCards(reports, isDark, colorScheme),

                const SizedBox(height: 24),

                // Status Distribution - Pie Chart
                _buildStatusDistribution(reports, isDark),

                const SizedBox(height: 24),

                // Category Distribution - Bar Chart
                _buildCategoryDistribution(reports, isDark),

                const SizedBox(height: 24),

                // Priority Distribution - Doughnut Chart
                _buildPriorityDistribution(reports, isDark),

                const SizedBox(height: 24),

                // Reports Timeline - Column Chart
                _buildReportsTimeline(reports, isDark),

                const SizedBox(height: 24),

                // Response Time Analytics
                _buildResponseTimeAnalytics(reports, isDark),

                const SizedBox(height: 24),

                // Top Categories Table
                _buildTopCategoriesTable(reports, isDark),

                const SizedBox(height: 24),

                // Location Analytics
                _buildLocationAnalytics(reports, isDark),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(
    List<ReportModel> reports,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    final totalReports = reports.length;
    final pendingReports = reports.where((r) => r.status == 'pending').length;
    final inProgressReports = reports
        .where((r) => r.status == 'in_progress')
        .length;
    final resolvedReports = reports.where((r) => r.status == 'resolved').length;
    final urgentReports = reports.where((r) => r.priority == 'urgent').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              'Total Reports',
              totalReports.toString(),
              Icons.assignment,
              Colors.blue,
              isDark,
            ),
            _buildStatCard(
              'Pending',
              pendingReports.toString(),
              Icons.pending_actions,
              Colors.orange,
              isDark,
            ),
            _buildStatCard(
              'In Progress',
              inProgressReports.toString(),
              Icons.build,
              Colors.purple,
              isDark,
            ),
            _buildStatCard(
              'Resolved',
              resolvedReports.toString(),
              Icons.check_circle,
              Colors.green,
              isDark,
            ),
            _buildStatCard(
              'Urgent',
              urgentReports.toString(),
              Icons.warning,
              Colors.red,
              isDark,
            ),
            _buildStatCard(
              'Resolution Rate',
              '${totalReports > 0 ? ((resolvedReports / totalReports) * 100).toStringAsFixed(1) : 0}%',
              Icons.trending_up,
              Colors.teal,
              isDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDistribution(List<ReportModel> reports, bool isDark) {
    final statusData = _calculateStatusDistribution(reports);

    return _buildChartCard(
      'Status Distribution',
      isDark,
      SfCircularChart(
        legend: Legend(
          isVisible: true,
          position: LegendPosition.bottom,
          overflowMode: LegendItemOverflowMode.wrap,
          textStyle: GoogleFonts.poppins(
            fontSize: 12,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        series: <CircularSeries>[
          PieSeries<_ChartData, String>(
            dataSource: statusData,
            xValueMapper: (_ChartData data, _) => data.category,
            yValueMapper: (_ChartData data, _) => data.value,
            pointColorMapper: (_ChartData data, _) => data.color,
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              labelPosition: ChartDataLabelPosition.outside,
              textStyle: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            explode: true,
            explodeIndex: 0,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDistribution(List<ReportModel> reports, bool isDark) {
    final categoryData = _calculateCategoryDistribution(reports);

    return _buildChartCard(
      'Category Distribution',
      isDark,
      SfCartesianChart(
        primaryXAxis: CategoryAxis(
          labelStyle: GoogleFonts.poppins(
            fontSize: 10,
            color: isDark ? Colors.white : Colors.black87,
          ),
          labelRotation: -45,
        ),
        primaryYAxis: NumericAxis(
          labelStyle: GoogleFonts.poppins(
            fontSize: 10,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        series: <CartesianSeries>[
          ColumnSeries<_ChartData, String>(
            dataSource: categoryData,
            xValueMapper: (_ChartData data, _) => data.category,
            yValueMapper: (_ChartData data, _) => data.value,
            pointColorMapper: (_ChartData data, _) => data.color,
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              textStyle: GoogleFonts.poppins(fontSize: 10),
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityDistribution(List<ReportModel> reports, bool isDark) {
    final priorityData = _calculatePriorityDistribution(reports);

    return _buildChartCard(
      'Priority Distribution',
      isDark,
      SfCircularChart(
        legend: Legend(
          isVisible: true,
          position: LegendPosition.bottom,
          textStyle: GoogleFonts.poppins(
            fontSize: 12,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        series: <CircularSeries>[
          DoughnutSeries<_ChartData, String>(
            dataSource: priorityData,
            xValueMapper: (_ChartData data, _) => data.category,
            yValueMapper: (_ChartData data, _) => data.value,
            pointColorMapper: (_ChartData data, _) => data.color,
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              labelPosition: ChartDataLabelPosition.outside,
              textStyle: GoogleFonts.poppins(fontSize: 11),
            ),
            innerRadius: '60%',
          ),
        ],
      ),
    );
  }

  Widget _buildReportsTimeline(List<ReportModel> reports, bool isDark) {
    final timelineData = _calculateTimelineData(reports);

    return _buildChartCard(
      'Reports Timeline (Last 7 Days)',
      isDark,
      SfCartesianChart(
        primaryXAxis: CategoryAxis(
          labelStyle: GoogleFonts.poppins(
            fontSize: 10,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        primaryYAxis: NumericAxis(
          labelStyle: GoogleFonts.poppins(
            fontSize: 10,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        series: <CartesianSeries>[
          SplineSeries<_ChartData, String>(
            dataSource: timelineData,
            xValueMapper: (_ChartData data, _) => data.category,
            yValueMapper: (_ChartData data, _) => data.value,
            color: Colors.blue,
            markerSettings: const MarkerSettings(isVisible: true),
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              textStyle: GoogleFonts.poppins(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseTimeAnalytics(List<ReportModel> reports, bool isDark) {
    final resolvedReports = reports
        .where((r) => r.status == 'resolved')
        .toList();
    final avgResponseTime = _calculateAverageResponseTime(resolvedReports);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Response Time Analytics',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildResponseMetric(
                  'Average Response Time',
                  avgResponseTime,
                  Icons.timer,
                  Colors.blue,
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildResponseMetric(
                  'Resolved Reports',
                  resolvedReports.length.toString(),
                  Icons.check_circle,
                  Colors.green,
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResponseMetric(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTopCategoriesTable(List<ReportModel> reports, bool isDark) {
    final categoryStats = _calculateDetailedCategoryStats(reports);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detailed Category Statistics',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Table(
            border: TableBorder.all(
              color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              width: 1,
            ),
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[200],
                ),
                children: [
                  _buildTableHeader('Category'),
                  _buildTableHeader('Count'),
                  _buildTableHeader('Resolved'),
                ],
              ),
              ...categoryStats
                  .map(
                    (stat) => TableRow(
                      children: [
                        _buildTableCell(stat['category'] as String, isDark),
                        _buildTableCell(
                          (stat['count'] as int).toString(),
                          isDark,
                        ),
                        _buildTableCell(
                          (stat['resolved'] as int).toString(),
                          isDark,
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: isDark ? Colors.white : Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLocationAnalytics(List<ReportModel> reports, bool isDark) {
    final reportsWithLocation = reports.where((r) => r.hasLocation).length;
    final percentage = reports.isEmpty
        ? 0
        : (reportsWithLocation / reports.length * 100);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location Coverage',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$reportsWithLocation of ${reports.length} reports have location data',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, bool isDark, Widget chart) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(height: 250, child: chart),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Failed to load analytics',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Data Available',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Analytics will appear once reports are submitted',
            style: GoogleFonts.poppins(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // Data Calculation Methods
  List<_ChartData> _calculateStatusDistribution(List<ReportModel> reports) {
    return [
      _ChartData(
        'Pending',
        reports.where((r) => r.status == 'pending').length,
        Colors.orange,
      ),
      _ChartData(
        'In Progress',
        reports.where((r) => r.status == 'in_progress').length,
        Colors.blue,
      ),
      _ChartData(
        'Resolved',
        reports.where((r) => r.status == 'resolved').length,
        Colors.green,
      ),
    ];
  }

  List<_ChartData> _calculateCategoryDistribution(List<ReportModel> reports) {
    final categories = [
      'Road Damage',
      'Flooding',
      'Garbage',
      'Street Light',
      'Water Leak',
      'Sewage Issue',
      'Other',
    ];
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.brown,
      Colors.yellow,
      Colors.cyan,
      Colors.purple,
      Colors.grey,
    ];

    return List.generate(categories.length, (index) {
      final count = reports
          .where((r) => r.category == categories[index])
          .length;
      return _ChartData(categories[index], count, colors[index]);
    }).where((data) => data.value > 0).toList();
  }

  List<_ChartData> _calculatePriorityDistribution(List<ReportModel> reports) {
    return [
      _ChartData(
        'Urgent',
        reports.where((r) => r.priority == 'urgent').length,
        Colors.red,
      ),
      _ChartData(
        'High',
        reports.where((r) => r.priority == 'high').length,
        Colors.orange,
      ),
      _ChartData(
        'Medium',
        reports.where((r) => r.priority == 'medium').length,
        Colors.blue,
      ),
      _ChartData(
        'Low',
        reports.where((r) => r.priority == 'low').length,
        Colors.green,
      ),
    ];
  }

  List<_ChartData> _calculateTimelineData(List<ReportModel> reports) {
    final now = DateTime.now();
    final data = <_ChartData>[];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final count = reports
          .where(
            (r) =>
                r.createdAt.year == date.year &&
                r.createdAt.month == date.month &&
                r.createdAt.day == date.day,
          )
          .length;
      data.add(
        _ChartData(DateFormat('MMM dd').format(date), count, Colors.blue),
      );
    }

    return data;
  }

  String _calculateAverageResponseTime(List<ReportModel> resolvedReports) {
    if (resolvedReports.isEmpty) return '0 days';

    final totalDays = resolvedReports.fold<int>(0, (sum, report) {
      return sum + report.updatedAt.difference(report.createdAt).inDays;
    });

    final avgDays = totalDays / resolvedReports.length;
    return '${avgDays.toStringAsFixed(1)} days';
  }

  List<Map<String, dynamic>> _calculateDetailedCategoryStats(
    List<ReportModel> reports,
  ) {
    final categories = [
      'Road Damage',
      'Flooding',
      'Garbage',
      'Street Light',
      'Water Leak',
      'Sewage Issue',
      'Other',
    ];

    return categories
        .map((category) {
          final categoryReports = reports
              .where((r) => r.category == category)
              .toList();
          final resolvedCount = categoryReports
              .where((r) => r.status == 'resolved')
              .length;

          return {
            'category': category,
            'count': categoryReports.length,
            'resolved': resolvedCount,
          };
        })
        .where((stat) => stat['count'] as int > 0)
        .toList();
  }

  // PDF Generation Method with Colors
  Future<void> _generatePdfReport() async {
    setState(() => _isGeneratingPdf = true);

    try {
      final reports = await _reportController.getAllReportsOnce();
      final pdf = pw.Document();

      // Add pages to PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            // Header
            pw.Header(
              level: 0,
              child: pw.Center(
                child: pw.Text(
                  'InfraGuard Analytics Report',
                  style: pw.TextStyle(
                    fontSize: 26,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ),

            pw.Center(
              child: pw.Paragraph(
                text:
                    'Generated on ${DateFormat('MMMM dd, yyyy - HH:mm').format(DateTime.now())}',
                style: const pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey700,
                ),
              ),
            ),
            pw.SizedBox(height: 20),

            // Summary Statistics
            pw.Header(level: 1, text: 'Summary Statistics'),
            pw.SizedBox(height: 10),
            _buildPdfStatsTable(reports),
            pw.SizedBox(height: 20),

            // Status Distribution
            pw.Header(level: 1, text: 'Status Distribution'),
            pw.SizedBox(height: 10),
            _buildPdfStatusTable(reports),
            pw.SizedBox(height: 20),

            // Category Statistics
            pw.Header(level: 1, text: 'Category Statistics'),
            pw.SizedBox(height: 10),
            _buildPdfCategoryTable(reports),
            pw.SizedBox(height: 20),

            // Priority Distribution
            pw.Header(level: 1, text: 'Priority Distribution'),
            pw.SizedBox(height: 10),
            _buildPdfPriorityTable(reports),
          ],
        ),
      );

      // Show PDF preview and download
      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name:
            'InfraGuard_Analytics_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf',
      );

      Get.snackbar(
        'Success',
        'PDF report generated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to generate PDF: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => _isGeneratingPdf = false);
    }
  }

  pw.Widget _buildPdfStatsTable(List<ReportModel> reports) {
    final totalReports = reports.length;
    final pendingReports = reports.where((r) => r.status == 'pending').length;
    final inProgressReports = reports
        .where((r) => r.status == 'in_progress')
        .length;
    final resolvedReports = reports.where((r) => r.status == 'resolved').length;
    final urgentReports = reports.where((r) => r.priority == 'urgent').length;
    final resolutionRate = totalReports > 0
        ? (resolvedReports / totalReports * 100)
        : 0;

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.blue800, width: 1),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blue100),
          children: [
            _buildPdfCell(
              'Metric',
              isHeader: true,
              headerColor: PdfColors.blue800,
            ),
            _buildPdfCell(
              'Value',
              isHeader: true,
              headerColor: PdfColors.blue800,
            ),
          ],
        ),
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.white),
          children: [
            _buildPdfCell('Total Reports'),
            _buildPdfCell('$totalReports', valueColor: PdfColors.blue700),
          ],
        ),
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey50),
          children: [
            _buildPdfCell('Pending'),
            _buildPdfCell('$pendingReports', valueColor: PdfColors.orange700),
          ],
        ),
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.white),
          children: [
            _buildPdfCell('In Progress'),
            _buildPdfCell(
              '$inProgressReports',
              valueColor: PdfColors.purple700,
            ),
          ],
        ),
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey50),
          children: [
            _buildPdfCell('Resolved'),
            _buildPdfCell('$resolvedReports', valueColor: PdfColors.green700),
          ],
        ),
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.white),
          children: [
            _buildPdfCell('Urgent Reports'),
            _buildPdfCell('$urgentReports', valueColor: PdfColors.red700),
          ],
        ),
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey50),
          children: [
            _buildPdfCell('Resolution Rate'),
            _buildPdfCell(
              '${resolutionRate.toStringAsFixed(1)}%',
              valueColor: PdfColors.teal700,
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildPdfStatusTable(List<ReportModel> reports) {
    final pending = reports.where((r) => r.status == 'pending').length;
    final inProgress = reports.where((r) => r.status == 'in_progress').length;
    final resolved = reports.where((r) => r.status == 'resolved').length;
    final total = reports.length;

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.green800, width: 1),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.green100),
          children: [
            _buildPdfCell(
              'Status',
              isHeader: true,
              headerColor: PdfColors.green800,
            ),
            _buildPdfCell(
              'Count',
              isHeader: true,
              headerColor: PdfColors.green800,
            ),
            _buildPdfCell(
              'Percentage',
              isHeader: true,
              headerColor: PdfColors.green800,
            ),
          ],
        ),
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.white),
          children: [
            _buildPdfCell('Pending'),
            _buildPdfCell('$pending', valueColor: PdfColors.orange700),
            _buildPdfCell(
              '${total > 0 ? (pending / total * 100).toStringAsFixed(1) : 0}%',
              valueColor: PdfColors.orange700,
            ),
          ],
        ),
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey50),
          children: [
            _buildPdfCell('In Progress'),
            _buildPdfCell('$inProgress', valueColor: PdfColors.blue700),
            _buildPdfCell(
              '${total > 0 ? (inProgress / total * 100).toStringAsFixed(1) : 0}%',
              valueColor: PdfColors.blue700,
            ),
          ],
        ),
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.white),
          children: [
            _buildPdfCell('Resolved'),
            _buildPdfCell('$resolved', valueColor: PdfColors.green700),
            _buildPdfCell(
              '${total > 0 ? (resolved / total * 100).toStringAsFixed(1) : 0}%',
              valueColor: PdfColors.green700,
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildPdfCategoryTable(List<ReportModel> reports) {
    final categories = [
      'Road Damage',
      'Flooding',
      'Garbage',
      'Street Light',
      'Water Leak',
      'Sewage Issue',
      'Other',
    ];

    final rows = categories
        .map((category) {
          final categoryReports = reports
              .where((r) => r.category == category)
              .toList();
          final total = categoryReports.length;
          final resolved = categoryReports
              .where((r) => r.status == 'resolved')
              .length;

          if (total == 0) return null;

          // Define colors for each category
          final categoryColors = {
            'Road Damage': PdfColors.red700,
            'Flooding': PdfColors.blue700,
            'Garbage': PdfColors.brown700,
            'Street Light': PdfColors.amber700,
            'Water Leak': PdfColors.cyan700,
            'Sewage Issue': PdfColors.purple700,
            'Other': PdfColors.grey700,
          };

          final rowIndex = categories.indexOf(category);
          final rowColor = rowIndex % 2 == 0
              ? PdfColors.white
              : PdfColors.grey50;

          return pw.TableRow(
            decoration: pw.BoxDecoration(color: rowColor),
            children: [
              _buildPdfCell(category, valueColor: categoryColors[category]),
              _buildPdfCell('$total', valueColor: categoryColors[category]),
              _buildPdfCell('$resolved', valueColor: categoryColors[category]),
              _buildPdfCell(
                '${total > 0 ? (resolved / total * 100).toStringAsFixed(1) : 0}%',
                valueColor: categoryColors[category],
              ),
            ],
          );
        })
        .whereType<pw.TableRow>()
        .toList();

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.purple800, width: 1),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.purple100),
          children: [
            _buildPdfCell(
              'Category',
              isHeader: true,
              headerColor: PdfColors.purple800,
            ),
            _buildPdfCell(
              'Total',
              isHeader: true,
              headerColor: PdfColors.purple800,
            ),
            _buildPdfCell(
              'Resolved',
              isHeader: true,
              headerColor: PdfColors.purple800,
            ),
            _buildPdfCell(
              'Resolution Rate',
              isHeader: true,
              headerColor: PdfColors.purple800,
            ),
          ],
        ),
        ...rows,
      ],
    );
  }

  pw.Widget _buildPdfPriorityTable(List<ReportModel> reports) {
    final urgent = reports.where((r) => r.priority == 'urgent').length;
    final high = reports.where((r) => r.priority == 'high').length;
    final medium = reports.where((r) => r.priority == 'medium').length;
    final low = reports.where((r) => r.priority == 'low').length;
    final total = reports.length;

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.orange800, width: 1),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.orange100),
          children: [
            _buildPdfCell(
              'Priority',
              isHeader: true,
              headerColor: PdfColors.orange800,
            ),
            _buildPdfCell(
              'Count',
              isHeader: true,
              headerColor: PdfColors.orange800,
            ),
            _buildPdfCell(
              'Percentage',
              isHeader: true,
              headerColor: PdfColors.orange800,
            ),
          ],
        ),
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.white),
          children: [
            _buildPdfCell('Urgent'),
            _buildPdfCell('$urgent', valueColor: PdfColors.red700),
            _buildPdfCell(
              '${total > 0 ? (urgent / total * 100).toStringAsFixed(1) : 0}%',
              valueColor: PdfColors.red700,
            ),
          ],
        ),
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey50),
          children: [
            _buildPdfCell('High'),
            _buildPdfCell('$high', valueColor: PdfColors.orange700),
            _buildPdfCell(
              '${total > 0 ? (high / total * 100).toStringAsFixed(1) : 0}%',
              valueColor: PdfColors.orange700,
            ),
          ],
        ),
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.white),
          children: [
            _buildPdfCell('Medium'),
            _buildPdfCell('$medium', valueColor: PdfColors.blue700),
            _buildPdfCell(
              '${total > 0 ? (medium / total * 100).toStringAsFixed(1) : 0}%',
              valueColor: PdfColors.blue700,
            ),
          ],
        ),
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey50),
          children: [
            _buildPdfCell('Low'),
            _buildPdfCell('$low', valueColor: PdfColors.green700),
            _buildPdfCell(
              '${total > 0 ? (low / total * 100).toStringAsFixed(1) : 0}%',
              valueColor: PdfColors.green700,
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildPdfCell(
    String text, {
    bool isHeader = false,
    PdfColor? headerColor,
    PdfColor? valueColor,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader
              ? headerColor ?? PdfColors.black
              : valueColor ?? PdfColors.black,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }
}

class _ChartData {
  final String category;
  final int value;
  final Color color;

  _ChartData(this.category, this.value, this.color);
}
