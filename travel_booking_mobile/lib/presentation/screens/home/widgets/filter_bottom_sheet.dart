import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/plan_filter.dart';

class FilterBottomSheet extends StatefulWidget {
  final PlanFilter currentFilter;
  final void Function(PlanFilter) onApply;

  const FilterBottomSheet({
    super.key,
    required this.currentFilter,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context,
    PlanFilter currentFilter,
    void Function(PlanFilter) onApply,
  ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterBottomSheet(
        currentFilter: currentFilter,
        onApply: onApply,
      ),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late PlanFilter _filter;

  static const _categories = [
    ('', '全て'),
    ('city', '都市観光'),
    ('cultural', '文化体験'),
    ('nature', '自然'),
    ('adventure', 'アドベンチャー'),
    ('leisure', 'リゾート'),
  ];

  static const _regions = [
    ('', '全て'),
    ('アジア', 'アジア'),
    ('ヨーロッパ', 'ヨーロッパ'),
    ('アメリカ大陸', 'アメリカ'),
    ('オセアニア', 'オセアニア'),
    ('アフリカ', 'アフリカ'),
  ];

  static const _difficulties = [
    ('', '全て'),
    ('easy', 'やさしい'),
    ('moderate', 'ふつう'),
    ('hard', 'ハード'),
  ];

  static const _sortOptions = [
    ('rating', '評価順'),
    ('price', '価格順'),
    ('duration', '期間順'),
    ('createdAt', '新着順'),
  ];

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              _buildHandle(),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildSectionTitle('カテゴリー'),
                    _buildChips(
                      _categories,
                      _filter.category ?? '',
                      (v) => setState(() => _filter = _filter.copyWith(
                            category: v.isEmpty ? null : v,
                            clearCategory: v.isEmpty,
                          )),
                    ),
                    _buildSectionTitle('地域'),
                    _buildChips(
                      _regions,
                      _filter.region ?? '',
                      (v) => setState(() => _filter = _filter.copyWith(
                            region: v.isEmpty ? null : v,
                            clearRegion: v.isEmpty,
                          )),
                    ),
                    _buildSectionTitle('難易度'),
                    _buildChips(
                      _difficulties,
                      _filter.difficulty ?? '',
                      (v) => setState(() => _filter = _filter.copyWith(
                            difficulty: v.isEmpty ? null : v,
                            clearDifficulty: v.isEmpty,
                          )),
                    ),
                    _buildSectionTitle('最大日数: ${_filter.maxDuration ?? "制限なし"}日'),
                    Slider(
                      value: (_filter.maxDuration ?? 30).toDouble(),
                      min: 1,
                      max: 30,
                      divisions: 29,
                      activeColor: AppTheme.primaryColor,
                      onChanged: (v) => setState(
                        () => _filter = _filter.copyWith(maxDuration: v.toInt()),
                      ),
                    ),
                    _buildSectionTitle('並び替え'),
                    _buildChips(
                      _sortOptions,
                      _filter.sortBy,
                      (v) => setState(() => _filter = _filter.copyWith(sortBy: v)),
                      multiSelect: false,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() => _filter = const PlanFilter());
                            },
                            child: const Text('リセット'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              widget.onApply(_filter);
                              Navigator.pop(context);
                            },
                            child: const Text('適用する'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppTheme.dividerColor,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildChips(
    List<(String, String)> options,
    String selected,
    void Function(String) onSelect, {
    bool multiSelect = false,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final (value, label) = option;
        final isSelected = selected == value;
        return FilterChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (_) => onSelect(value),
          selectedColor: AppTheme.primaryColor.withValues(alpha: 0.15),
          checkmarkColor: AppTheme.primaryColor,
          labelStyle: TextStyle(
            color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }
}
