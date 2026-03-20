import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';

class CustomDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onChanged;

  const CustomDatePicker({
    super.key,
    required this.initialDate,
    required this.onChanged,
  });

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  late DateTime _selected;
  late DateTime _viewMonth;

  final _months = [
    'Januari','Februari','Maret','April','Mei','Juni',
    'Juli','Agustus','September','Oktober','November','Desember'
  ];
  final _days = ['Sen','Sel','Rab','Kam','Jum','Sab','Min'];

  @override
  void initState() {
    super.initState();
    _selected = widget.initialDate;
    _viewMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
  }

  List<DateTime?> _buildCalendar() {
    final firstDay = DateTime(_viewMonth.year, _viewMonth.month, 1);
    final lastDay = DateTime(_viewMonth.year, _viewMonth.month + 1, 0);
    final startOffset = (firstDay.weekday - 1) % 7;
    final cells = <DateTime?>[];
    for (int i = 0; i < startOffset; i++) cells.add(null);
    for (int d = 1; d <= lastDay.day; d++) {
      cells.add(DateTime(_viewMonth.year, _viewMonth.month, d));
    }
    while (cells.length % 7 != 0) cells.add(null);
    return cells;
  }

  @override
  Widget build(BuildContext context) {
    final cells = _buildCalendar();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _viewMonth = DateTime(
                      _viewMonth.year,
                      _viewMonth.month - 1,
                    );
                  });
                },
                icon: const Icon(
                  Icons.chevron_left_rounded,
                  color: AppColors.violetLight,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final years = List.generate(10, (i) => DateTime.now().year - 2 + i);
                  final picked = await showDialog<int>(
                    context: context,
                    builder: (_) => Dialog(
                      backgroundColor: AppColors.bgCard,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: SizedBox(
                        height: 300,
                        child: ListView.builder(
                          itemCount: years.length,
                          itemBuilder: (_, i) => ListTile(
                            title: Text(
                              '${years[i]}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: years[i] == _viewMonth.year
                                    ? AppColors.violetLight
                                    : AppColors.textPrimary,
                                fontWeight: years[i] == _viewMonth.year
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                            ),
                            onTap: () => Navigator.pop(context, years[i]),
                          ),
                        ),
                      ),
                    ),
                  );
                  if (picked != null) {
                    setState(() {
                      _viewMonth = DateTime(picked, _viewMonth.month);
                    });
                  }
                },
                child: Text(
                  '${_months[_viewMonth.month - 1]} ${_viewMonth.year}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _viewMonth = DateTime(
                      _viewMonth.year,
                      _viewMonth.month + 1,
                    );
                  });
                },
                icon: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.violetLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: _days.map((d) => Expanded(
              child: Center(
                child: Text(
                  d,
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: cells.length,
            itemBuilder: (_, i) {
              final date = cells[i];
              if (date == null) return const SizedBox();
              final isSelected = date.day == _selected.day &&
                  date.month == _selected.month &&
                  date.year == _selected.year;
              final isToday = date.day == DateTime.now().day &&
                  date.month == DateTime.now().month &&
                  date.year == DateTime.now().year;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selected = date);
                  widget.onChanged(date);
                },
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.violet
                        : isToday
                            ? AppColors.violet.withOpacity(0.2)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: isToday && !isSelected
                        ? Border.all(color: AppColors.violetLight, width: 1)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: isSelected || isToday
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
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
                'Pilih',
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

Future<DateTime?> showCustomDatePicker(
  BuildContext context, {
  required DateTime initialDate,
}) async {
  DateTime? result;
  await showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: CustomDatePicker(
        initialDate: initialDate,
        onChanged: (d) => result = d,
      ),
    ),
  );
  return result;
}
