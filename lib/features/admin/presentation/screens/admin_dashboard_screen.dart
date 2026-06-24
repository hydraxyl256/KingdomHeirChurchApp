import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:file_saver/file_saver.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/di/providers.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';

final analyticsDashboardProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);

  // We perform parallel RPCs or direct selects to gather the data quickly
  final results = await Future.wait<dynamic>([
    supabase.from('view_online_users').select().single(),
    supabase.from('view_dau').select().single(),
    supabase.from('view_wau').select().single(),
    supabase.from('view_mau').select().single(),
    supabase.from('view_donation_analytics').select().single(),
    supabase.from('profiles').count(),
    supabase.from('app_installations').count(),
    supabase.from('view_country_analytics').select().limit(5),
    supabase.from('view_language_analytics').select().limit(5),
  ]);

  final online = results[0] as Map<String, dynamic>;
  final dau = results[1] as Map<String, dynamic>;
  final wau = results[2] as Map<String, dynamic>;
  final mau = results[3] as Map<String, dynamic>;
  return {
    'online': online['online_users_count'] ?? 0,
    'dau': dau['active_today'] ?? 0,
    'wau': wau['active_this_week'] ?? 0,
    'mau': mau['active_this_month'] ?? 0,
    'financial': results[4],
    'total_users': results[5] as int? ?? 0,
    'total_installs': results[6] as int? ?? 0,
    'geography': results[7],
    'languages': results[8],
  };
});

class AdminAnalyticsDashboardScreen extends ConsumerWidget {
  const AdminAnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(analyticsDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Intelligence'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export Financial Data (CSV)',
            onPressed: () {
              final data = asyncData.valueOrNull;
              if (data != null && data['financial'] != null) {
                _exportToCsv(
                    context, data['financial'] as Map<String, dynamic>,);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No data to export')),);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(analyticsDashboardProvider),
          ),
        ],
      ),
      body: asyncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (data) {
          final financial = data['financial'] as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(context, 'Realtime Engagement'),
                const SizedBox(height: 16),
                _buildKpiGrid(context, [
                  _Kpi('Online Now', data['online'].toString(),
                      Icons.wifi_tethering, AppColors.success,),
                  _Kpi('Daily Active (DAU)', data['dau'].toString(),
                      Icons.today, AppColors.info,),
                  _Kpi('Weekly Active (WAU)', data['wau'].toString(),
                      Icons.calendar_view_week, AppColors.tertiary,),
                  _Kpi('Monthly Active (MAU)', data['mau'].toString(),
                      Icons.calendar_month, AppColors.navyAccent,),
                  _Kpi('Total Users', data['total_users'].toString(),
                      Icons.people, AppColors.warning,),
                  _Kpi('Total Installs', data['total_installs'].toString(),
                      Icons.download, AppColors.goldDark,),
                ]),
                const SizedBox(height: 32),
                _buildSectionTitle(context, 'Financial Analytics'),
                const SizedBox(height: 16),
                _buildKpiGrid(context, [
                  _Kpi('Revenue Today', '\$${financial['donations_today']}',
                      Icons.payments, AppColors.success,),
                  _Kpi(
                      'Revenue (30d)',
                      '\$${financial['donations_this_month']}',
                      Icons.account_balance,
                      AppColors.info,),
                  _Kpi('Average Gift', '\$${financial['average_donation']}',
                      Icons.show_chart, AppColors.tertiary,),
                  _Kpi(
                      'Top Campaign',
                      (financial['top_giving_fund'] as String?) ?? 'N/A',
                      Icons.star,
                      AppColors.warning,),
                ]),
                const SizedBox(height: 32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: _buildGeographyTable(
                            context, data['geography'] as List<dynamic>,),),
                    const SizedBox(width: 24),
                    Expanded(
                        child: _buildLanguageTable(
                            context, data['languages'] as List<dynamic>,),),
                  ],
                ),
                const SizedBox(height: 32),
                _buildSectionTitle(context, 'Growth Trends (30 Days)'),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: const [
                                FlSpot(0, 3),
                                FlSpot(1, 4),
                                FlSpot(2, 6),
                                FlSpot(3, 8),
                                FlSpot(4, 12),
                                FlSpot(5, 18),
                              ],
                              isCurved: true,
                              color: Theme.of(context).colorScheme.primary,
                              barWidth: 4,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .headlineSmall
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildKpiGrid(BuildContext context, List<_Kpi> kpis) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200
            ? 6
            : (constraints.maxWidth > 800 ? 4 : 2);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: kpis.length,
          itemBuilder: (context, index) {
            final kpi = kpis[index];
            return Card(
              elevation: 0,
              color: kpi.color.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: kpi.color.withValues(alpha: 0.3)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(kpi.icon, color: kpi.color, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            kpi.title,
                            style: TextStyle(
                                color: kpi.color,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      kpi.value,
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: kpi.color.withValues(alpha: 0.8),),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _exportToCsv(
      BuildContext context, Map<String, dynamic> financial,) async {
    try {
      final rows = <List<dynamic>>[
        ['Metric', 'Value'],
        ['Revenue Today', financial['donations_today']],
        ['Revenue (30d)', financial['donations_this_month']],
        ['Average Gift', financial['average_donation']],
        ['Top Campaign', financial['top_giving_fund'] ?? 'N/A'],
      ];

      final csv = const ListToCsvConverter().convert(rows);
      final bytes = Uint8List.fromList(csv.codeUnits);

      await FileSaver.instance.saveFile(
        name:
            'donation_analytics_${DateTime.now().toIso8601String().split('T')[0]}',
        bytes: bytes,
        ext: 'csv',
        mimeType: MimeType.csv,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exported successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export: $e')),
        );
      }
    }
  }

  Widget _buildGeographyTable(BuildContext context, List<dynamic> geoData) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Top Countries',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
          ),
          const Divider(height: 1),
          DataTable(
            columns: const [
              DataColumn(label: Text('Country')),
              DataColumn(label: Text('Users')),
              DataColumn(label: Text('Online Now')),
            ],
            rows: geoData.map((dynamic raw) {
              final row = raw as Map<String, dynamic>;
              return DataRow(
                cells: [
                  DataCell(Text(row['country'].toString())),
                  DataCell(Text(row['users'].toString())),
                  DataCell(Text(row['online_users'].toString())),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTable(BuildContext context, List<dynamic> langData) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Language Demographics',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
          ),
          const Divider(height: 1),
          DataTable(
            columns: const [
              DataColumn(label: Text('Language')),
              DataColumn(label: Text('Users')),
            ],
            rows: langData.map((dynamic raw) {
              final row = raw as Map<String, dynamic>;
              return DataRow(
                cells: [
                  DataCell(
                      Text(row['preferred_language'].toString().toUpperCase()),),
                  DataCell(Text(row['users_count'].toString())),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _Kpi {
  _Kpi(this.title, this.value, this.icon, this.color);
  final String title;
  final String value;
  final IconData icon;
  final Color color;
}
