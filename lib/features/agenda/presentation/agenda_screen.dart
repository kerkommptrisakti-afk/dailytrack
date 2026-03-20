import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/aurora_background.dart';
import '../../activity/data/models/activity_model.dart';
import '../../activity/data/models/activity_provider.dart';
import '../../activity/presentation/add_activity_screen.dart';

enum AgendaMode { today, week, month }

class AgendaScreen extends ConsumerStatefulWidget {
  const AgendaScreen({super.key});

  @override
  ConsumerState<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends ConsumerState<AgendaScreen> {
  AgendaMode _mode = AgendaMode.today;
  DateTime _focusedDay = DateTime.now();

  final _months = [
    'Jan','Feb','Mar','Apr','Mei','Jun',
    'Jul','Ags','Sep','Okt','Nov','Des'
  ];
  final _days = ['Sen','Sel','Rab','Kam','Jum','Sab','Min'];

  List<Activity> _getActivities(List<Activity> all) {
    switch (_mode) {
      case AgendaMode.today:
        return all.where((a) =>
          a.date.year == _focusedDay.year &&
          a.date.month == _focusedDay.month &&
          a.date.day == _focusedDay.day
        ).toList()..sort((a, b) {
          if (a.time == null) return 1;
          if (b.time == null) return -1;
          return a.time!.compareTo(b.time!);
        });
      case AgendaMode.week:
        final start = _focusedDay.subtract(
          Duration(days: _focusedDay.weekday - 1),
        );
        final end = start.add(const Duration(days: 6));
        return all.where((a) =>
          !a.date.isBefore(DateTime(start.year, start.month, start.day)) &&
          !a.date.isAfter(DateTime(end.year, end.month, end.day, 23, 59))
        ).toList()..sort((a, b) => a.date.compareTo(b.date));
      case AgendaMode.month:
        return all.where((a) =>
          a.date.year == _focusedDay.year &&
          a.date.month == _focusedDay.month
        ).toList()..sort((a, b) => a.date.compareTo(b.date));
    }
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(activityProvider);
    final filtered = _getActivities(all);

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
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Agenda',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          IconButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AddActivityScreen(),
                                ),
                              );
                            },
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.violet, AppColors.blue],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _ModeSelector(
                        mode: _mode,
                        onChanged: (m) {
                          HapticFeedback.lightImpact();
                          setState(() => _mode = m);
                        },
                      ),
                      const SizedBox(height: 16),
                      _DateNav(
                        mode: _mode,
                        focusedDay: _focusedDay,
                        months: _months,
                        onPrev: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            switch (_mode) {
                              case AgendaMode.today:
                                _focusedDay = _focusedDay.subtract(
                                  const Duration(days: 1),
                                );
                                break;
                              case AgendaMode.week:
                                _focusedDay = _focusedDay.subtract(
                                  const Duration(days: 7),
                                );
                                break;
                              case AgendaMode.month:
                                _focusedDay = DateTime(
                                  _focusedDay.year,
                                  _focusedDay.month - 1,
                                );
                                break;
                            }
                          });
                        },
                        onNext: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            switch (_mode) {
                              case AgendaMode.today:
                                _focusedDay = _focusedDay.add(
                                  const Duration(days: 1),
                                );
                                break;
                              case AgendaMode.week:
                                _focusedDay = _focusedDay.add(
                                  const Duration(days: 7),
                                );
                                break;
                              case AgendaMode.month:
                                _focusedDay = DateTime(
                                  _focusedDay.year,
                                  _focusedDay.month + 1,
                                );
                                break;
                            }
                          });
                        },
                      ),
                      if (_mode == AgendaMode.week) ...[
                        const SizedBox(height: 12),
                        _WeekRow(
                          focusedDay: _focusedDay,
                          days: _days,
                          activities: all,
                          onDayTap: (d) {
                            HapticFeedback.lightImpact();
                            setState(() => _focusedDay = d);
                          },
                        ),
                      ],
                      if (_mode == AgendaMode.month) ...[
                        const SizedBox(height: 12),
                        _MonthGrid(
                          focusedDay: _focusedDay,
                          days: _days,
                          activities: all,
                          onDayTap: (d) {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _focusedDay = d;
                              _mode = AgendaMode.today;
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_note_rounded,
                                size: 48,
                                color: AppColors.textTertiary,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Tidak ada kegiatan',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, i) =>
                              _AgendaItem(activity: filtered[i]),
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

class _ModeSelector extends StatelessWidget {
  final AgendaMode mode;
  final ValueChanged<AgendaMode> onChanged;

  const _ModeSelector({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorderSm),
      ),
      child: Row(
        children: AgendaMode.values.map((m) {
          final isSelected = mode == m;
          final labels = ['Hari Ini', 'Minggu', 'Bulan'];
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(m),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.violet
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  labels[m.index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: isSelected
                        ? Colors.white
                        : AppColors.textTertiary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DateNav extends StatelessWidget {
  final AgendaMode mode;
  final DateTime focusedDay;
  final List<String> months;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _DateNav({
    required this.mode,
    required this.focusedDay,
    required this.months,
    required this.onPrev,
    required this.onNext,
  });

  String get _label {
    switch (mode) {
      case AgendaMode.today:
        return '${focusedDay.day} ${months[focusedDay.month - 1]} ${focusedDay.year}';
      case AgendaMode.week:
        final start = focusedDay.subtract(
          Duration(days: focusedDay.weekday - 1),
        );
        final end = start.add(const Duration(days: 6));
        return '${start.day} ${months[start.month - 1]} — ${end.day} ${months[end.month - 1]}';
      case AgendaMode.month:
        return '${months[focusedDay.month - 1]} ${focusedDay.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: onPrev,
          icon: const Icon(
            Icons.chevron_left_rounded,
            color: AppColors.violetLight,
          ),
        ),
        Text(
          _label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.violetLight,
          ),
        ),
      ],
    );
  }
}

class _WeekRow extends StatelessWidget {
  final DateTime focusedDay;
  final List<String> days;
  final List<Activity> activities;
  final ValueChanged<DateTime> onDayTap;

  const _WeekRow({
    required this.focusedDay,
    required this.days,
    required this.activities,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final start = focusedDay.subtract(
      Duration(days: focusedDay.weekday - 1),
    );
    return Row(
      children: List.generate(7, (i) {
        final day = start.add(Duration(days: i));
        final isSelected = day.day == focusedDay.day &&
            day.month == focusedDay.month;
        final isToday = day.day == DateTime.now().day &&
            day.month == DateTime.now().month &&
            day.year == DateTime.now().year;
        final hasActivity = activities.any((a) =>
            a.date.day == day.day &&
            a.date.month == day.month &&
            a.date.year == day.year);
        return Expanded(
          child: GestureDetector(
            onTap: () => onDayTap(day),
            child: Column(
              children: [
                Text(
                  days[i],
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected
                        ? AppColors.violetLight
                        : AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.violet
                        : isToday
                            ? AppColors.violet.withOpacity(0.2)
                            : Colors.transparent,
                    shape: BoxShape.circle,
                    border: isToday && !isSelected
                        ? Border.all(color: AppColors.violetLight)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: hasActivity
                        ? AppColors.violetLight
                        : Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  final DateTime focusedDay;
  final List<String> days;
  final List<Activity> activities;
  final ValueChanged<DateTime> onDayTap;

  const _MonthGrid({
    required this.focusedDay,
    required this.days,
    required this.activities,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(focusedDay.year, focusedDay.month, 1);
    final lastDay = DateTime(focusedDay.year, focusedDay.month + 1, 0);
    final startOffset = (firstDay.weekday - 1) % 7;
    final cells = <DateTime?>[];
    for (int i = 0; i < startOffset; i++) cells.add(null);
    for (int d = 1; d <= lastDay.day; d++) {
      cells.add(DateTime(focusedDay.year, focusedDay.month, d));
    }
    while (cells.length % 7 != 0) cells.add(null);

    return Column(
      children: [
        Row(
          children: days.map((d) => Expanded(
            child: Center(
              child: Text(
                d,
                style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 10,
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
            final isToday = date.day == DateTime.now().day &&
                date.month == DateTime.now().month &&
                date.year == DateTime.now().year;
            final hasActivity = activities.any((a) =>
                a.date.day == date.day &&
                a.date.month == date.month &&
                a.date.year == date.year);
            return GestureDetector(
              onTap: () => onDayTap(date),
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isToday
                      ? AppColors.violet.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isToday
                      ? Border.all(color: AppColors.violetLight)
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isToday
                            ? AppColors.violetLight
                            : AppColors.textPrimary,
                        fontWeight: isToday
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                    if (hasActivity)
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.violetLight,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _AgendaItem extends ConsumerWidget {
  const _AgendaItem({required this.activity});
  final Activity activity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final priorityColor = AppColors.forPriority(activity.priority);
    return Dismissible(
      key: Key(activity.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        HapticFeedback.mediumImpact();
        ref.read(activityProvider.notifier).delete(activity.id);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_rounded, color: AppColors.red),
      ),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          ref.read(activityProvider.notifier).toggleDone(activity.id);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.glassBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.glassBorderSm),
          ),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 36,
                decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
           const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: activity.isDone
                            ? AppColors.textTertiary
                            : AppColors.textPrimary,
                        decoration: activity.isDone
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      activity.time == null
                          ? '${activity.date.day}/${activity.date.month} • ${activity.category}'
                          : '${activity.time!.hour.toString().padLeft(2, '0')}:${activity.time!.minute.toString().padLeft(2, '0')} • ${activity.category}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (activity.reminderMinutes != null)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.cyanLight.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '${activity.reminderMinutes}m',
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.cyanLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Icon(
                activity.isDone
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: activity.isDone
                    ? AppColors.green
                    : AppColors.textTertiary,
                size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
