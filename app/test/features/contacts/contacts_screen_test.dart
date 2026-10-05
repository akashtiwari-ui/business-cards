import 'dart:async';

import 'package:b_card/app/theme.dart';
import 'package:b_card/features/contacts/application/contact_providers.dart';
import 'package:b_card/features/contacts/domain/contact.dart';
import 'package:b_card/features/contacts/domain/contact_repository.dart';
import 'package:b_card/features/contacts/presentation/contact_screen.dart';
import 'package:b_card/features/contacts/presentation/contacts_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeContacts implements ContactRepository {
  FakeContacts(this.items);

  final List<Contact> items;

  @override
  Stream<List<Contact>> watchAll() => Stream.value(items);

  @override
  Stream<Contact?> watch(String id) =>
      Stream.value(items.where((c) => c.id == id).firstOrNull);

  @override
  Future<Contact?> findBySlug(String slug) async => null;

  @override
  Future<Contact?> findByEmailOrPhone({
    required String email,
    required String phone,
  }) async => null;

  @override
  Future<List<Contact>> pendingProfiles() async => [];

  @override
  Future<void> save(Contact contact) async {}

  @override
  Future<void> delete(String id) async {}
}

Contact _contact(
  String id,
  String name, {
  String company = '',
  String notes = '',
  bool pending = false,
}) => Contact(
  id: id,
  source: ContactSource.qr,
  name: name,
  company: company,
  notes: notes,
  profilePending: pending,
  createdAt: DateTime(2026, 10, 5),
  updatedAt: DateTime(2026, 10, 5),
);

Widget _screen(List<Contact> items) => ProviderScope(
  overrides: [contactRepositoryProvider.overrideWithValue(FakeContacts(items))],
  child: MaterialApp(theme: AppTheme.light, home: const ContactsScreen()),
);

Widget _detailScreen(Contact contact) => ProviderScope(
  overrides: [
    contactRepositoryProvider.overrideWithValue(FakeContacts([contact])),
  ],
  child: MaterialApp(
    theme: AppTheme.light,
    home: ContactScreen(contactId: contact.id),
  ),
);

void main() {
  testWidgets('empty list prompts to scan the first card', (tester) async {
    await tester.pumpWidget(_screen([]));
    await tester.pumpAndSettle();
    expect(find.text('Scan your first card'), findsOneWidget);
  });

  testWidgets('search matches name, company and notes as you type', (
    tester,
  ) async {
    await tester.pumpWidget(
      _screen([
        _contact('1', 'Priya Shah', company: 'Acme'),
        _contact(
          '2',
          'Kabir Rao',
          company: 'Studio',
          notes: 'Met at TechSparks',
        ),
        _contact('3', 'priya', pending: true),
      ]),
    );
    await tester.pumpAndSettle();
    expect(find.text('Pending'), findsOneWidget);

    await tester.enterText(find.byType(SearchBar), 'techsparks');
    await tester.pump();
    expect(find.text('Kabir Rao'), findsOneWidget);
    expect(find.text('Priya Shah'), findsNothing);

    await tester.enterText(find.byType(SearchBar), 'acme');
    await tester.pump();
    expect(find.text('Priya Shah'), findsOneWidget);
    expect(find.text('Kabir Rao'), findsNothing);
  });

  testWidgets('contact details show quick actions and copyable fields', (
    tester,
  ) async {
    await tester.pumpWidget(
      _detailScreen(
        Contact(
          id: '1',
          source: ContactSource.qr,
          name: 'Priya Shah',
          title: 'Founder',
          company: 'Acme',
          email: 'priya@acme.test',
          phone: '+91 98765 43210',
          website: 'https://acme.test',
          location: 'Pune',
          createdAt: DateTime(2026, 10, 5),
          updatedAt: DateTime(2026, 10, 5),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Call'), findsOneWidget);
    expect(find.text('Email'), findsWidgets);
    expect(find.text('Website'), findsWidgets);
    expect(find.text('Added via QR scan · 5 Oct 2026'), findsOneWidget);
    expect(find.byTooltip('Copy email'), findsOneWidget);
    expect(find.byTooltip('Copy phone'), findsOneWidget);
  });
}
