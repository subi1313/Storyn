import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class MoodChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const MoodChip({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.onboardingButton : AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.onboardingButton : AppColors.dotInactive,
                width: 1.2,
              ),
            ),
            child: Icon(
              icon,
              color: isSelected ? AppColors.white : AppColors.textPrimary,
              size: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: isSelected ? AppColors.dotActive : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}