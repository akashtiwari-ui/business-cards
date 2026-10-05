import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../app/widgets/status_pill.dart';
import '../application/contact_providers.dart';
import '../domain/contact.dart';

/// Saved contacts with search (PRD 4.5).
class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final contacts = ref.watch(contactsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Contacts')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOptions(context),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: contacts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load contacts.\n$e')),
        data: (all) {
          if (all.isEmpty) return const _EmptyState();
          final query = _query.trim().toLowerCase();
          final shown = query.isEmpty ? all : all.where((c) => c.searchText.contains(query)).toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: SearchBar(
                  hintText: 'Search name, company, email, notes',
                  leading: const Icon(Icons.search),
                  elevation: const WidgetStatePropertyAll(0),
                  backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.surface),
                  side: WidgetStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.outline)),
                  shape: const WidgetStatePropertyAll(
                    RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              Expanded(
                child: shown.isEmpty
                    ? Center(child: Text('No contacts match "$_query"'))
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 96),
                        itemCount: shown.length,
                        separatorBuilder: (_, _) => const Divider(indent: 72),
                        itemBuilder: (context, i) => _ContactTile(contact: shown[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: const Text('Scan a card'),
              onTap: () {
                Navigator.pop(sheet);
                context.go('/scan');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add_alt),
              title: const Text('Add manually'),
              onTap: () {
                Navigator.pop(sheet);
                context.push('/contacts/new');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      minTileHeight: 64,
      leading: CircleAvatar(
        backgroundColor: AppColors.avatarFor(contact.name),
        child: Text(contact.initials, style: theme.textTheme.labelLarge?.copyWith(color: AppColors.ink)),
      ),
      title: Text(contact.name, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
      subtitle: contact.profilePending
          ? const Text('Details load when back online')
          : (contact.headline.isEmpty ? null : Text(contact.headline, maxLines: 1, overflow: TextOverflow.ellipsis)),
      trailing: contact.profilePending
          ? const StatusPill(label: 'Pending', icon: Icons.cloud_off_outlined, tone: PillTone.warning)
          : null,
      onTap: () => context.push('/contacts/${contact.id}'),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(Icons.people_outline, size: 40, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 16),
            Text('No contacts yet', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Scan someone\'s card and they\'re saved here, searchable and available offline.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.go('/scan'),
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan your first card'),
            ),
          ],
        ),
      ),
    );
  }
}
