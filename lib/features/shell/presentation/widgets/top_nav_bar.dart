import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/responsive_layout.dart';

/// Top App Bar providing route context, theme toggle, and quick actions.
/// Incorporates Stark Group industrial header styling.
class TopNavBar extends ConsumerWidget implements PreferredSizeWidget {
  final VoidCallback? onOpenDrawer;

  const TopNavBar({
    super.key,
    this.onOpenDrawer,
  });

  @override
  Size get preferredSize => const Size.fromHeight(AppConstants.topNavBarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentRoute = GoRouterState.of(context).matchedLocation;
    final isDesktop = ResponsiveLayout.isDesktop(context);

    final title = _getTitleForRoute(currentRoute);

    return Container(
      height: AppConstants.topNavBarHeight,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          // Drawer trigger for tablet/mobile
          if (!isDesktop) ...[
            IconButton(
              icon: const Icon(Icons.menu_rounded),
              tooltip: 'Open navigation',
              onPressed: onOpenDrawer,
            ),
            const SizedBox(width: 8),
          ],

          // Page Title & Breadcrumb
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      fontSize: 18,
                    ),
                  ),
                ),
                if (currentRoute == AppConstants.routeVehicleCreate) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.starkOrange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Registration',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.starkOrangeLight,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Quick Theme Mode Toggle
          IconButton(
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 20,
            ),
            onPressed: () {
              final currentMode = ref.read(themeModeProvider);
              ref.read(themeModeProvider.notifier).state =
                  currentMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
            },
          ),

          // Primary CTA (Desktop shortcut)
          if (isDesktop && currentRoute != AppConstants.routeVehicleCreate) ...[
            const SizedBox(width: 8),
            FilledButton.icon(
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Register Vehicle'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onPressed: () => context.go(AppConstants.routeVehicleCreate),
            ),
          ],
        ],
      ),
    );
  }

  String _getTitleForRoute(String route) {
    if (route == AppConstants.routeVehicles) {
      return 'Fleet Inventory';
    } else if (route == AppConstants.routeVehicleCreate) {
      return 'Register New Vehicle';
    } else if (route.contains('/edit')) {
      return 'Edit Vehicle Specifications';
    }
    return 'Stark Group Fleet Portal';
  }
}
