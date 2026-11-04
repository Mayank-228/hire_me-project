// lib/shared/widgets/hireme_app_bar.dart

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Top app bar matching the HireMe HTML design:
/// Logo text on left, mode badge, and user avatar on right.
class HireMeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String modeLabel;
  final String? avatarUrl;
  final VoidCallback? onAvatarTap;

  const HireMeAppBar({
    super.key,
    this.modeLabel = 'Worker Mode',
    this.avatarUrl,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface.withOpacity(0.85),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.04),
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: Logo + mode label
            Row(
              children: [
                // App icon placeholder
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text('H', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  modeLabel,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                    color: AppColors.primaryContainer,
                  ),
                ),
              ],
            ),
            // Right: Avatar
            GestureDetector(
              onTap: onAvatarTap,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceContainerHigh,
                  image: avatarUrl != null
                      ? DecorationImage(image: NetworkImage(avatarUrl!), fit: BoxFit.cover)
                      : null,
                ),
                child: avatarUrl == null
                    ? const Icon(Icons.person_rounded, size: 20, color: AppColors.outline)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
