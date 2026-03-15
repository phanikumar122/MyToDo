import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import 'dashboard_screen.dart';
import 'tasks_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';
import 'add_edit_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const _destinations = [
    NavigationDestination(
      icon:          Icon(Icons.home_outlined),
      selectedIcon:  Icon(Icons.home_rounded),
      label:         'Home',
    ),
    NavigationDestination(
      icon:          Icon(Icons.task_alt_outlined),
      selectedIcon:  Icon(Icons.task_alt),
      label:         'Tasks',
    ),
    NavigationDestination(
      icon:          Icon(Icons.bar_chart_outlined),
      selectedIcon:  Icon(Icons.bar_chart),
      label:         'Statistics',
    ),
    NavigationDestination(
      icon:          Icon(Icons.settings_outlined),
      selectedIcon:  Icon(Icons.settings),
      label:         'Settings',
    ),
  ];

  static const _screens = [
    DashboardScreen(),
    TasksScreen(),
    StatisticsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: _destinations,
        animationDuration: const Duration(milliseconds: 400),
      ),
      floatingActionButton: _selectedIndex <= 1
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AddEditTaskScreen()),
              ),
              icon:  const Icon(Icons.add),
              label: const Text('New Task'),
              heroTag: 'fab',
            )
          : null,
    );
  }
}
