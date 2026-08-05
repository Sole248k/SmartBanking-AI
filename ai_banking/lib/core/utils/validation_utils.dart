class ValidationUtils {
  /// Validates email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  /// Validates password strength (min 8 chars, 1 upper, 1 number)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!value.contains(RegExp(r'[A-Z]'))) return 'Must contain at least one uppercase letter';
    if (!value.contains(RegExp(r'[0-9]'))) return 'Must contain at least one number';
    return null;
  }

  /// Validates full name
  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) return 'Name is required';
    if (value.trim().split(' ').length < 2) return 'Please enter your full name';
    return null;
  }

  /// Validates transfer amount
  static String? validateAmount(String? value, double availableBalance) {
    if (value == null || value.isEmpty) return 'Amount is required';
    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) return 'Enter a valid positive amount';
    if (amount > availableBalance) return 'Insufficient funds (₱${availableBalance.toStringAsFixed(2)})';
    return null;
  }

  /// Validates account number format
  static String? validateAccountNumber(String? value) {
    if (value == null || value.isEmpty) return 'Account number is required';
    final accountRegex = RegExp(r'^010-\d{4}-\d{4}$');
    if (!accountRegex.hasMatch(value)) return 'Format must be 010-XXXX-XXXX';
    return null;
  }
}
