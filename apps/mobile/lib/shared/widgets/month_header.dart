import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';

class MonthHeader extends StatelessWidget {
  final String monthYear;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final Widget? trailing;

  const MonthHeader({
    super.key, 
    required this.monthYear,
    this.onPrevious,
    this.onNext,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edgeMargin, vertical: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (onPrevious != null)
                IconButton(icon: const Icon(Icons.chevron_left), onPressed: onPrevious),
              Text(monthYear, style: Theme.of(context).textTheme.titleLarge),
              if (onNext != null)
                IconButton(icon: const Icon(Icons.chevron_right), onPressed: onNext),
            ],
          ),
          ?trailing,
        ],
      ),
    );
  }
}
