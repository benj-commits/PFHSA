import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/theme_controller.dart';
import '../models/user.dart';

class _NavEntry {
  final String key;
  final IconData icon;
  final String label;
  const _NavEntry(this.key, this.icon, this.label);
}

const _navEntries = [
  _NavEntry('overview', Icons.grid_view_rounded, 'Overview'),
  _NavEntry('ledger', Icons.receipt_long_rounded, 'Ledger'),
  _NavEntry('budgets', Icons.pie_chart_rounded, 'Budgets'),
  _NavEntry('goals', Icons.flag_rounded, 'Goals'),
  _NavEntry('profile', Icons.person_rounded, 'Profile'),
];

/// A persistent, collapsible sidebar shown on every screen (including the
/// login/register flow), matching the same interaction pattern as the web
/// app's sidebar: an icon rail that expands to show labels, plus a dark
/// mode pill switch. Nav items, the mini profile, and logout only render
/// once the user is authenticated.
class AppSidebar extends StatefulWidget {
  final bool isAuthenticated;
  final String currentView;
  final ValueChanged<String> onViewSelected;
  final VoidCallback onLogout;
  final User? user;

  const AppSidebar({
    super.key,
    required this.isAuthenticated,
    required this.currentView,
    required this.onViewSelected,
    required this.onLogout,
    this.user,
  });

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  bool _collapsed = true; // start collapsed to save space on phone screens

  @override
  Widget build(BuildContext context) {
    final width = _collapsed ? 72.0 : 220.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.paperDim,
        border: Border(right: BorderSide(color: AppColors.hairline)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  if (!_collapsed) ...[
                    Icon(Icons.account_balance_wallet_rounded, size: 20, color: AppColors.brass),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text('PFHSA',
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.display(16, weight: FontWeight.w600)),
                    ),
                  ] else
                    const Spacer(),
                  IconButton(
                    onPressed: () => setState(() => _collapsed = !_collapsed),
                    icon: Icon(_collapsed ? Icons.menu_rounded : Icons.menu_open_rounded, size: 20),
                    color: AppColors.mutedInk,
                    tooltip: 'Toggle sidebar',
                  ),
                ],
              ),
            ),
            Divider(color: AppColors.hairline, height: 24),

            if (widget.isAuthenticated)
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: _navEntries.map((entry) {
                    final active = widget.currentView == entry.key;
                    return _SidebarItem(
                      icon: entry.icon,
                      label: entry.label,
                      collapsed: _collapsed,
                      active: active,
                      onTap: () => widget.onViewSelected(entry.key),
                    );
                  }).toList(),
                ),
              )
            else
              const Spacer(),

            // ---- Dark mode toggle ----
            AnimatedBuilder(
              animation: ThemeController.instance,
              builder: (context, _) {
                final isDark = ThemeController.instance.isDark;
                return InkWell(
                  onTap: () => ThemeController.instance.toggle(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      mainAxisAlignment: _collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                      children: [
                        Icon(isDark ? Icons.dark_mode_rounded : Icons.dark_mode_outlined,
                            size: 20, color: AppColors.mutedInk),
                        if (!_collapsed) ...[
                          const SizedBox(width: 14),
                          Expanded(child: Text('Dark Mode', style: AppTextStyles.body(13, color: AppColors.mutedInk))),
                          Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              value: isDark,
                              onChanged: (_) => ThemeController.instance.toggle(),
                              activeColor: AppColors.pine,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),

            if (widget.isAuthenticated) ...[
              Divider(color: AppColors.hairline, height: 8),
              InkWell(
                onTap: null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    mainAxisAlignment: _collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: AppColors.pine,
                        child: Text(
                          widget.user != null && widget.user!.name.isNotEmpty
                              ? widget.user!.name[0].toUpperCase()
                              : '?',
                          style: AppTextStyles.display(12, color: AppColors.paper),
                        ),
                      ),
                      if (!_collapsed) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.user?.name ?? '',
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.body(13, weight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              _SidebarItem(
                icon: Icons.logout_rounded,
                label: 'Log out',
                collapsed: _collapsed,
                active: false,
                iconColor: AppColors.clay,
                onTap: widget.onLogout,
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool collapsed;
  final bool active;
  final Color? iconColor;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.collapsed,
    required this.active,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? (active ? AppColors.pine : AppColors.mutedInk);
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: active ? AppColors.paper : Colors.transparent,
          border: active ? Border(right: BorderSide(color: AppColors.pine, width: 3)) : null,
        ),
        child: Row(
          mainAxisAlignment: collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: color),
            if (!collapsed) ...[
              const SizedBox(width: 14),
              Text(label,
                  style: AppTextStyles.body(14, color: color, weight: active ? FontWeight.w600 : FontWeight.w500)),
            ],
          ],
        ),
      ),
    );
  }
}
