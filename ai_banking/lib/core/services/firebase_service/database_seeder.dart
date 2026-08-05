import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_provisioning_service.dart';

class DatabaseSeeder {
  static final UserProvisioningService _provisioningService = UserProvisioningService();

  static Future<void> seedData() async {
    final firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('No user logged in to seed data');
    
    final uid = user.uid;
    final name = user.displayName ?? 'SmartBank User';

    // 1. Cleanup old debug data if it exists
    await firestore.collection('profiles').doc('debug_user').delete().catchError((_) {});

    // 2. Provision initial data if missing
    await _provisioningService.provisionNewUser(
      uid: uid,
      email: user.email!,
      fullName: name,
    );
    
    // 3. Seed full data suite (Transactions, Budgets, Beneficiaries)
    await _seedFullDataForUser(uid);
  }

  static Future<void> createDemoUsers() async {
    final auth = FirebaseAuth.instance;
    
    final demoUsers = [
      {'email': 'user1@smartbank.ai', 'name': 'User One', 'account': '010-1111-1111'},
      {'email': 'user2@smartbank.ai', 'name': 'User Two', 'account': '010-2222-2222'},
      {'email': 'bot@smartbank.ai', 'name': 'System Bot', 'account': '010-9999-9999'},
    ];

    for (final user in demoUsers) {
      try {
        // 1. Attempt to create Auth user
        final credential = await auth.createUserWithEmailAndPassword(
          email: user['email']!,
          password: 'Password123',
        );
        final uid = credential.user!.uid;
        await credential.user!.updateDisplayName(user['name']);

        // 2. Provision Firestore documents
        await _provisioningService.provisionNewUser(
          uid: uid,
          email: user['email']!,
          fullName: user['name']!,
          forcedAccountNumber: user['account'],
        );

        // 3. Seed full data for the new demo user
        await _seedFullDataForUser(uid);
      } catch (e) {
        // If user already exists, we could attempt to fetch UID and seed,
        // but the login logic will handle it if they log in.
        print('Demo user ${user['email']} exists or failed: $e');
      }
    }
  }

  static Future<void> _seedFullDataForUser(String uid) async {
    final firestore = FirebaseFirestore.instance;
    
    // Check if transactions already exist to avoid double-seeding
    final transactions = firestore.collection('transactions');
    final transactionDocs = await transactions.where('userId', isEqualTo: uid).limit(1).get();
    
    if (transactionDocs.docs.isEmpty) {
      final accounts = await firestore.collection('accounts').where('userId', isEqualTo: uid).get();
      if (accounts.docs.isNotEmpty) {
        final mainAccountId = accounts.docs.first.id;
        final now = DateTime.now();

        // 1. Seed Beneficiaries
        final beneficiaries = firestore.collection('beneficiaries');
        final mockBeneficiaries = [
          {'name': 'Meralco', 'accountNumber': '1022334455', 'bankName': 'Meralco Payments'},
          {'name': 'PLDT Home', 'accountNumber': '9887766554', 'bankName': 'PLDT'},
          {'name': 'Jane Doe', 'accountNumber': '5544332211', 'bankName': 'SmartBank'},
          {'name': 'John Smith', 'accountNumber': '1122334455', 'bankName': 'BDO'},
        ];

        for (final b in mockBeneficiaries) {
          await beneficiaries.add({...b, 'userId': uid});
        }

        // 2. Seed Budgets
        final budgets = firestore.collection('budgets');
        final mockBudgets = [
          {'category': 'Food & Drink', 'limitAmount': 5000.0, 'spentAmount': 1200.0},
          {'category': 'Shopping', 'limitAmount': 3000.0, 'spentAmount': 850.0},
          {'category': 'Bills', 'limitAmount': 10000.0, 'spentAmount': 4500.0},
        ];

        for (final b in mockBudgets) {
          await budgets.add({...b, 'userId': uid, 'period': 'Monthly'});
        }

        // 3. Seed 15+ Transactions for Analytics
        final mockTransactions = [
          {'title': 'GrabFood', 'amount': 450.0, 'category': 'Food & Drink', 'type': 'debit'},
          {'title': 'Starbucks', 'amount': 185.0, 'category': 'Food & Drink', 'type': 'debit'},
          {'title': 'SM Supermarket', 'amount': 2200.0, 'category': 'Shopping', 'type': 'debit'},
          {'title': 'Lazada Order', 'amount': 1500.0, 'category': 'Shopping', 'type': 'debit'},
          {'title': 'Meralco Bill', 'amount': 3500.0, 'category': 'Bills', 'type': 'debit'},
          {'title': 'Netflix', 'amount': 549.0, 'category': 'Entertainment', 'type': 'debit'},
          {'title': 'Salary', 'amount': 25000.0, 'category': 'Salary', 'type': 'credit'},
          {'title': 'Freelance Work', 'amount': 5000.0, 'category': 'Income', 'type': 'credit'},
          {'title': '7-Eleven', 'amount': 120.0, 'category': 'Food & Drink', 'type': 'debit'},
          {'title': 'Fuel', 'amount': 2000.0, 'category': 'Transport', 'type': 'debit'},
          {'title': 'Grab Car', 'amount': 350.0, 'category': 'Transport', 'type': 'debit'},
          {'title': 'Uniqlo', 'amount': 1990.0, 'category': 'Shopping', 'type': 'debit'},
          {'title': 'Water Bill', 'amount': 800.0, 'category': 'Bills', 'type': 'debit'},
          {'title': 'Internet Bill', 'amount': 1699.0, 'category': 'Bills', 'type': 'debit'},
          {'title': 'Gym Membership', 'amount': 2500.0, 'category': 'Health', 'type': 'debit'},
          {'title': 'Mercury Drug', 'amount': 450.0, 'category': 'Health', 'type': 'debit'},
        ];

        for (var i = 0; i < mockTransactions.length; i++) {
          final mock = mockTransactions[i];
          final date = now.subtract(Duration(days: (i % 20)));
          await transactions.add({
            'userId': uid,
            'accountId': mainAccountId,
            'title': mock['title'],
            'description': 'Demo Transaction',
            'amount': mock['amount'],
            'date': Timestamp.fromDate(date),
            'category': mock['category'],
            'status': 'completed',
            'type': mock['type'],
          });
        }

        // Update Balance
        for (var doc in accounts.docs) {
          await doc.reference.update({
            'balance': 15000.0,
            'availableBalance': 14800.0,
          });
        }
      }
    }
  }
}
