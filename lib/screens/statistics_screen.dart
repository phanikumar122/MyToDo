import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/task_provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tasks  = context.watch<TaskProvider>();
    final colors = Theme.of(context).colorScheme;
    final stats  = tasks.stats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: stats == null && !tasks.isLoading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bar_chart, size: 64,
                      color: colors.onSurface.withValues(alpha: 0.2)),
                  const SizedBox(height: 12),
                  const Text('No data yet. Complete some tasks!'),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await tasks.loadTasks();
                await tasks.loadStats();
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary stat cards
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing:  12,
                      childAspectRatio: 1.6,
                      shrinkWrap:       true,
                      physics:          const NeverScrollableScrollPhysics(),
                      children: [
                        _StatCard(
                          label: 'Today Completed',
                          value: '${stats?['todayCompleted'] ?? 0}',
                          icon:  Icons.today_rounded,
                          color: colors.primary,
                        ),
                        _StatCard(
                          label: 'Completion Rate',
                          value: '${stats?['completionRate'] ?? 0}%',
                          icon:  Icons.pie_chart_rounded,
                          color: Colors.green,
                        ),
                        _StatCard(
                          label: 'Total Tasks',
                          value: '${stats?['total'] ?? 0}',
                          icon:  Icons.task_alt_rounded,
                          color: Colors.orange,
                        ),
                        _StatCard(
                          label: 'Streak',
                          value: '${stats?['streak'] ?? 0} days',
                          icon:  Icons.local_fire_department_rounded,
                          color: Colors.deepOrange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Weekly chart
                    const Text('Weekly Activity',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          height: 200,
                          child: _WeeklyBarChart(weekly: stats?['weekly'] ?? []),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // By category
                    if ((stats?['byCategory'] as List?)?.isNotEmpty ?? false) ...[
                      const Text('By Category',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                      const SizedBox(height: 12),
                      ...((stats!['byCategory'] as List).cast<Map<String, dynamic>>()
                          .map((c) => _CategoryRow(data: c))),
                    ],
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String   label;
  final String   value;
  final IconData icon;
  final Color    color;
  const _StatCard({required this.label, required this.value,
                   required this.icon,  required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const Spacer(),
            Text(value,
                style: TextStyle(fontWeight: FontWeight.w800,
                    fontSize: 22, color: color)),
            Text(label,
                style: TextStyle(fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
          ],
        ),
      ),
    );
  }
}

class _WeeklyBarChart extends StatelessWidget {
  final List<dynamic> weekly;
  const _WeeklyBarChart({required this.weekly});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // Build a list of last 7 days with completed count
    final now     = DateTime.now();
    final days    = List.generate(7, (i) =>
        DateTime(now.year, now.month, now.day - (6 - i)));
    final daysMap = {for (var row in weekly)
      (row as Map<String, dynamic>)['day'].toString().substring(0, 10):
      (row['count'] as int? ?? 0)};

    final spots = days.asMap().entries.map((e) {
      final key = '${e.value.year}-${e.value.month.toString().padLeft(2,'0')}-${e.value.day.toString().padLeft(2,'0')}';
      return BarChartGroupData(
        x:       e.key,
        barRods: [BarChartRodData(
          toY:        (daysMap[key] ?? 0).toDouble(),
          color:      colors.primary,
          width:      18,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        )],
      );
    }).toList();

    const dayLabels = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];

    return BarChart(BarChartData(
      barGroups:   spots,
      borderData:  FlBorderData(show: false),
      gridData:    FlGridData(show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: colors.onSurface.withValues(alpha: 0.1))),
      titlesData:  FlTitlesData(
        leftTitles:   AxisTitles(sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          interval:     1,
          getTitlesWidget: (v, _) => v == v.floorToDouble()
              ? Text('${v.toInt()}',
                    style: TextStyle(fontSize: 10,
                        color: colors.onSurface.withValues(alpha: 0.5)))
              : const SizedBox.shrink(),
        )),
        bottomTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 24,
          getTitlesWidget: (v, _) {
            final d = days[v.toInt()];
            return Text(dayLabels[d.weekday - 1],
                style: TextStyle(fontSize: 10,
                    color: colors.onSurface.withValues(alpha: 0.5)));
          },
        )),
        topTitles:    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
    ));
  }
}

class _CategoryRow extends StatelessWidget {
  final Map<String, dynamic> data;
  const _CategoryRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final colors    = Theme.of(context).colorScheme;
    final total     = (data['total']         as int? ?? 0);
    final completed = (data['completed_count'] as int? ?? 0);
    final rate      = total > 0 ? completed / total : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(data['category'] as String? ?? '-',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text('$completed/$total',
                      style: TextStyle(
                          color: colors.onSurface.withValues(alpha: 0.6),
                          fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value:           rate,
                  minHeight:       6,
                  backgroundColor: colors.surfaceContainerHighest,
                  valueColor:      AlwaysStoppedAnimation<Color>(colors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
