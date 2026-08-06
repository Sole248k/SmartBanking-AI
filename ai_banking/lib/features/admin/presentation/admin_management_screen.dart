import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/constants/app_constants.dart';
import '../domain/admin_user.dart';
import '../providers/admin_auth_provider.dart';

class AdminManagementScreen extends ConsumerWidget {
  const AdminManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentAdmin = ref.watch(adminAuthNotifierProvider).value;
    final adminsAsync = ref.watch(allAdminsProvider);

    // Only Super Admin can access this screen
    if (currentAdmin?.role != AdminRole.superAdmin) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0E1A),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_rounded,
                  color: Color(0xFFFC8181), size: 48),
              const SizedBox(height: 16),
              const Text(
                'Access Denied',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Only Super Admins can manage admin accounts.',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.4), fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.manage_accounts_rounded,
                            color: Color(0xFFB794F4), size: 22),
                        const SizedBox(width: 10),
                        const Text(
                          'Admin Management',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage administrator accounts and roles',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () =>
                      _showCreateAdminDialog(context, ref),
                  icon: const Icon(Icons.person_add_rounded, size: 18),
                  label: const Text('Create Admin'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B6FE0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMd),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: adminsAsync.when(
              data: (admins) {
                if (admins.isEmpty) {
                  return Center(
                    child: Text(
                      'No admin accounts found.',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 14),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                  itemCount: admins.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 10),
                  itemBuilder: (_, i) => _AdminAccountCard(
                    admin: admins[i],
                    currentAdmin: currentAdmin!,
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                    color: Color(0xFFB794F4)),
              ),
              error: (e, _) => Center(
                child: Text('Error: $e',
                    style: const TextStyle(color: Color(0xFFFF9090))),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateAdminDialog(BuildContext context, WidgetRef ref) {
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    AdminRole selectedRole = AdminRole.opsAdmin;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState2) => AlertDialog(
          backgroundColor: const Color(0xFF111827),
          title: const Text('Create Admin Account',
              style: TextStyle(color: Colors.white, fontSize: 18)),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DialogField(
                    controller: nameCtrl, label: 'Full Name'),
                const SizedBox(height: 12),
                _DialogField(
                  controller: emailCtrl,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                _DialogField(
                  controller: passwordCtrl,
                  label: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Role',
                  style: TextStyle(
                      color: Color(0xFF718096),
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ...AdminRole.values.map((role) {
                  return RadioListTile<AdminRole>(
                    title: Text(role.displayName,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13)),
                    value: role,
                    groupValue: selectedRole,
                    onChanged: (v) =>
                        setState2(() => selectedRole = v!),
                    activeColor: const Color(0xFF7BA4F8),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: Color(0xFF718096))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B6FE0),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty ||
                    emailCtrl.text.trim().isEmpty ||
                    passwordCtrl.text.trim().isEmpty) {
                  return;
                }
                Navigator.pop(context);
                final result = await ref
                    .read(adminAuthRepositoryProvider)
                    .createAdmin(
                      email: emailCtrl.text.trim(),
                      password: passwordCtrl.text.trim(),
                      fullName: nameCtrl.text.trim(),
                      role: selectedRole,
                    );
                result.fold(
                  (l) => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(l.message),
                        backgroundColor: const Color(0xFFFC8181)),
                  ),
                  (r) => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Admin account created!'),
                      backgroundColor: Color(0xFF68D391),
                    ),
                  ),
                );
              },
              child: const Text('Create Admin'),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// Admin Account Card
// ──────────────────────────────────────────

class _AdminAccountCard extends ConsumerWidget {
  const _AdminAccountCard(
      {required this.admin, required this.currentAdmin});

  final AdminUser admin;
  final AdminUser currentAdmin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelf = admin.uid == currentAdmin.uid;
    final roleColor = _roleColor(admin.role);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827).withOpacity(0.8),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(
          color: isSelf
              ? const Color(0xFF3B6FE0).withOpacity(0.3)
              : Colors.white.withOpacity(0.07),
          width: isSelf ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: roleColor.withOpacity(0.2),
            child: Text(
              admin.fullName.isNotEmpty
                  ? admin.fullName[0].toUpperCase()
                  : 'A',
              style: TextStyle(
                color: roleColor,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      admin.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    if (isSelf) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B6FE0).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(
                              AppConstants.radiusMax),
                        ),
                        child: const Text(
                          'You',
                          style: TextStyle(
                              color: Color(0xFF7BA4F8), fontSize: 10),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  admin.email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: roleColor.withOpacity(0.12),
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusMax),
                ),
                child: Text(
                  admin.role.displayName,
                  style: TextStyle(
                    color: roleColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: admin.isActive
                      ? const Color(0xFF68D391).withOpacity(0.1)
                      : const Color(0xFF4A5568).withOpacity(0.2),
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusMax),
                ),
                child: Text(
                  admin.isActive ? 'Active' : 'Suspended',
                  style: TextStyle(
                    color: admin.isActive
                        ? const Color(0xFF68D391)
                        : const Color(0xFF718096),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (!isSelf) ...[
            const SizedBox(width: 12),
            PopupMenuButton<String>(
              color: const Color(0xFF1A2035),
              icon: Icon(Icons.more_vert_rounded,
                  color: Colors.white.withOpacity(0.4)),
              onSelected: (value) =>
                  _handleAction(context, ref, value),
              itemBuilder: (_) => [
                if (admin.isActive)
                  const PopupMenuItem(
                    value: 'suspend',
                    child: Row(
                      children: [
                        Icon(Icons.pause_circle_outline_rounded,
                            color: Color(0xFFF6AD55), size: 18),
                        SizedBox(width: 8),
                        Text('Suspend',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  )
                else
                  const PopupMenuItem(
                    value: 'activate',
                    child: Row(
                      children: [
                        Icon(Icons.play_circle_outline_rounded,
                            color: Color(0xFF68D391), size: 18),
                        SizedBox(width: 8),
                        Text('Activate',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded,
                          color: Color(0xFFFC8181), size: 18),
                      SizedBox(width: 8),
                      Text('Delete',
                          style: TextStyle(color: Color(0xFFFC8181))),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _roleColor(AdminRole role) {
    switch (role) {
      case AdminRole.superAdmin:
        return const Color(0xFFFFB347);
      case AdminRole.complianceOfficer:
        return const Color(0xFF68D391);
      default:
        return const Color(0xFF7BA4F8);
    }
  }

  Future<void> _handleAction(
      BuildContext context, WidgetRef ref, String value) async {
    final repo = ref.read(adminAuthRepositoryProvider);
    switch (value) {
      case 'suspend':
        await repo.updateAdmin(adminUid: admin.uid, isActive: false);
        break;
      case 'activate':
        await repo.updateAdmin(adminUid: admin.uid, isActive: true);
        break;
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: const Color(0xFF111827),
            title: const Text('Delete Admin',
                style: TextStyle(color: Colors.white)),
            content: Text(
              'Are you sure you want to delete ${admin.fullName}? This action cannot be undone.',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.6), fontSize: 13),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel',
                    style: TextStyle(color: Color(0xFF718096))),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFC8181),
                    foregroundColor: Colors.white),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          await repo.deleteAdmin(admin.uid);
        }
        break;
    }
  }
}

// ──────────────────────────────────────────
// Dialog text field helper
// ──────────────────────────────────────────

class _DialogField extends StatelessWidget {
  const _DialogField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              color: Color(0xFF718096),
              fontSize: 12,
              fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              borderSide:
                  BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              borderSide:
                  BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              borderSide: const BorderSide(
                  color: Color(0xFF7BA4F8), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
