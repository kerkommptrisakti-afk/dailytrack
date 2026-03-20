import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/aurora_background.dart';
import '../../../shared/widgets/search_bar_widget.dart';
import '../../../shared/widgets/filter_chips_widget.dart';
import '../../activity/data/models/activity_model.dart';
import '../../activity/data/models/activity_provider.dart';
import '../../activity/presentation/add_activity_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _searchQuery = '';
  String? _filterCategory;
  int? _filterPriority;

  List<Activity> _applyFilters(List<Activity> list) {
    return list.where((a) {
      final matchSearch = _searchQuery.isEmpty ||
          a.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          a.category.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchCategory =
          _filterCategory == null || a.category == _filterCategory;
      final matchPriority =
          _filterPriority == null || a.priority == _filterPriority;
      return matchSearch && matchCategory && matchPriority;
    }).toList();
  }

  String _formattedDate() {
    final now = DateTime.now();
    final days = [
      'Senin','Selasa','Rabu','Kamis','Jumat','Sabtu','Minggu'
    ];
    final months = [
      'Jan','Feb','Mar','Apr','Mei','Jun',
      'Jul','Ags','Sep','Okt','Nov','Des'
    ];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final todayList = ref.watch(todayActivitiesProvider);
    final filteredList = _applyFilters(todayList);
    final doneCount = todayList.where((a) => a.isDone).length;
    final streak = todayList.isEmpty
        ? 0
        : (doneCount / todayList.length * 100).round();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          const AuroraBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo, Bro! 👋',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formattedDate(),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [AppColors.violet, AppColors.blue],
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'B',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Stat cards
                  Row(
                    children: [
                      _StatCard(
                        label: 'Hari Ini',
                        value: '${todayList.length}',
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        label: 'Selesai',
                        value: '$doneCount',
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        label: 'Streak',
                        value: '$streak%',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Search bar
                  SearchBarWidget(
                    onChanged: (q) => setState(() => _searchQuery = q),
                    onClear: () => setState(() => _searchQuery = ''),
                  ),
                  const SizedBox(height: 12),
                  // Filter chips
                  FilterChipsWidget(
                    selectedCategory: _filterCategory,
                    selectedPriority: _filterPriority,
                    onCategoryChanged: (c) =>
                        setState(() => _filterCategory = c),
                    onPriorityChanged: (p) =>
                        setState(() => _filterPriority = p),
                  ),
                  const SizedBox(height: 16),
                  // Section title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'JADWAL HARI INI',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(
                              color: AppColors.violetLight,
                              letterSpacing: 1.2,
                              fontSize: 10,
                            ),
                      ),
                      if (filteredList.isNotEmpty)
                        Text(
                          '${filteredList.length} kegiatan',
                          style: const TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Activity list
                  Expanded(
                    child: filteredList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _searchQuery.isNotEmpty ||
                                          _filterCategory != null ||
                                          _filterPriority != null
                                      ? Icons.search_off_rounded
                                      : Icons.add_circle_outline_rounded,
                                  size: 48,
                                  color: AppColors.textTertiary,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _searchQuery.isNotEmpty ||
                                          _filterCategory != null ||
                                          _filterPriority != null
                                      ? 'Tidak ada hasil'
                                      : 'Belum ada kegiatan',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _searchQuery.isNotEmpty ||
                                          _filterCategory != null ||
                                          _filterPriority != null
                                      ? 'Coba ubah filter atau kata kunci'
                                      : 'Tap + untuk tambah kegiatan',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: AppColors.textTertiary,
                                        fontSize: 12,
                                      ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.only(bottom: 100),
                            itemCount: filteredList.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, i) =>
                                _ActivityItem(activity: filteredList[i]),
                          ),
                  ),
                ],
              ),
            ),
          ),
          // FAB
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddActivityScreen(),
                    ),
                  );
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.violet, AppColors.blue],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.violet.withOpacity(0.45),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends ConsumerWidget {
  const _ActivityItem({required this.activity});
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
                          ? activity.category
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: priorityColor.withOpacity(0.25),
                  ),
                ),
                child: Text(
                  AppConstants.priorityLabels[activity.priority],
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: priorityColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
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

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.glassBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorderSm),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium!
                  .copyWith(fontSize: 22),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontSize: 10,
                    color: AppColors.textTertiary,
                    letterSpacing: 0.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
