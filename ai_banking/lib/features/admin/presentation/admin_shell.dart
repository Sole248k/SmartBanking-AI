import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_constants.dart';
import '../domain/admin_user.dart';
import '../providers/admin_auth_provider.dart';

class AdminShell extends ConsumerWidget {
  const AdminShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminAsync = ref.watch(adminAuthNotifierProvider);
    final admin = adminAsync.value;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Row(
        children: [
          // Side nav (always visible on web)
          _AdminSideNav(
            currentLocation: location,
            admin: admin,
            onLogout: () async {
              await ref.read(adminAuthNotifierProvider.notifier).logout();
              if (context.mounted) context.go('/admin/login');
            },
          ),
          // Main content
          Expanded(child: child),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────
// Side Navigation
// ──────────────────────────────────────────

class _AdminSideNav extends StatelessWidget {
  const _AdminSideNav({
    required this.currentLocation,
    required this.admin,
    required this.onLogout,
  });

  final String currentLocation;
  final AdminUser? admin;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final items = _buildNavItems(admin);

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1220),
        border: Border(
          right: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B6FE0), Color(0xFF6C3FE0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(Icons.admin_panel_settings_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SmartBank AI',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Admin Portal',
                          style: TextStyle(
                            color: Color(0xFF7BA4F8),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (admin != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMd),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor:
                              const Color(0xFF3B6FE0).withOpacity(0.3),
                          child: Text(
                            admin!.fullName.isNotEmpty
                                ? admin!.fullName[0].toUpperCase()
                                : 'A',
                            style: const TextStyle(
                              color: Color(0xFF7BA4F8),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                admin!.fullName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                admin!.role.displayName,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.45),
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Nav items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(8, 4, 8, 8),
                  child: Text(
                    'MAIN MENU',
                    style: TextStyle(
                      color: Color(0xFF4A5568),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                ...items.map((item) => _NavItem(
                      item: item,
                      isActive: currentLocation.startsWith(item.route),
                    )),
              ],
            ),
          ),

          // Logout button
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.06)),
              ),
            ),
            child: ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusMd)),
              leading: const Icon(Icons.logout_rounded,
                  color: Color(0xFF718096), size: 20),
              title: const Text(
                'Sign Out',
                style: TextStyle(color: Color(0xFF718096), fontSize: 14),
              ),
              onTap: onLogout,
              dense: true,
            ),
          ),
        ],
      ),
    );
  }

  List<_NavItemData> _buildNavItems(AdminUser? admin) {
    final items = <_NavItemData>[
      _NavItemData(
        icon: Icons.dashboard_rounded,
        label: 'Dashboard',
        route: '/admin',
        exact: true,
      ),
      _NavItemData(
        icon: Icons.verified_user_rounded,
        label: 'KYC Queue',
        route: '/admin/kyc',
      ),
      _NavItemData(
        icon: Icons.assignment_rounded,
        label: 'Applications',
        route: '/admin/applications',
      ),
      _NavItemData(
        icon: Icons.search_rounded,
        label: 'User Search',
        route: '/admin/users',
      ),
      _NavItemData(
        icon: Icons.history_rounded,
        label: 'Audit Logs',
        route: '/admin/audit',
      ),
    ];

    // Super Admin only
    if (admin?.role == AdminRole.superAdmin) {
      items.add(_NavItemData(
        icon: Icons.manage_accounts_rounded,
        label: 'Admin Management',
        route: '/admin/manage-admins',
      ));
    }

    return items;
  }
}

class _NavItemData {
  const _NavItemData({
    required this.icon,
    required this.label,
    required this.route,
    this.exact = false,
  });

  final IconData icon;
  final String label;
  final String route;
  final bool exact;
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.item, required this.isActive});

  final _NavItemData item;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF3B6FE0).withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        ),
        child: ListTile(
          onTap: () => context.go(item.route),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          leading: Icon(
            item.icon,
            color: isActive ? const Color(0xFF7BA4F8) : const Color(0xFF4A5568),
            size: 20,
          ),
          title: Text(
            item.label,
            style: TextStyle(
              color:
                  isActive ? const Color(0xFF7BA4F8) : const Color(0xFF718096),
              fontSize: 14,
              fontWeight:
                  isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          dense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          selected: isActive,
        ),
      ),
    );
  }
}
