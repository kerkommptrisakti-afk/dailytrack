import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';

class SearchBarWidget extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  const SearchBarWidget({
    super.key,
    required this.onChanged,
    this.onClear,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorderSm),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            color: AppColors.textTertiary,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                hintText: 'Cari kegiatan...',
                hintStyle: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (val) {
                setState(() => _hasText = val.isNotEmpty);
                widget.onChanged(val);
              },
            ),
          ),
          if (_hasText)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _controller.clear();
                setState(() => _hasText = false);
                widget.onChanged('');
                widget.onClear?.call();
              },
              child: const Icon(
                Icons.close_rounded,
                color: AppColors.textTertiary,
                size: 18,
              ),
            ),
        ],
      ),
    );
  }
}
