import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';

class CustomTimePicker extends StatefulWidget {
  final DateTime? initialTime;
  final ValueChanged<DateTime> onChanged;

  const CustomTimePicker({
    super.key,
    this.initialTime,
    required this.onChanged,
  });

  @override
  State<CustomTimePicker> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  late int _hour;
  late int _minute;

  @override
  void initState() {
    super.initState();
    final t = widget.initialTime ?? DateTime.now();
    _hour = t.hour;
    _minute = t.minute;
  }

  void _emit() {
    final now = DateTime.now();
    widget.onChanged(DateTime(now.year, now.month, now.day, _hour, _minute));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Pilih Waktu',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Spinner(
                value: _hour,
                min: 0,
                max: 23,
                label: 'Jam',
                onChanged: (v) {
                  HapticFeedback.lightImpact();
                  setState(() => _hour = v);
                  _emit();
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  ':',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _Spinner(
                value: _minute,
                min: 0,
                max: 59,
                label: 'Menit',
                onChanged: (v) {
                  HapticFeedback.lightImpact();
                  setState(() => _minute = v);
                  _emit();
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.violet,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Selesai',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Spinner extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final String label;
  final ValueChanged<int> onChanged;

  const _Spinner({
    required this.value,
    required this.min,
    required this.max,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textTertiary,
            fontSize: 11,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.glassBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorderSm),
          ),
          child: Column(
            children: [
              IconButton(
                onPressed: () {
                  final next = value >= max ? min : value + 1;
                  onChanged(next);
                },
                icon: const Icon(
                  Icons.keyboard_arrow_up_rounded,
                  color: AppColors.violetLight,
                ),
              ),
              Container(
                width: 72,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.violet.withOpacity(0.15),
                  border: Border.symmetric(
                    horizontal: BorderSide(
                      color: AppColors.glassBorderSm,
                    ),
                  ),
                ),
                child: Text(
                  value.toString().padLeft(2, '0'),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  final next = value <= min ? max : value - 1;
                  onChanged(next);
                },
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.violetLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<DateTime?> showCustomTimePicker(
  BuildContext context, {
  DateTime? initialTime,
}) async {
  DateTime? result;
  await showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      child: CustomTimePicker(
        initialTime: initialTime,
        onChanged: (t) => result = t,
      ),
    ),
  );
  return result;
}
