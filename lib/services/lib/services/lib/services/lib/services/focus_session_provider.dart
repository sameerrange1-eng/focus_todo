import 'dart:async';
import 'package:flutter/foundation.dart';
import 'distraction_blocker_service.dart';

enum FocusSessionState { idle, running, paused, completed }

class FocusSessionProvider extends ChangeNotifier {
  final DistractionBlockerService _blocker;
  Timer? _ticker;

  FocusSessionProvider({DistractionBlockerService? blocker})
      : _blocker = blocker ?? StubDistractionBlockerService();

  FocusSessionState _state = FocusSessionState.idle;
  Duration _totalDuration = const Duration(minutes: 25);
  Duration _remaining = const Duration(minutes: 25);
  String? _linkedTaskId;

  FocusSessionState get state => _state;
  Duration get remaining => _remaining;
  Duration get totalDuration => _totalDuration;
  String? get linkedTaskId => _linkedTaskId;
  double get progress => _totalDuration.inSeconds == 0
      ? 0
      : 1 - (_remaining.inSeconds / _totalDuration.inSeconds);

  void setDuration(Duration duration) {
    if (_state == FocusSessionState.running) return;
    _totalDuration = duration;
    _remaining = duration;
    notifyListeners();
  }

  Future<void> start({
    String? taskId,
    List<String> blockedApps = const [],
  }) async {
    _linkedTaskId = taskId;
    _state = FocusSessionState.running;
    await _blocker.startBlocking(blockedApps);
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    notifyListeners();
  }

  void _tick() {
    if (_remaining.inSeconds <= 1) {
      _complete();
      return;
    }
    _remaining -= const Duration(seconds: 1);
    notifyListeners();
  }

  Future<void> _complete() async {
    _remaining = Duration.zero;
    _state = FocusSessionState.completed;
    _ticker?.cancel();
    await _blocker.stopBlocking();
    notifyListeners();
  }

  void pause() {
    if (_state != FocusSessionState.running) return;
    _state = FocusSessionState.paused;
    _ticker?.cancel();
    notifyListeners();
  }

  void resume() {
    if (_state != FocusSessionState.paused) return;
    _state = FocusSessionState.running;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    notifyListeners();
  }

  Future<void> cancel() async {
    _ticker?.cancel();
    await _blocker.stopBlocking();
    _state = FocusSessionState.idle;
    _remaining = _totalDuration;
    notifyListeners();
  }

  Future<void> reset() async {
    _ticker?.cancel();
    await _blocker.stopBlocking();
    _state = FocusSessionState.idle;
    _remaining = _totalDuration;
    _linkedTaskId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
