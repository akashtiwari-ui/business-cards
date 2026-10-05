import 'package:b_card/app/app.dart';
import 'package:b_card/features/auth/application/auth_providers.dart';
import 'package:b_card/features/auth/domain/auth_repository.dart';
import 'package:b_card/features/card/application/card_providers.dart';
import 'package:b_card/features/card/domain/business_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fakes.dart';

Widget _app(FakeCardRepository repo) => ProviderScope(
      overrides: [cardRepositoryProvider.overrideWithValue(repo)],
      child: const BCardApp(),
    );

void main() {
  testWidgets('new user creates a card with only a name', (tester) async {
    final repo = FakeCardRepository();
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    expect(find.text('Create your digital card'), findsOneWidget);
    await tester.tap(find.text('Create card'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Name *'), 'Aarav Shah');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(repo.card!.slug, 'aarav-shah');
    expect(find.text('Aarav Shah'), findsOneWidget);
    expect(find.text('Public profile · Live'), findsOneWidget);
  });

  testWidgets('visibility pill toggles and share screen shows the link', (tester) async {
    final repo = FakeCardRepository(
      BusinessCard(id: '1', slug: 'aarav', name: 'Aarav Shah', updatedAt: DateTime(2026)),
    );
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Public profile · Live'));
    await tester.pumpAndSettle();
    expect(find.text('Public profile · Hidden'), findsOneWidget);

    await tester.tap(find.text('Share my card'));
    await tester.pumpAndSettle();
    expect(find.text('https://bcard.example/p/aarav'), findsOneWidget);
    expect(find.text('Your profile is hidden'), findsOneWidget);
  });

  testWidgets('a taken profile link is rejected with a suggestion', (tester) async {
    final remote = FakeCardRemote()..takenSlugs.addAll({'aarav-shah', 'aarav-shah-1'});
    final repo = FakeCardRepository();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRequiredProvider.overrideWithValue(true),
        authRepositoryProvider.overrideWithValue(
          FakeAuthRepository(signedInAs: const AppUser(id: 'u1', email: 'aarav@acme.in')),
        ),
        cardRepositoryProvider.overrideWithValue(repo),
        cardRemoteProvider.overrideWithValue(remote),
        cardSyncProvider.overrideWithValue(null),
      ],
      child: const BCardApp(),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create card'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Name *'), 'Aarav Shah');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('This link is taken. Try "aarav-shah-2".'), findsOneWidget);
    expect(repo.card, isNull);

    await tester.enterText(find.widgetWithText(TextFormField, 'Profile link'), 'aarav-shah-2');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(repo.card!.slug, 'aarav-shah-2');
  });
}
