import 'dart:async';

import 'package:b_card/features/auth/domain/auth_repository.dart';
import 'package:b_card/features/card/domain/business_card.dart';
import 'package:b_card/features/card/domain/card_remote_data_source.dart';
import 'package:b_card/features/card/domain/card_repository.dart';

class FakeCardRepository implements CardRepository {
  FakeCardRepository([this._card]);

  BusinessCard? _card;
  final _changes = StreamController<BusinessCard?>.broadcast();

  BusinessCard? get card => _card;

  @override
  Stream<BusinessCard?> watchMyCard() async* {
    yield _card;
    yield* _changes.stream;
  }

  @override
  Future<void> save(BusinessCard card) async => _changes.add(_card = card);

  @override
  Future<void> setVisibility(String cardId, {required bool isPublic}) async =>
      _changes.add(_card = _card!.copyWith(isPublic: isPublic));
}

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.requireConfirmation = false, AppUser? signedInAs}) : _user = signedInAs;

  final bool requireConfirmation;
  AppUser? _user;
  final _changes = StreamController<AppUser?>.broadcast();
  final _accounts = <String, String>{'aarav@acme.in': 'correct-horse'};

  @override
  Stream<AppUser?> watchUser() async* {
    yield _user;
    yield* _changes.stream;
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    if (_accounts[email.trim()] != password) {
      throw const AuthFailure('Incorrect email or password.');
    }
    _changes.add(_user = AppUser(id: 'u1', email: email.trim()));
  }

  @override
  Future<SignUpOutcome> signUp({required String email, required String password}) async {
    _accounts[email.trim()] = password;
    if (requireConfirmation) return SignUpOutcome.confirmEmail;
    _changes.add(_user = AppUser(id: 'u2', email: email.trim()));
    return SignUpOutcome.signedIn;
  }

  @override
  Future<void> signOut() async => _changes.add(_user = null);
}

class FakeCardRemote implements CardRemoteDataSource {
  final cards = <String, BusinessCard>{}; // by user id
  final takenSlugs = <String>{};
  bool offline = false;
  int upserts = 0;

  void _check() {
    if (offline) throw Exception('offline');
  }

  @override
  Future<BusinessCard?> fetchMyCard(String userId) async {
    _check();
    return cards[userId];
  }

  @override
  Future<void> upsert(BusinessCard card, String userId) async {
    _check();
    upserts++;
    cards[userId] = card;
    takenSlugs.add(card.slug);
  }

  @override
  Future<bool> isSlugAvailable(String slug) async {
    _check();
    return !takenSlugs.contains(slug);
  }
}
