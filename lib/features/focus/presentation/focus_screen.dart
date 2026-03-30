import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/aurora_background.dart';

enum PomodoroState { idle, work, shortBreak, longBreak }

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen>
    with TickerProviderStateMixin {
  PomodoroState _state = PomodoroState.idle;
  Timer? _timer;
  int _secondsLeft = 25 * 60;
  int _sessionsCompleted = 0;
  bool _isRunning = false;
  int _workMinutes = 25;
  int _shortBreakMinutes = 5;
  int _longBreakMinutes = 15;
  int _sessionsBeforeLongBreak = 4;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _secondsLeft = _workMinutes * 60;
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  int get _totalSeconds {
    switch (_state) {
      case PomodoroState.work:
      case PomodoroState.idle:
        return _workMinutes * 60;
      case PomodoroState.shortBreak:
        return _shortBreakMinutes * 60;
      case PomodoroState.longBreak:
        return _longBreakMinutes * 60;
    }
  }

  double get _progress =>
      _totalSeconds == 0 ? 0 : (_totalSeconds - _secondsLeft) / _totalSeconds;

  Color get _stateColor {
    switch (_state) {
      case PomodoroState.idle:
      case PomodoroState.work:
        return AppColors.violetLight;
      case PomodoroState.shortBreak:
        return AppColors.cyanLight;
      case PomodoroState.longBreak:
        return AppColors.green;
    }
  }

  String get _stateLabel {
    switch (_state) {
      case PomodoroState.idle:
        return 'Siap Fokus';
      case PomodoroState.work:
        return 'Fokus';
      case PomodoroState.shortBreak:
        return 'Istirahat Singkat';
      case PomodoroState.longBreak:
        return 'Istirahat Panjang';
    }
  }

  String get _timeString {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _startPause() {
    HapticFeedback.mediumImpact();
    if (_isRunning) {
      _pause();
    } else {
      _start();
    }
  }

  void _start() {
    if (_state == PomodoroState.idle) {
      setState(() => _state = PomodoroState.work);
    }
    setState(() => _isRunning = true);
    _pulseCtrl.repeat(reverse: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        _onTimerEnd();
      }
    });
  }

  void _pause() {
    _timer?.cancel();
    _pulseCtrl.stop();
    setState(() => _isRunning = false);
  }

  void _reset() {
    HapticFeedback.lightImpact();
    _timer?.cancel();
    _pulseCtrl.stop();
    setState(() {
      _isRunning = false;
      _state = PomodoroState.idle;
      _secondsLeft = _workMinutes * 60;
    });
  }

  void _skip() {
    HapticFeedback.lightImpact();
    _timer?.cancel();
    _onTimerEnd();
  }

  void _onTimerEnd() {
    HapticFeedback.heavyImpact();
    _pulseCtrl.stop();
    _timer?.cancel();
    if (_state == PomodoroState.work) {
      final newSessions = _sessionsCompleted + 1;
      final isLongBreak = newSessions % _sessionsBeforeLongBreak == 0;
      setState(() {
        _sessionsCompleted = newSessions;
        _state = isLongBreak ? PomodoroState.longBreak : PomodoroState.shortBreak;
        _secondsLeft = isLongBreak ? _longBreakMinutes * 60 : _shortBreakMinutes * 60;
        _isRunning = false;
      });
    } else {
      setState(() {
        _state = PomodoroState.work;
        _secondsLeft = _workMinutes * 60;
        _isRunning = false;
      });
    }
  }

  void _showSettings() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SettingsSheet(
        workMinutes: _workMinutes,
        shortBreakMinutes: _shortBreakMinutes,
        longBreakMinutes: _longBreakMinutes,
        sessionsBeforeLongBreak: _sessionsBeforeLongBreak,
        onSave: (work, short, long, sessions) {
          setState(() {
            _workMinutes = work;
            _shortBreakMinutes = short;
            _longBreakMinutes = long;
            _sessionsBeforeLongBreak = sessions;
            if (!_isRunning) {
              _secondsLeft = work * 60;
              _state = PomodoroState.idle;
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          const AuroraBackground(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Focus',
                        style: GoogleFonts.syne(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      GestureDetector(
                        onTap: _showSettings,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.glassBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.glassBorderSm),
                          ),
                          child: const Icon(
                            Icons.tune_rounded,
                            color: AppColors.textSecondary,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_sessionsBeforeLongBreak, (i) {
                      final filled = i < (_sessionsCompleted % _sessionsBeforeLongBreak);
                      return Container(
                        width: 32,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: filled ? _stateColor : AppColors.glassBg,
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                            color: filled
                                ? _stateColor.withOpacity(0.5)
                                : AppColors.glassBorderSm,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const Spacer(),
                AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (_, child) => Transform.scale(
                    scale: _isRunning ? _pulseAnim.value : 1.0,
                    child: child,
                  ),
                  child: SizedBox(
                    width: 260,
                    height: 260,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 260,
                          height: 260,
                          child: CircularProgressIndicator(
                            value: 1.0,
                            strokeWidth: 8,
                            color: AppColors.glassBg,
                          ),
                        ),
                        SizedBox(
                          width: 260,
                          height: 260,
                          child: CircularProgressIndicator(
                            value: _progress,
                            strokeWidth: 8,
                            color: _stateColor,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        ClipOval(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.glassBg,
                                border: Border.all(
                                  color: _stateColor.withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _stateLabel,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _stateColor,
                                      letterSpacing: 1.2,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _timeString,
                                    style: GoogleFonts.syne(
                                      fontSize: 42,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: -2,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Sesi ke-${_sessionsCompleted + 1}',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      color: AppColors.textTertiary,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ControlButton(icon: Icons.refresh_rounded, onTap: _reset, size: 52),
                      const SizedBox(width: 20),
                      GestureDetector(
                        onTap: _startPause,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [_stateColor, _stateColor.withOpacity(0.7)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _stateColor.withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      _ControlButton(icon: Icons.skip_next_rounded, onTap: _skip, size: 52),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Row(
                    children: [
                      _StatChip(
                        label: 'Sesi Selesai',
                        value: '$_sessionsCompleted',
                        color: _stateColor,
                      ),
                      const SizedBox(width: 12),
                      _StatChip(
                        label: 'Total Fokus',
                        value: '${_sessionsCompleted * _workMinutes} mnt',
                        color: AppColors.amberLight,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const _ControlButton({required this.icon, required this.onTap, required this.size});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.glassBg,
          border: Border.all(color: AppColors.glassBorderSm),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 22),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.glassBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorderSm),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.syne(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: AppColors.textTertiary,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSheet extends StatefulWidget {
  final int workMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int sessionsBeforeLongBreak;
  final Function(int, int, int, int) onSave;

  const _SettingsSheet({
    required this.workMinutes,
    required this.shortBreakMinutes,
    required this.longBreakMinutes,
    required this.sessionsBeforeLongBreak,
    required this.onSave,
  });

  @override
  State<_SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<_SettingsSheet> {
  late int _work;
  late int _short;
  late int _long;
  late int _sessions;

  @override
  void initState() {
    super.initState();
    _work = widget.workMinutes;
    _short = widget.shortBreakMinutes;
    _long = widget.longBreakMinutes;
    _sessions = widget.sessionsBeforeLongBreak;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pengaturan Timer',
            style: GoogleFonts.syne(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 24),
          _SettingRow(
            label: 'Durasi Fokus',
            value: _work,
            min: 5,
            max: 60,
            unit: 'menit',
            color: AppColors.violetLight,
            onChanged: (v) => setState(() => _work = v),
          ),
          const SizedBox(height: 16),
          _SettingRow(
            label: 'Istirahat Singkat',
            value: _short,
            min: 1,
            max: 15,
            unit: 'menit',
            color: AppColors.cyanLight,
            onChanged: (v) => setState(() => _short = v),
          ),
          const SizedBox(height: 16),
          _SettingRow(
            label: 'Istirahat Panjang',
            value: _long,
            min: 5,
            max: 30,
            unit: 'menit',
            color: AppColors.green,
            onChanged: (v) => setState(() => _long = v),
          ),
          const SizedBox(height: 16),
          _SettingRow(
            label: 'Sesi sebelum istirahat panjang',
            value: _sessions,
            min: 2,
            max: 6,
            unit: 'sesi',
            color: AppColors.amberLight,
            onChanged: (v) => setState(() => _sessions = v),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              widget.onSave(_work, _short, _long, _sessions);
              Navigator.pop(context);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.violet, AppColors.blue],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.violet.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
   ),
                ],
              ),
              child: Text(
                'Simpan',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final String unit;
  final Color color;
  final ValueChanged<int> onChanged;

  const _SettingRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppColors.textSecondary,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: value > min ? () => onChanged(value - 1) : null,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.glassBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.glassBorderSm),
                ),
                child: Icon(
                  Icons.remove_rounded,
                  size: 16,
                  color: value > min ? AppColors.textSecondary : AppColors.textTertiary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 60,
              child: Text(
                '$value $unit',
                textAlign: TextAlign.center,
                style: GoogleFonts.syne(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: value < max ? () => onChanged(value + 1) : null,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.glassBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.glassBorderSm),
                ),
                child: Icon(
                  Icons.add_rounded,
                  size: 16,
                  color: value < max ? AppColors.textSecondary : AppColors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
