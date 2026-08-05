import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_lock_provider.g.dart';

/// In-memory state for overall app session lock.
/// On app launch or browser refresh, initial state is `true` (locked).
@riverpod
class SessionLockController extends _$SessionLockController {
  @override
  bool build() {
    return true;
  }

  void lockSession() {
    state = true;
  }

  void unlockSession() {
    state = false;
  }
}

/// In-memory state holding the currently authenticated card ID and expiration timestamp.
class CardAuthSession {
  final String? cardId;
  final DateTime? expiresAt;

  const CardAuthSession({this.cardId, this.expiresAt});

  /// Check if the target card is currently authenticated within its grace period.
  bool isCardAuthenticated(String targetCardId) {
    if (cardId == null || cardId != targetCardId || expiresAt == null) {
      return false;
    }
    return DateTime.now().isBefore(expiresAt!);
  }
}

@riverpod
class CardAuthSessionController extends _$CardAuthSessionController {
  @override
  CardAuthSession build() {
    return const CardAuthSession();
  }

  /// Grant a 60-second authentication grace period for a specific card ID.
  void authenticateCard(String cardId, {int gracePeriodSeconds = 60}) {
    state = CardAuthSession(
      cardId: cardId,
      expiresAt: DateTime.now().add(Duration(seconds: gracePeriodSeconds)),
    );
  }

  /// Immediately clear card viewing authentication state.
  void clearSession() {
    state = const CardAuthSession();
  }
}
