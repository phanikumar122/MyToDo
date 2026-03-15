import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../models/task_model.dart';

class FocusScreen extends StatefulWidget {
  final TaskModel task;
  const FocusScreen({super.key, required this.task});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TimerProvider>().setActiveTask(widget.task.title);
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timer  = context.watch<TimerProvider>();
    final colors = Theme.of(context).colorScheme;

    return PopScope(
      canPop: !timer.isRunning,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && timer.isRunning) {
          final leave = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title:   const Text('Leave Focus Mode?'),
              content: const Text('Your timer is still running. Are you sure you want to leave?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Stay')),
                ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Leave')),
              ],
            ),
          );
          if (leave == true && context.mounted) {
            timer.pause();
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        backgroundColor: colors.primary,
        body: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon:  const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        if (!timer.isRunning) Navigator.pop(context);
                      },
                    ),
                    const Spacer(),
                    Text(
                      timer.phaseLabel,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Phase tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    _PhaseTab(
                      label:      'Focus',
                      isSelected: timer.phase == PomodoroPhase.work,
                      onTap: () => timer.switchPhase(PomodoroPhase.work),
                    ),
                    const SizedBox(width: 8),
                    _PhaseTab(
                      label:      'Short Break',
                      isSelected: timer.phase == PomodoroPhase.shortBreak,
                      onTap: () => timer.switchPhase(PomodoroPhase.shortBreak),
                    ),
                    const SizedBox(width: 8),
                    _PhaseTab(
                      label:      'Long Break',
                      isSelected: timer.phase == PomodoroPhase.longBreak,
                      onTap: () => timer.switchPhase(PomodoroPhase.longBreak),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Timer ring
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, child) {
                  final pulse = timer.isRunning
                      ? 0.95 + _pulseCtrl.value * 0.05
                      : 1.0;
                  return Transform.scale(scale: pulse, child: child);
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 260, height: 260,
                      child: CircularProgressIndicator(
                        value:      timer.progress,
                        strokeWidth: 12,
                        color:      Colors.white,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          timer.formattedTime,
                          style: const TextStyle(
                            color:      Colors.white,
                            fontSize:   64,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          '${timer.cycleCount} cycle${timer.cycleCount != 1 ? 's' : ''} done',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Task name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Text(
                      'Currently focusing on:',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.task.title,
                      textAlign: TextAlign.center,
                      maxLines:  2,
                      overflow:  TextOverflow.ellipsis,
                      style: const TextStyle(
                        color:      Colors.white,
                        fontSize:   18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon:      const Icon(Icons.restart_alt_rounded,
                        color: Colors.white, size: 32),
                    tooltip:   'Reset',
                    onPressed: timer.reset,
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap:  timer.isRunning ? timer.pause : timer.start,
                    child:  Container(
                      width:  80, height: 80,
                      decoration: BoxDecoration(
                        color:        Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color:  Colors.black.withValues(alpha: 0.15),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        timer.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        size:  40,
                        color: colors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                    IconButton(
                      icon:      const Icon(Icons.skip_next_rounded,
                          color: Colors.white, size: 32),
                      tooltip:   'Next phase',
                      onPressed: () => timer.onPhaseCompleteManual(),
                    ),
                ],
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhaseTab extends StatelessWidget {
  final String   label;
  final bool     isSelected;
  final VoidCallback onTap;
  const _PhaseTab({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration:    const Duration(milliseconds: 200),
          padding:     const EdgeInsets.symmetric(vertical: 8),
          decoration:  BoxDecoration(
            color:        isSelected
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border:       isSelected
                ? Border.all(color: Colors.white.withValues(alpha: 0.4))
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color:      isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              fontSize:   12,
            ),
          ),
        ),
      ),
    );
  }
}

// Extension to allow manual phase skip from UI
extension _TimerExt on TimerProvider {
  void onPhaseCompleteManual() {
    pause();
    if (phase == PomodoroPhase.work) {
      switchPhase(PomodoroPhase.shortBreak);
    } else {
      switchPhase(PomodoroPhase.work);
    }
  }
}
