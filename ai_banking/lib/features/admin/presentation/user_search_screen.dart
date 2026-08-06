import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../app/constants/app_constants.dart';

class UserSearchScreen extends ConsumerStatefulWidget {
  const UserSearchScreen({super.key});

  @override
  ConsumerState<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends ConsumerState<UserSearchScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  List<Map<String, dynamic>> _results = [];

  final _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _isSearching = true);
    try {
      // Search by email (exact match)
      final byEmail = await _firestore
          .collection('users')
          .where('email', isEqualTo: query.trim())
          .limit(10)
          .get();

      // Search by fullName prefix (range query)
      final byName = await _firestore
          .collection('users')
          .orderBy('fullName')
          .startAt([query])
          .endAt(['$query\uf8ff'])
          .limit(10)
          .get();

      final combined = <String, Map<String, dynamic>>{};
      for (final doc in [...byEmail.docs, ...byName.docs]) {
        final data = doc.data();
        data['uid'] = doc.id;
        combined[doc.id] = data;
      }
      setState(() => _results = combined.values.toList());
    } catch (e) {
      setState(() => _results = []);
    } finally {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    const Icon(Icons.search_rounded,
                        color: Color(0xFF7BA4F8), size: 22),
                    const SizedBox(width: 10),
                    const Text(
                      'Customer Search',
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
                  'Look up any customer by name or email',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                        onSubmitted: _search,
                        onChanged: (v) => setState(() => _searchQuery = v),
                        decoration: InputDecoration(
                          hintText: 'Search by name, email or UID…',
                          hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.25),
                              fontSize: 14),
                          prefixIcon: Icon(Icons.search_rounded,
                              color: Colors.white.withOpacity(0.4), size: 20),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
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
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => _search(_searchController.text),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B6FE0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusMd),
                        ),
                      ),
                      child: const Text('Search'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isSearching
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF7BA4F8)),
                  )
                : _results.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_search_rounded,
                                color: Colors.white.withOpacity(0.1),
                                size: 56),
                            const SizedBox(height: 12),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'Enter a name or email to search'
                                  : 'No customers found',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                        itemCount: _results.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (_, i) => _CustomerCard(
                          key: ValueKey(_results[i]['uid'] ?? 'usr_$i'),
                          user: _results[i],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────
// Customer Result Card
// ──────────────────────────────────────────

class _CustomerCard extends StatefulWidget {
  const _CustomerCard({super.key, required this.user});

  final Map<String, dynamic> user;

  @override
  State<_CustomerCard> createState() => _CustomerCardState();
}

class _CustomerCardState extends State<_CustomerCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final name = user['fullName'] as String? ?? 'Unknown';
    final email = user['email'] as String? ?? '';
    final uid = user['uid'] as String? ?? '';
    final kycStatus = user['kycStatus'] as String? ?? 'not_submitted';

    Color kycColor;
    String kycLabel;
    switch (kycStatus) {
      case 'approved':
        kycColor = const Color(0xFF68D391);
        kycLabel = 'KYC Approved';
        break;
      case 'rejected':
        kycColor = const Color(0xFFFC8181);
        kycLabel = 'KYC Rejected';
        break;
      case 'pending':
        kycColor = const Color(0xFFF6AD55);
        kycLabel = 'KYC Pending';
        break;
      default:
        kycColor = const Color(0xFF4A5568);
        kycLabel = 'KYC Not Submitted';
    }

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
                  CircleAvatar(
                    radius: 22,
                    backgroundColor:
                        const Color(0xFF3B6FE0).withOpacity(0.2),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
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
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: kycColor.withOpacity(0.12),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMax),
                    ),
                    child: Text(
                      kycLabel,
                      style: TextStyle(
                        color: kycColor,
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
          if (_expanded) ...[
            Divider(color: Colors.white.withOpacity(0.06), height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailRow('User ID', uid),
                  _DetailRow('Email', email),
                  _DetailRow('KYC Status', kycLabel),
                  if (user['phoneNumber'] != null)
                    _DetailRow('Phone', user['phoneNumber'].toString()),
                  if (user['createdAt'] != null)
                    _DetailRow('Registered',
                        _formatDate(user['createdAt'] as Timestamp)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(Timestamp ts) {
    final dt = ts.toDate();
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
