import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../card/application/card_providers.dart';
import '../data/local_contact_repository.dart';
import '../domain/contact.dart';
import '../domain/contact_repository.dart';

final contactRepositoryProvider = Provider<ContactRepository>(
  (ref) => LocalContactRepository(
    ref.watch(appDatabaseProvider),
    ownerId: ref.watch(currentUserIdProvider),
  ),
);

final contactsProvider = StreamProvider<List<Contact>>(
  (ref) => ref.watch(contactRepositoryProvider).watchAll(),
);

final contactProvider = StreamProvider.family<Contact?, String>(
  (ref, id) => ref.watch(contactRepositoryProvider).watch(id),
);
