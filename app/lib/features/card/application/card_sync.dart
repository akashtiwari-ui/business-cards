import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/local_card_repository.dart';
import '../domain/business_card.dart';
import '../domain/card_remote_data_source.dart';

/// Keeps the on-device card and the server copy in step (PRD 5.3).
///
/// Local edits always win: a pending local card is pushed, and the server
/// copy only replaces local data that has no unsynced changes. Failures
/// (usually offline) leave the card pending; the next edit or app resume
/// retries.
class CardSync {
  CardSync({required this.local, required this.remote, required this.userId});

  final LocalCardRepository local;
  final CardRemoteDataSource remote;
  final String userId;

  StreamSubscription<BusinessCard?>? _subscription;
  Future<void>? _running;
  bool _runAgain = false;

  void start() {
    _subscription = local.watchMyCard().listen((card) {
      if (card?.syncPending ?? false) syncNow();
    });
    syncNow();
  }

  /// Push, then pull. Calls made while a sync runs are folded into one rerun.
  Future<void> syncNow() {
    if (_running case final running?) {
      _runAgain = true;
      return running;
    }
    return _running = _run().whenComplete(() {
      _running = null;
      if (_runAgain) {
        _runAgain = false;
        syncNow();
      }
    });
  }

  Future<void> _run() async {
    try {
      final card = await local.watchMyCard().first;
      if (card != null && card.syncPending) {
        await remote.upsert(card, userId);
        await local.markSynced(card.id, card.updatedAt);
      }
      final serverCard = await remote.fetchMyCard(userId);
      if (serverCard != null) await local.saveFromRemote(serverCard);
    } catch (e) {
      debugPrint('Card sync deferred: $e');
    }
  }

  void dispose() => _subscription?.cancel();
}
