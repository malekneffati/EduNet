import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../components/admin/admin_header.dart';
import '../components/admin/admin_sidebar.dart';
import '../components/admin/stat_card.dart';
import '../viewmodels/admin/admin_dashboard_viewmodel.dart';
import '../viewmodels/admin/admin_sidebar_viewmodel.dart';

class AdminDashboardView extends ConsumerStatefulWidget {
  const AdminDashboardView({super.key});

  @override
  ConsumerState<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends ConsumerState<AdminDashboardView> {
  String _selectedPeriod = '7'; // 7, 30, 90 days

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminDashboardProvider).loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardViewModel = ref.watch(adminDashboardProvider);
    final sidebarViewModel = ref.watch(adminSidebarProvider);
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;
    final isTablet = width >= 768 && width < 1024;

    return Scaffold(
      drawer: isMobile
          ? Drawer(
              child: AdminSidebar(
                selectedIndex: sidebarViewModel.selectedIndex,
                onItemSelected: (index) {
                  sidebarViewModel.selectItem(index);
                  Navigator.pop(context);
                },
              ),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            AdminSidebar(
              selectedIndex: sidebarViewModel.selectedIndex,
              onItemSelected: (index) {
                sidebarViewModel.selectItem(index);
              },
            ),
          Expanded(
            child: Column(
              children: [
                AdminHeader(isMobile: isMobile),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 12.0 : 24.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatsGrid(dashboardViewModel, isMobile, isTablet),
                          const SizedBox(height: 24),
                          _buildVisitorsChart(isMobile),
                          const SizedBox(height: 24),
                          _buildRevenueChart(isMobile),
                          const SizedBox(height: 24),
                          _buildQuickActions(context, isMobile, isTablet),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(AdminDashboardViewModel vm, bool isMobile, bool isTablet) {
    int crossAxisCount = 4;
    double aspectRatio = 1.5;
    
    if (isMobile) {
      crossAxisCount = 1;
      aspectRatio = 3.2;
    } else if (isTablet) {
      crossAxisCount = 2;
      aspectRatio = 2.0;
    }

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: aspectRatio,
      children: [
        StatCard(
          title: 'Utilisateurs totaux',
          value: vm.totalUsers.toString(),
          icon: Icons.people,
          color: const Color(0xFF4F46E5),
          isLoading: vm.totalUsers == 0,
        ),
        StatCard(
          title: 'Cours disponibles',
          value: vm.totalCourses.toString(),
          icon: Icons.school,
          color: const Color(0xFF10B981),
          isLoading: vm.totalCourses == 0,
        ),
        StatCard(
          title: 'Revenus (TND)',
          value: '${vm.totalRevenue.toStringAsFixed(2)}',
          icon: Icons.attach_money,
          color: const Color(0xFFF59E0B),
          isLoading: vm.totalRevenue == 0,
        ),
        StatCard(
          title: 'Abonnements actifs',
          value: vm.activeSubscriptions.toString(),
          icon: Icons.card_membership,
          color: const Color(0xFFEF4444),
          isLoading: vm.activeSubscriptions == 0,
        ),
      ],
    );
  }

  Widget _buildVisitorsChart(bool isMobile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Visiteurs totaux',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total des derniers $_selectedPeriod jours',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                _buildPeriodSelector(),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: isMobile ? 200 : 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
                          if (value.toInt() < days.length) {
                            return Text(days[value.toInt()], style: const TextStyle(fontSize: 10));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _getVisitorSpots(),
                      isCurved: true,
                      color: const Color(0xFF4F46E5),
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF4F46E5).withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _getVisitorSpots() {
    // Données simulées
    return [
      const FlSpot(0, 40),
      const FlSpot(1, 55),
      const FlSpot(2, 45),
      const FlSpot(3, 80),
      const FlSpot(4, 70),
      const FlSpot(5, 90),
      const FlSpot(6, 85),
    ];
  }

  Widget _buildPeriodSelector() {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: '7', label: Text('7j', style: TextStyle(fontSize: 12))),
        ButtonSegment(value: '30', label: Text('30j', style: TextStyle(fontSize: 12))),
        ButtonSegment(value: '90', label: Text('3m', style: TextStyle(fontSize: 12))),
      ],
      selected: {_selectedPeriod},
      onSelectionChanged: (Set<String> newSelection) {
        setState(() {
          _selectedPeriod = newSelection.first;
        });
      },
    );
  }

  Widget _buildRevenueChart(bool isMobile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revenus mensuels',
              style: TextStyle(
                fontSize: isMobile ? 16 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Évolution des revenus par mois',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: isMobile ? 200 : 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 20000,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${(value / 1000).toInt()}k',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun'];
                          if (value.toInt() < months.length) {
                            return Text(months[value.toInt()], style: const TextStyle(fontSize: 10));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                  barGroups: _getRevenueBarGroups(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _getRevenueBarGroups() {
    return [
      _makeBarGroup(0, 12500, const Color(0xFF4F46E5)),
      _makeBarGroup(1, 15000, const Color(0xFF4F46E5)),
      _makeBarGroup(2, 13000, const Color(0xFF4F46E5)),
      _makeBarGroup(3, 17000, const Color(0xFF4F46E5)),
      _makeBarGroup(4, 14500, const Color(0xFF4F46E5)),
      _makeBarGroup(5, 18000, const Color(0xFF10B981)),
    ];
  }

  BarChartGroupData _makeBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 16,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isMobile, bool isTablet) {
    int crossAxisCount = 4;
    double aspectRatio = 2.0;
    
    if (isMobile) {
      crossAxisCount = 1;
      aspectRatio = 5.0;
    } else if (isTablet) {
      crossAxisCount = 2;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions rapides',
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: aspectRatio,
          children: [
            _buildQuickActionCard(
              context,
              'Gérer les cours',
              'Ajouter/modifier',
              Icons.add_circle,
              const Color(0xFF10B981),
              '/admin/courses',
            ),
            _buildQuickActionCard(
              context,
              'Utilisateurs',
              'Voir/modifier',
              Icons.people,
              const Color(0xFF4F46E5),
              '/admin/users',
            ),
            _buildQuickActionCard(
              context,
              'Paiements',
              'Historique',
              Icons.payment,
              const Color(0xFFF59E0B),
              '/admin/payments',
            ),
            _buildQuickActionCard(
              context,
              'Promotions',
              'Offres spéciales',
              Icons.local_offer,
              const Color(0xFFEF4444),
              '/admin/promotions',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    String route,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go(route),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                radius: 24,
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}