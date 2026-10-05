import 'package:b_card/app/app.dart';
import 'package:b_card/features/auth/application/auth_providers.dart';
import 'package:b_card/features/card/application/card_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fakes.dart';

Widget _app(FakeAuthRepository auth) => ProviderScope(
      overrides: [
        authRequiredProvider.overrideWithValue(true),
        authRepositoryProvider.overrideWithValue(auth),
        cardRepositoryProvider.overrideWithValue(FakeCardRepository()),
        cardRemoteProvider.overrideWithValue(null),
      ],
      child: const BCardApp(),
    );

Future<void> _fill(WidgetTester tester, String email, String password) async {
  await tester.enterText(find.widgetWithText(TextFormField, 'Email'), email);
  await tester.enterText(find.widgetWithText(TextFormField, 'Password'), password);
}

void main() {
  testWidgets('signed-out users land on sign in; wrong password shows an error', (tester) async {
    await tester.pumpWidget(_app(FakeAuthRepository()));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);

    await _fill(tester, 'aarav@acme.in', 'wrong');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Incorrect email or password.'), findsOneWidget);
  });

  testWidgets('signing in opens My Card, signing out returns to sign in', (tester) async {
    await tester.pumpWidget(_app(FakeAuthRepository()));
    await tester.pumpAndSettle();

    await _fill(tester, 'aarav@acme.in', 'correct-horse');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Create your digital card'), findsOneWidget);

    await tester.tap(find.byTooltip('Account'));
    await tester.pumpAndSettle();
    expect(find.text('aarav@acme.in'), findsOneWidget);
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('sign up validates password length and asks to confirm email', (tester) async {
    await tester.pumpWidget(_app(FakeAuthRepository(requireConfirmation: true)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New to B Card? Create an account'));
    await tester.pumpAndSettle();

    await _fill(tester, 'new@acme.in', 'short');
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pumpAndSettle();
    expect(find.text('Use at least 8 characters'), findsOneWidget);

    await _fill(tester, 'new@acme.in', 'long-enough-pw');
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Confirm your email'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
