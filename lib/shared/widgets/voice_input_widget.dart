import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/speech_service.dart';
import '../../core/services/nlp_parser.dart';

class VoiceInputWidget extends StatelessWidget {
  final ValueChanged<String> onResult;
  final ValueChanged<DateTime>? onDateParsed;
  final ValueChanged<DateTime>? onTimeParsed;

  const VoiceInputWidget({
    super.key,
    required this.onResult,
    this.onDateParsed,
    this.onTimeParsed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (_) => _VoiceOverlay(
            onResult: onResult,
            onDateParsed: onDateParsed,
            onTimeParsed: onTimeParsed,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.glassBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.glassBorderSm),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.violet.withOpacity(0.15),
                border: Border.all(
                  color: AppColors.violetLight.withOpacity(0.3),
                ),
              ),
              child: const Icon(
                Icons.mic_none_rounded,
                color: AppColors.violetLight,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INPUT SUARA',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTertiary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Contoh: "Besok rapat jam 9 pagi"',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _VoiceOverlay extends StatefulWidget {
  final ValueChanged<String> onResult;
  final ValueChanged<DateTime>? onDateParsed;
  final ValueChanged<DateTime>? onTimeParsed;

  const _VoiceOverlay({
    required this.onResult,
    this.onDateParsed,
    this.onTimeParsed,
  });

  @override
  State<_VoiceOverlay> createState() => _VoiceOverlayState();
}

class _VoiceOverlayState extends State<_VoiceOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  bool _isListening = false;
  bool _isDone = false;
  String _rawText = '';
  ParsedActivity? _parsed;
  String _statusText = 'Tap tombol mic untuk mulai';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startListening() async {
    HapticFeedback.mediumImpact();
    setState(() {
      _isListening = true;
      _isDone = false;
      _rawText = '';
      _parsed = null;
      _statusText = 'Mendengarkan...';
    });
    _pulseController.repeat(reverse: true);

    final result = await SpeechService.startListening();

    _pulseController.stop();
    _pulseController.reset();

    if (result.isNotEmpty) {
      HapticFeedback.mediumImpact();
      final parsed = NlpParser.parse(result);
      setState(() {
        _isListening = false;
        _isDone = true;
        _rawText = result;
        _parsed = parsed;
        _statusText = 'Hasil transkripsi:';
      });
    } else {
      setState(() {
        _isListening = false;
        _statusText = 'Tidak terdengar, coba lagi';
      });
    }
  }

  void _confirm() {
    if (_parsed != null) {
      widget.onResult(_parsed!.title);
      if (_parsed!.date != null) widget.onDateParsed?.call(_parsed!.date!);
      if (_parsed!.time != null) widget.onTimeParsed?.call(_parsed!.time!);
      Navigator.pop(context);
    }
  }

  void _retry() {
    setState(() {
      _isDone = false;
      _rawText = '';
      _parsed = null;
      _statusText = 'Tap tombol mic untuk mulai';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.glassBorderSm,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Input Suara',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _statusText,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Contoh: "Besok rapat jam 9 pagi"',
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 28),
          if (!_isDone) ...[
            GestureDetector(
              onTap: _isListening ? null : _startListening,
              child: AnimatedBuilder(
                animation: _pulseAnim,
                builder: (_, child) => Transform.scale(
                  scale: _isListening ? _pulseAnim.value : 1.0,
                  child: child,
                ),
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _isListening
                          ? [AppColors.violet, AppColors.blue]
                          : [
                              AppColors.violet.withOpacity(0.6),
                              AppColors.blue.withOpacity(0.6),
                            ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.violet.withOpacity(
                          _isListening ? 0.5 : 0.25,
                        ),
                        blurRadius: _isListening ? 30 : 15,
                        spreadRadius: _isListening ? 5 : 0,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
            ),
            if (_isListening) ...[
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final heights = [12.0, 20.0, 28.0, 20.0, 12.0];
                  return AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (_, __) => Container(
                      width: 4,
                      height: heights[i] * _pulseAnim.value,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: AppColors.violetLight.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ],
          if (_isDone && _parsed != null) ...[
            // Raw text
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.glassBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.violetLight.withOpacity(0.3),
                ),
              ),
              child: Text(
                '"$_rawText"',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            // Parsed result
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.violet.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.violetLight.withOpacity(0.25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'HASIL PARSING',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textTertiary,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _ParsedRow(
                    icon: Icons.title_rounded,
                    label: 'Judul',
                    value: _parsed!.title,
                    color: AppColors.violetLight,
                  ),
                  if (_parsed!.date != null) ...[
                    const SizedBox(height: 8),
                    _ParsedRow(
                      icon: Icons.calendar_today_rounded,
                      label: 'Tanggal',
                      value: '${_parsed!.date!.day}/${_parsed!.date!.month}/${_parsed!.date!.year}',
                      color: AppColors.cyanLight,
                    ),
                  ],
                  if (_parsed!.time != null) ...[
                    const SizedBox(height: 8),
                    _ParsedRow(
                      icon: Icons.access_time_rounded,
                      label: 'Waktu',
                      value: '${_parsed!.time!.hour.toString().padLeft(2, '0')}:${_parsed!.time!.minute.toString().padLeft(2, '0')}',
                      color: AppColors.amberLight,
                    ),
                  ],
                  if (_parsed!.date == null && _parsed!.time == null) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Tanggal & waktu tidak terdeteksi — isi manual',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _retry,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.glassBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.glassBorderSm),
                      ),
                      child: const Text(
                        'Ulangi',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: _confirm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.violet, AppColors.blue],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.violet.withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Gunakan Ini',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ParsedRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ParsedRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textTertiary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
