import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class LibraryFolderCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final int? count;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isAddCard;

  const LibraryFolderCard({
    super.key,
    required this.title,
    required this.icon,
    required this.count,
    required this.onTap,
    this.onLongPress,
    this.isAddCard = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: isAddCard ? AppColors.white : AppColors.textSecondary,
          borderRadius: BorderRadius.circular(16),
          border: isAddCard ? Border.all(color: AppColors.dotInactive, width: 1.4) : null,
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: AppColors.onboardingButton, size: 26),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            if (count != null)
              Text('$count book${count == 1 ? '' : 's'}', style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.dotActive)),
          ],
        ),
      ),
    );
  }
}