import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_time_picker.dart';
import '../../../shared/widgets/custom_date_picker.dart';
import '../data/models/activity_provider.dart';
import '../../../shared/widgets/voice_input_widget.dart';

class AddActivityScreen extends ConsumerStatefulWidget {
  const AddActivityScreen({super.key});

  @override
  ConsumerState<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends ConsumerState<AddActivityScreen> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  final _customReminderController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  DateTime? _selectedTime;
  int _selectedPriority = 1;
  String _selectedCategory = 'Kerja';
  int? _selectedReminder;
  bool _useCustomReminder = false;

  final _categories = AppConstants.defaultCategories;
  final _priorityColors = [
    AppColors.priorityLow,
    AppColors.priorityNormal,
    AppColors.priorityHigh,
    AppColors.priorityCritical,
  ];
  final _reminderOptions = [5, 10, 15];

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    _customReminderController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showCustomDatePicker(
      context,
      initialDate: _selectedDate,
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showCustomTimePicker(
      context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Judul kegiatan tidak boleh kosong'),
        ),
      );
      return;
    }

    int? reminderMins = _selectedReminder;
    if (_useCustomReminder) {
      final custom = int.tryParse(_customReminderController.text);
      if (custom != null && custom >= 1) {
        reminderMins = custom;
      }
    }

    HapticFeedback.mediumImpact();
    ref.read(activityProvider.notifier).add(
          title: _titleController.text.trim(),
          date: _selectedDate,
          time: _selectedTime,
          priority: _selectedPriority,
          category: _selectedCategory,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
          reminderMinutes: reminderMins,
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bgCard,
        title: const Text('Tambah Kegiatan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Judul Kegiatan'),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Masukkan judul kegiatan...',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            VoiceInputWidget(
             onResult: (text) {
             setState(() {
             _titleController.text = text;
             _titleController.selection = TextSelection.fromPosition(
        TextPosition(offset: text.length),
      );
    });
  },
  onDateParsed: (date) {
    setState(() => _selectedDate = date);
  },
  onTimeParsed: (time) {
    setState(() => _selectedTime = time);
  },
),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Tanggal'),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickDate,
                        child: _FieldBox(
                          icon: Icons.calendar_today_rounded,
                          text:
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Waktu'),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickTime,
                        child: _FieldBox(
                          icon: Icons.access_time_rounded,
                          text: _selectedTime == null
                              ? 'Pilih'
                              : '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _label('Prioritas'),
            const SizedBox(height: 8),
            Row(
              children: List.generate(4, (i) {
                final isSelected = _selectedPriority == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _selectedPriority = i);
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _priorityColors[i].withOpacity(0.2)
                            : AppColors.glassBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? _priorityColors[i]
                              : AppColors.glassBorderSm,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        AppConstants.priorityLabels[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? _priorityColors[i]
                              : AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            _label('Kategori'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _selectedCategory = cat);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.violet.withOpacity(0.2)
                          : AppColors.glassBg,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.violetLight
                            : AppColors.glassBorderSm,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected
                            ? AppColors.violetLight
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            _label('Reminder Sebelum Kegiatan'),
            const SizedBox(height: 8),
            if (_selectedTime == null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.amber.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.amber.withOpacity(0.25),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 16, color: AppColors.amber),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pilih waktu dulu untuk aktifkan reminder',
                        style: TextStyle(
                          color: AppColors.amber,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              Row(
                children: [
                  ..._reminderOptions.map((min) {
                    final isSelected =
                        !_useCustomReminder && _selectedReminder == min;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedReminder = min;
                            _useCustomReminder = false;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.cyan.withOpacity(0.15)
                                : AppColors.glassBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.cyanLight
                                  : AppColors.glassBorderSm,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Text(
                            '$min mnt',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? AppColors.cyanLight
                                  : AppColors.textTertiary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _useCustomReminder = true;
                          _selectedReminder = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _useCustomReminder
                              ? AppColors.pink.withOpacity(0.15)
                              : AppColors.glassBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _useCustomReminder
                                ? AppColors.pinkLight
                                : AppColors.glassBorderSm,
                            width: _useCustomReminder ? 1.5 : 1,
                          ),
                        ),
                        child: Text(
                          'Custom',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: _useCustomReminder
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: _useCustomReminder
                                ? AppColors.pinkLight
                                : AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_useCustomReminder) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _customReminderController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Masukkan menit (min. 1)',
                    suffixText: 'menit',
                    suffixStyle: TextStyle(color: AppColors.textTertiary),
                  ),
                ),
              ],
            ],
            const SizedBox(height: 20),
            _label('Catatan (opsional)'),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              style: const TextStyle(color: AppColors.textPrimary),
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Tambah catatan...',
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.violet,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'SIMPAN KEGIATAN',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textTertiary,
          letterSpacing: 0.9,
        ),
      );
}

class _FieldBox extends StatelessWidget {
  const _FieldBox({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorderSm),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.violetLight),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
