import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/notification_service.dart';

enum PomodoroPhase { work, shortBreak, longBreak }

class TimerProvider extends ChangeNotifier {
  Timer?         _timer;
  int            _secondsLeft  = kPomodoroWork * 60;
  bool           _isRunning    = false;
  PomodoroPhase  _phase        = PomodoroPhase.work;
  int            _cycleCount   = 0;      // completed work cycles
  String?        _activeTask;

  int           get secondsLeft  => _secondsLeft;
  bool          get isRunning    => _isRunning;
  PomodoroPhase get phase        => _phase;
  int           get cycleCount   => _cycleCount;
  String?       get activeTask   => _activeTask;

  double get progress {
    final total = _totalSeconds;
    return (_secondsLeft / total).clamp(0.0, 1.0);
  }

  int get _totalSeconds {
    switch (_phase) {
      case PomodoroPhase.work:        return kPomodoroWork  * 60;
      case PomodoroPhase.shortBreak:  return kPomodoroBreak * 60;
      case PomodoroPhase.longBreak:   return kPomodoroLong  * 60;
    }
  }

  String get formattedTime {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft  %  60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get phaseLabel {
    switch (_phase) {
      case PomodoroPhase.work:       return 'Focus Time';
      case PomodoroPhase.shortBreak: return 'Short Break';
      case PomodoroPhase.longBreak:  return 'Long Break';
    }
  }

  void setActiveTask(String taskTitle) {
    _activeTask = taskTitle;
    notifyListeners();
  }

  void start() {
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    notifyListeners();
  }

  void pause() {
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  void reset() {
    _timer?.cancel();
    _isRunning   = false;
    _secondsLeft = _totalSeconds;
    notifyListeners();
  }

  void _tick() {
    if (_secondsLeft > 0) {
      _secondsLeft--;
      notifyListeners();
    } else {
      _timer?.cancel();
      _isRunning = false;
      _onPhaseComplete();
    }
  }

  void _onPhaseComplete() async {
    await NotificationService().showPomodoroComplete();

    if (_phase == PomodoroPhase.work) {
      _cycleCount++;
      _phase = (_cycleCount % 4 == 0)
          ? PomodoroPhase.longBreak
          : PomodoroPhase.shortBreak;
    } else {
      _phase = PomodoroPhase.work;
    }

    _secondsLeft = _totalSeconds;
    notifyListeners();
  }

  void switchPhase(PomodoroPhase newPhase) {
    _timer?.cancel();
    _isRunning   = false;
    _phase       = newPhase;
    _secondsLeft = _totalSeconds;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
