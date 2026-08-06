import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/constants/app_constants.dart';
import '../domain/product_application.dart';
import '../providers/admin_auth_provider.dart';
import '../providers/admin_data_providers.dart';

class ProductApplicationsScreen extends ConsumerStatefulWidget {
  const ProductApplicationsScreen({super.key});

  @override
  ConsumerState<ProductApplicationsScreen> createState() =>
      _ProductApplicationsScreenState();
}

class _ProductApplicationsScreenState
    extends ConsumerState<ProductApplicationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  static const _tabs = [
    ('All', null),
    ('Pending', ApplicationStatus.pending),
    ('Under Review', ApplicationStatus.underReview),
    ('Approved', ApplicationStatus.approved),
    ('Rejected', ApplicationStatus.rejected),
    ('More Info', ApplicationStatus.moreInfoRequired),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.assignment_rounded,
                        color: Color(0xFF7BA4F8), size: 22),
                    const SizedBox(width: 10),
                    const Text(
                      'Product Applications',
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
                  'Review and process customer product applications',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                _buildSearchBar(),
                const SizedBox(height: 16),
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF4A5568),
                  indicatorColor: const Color(0xFF7BA4F8),
                  indicatorWeight: 2.5,
                  dividerColor: Colors.white.withOpacity(0.06),
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                  tabs: _tabs.map((t) => Tab(text: t.$1)).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabs.map((tab) {
                return _ApplicationTabContent(
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
        hintText: 'Search by name, email, product type…',
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
          borderSide:
              const BorderSide(color: Color(0xFF7BA4F8), width: 1.5),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// Tab content
// ──────────────────────────────────────────

class _ApplicationTabContent extends ConsumerWidget {
  const _ApplicationTabContent({
    required this.statusFilter,
    required this.searchQuery,
  });

  final ApplicationStatus? statusFilter;
  final String searchQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stream = statusFilter == null
        ? ref.watch(allProductApplicationsProvider)
        : ref.watch(productApplicationsByStatusProvider(statusFilter!));

    return stream.when(
      data: (apps) {
        var filtered = apps;
        if (searchQuery.isNotEmpty) {
          filtered = apps.where((a) {
            final name = a.userFullName.toLowerCase();
            final email = a.userEmail.toLowerCase();
            final product = a.productType.displayName.toLowerCase();
            return name.contains(searchQuery) ||
                email.contains(searchQuery) ||
                product.contains(searchQuery);
          }).toList();
        }
        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.assignment_outlined,
                    color: Colors.white.withOpacity(0.1), size: 48),
                const SizedBox(height: 12),
                Text(
                  searchQuery.isNotEmpty
                      ? 'No results found'
                      : 'No applications in this category',
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
          itemBuilder: (_, i) =>
              _ApplicationCard(application: filtered[i]),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFF7BA4F8)),
      ),
      error: (e, _) => Center(
        child: Text('Error: $e',
            style: const TextStyle(color: Color(0xFFFF9090))),
      ),
    );
  }
}

// ──────────────────────────────────────────
// Application Card
// ──────────────────────────────────────────

class _ApplicationCard extends ConsumerStatefulWidget {
  const _ApplicationCard({required this.application});

  final ProductApplication application;

  @override
  ConsumerState<_ApplicationCard> createState() => _ApplicationCardState();
}

class _ApplicationCardState extends ConsumerState<_ApplicationCard> {
  bool _expanded = false;
  final _notesController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime dt) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  Color _statusColor(ApplicationStatus s) {
    switch (s) {
      case ApplicationStatus.approved:
        return const Color(0xFF68D391);
      case ApplicationStatus.rejected:
        return const Color(0xFFFC8181);
      case ApplicationStatus.underReview:
        return const Color(0xFF7BA4F8);
      case ApplicationStatus.moreInfoRequired:
        return const Color(0xFFF6AD55);
      default:
        return const Color(0xFFFFB347);
    }
  }

  IconData _productIcon(ProductType t) {
    switch (t) {
      case ProductType.savings:
        return Icons.savings_rounded;
      case ProductType.current:
        return Icons.account_balance_rounded;
      case ProductType.loan:
        return Icons.money_rounded;
      case ProductType.creditCard:
        return Icons.credit_card_rounded;
      case ProductType.timeDeposit:
        return Icons.timer_rounded;
      case ProductType.insurance:
        return Icons.health_and_safety_rounded;
      case ProductType.investment:
        return Icons.trending_up_rounded;
      default:
        return Icons.work_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.application;
    final statusColor = _statusColor(app.status);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111827).withOpacity(0.8),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMd),
                    ),
                    child: Icon(_productIcon(app.productType),
                        color: statusColor, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          app.productType.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          app.userFullName,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          app.userEmail,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.35),
                            fontSize: 11,
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
                          color: statusColor.withOpacity(0.12),
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusMax),
                        ),
                        child: Text(
                          app.status.displayName,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _fmtDate(app.submittedAt),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 11,
                        ),
                      ),
                    ],
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
          if (_expanded) ...[
            Divider(color: Colors.white.withOpacity(0.06), height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Application details
                  if (app.assignedAdminName != null)
                    _InfoRow(
                        label: 'Assigned To',
                        value: app.assignedAdminName!),
                  if (app.internalNotes != null)
                    _InfoRow(
                        label: 'Notes', value: app.internalNotes!),
                  if (app.rejectionReason != null)
                    _InfoRow(
                        label: 'Rejection Reason',
                        value: app.rejectionReason!),
                  if (app.assignedAdminName != null ||
                      app.internalNotes != null ||
                      app.rejectionReason != null)
                    const SizedBox(height: 12),
                  // Notes
                  Text(
                    'Internal Notes',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    style:
                        const TextStyle(color: Colors.white, fontSize: 13),
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Add notes…',
                      hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.2),
                          fontSize: 13),
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
                            color: Color(0xFF7BA4F8), width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (app.status != ApplicationStatus.approved)
                        _ActionBtn(
                          label: 'Approve',
                          icon: Icons.check_circle_rounded,
                          color: const Color(0xFF68D391),
                          onPressed: () => _approve(app.id),
                        ),
                      if (app.status != ApplicationStatus.rejected)
                        _ActionBtn(
                          label: 'Reject',
                          icon: Icons.cancel_rounded,
                          color: const Color(0xFFFC8181),
                          onPressed: () => _showRejectDialog(app.id),
                        ),
                      _ActionBtn(
                        label: 'More Info',
                        icon: Icons.info_outline_rounded,
                        color: const Color(0xFFF6AD55),
                        onPressed: () => _showMoreInfoDialog(app.id),
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

  void _approve(String id) async {
    await ref.read(applicationActionsControllerProvider.notifier).approve(
          applicationId: id,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Application approved!'),
        backgroundColor: Color(0xFF68D391),
      ));
      setState(() => _expanded = false);
    }
  }

  void _showRejectDialog(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF111827),
        title: const Text('Reject Application',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Provide rejection reason:',
                style: TextStyle(color: Color(0xFF718096), fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: _reasonController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Reason…',
                hintStyle: const TextStyle(color: Color(0xFF4A5568)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
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
                      color: Color(0xFFFC8181), width: 1.5),
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
                foregroundColor: Colors.white),
            onPressed: () async {
              if (_reasonController.text.trim().isEmpty) return;
              Navigator.pop(context);
              await ref
                  .read(applicationActionsControllerProvider.notifier)
                  .reject(
                    applicationId: id,
                    reason: _reasonController.text.trim(),
                    notes: _notesController.text.trim().isEmpty
                        ? null
                        : _notesController.text.trim(),
                  );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Application rejected.'),
                  backgroundColor: Color(0xFFFC8181),
                ));
                setState(() => _expanded = false);
              }
            },
            child: const Text('Confirm Rejection'),
          ),
        ],
      ),
    );
  }

  void _showMoreInfoDialog(String id) {
    final docs = <String>{};
    final presets = [
      'Proof of Income',
      'Bank Statement (3 months)',
      'Employment Certificate',
      'Valid Government ID',
      'Proof of Address',
    ];
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState2) => AlertDialog(
          backgroundColor: const Color(0xFF111827),
          title: const Text('Request More Info',
              style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: presets.map((doc) {
              return CheckboxListTile(
                title: Text(doc,
                    style:
                        const TextStyle(color: Colors.white, fontSize: 13)),
                value: docs.contains(doc),
                onChanged: (v) {
                  setState2(() {
                    if (v == true) {
                      docs.add(doc);
                    } else {
                      docs.remove(doc);
                    }
                  });
                },
                activeColor: const Color(0xFFF6AD55),
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
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
              onPressed: docs.isEmpty
                  ? null
                  : () async {
                      Navigator.pop(context);
                      await ref
                          .read(applicationActionsControllerProvider.notifier)
                          .requestMoreInfo(
                            applicationId: id,
                            requestedDocuments: docs.toList(),
                            notes: _notesController.text.trim().isEmpty
                                ? null
                                : _notesController.text.trim(),
                          );
                      if (mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('More info requested.'),
                          backgroundColor: Color(0xFFF6AD55),
                        ));
                        setState(() => _expanded = false);
                      }
                    },
              child: const Text('Send Request'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.4), fontSize: 12)),
          Expanded(
            child: Text(value,
                style:
                    const TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        ),
      ),
    );
  }
}
