import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/responsive_layout.dart';
import 'widgets/sidebar_nav.dart';
import 'widgets/top_nav_bar.dart';

/// Responsive Application Shell wrapping all authenticated screens.
class AppShell extends StatefulWidget {
  final Widget child;

  const AppShell({
    super.key,
    required this.child,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            const SidebarNav(),
            Expanded(
              child: Column(
                children: [
                  const TopNavBar(),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: AppConstants.maxContentWidth,
                        ),
                        child: widget.child,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Tablet & Mobile layout with drawer
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: SidebarNav(
          onDestinationSelected: () {
            if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      appBar: TopNavBar(
        onOpenDrawer: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      body: widget.child,
    );
  }
}

