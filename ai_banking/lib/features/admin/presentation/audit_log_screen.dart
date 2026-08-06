import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/constants/app_constants.dart';
import '../domain/audit_log.dart';
import '../providers/admin_data_providers.dart';

class AuditLogScreen extends ConsumerStatefulWidget {
  const AuditLogScreen({super.key});

  @override
  ConsumerState<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends ConsumerState<AuditLogScreen> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(auditLogsProvider());

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.history_rounded,
                        color: Color(0xFFB794F4), size: 22),
                    const SizedBox(width: 10),
                    const Text(
                      'Audit Logs',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFC8181).withOpacity(0.12),
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMax),
                      ),
                      child: const Text(
                        '🔒 Immutable Records',
                        style: TextStyle(
                          color: Color(0xFFFC8181),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'All admin actions are permanently recorded',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                _buildSearchBar(),
              ],
            ),
          ),
          Expanded(
            child: logsAsync.when(
              data: (logs) {
                var filtered = logs;
                if (_searchQuery.isNotEmpty) {
                  filtered = logs.where((log) {
                    final name = log.adminName.toLowerCase();
                    final action = log.action.displayName.toLowerCase();
                    final target =
                        (log.targetUserName ?? '').toLowerCase();
                    return name.contains(_searchQuery) ||
                        action.contains(_searchQuery) ||
                        target.contains(_searchQuery);
                  }).toList();
                }
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history_rounded,
                            color: Colors.white.withOpacity(0.1),
                            size: 48),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No matching logs'
                              : 'No audit logs yet',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _AuditLogCard(log: filtered[i]),
                );
              },
              loading: () => const Center(
                child:
                    CircularProgressIndicator(color: Color(0xFFB794F4)),
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

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
      decoration: InputDecoration(
        hintText: 'Search by admin, action, or target user…',
        hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.25), fontSize: 14),
        prefixIcon: Icon(Icons.search_rounded,
            color: Colors.white.withOpacity(0.4), size: 20),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear,
                    color: Colors.white.withOpacity(0.4), size: 18),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: const BorderSide(
              color: Color(0xFFB794F4), width: 1.5),
        ),
      ),
    );
  }
}

class _AuditLogCard extends StatelessWidget {
  const _AuditLogCard({required this.log});

  final AuditLog log;

  Color _actionColor(AuditAction action) {
    if (action.name.contains('approved') ||
        action.name.contains('Approved')) {
      return const Color(0xFF68D391);
    }
    if (action.name.contains('rejected') ||
        action.name.contains('Rejected')) {
      return const Color(0xFFFC8181);
    }
    if (action.name.contains('deleted') ||
        action.name.contains('suspended')) {
      return const Color(0xFFFC8181);
    }
    if (action.name.contains('created')) {
      return const Color(0xFF68D391);
    }
    return const Color(0xFFB794F4);
  }

  String _fmtTimestamp(DateTime dt) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    final h = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day}, $h:$m $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final actionColor = _actionColor(log.action);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827).withOpacity(0.7),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline dot
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: actionColor.withOpacity(0.6),
                  boxShadow: [
                    BoxShadow(
                      color: actionColor.withOpacity(0.3),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Action
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        log.action.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      _fmtTimestamp(log.timestamp),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Admin & target
                Text.rich(TextSpan(
                  children: [
                    TextSpan(
                      text: 'By: ',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 12,
                      ),
                    ),
                    TextSpan(
                      text: '${log.adminName} (${log.adminRole})',
                      style: const TextStyle(
                        color: Color(0xFF7BA4F8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                )),
                if (log.targetUserName != null)
                  Text.rich(TextSpan(
                    children: [
                      TextSpan(
                        text: 'Target: ',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 12,
                        ),
                      ),
                      TextSpan(
                        text: log.targetUserName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  )),
                if (log.previousStatus != null && log.newStatus != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _StatusChip(log.previousStatus!,
                          const Color(0xFF4A5568)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(Icons.arrow_forward_rounded,
                            size: 12, color: Color(0xFF4A5568)),
                      ),
                      _StatusChip(log.newStatus!, actionColor),
                    ],
                  ),
                ],
                if (log.notes != null && log.notes!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusSm),
                    ),
                    child: Text(
                      log.notes!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(this.label, this.color);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusMax),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}
