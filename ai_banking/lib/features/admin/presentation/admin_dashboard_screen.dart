import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_constants.dart';
import '../domain/admin_user.dart';
import '../providers/admin_auth_provider.dart';
import '../providers/admin_data_providers.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final admin = ref.watch(adminAuthNotifierProvider).value;
    final statsAsync = ref.watch(adminDashboardStatsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(admin),
            const SizedBox(height: AppConstants.xl),

            // Stats cards
            statsAsync.when(
              data: (stats) => _buildStatsRow(context, stats),
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFF3B6FE0)),
              ),
              error: (e, _) => _buildStatsRow(context, const {}),
            ),
            const SizedBox(height: AppConstants.xl),

            // Quick Actions
            _buildSectionTitle('Quick Actions'),
            const SizedBox(height: AppConstants.md),
            _buildQuickActions(context, admin),
            const SizedBox(height: AppConstants.xl),

            // Recent Activity (Audit Logs preview)
            _buildSectionTitle('Recent Activity'),
            const SizedBox(height: AppConstants.md),
            _buildRecentActivity(ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AdminUser? admin) {
    final hour = DateTime.now().hour;
    String greeting = 'Good morning';
    if (hour >= 12 && hour < 17) greeting = 'Good afternoon';
    if (hour >= 17) greeting = 'Good evening';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting,',
              style: TextStyle(
                color: Colors.white.withOpacity(0.45),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              admin?.fullName ?? 'Administrator',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF3B6FE0).withOpacity(0.15),
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusMax),
              ),
              child: Text(
                admin?.role.displayName ?? '',
                style: const TextStyle(
                  color: Color(0xFF7BA4F8),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            border: Border.all(color: Colors.white.withOpacity(0.07)),
          ),
          child: Column(
            children: [
              Text(
                _formatDate(),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatTime(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context, Map<String, int> stats) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _StatCard(
          label: 'Pending Applications',
          value: '${stats['pendingApplications'] ?? 0}',
          icon: Icons.assignment_late_rounded,
          color: const Color(0xFFFFB347),
          onTap: () => context.go('/admin/applications'),
        ),
        _StatCard(
          label: 'Under Review',
          value: '${stats['underReviewApplications'] ?? 0}',
          icon: Icons.pending_actions_rounded,
          color: const Color(0xFF7BA4F8),
          onTap: () => context.go('/admin/applications'),
        ),
        _StatCard(
          label: 'Pending KYC',
          value: '${stats['pendingKyc'] ?? 0}',
          icon: Icons.verified_user_rounded,
          color: const Color(0xFF68D391),
          onTap: () => context.go('/admin/kyc'),
        ),
        _StatCard(
          label: 'Admin Accounts',
          value: '—',
          icon: Icons.group_rounded,
          color: const Color(0xFFB794F4),
          onTap: () => context.go('/admin/manage-admins'),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white.withOpacity(0.6),
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AdminUser? admin) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _QuickAction(
          icon: Icons.assignment_rounded,
          label: 'Review Applications',
          onTap: () => context.go('/admin/applications'),
        ),
        _QuickAction(
          icon: Icons.verified_user_rounded,
          label: 'Review KYC',
          onTap: () => context.go('/admin/kyc'),
        ),
        _QuickAction(
          icon: Icons.search_rounded,
          label: 'Search Customer',
          onTap: () => context.go('/admin/users'),
        ),
        _QuickAction(
          icon: Icons.history_rounded,
          label: 'View Audit Logs',
          onTap: () => context.go('/admin/audit'),
        ),
        if (admin?.role == AdminRole.superAdmin)
          _QuickAction(
            icon: Icons.person_add_rounded,
            label: 'Create Admin',
            onTap: () => context.go('/admin/manage-admins'),
          ),
      ],
    );
  }

  Widget _buildRecentActivity(WidgetRef ref) {
    final logsAsync = ref.watch(auditLogsProvider());
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111827).withOpacity(0.7),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: logsAsync.when(
        data: (logs) {
          if (logs.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No audit log entries yet.',
                  style: TextStyle(color: Color(0xFF4A5568)),
                ),
              ),
            );
          }
          final recent = logs.take(8).toList();
          return Column(
            children: recent.asMap().entries.map((entry) {
              final log = entry.value;
              final isLast = entry.key == recent.length - 1;
              return _AuditLogRow(log: log, isLast: isLast);
            }).toList(),
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: CircularProgressIndicator(color: Color(0xFF3B6FE0)),
          ),
        ),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Error loading logs: $e',
              style: const TextStyle(color: Color(0xFFFF9090))),
        ),
      ),
    );
  }

  String _formatDate() {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  String _formatTime() {
    final now = DateTime.now();
    final h = now.hour > 12 ? now.hour - 12 : now.hour == 0 ? 12 : now.hour;
    final m = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }
}

// ──────────────────────────────────────────
// Widgets
// ──────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 200,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF111827).withOpacity(0.8),
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.45),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF7BA4F8), size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuditLogRow extends StatelessWidget {
  const _AuditLogRow({required this.log, required this.isLast});

  final dynamic log;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: !isLast
            ? Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF3B6FE0).withOpacity(0.6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${log.adminName} — ${log.action.displayName}',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                if (log.targetUserName != null)
                  Text(
                    'Target: ${log.targetUserName}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            _formatTime(log.timestamp),
            style: TextStyle(
              color: Colors.white.withOpacity(0.35),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
