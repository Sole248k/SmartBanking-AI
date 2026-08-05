import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../domain/entities/savings_goal.dart';
import '../../providers/savings_provider.dart';

class SavingsCreateScreen extends ConsumerStatefulWidget {
  const SavingsCreateScreen({super.key});

  @override
  ConsumerState<SavingsCreateScreen> createState() =>
      _SavingsCreateScreenState();
}

class _SavingsCreateScreenState extends ConsumerState<SavingsCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _targetController = TextEditingController();
  final _autoDepositController = TextEditingController();
  bool _isAutoDeposit = false;
  String _frequency = 'monthly';
  String _selectedColor = '#0A84FF';
  String _selectedIcon = 'savings';
  DateTime? _deadline;

  static final _icons = [
    {'key': 'savings', 'icon': LucideIcons.piggyBank},
    {'key': 'shield', 'icon': LucideIcons.shield},
    {'key': 'flight', 'icon': LucideIcons.plane},
    {'key': 'laptop', 'icon': LucideIcons.laptop},
    {'key': 'home', 'icon': LucideIcons.house},
    {'key': 'car', 'icon': LucideIcons.car},
  ];

  static const _colors = [
    '#0A84FF', '#30D158', '#FF9F0A', '#AF52DE', '#FF375F', '#5E5CE6',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _targetController.dispose();
    _autoDepositController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    final user = await ref.read(authNotifierProvider.future);
    final goal = SavingsGoal(
      id: const Uuid().v4(),
      userId: user?.id ?? '',
      title: _titleController.text.trim(),
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      targetAmount: double.parse(_targetController.text.replaceAll(',', '')),
      currentAmount: 0,
      deadline: _deadline,
      iconName: _selectedIcon,
      colorHex: _selectedColor,
      isAutoDeposit: _isAutoDeposit,
      autoDepositAmount: _isAutoDeposit ? double.tryParse(_autoDepositController.text.replaceAll(',', '')) ?? 0 : 0,
      autoDepositFrequency: _isAutoDeposit ? _frequency : null,
      createdAt: DateTime.now(),
    );
    
    await ref.read(savingsControllerProvider.notifier).createGoal(goal);
    if (mounted && !ref.read(savingsControllerProvider).hasError) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final savingsState = ref.watch(savingsControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('New Savings Goal')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Icon picker
            Row(
              children: _icons.map((item) {
                final isSelected = _selectedIcon == item['key'];
                final color = Color(int.parse(_selectedColor.replaceFirst('#', '0xFF')));
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedIcon = item['key'] as String),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected ? color.withOpacity(0.15) : colorScheme.surfaceVariant.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? color : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Icon(item['icon'] as IconData,
                          color: isSelected ? color : colorScheme.onSurfaceVariant,
                          size: 22),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Color picker
            Row(
              children: _colors.map((hex) {
                final color = Color(int.parse(hex.replaceFirst('#', '0xFF')));
                final isSelected = _selectedColor == hex;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedColor = hex),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: isSelected
                            ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6)]
                            : null,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Goal Title',
                prefixIcon: Icon(LucideIcons.flag),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                prefixIcon: Icon(LucideIcons.text),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _targetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Target Amount (₱)',
                prefixIcon: Icon(LucideIcons.target),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Target is required';
                final a = double.tryParse(v.replaceAll(',', ''));
                if (a == null || a <= 0) return 'Enter a valid amount';
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: const Icon(LucideIcons.calendar),
              title: Text(
                _deadline == null
                    ? 'Set Deadline (optional)'
                    : 'Deadline: ${_deadline!.day}/${_deadline!.month}/${_deadline!.year}',
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 90)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2035),
                );
                if (picked != null) setState(() => _deadline = picked);
              },
            ),
            const Divider(),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Auto Deposit'),
              subtitle: const Text('Automatically add funds on schedule'),
              value: _isAutoDeposit,
              onChanged: (v) => setState(() => _isAutoDeposit = v),
            ),
            if (_isAutoDeposit) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _autoDepositController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Auto Deposit Amount (₱)',
                  prefixIcon: Icon(LucideIcons.repeat),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                validator: (v) {
                  if (!_isAutoDeposit) return null;
                  if (v == null || v.isEmpty) return 'Amount is required';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _frequency,
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                items: const [
                  DropdownMenuItem(value: 'daily', child: Text('Daily')),
                  DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                ],
                onChanged: (v) => setState(() => _frequency = v ?? 'monthly'),
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: savingsState.isLoading ? null : _save,
              child: savingsState.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Create Goal'),
            ),
          ],
        ),
      ),
    );
  }
}
