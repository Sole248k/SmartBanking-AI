import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/constants/app_constants.dart';
import '../providers/admin_data_providers.dart';
import '../providers/admin_auth_provider.dart';

class KycQueueScreen extends ConsumerStatefulWidget {
  const KycQueueScreen({super.key});

  @override
  ConsumerState<KycQueueScreen> createState() => _KycQueueScreenState();
}

class _KycQueueScreenState extends ConsumerState<KycQueueScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  static const _tabs = [
    ('All', ''),
    ('Pending', 'pending'),
    ('Approved', 'approved'),
    ('Rejected', 'rejected'),
    ('More Info', 'moreInfoRequired'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified_user_rounded,
                        color: Color(0xFF68D391), size: 22),
                    const SizedBox(width: 10),
                    const Text(
                      'KYC Review Queue',
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
                  'Review and process customer identity verifications',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                // Search
                _buildSearchBar(),
                const SizedBox(height: 16),
                // Tabs
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF4A5568),
                  indicatorColor: const Color(0xFF68D391),
                  indicatorWeight: 2.5,
                  dividerColor: Colors.white.withOpacity(0.06),
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                  tabs:
                      _tabs.map((t) => Tab(text: t.$1)).toList(),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabs.map((tab) {
                return _KycTabContent(
                  statusFilter: tab.$2,
                  searchQuery: _searchQuery,
                );
              }).toList(),
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
        hintText: 'Search by name, email or user ID…',
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 14),
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
          borderSide: const BorderSide(color: Color(0xFF68D391), width: 1.5),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// Tab content
// ──────────────────────────────────────────

class _KycTabContent extends ConsumerWidget {
  const _KycTabContent({
    required this.statusFilter,
    required this.searchQuery,
  });

  final String statusFilter;
  final String searchQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stream = statusFilter.isEmpty
        ? ref.watch(allKycRecordsProvider)
        : ref.watch(kycByStatusProvider(statusFilter));

    return stream.when(
      data: (records) {
        var filtered = records;
        if (searchQuery.isNotEmpty) {
          filtered = records.where((r) {
            final name = (r['fullName'] as String? ?? '').toLowerCase();
            final email = (r['email'] as String? ?? '').toLowerCase();
            final uid = (r['userId'] as String? ?? '').toLowerCase();
            return name.contains(searchQuery) ||
                email.contains(searchQuery) ||
                uid.contains(searchQuery);
          }).toList();
        }
        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_user_rounded,
                    color: Colors.white.withOpacity(0.1), size: 48),
                const SizedBox(height: 12),
                Text(
                  searchQuery.isNotEmpty
                      ? 'No results found'
                      : 'No KYC records in this category',
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
          padding: const EdgeInsets.all(28),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) =>
              _KycRecordCard(record: filtered[i]),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFF68D391)),
      ),
      error: (e, _) => Center(
        child: Text('Error: $e',
            style: const TextStyle(color: Color(0xFFFF9090))),
      ),
    );
  }
}

// ──────────────────────────────────────────
// KYC Record Card
// ──────────────────────────────────────────

class _KycRecordCard extends ConsumerStatefulWidget {
  const _KycRecordCard({required this.record});
  final Map<String, dynamic> record;

  @override
  ConsumerState<_KycRecordCard> createState() => _KycRecordCardState();
}

class _KycRecordCardState extends ConsumerState<_KycRecordCard> {
  bool _expanded = false;
  final _notesController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  String _statusColor(String status) {
    switch (status) {
      case 'approved':
        return '68D391';
      case 'rejected':
        return 'FC8181';
      case 'moreInfoRequired':
        return 'F6AD55';
      default:
        return '7BA4F8';
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'moreInfoRequired':
        return 'More Info Required';
      default:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    final status = record['status'] as String? ?? 'pending';
    final statusHex = _statusColor(status);
    final statusColor = Color(int.parse('FF$statusHex', radix: 16));
    final fullName = record['fullName'] as String? ?? 'Unknown';
    final userId = record['userId'] as String? ?? record['id'] as String? ?? '';
    final idType = record['idType'] as String? ?? '';
    final kycId = record['id'] as String? ?? '';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111827).withOpacity(0.8),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        children: [
          // Row summary
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor:
                        const Color(0xFF3B6FE0).withOpacity(0.2),
                    child: Text(
                      fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Color(0xFF7BA4F8),
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
                        Text(
                          fullName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'ID: $userId',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.35),
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (idType.isNotEmpty)
                          Text(
                            'ID Type: ${idType.toUpperCase()}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMax),
                    ),
                    child: Text(
                      _statusLabel(status),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ],
              ),
            ),
          ),

          // Expanded actions
          if (_expanded) ...[
            Divider(color: Colors.white.withOpacity(0.06), height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notes field
                  Text(
                    'Internal Notes (optional)',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Add internal notes…',
                      hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.2), fontSize: 13),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.04),
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMd),
                        borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMd),
                        borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMd),
                        borderSide: const BorderSide(
                            color: Color(0xFF68D391), width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Action buttons
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (status != 'approved')
                        _ActionButton(
                          label: 'Approve',
                          icon: Icons.check_circle_rounded,
                          color: const Color(0xFF68D391),
                          onPressed: () => _approve(kycId, userId, fullName),
                        ),
                      if (status != 'rejected')
                        _ActionButton(
                          label: 'Reject',
                          icon: Icons.cancel_rounded,
                          color: const Color(0xFFFC8181),
                          onPressed: () =>
                              _showRejectDialog(kycId, userId, fullName),
                        ),
                      _ActionButton(
                        label: 'Request Docs',
                        icon: Icons.upload_file_rounded,
                        color: const Color(0xFFF6AD55),
                        onPressed: () =>
                            _showRequestDocsDialog(kycId, userId, fullName),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _approve(String kycId, String userId, String fullName) async {
    final controller = ref.read(kycActionsControllerProvider.notifier);
    await controller.approveKyc(
      kycId: kycId,
      userId: userId,
      userFullName: fullName,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('KYC approved successfully.'),
          backgroundColor: Color(0xFF68D391),
        ),
      );
      setState(() => _expanded = false);
    }
  }

  void _showRejectDialog(
      String kycId, String userId, String fullName) {
    showDialog(
      context: context,
      builder: (_) => _RejectDialog(
        title: 'Reject KYC',
        onConfirm: (reason) async {
          final controller =
              ref.read(kycActionsControllerProvider.notifier);
          await controller.rejectKyc(
            kycId: kycId,
            userId: userId,
            userFullName: fullName,
            reason: reason,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('KYC rejected.'),
                backgroundColor: Color(0xFFFC8181),
              ),
            );
            setState(() => _expanded = false);
          }
        },
      ),
    );
  }

  void _showRequestDocsDialog(
      String kycId, String userId, String fullName) {
    showDialog(
      context: context,
      builder: (_) => _RequestDocsDialog(
        onConfirm: (docs) async {
          final result = await ref
              .read(kycAdminRepositoryProvider)
              .requestKycDocuments(
                kycId: kycId,
                userId: userId,
                userFullName: fullName,
                admin: ref.read(adminAuthNotifierProvider).value!,
                requestedDocuments: docs,
                notes: _notesController.text.trim().isEmpty
                    ? null
                    : _notesController.text.trim(),
              );
          result.fold(
            (l) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(l.message),
                  backgroundColor: const Color(0xFFFC8181)),
            ),
            (r) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Document request sent.'),
                  backgroundColor: Color(0xFFF6AD55),
                ),
              );
              setState(() => _expanded = false);
            },
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────
// Shared widgets
// ──────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: color),
      label: Text(label, style: TextStyle(color: color, fontSize: 13)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withOpacity(0.4)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        ),
      ),
    );
  }
}

class _RejectDialog extends StatefulWidget {
  const _RejectDialog({required this.title, required this.onConfirm});

  final String title;
  final Future<void> Function(String reason) onConfirm;

  @override
  State<_RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends State<_RejectDialog> {
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF111827),
      title: Text(widget.title,
          style: const TextStyle(color: Colors.white, fontSize: 18)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Please provide a rejection reason:',
            style: TextStyle(color: Color(0xFF718096), fontSize: 13),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reasonController,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter reason…',
              hintStyle: const TextStyle(color: Color(0xFF4A5568)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
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
                borderSide:
                    const BorderSide(color: Color(0xFFFC8181), width: 1.5),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel',
              style: TextStyle(color: Color(0xFF718096))),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFC8181),
            foregroundColor: Colors.white,
          ),
          onPressed: () async {
            if (_reasonController.text.trim().isEmpty) return;
            Navigator.pop(context);
            await widget.onConfirm(_reasonController.text.trim());
          },
          child: const Text('Confirm Rejection'),
        ),
      ],
    );
  }
}

class _RequestDocsDialog extends StatefulWidget {
  const _RequestDocsDialog({required this.onConfirm});

  final Future<void> Function(List<String> docs) onConfirm;

  @override
  State<_RequestDocsDialog> createState() => _RequestDocsDialogState();
}

class _RequestDocsDialogState extends State<_RequestDocsDialog> {
  final _presets = [
    'Proof of Address',
    'Bank Statement (last 3 months)',
    'Updated Government ID',
    'Selfie with ID',
    'Income Certificate',
    'Employment Certificate',
  ];
  final _selected = <String>{};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF111827),
      title: const Text('Request Documents',
          style: TextStyle(color: Colors.white, fontSize: 18)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: _presets.map((doc) {
          final isSelected = _selected.contains(doc);
          return CheckboxListTile(
            title: Text(doc,
                style: const TextStyle(color: Colors.white, fontSize: 13)),
            value: isSelected,
            onChanged: (v) {
              setState(() {
                if (v == true) {
                  _selected.add(doc);
                } else {
                  _selected.remove(doc);
                }
              });
            },
            activeColor: const Color(0xFFF6AD55),
            checkColor: Colors.black,
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel',
              style: TextStyle(color: Color(0xFF718096))),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF6AD55),
            foregroundColor: Colors.black,
          ),
          onPressed: _selected.isEmpty
              ? null
              : () async {
                  Navigator.pop(context);
                  await widget.onConfirm(_selected.toList());
                },
          child: const Text('Send Request'),
        ),
      ],
    );
  }
}
