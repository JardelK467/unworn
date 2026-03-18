import 'package:flutter/material.dart';

import '../../../../core/constants/consts.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(InfoSpacing.cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: InfoSpacing.cardIconSize,
            height: InfoSpacing.cardIconSize,
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: AppColors.purple),
          ),
          const SizedBox(width: InfoSpacing.cardIconMarginRight),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: InfoSpacing.cardTitleFontSize,
                    fontWeight: InfoSpacing.cardTitleFontWeight,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: InfoSpacing.cardTitleSubtitleGap),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: InfoSpacing.cardSubtitleFontSize,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade600,
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
