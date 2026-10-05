import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../../app/theme.dart';
import '../../../app/widgets/status_pill.dart';
import '../../card/domain/card_validators.dart';
import '../application/contact_providers.dart';
import '../domain/contact.dart';

/// Review, edit or add a contact (PRD 4.4 review step, 4.6 details).
/// [contactId] is `new` for a manual contact.
class ContactScreen extends ConsumerWidget {
  const ContactScreen({super.key, required this.contactId});

  final String contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (contactId == 'new') return const _ContactForm(contact: null);
    final contact = ref.watch(contactProvider(contactId));
    return contact.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('$e')),
      ),
      data: (c) => c == null
          ? Scaffold(
              appBar: AppBar(),
              body: const Center(child: Text('This contact was deleted.')),
            )
          : _ContactForm(key: ValueKey(c.id), contact: c),
    );
  }
}

class _ContactForm extends ConsumerStatefulWidget {
  const _ContactForm({super.key, required this.contact});

  final Contact? contact;

  @override
  ConsumerState<_ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends ConsumerState<_ContactForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.contact?.name);
  late final _title = TextEditingController(text: widget.contact?.title);
  late final _company = TextEditingController(text: widget.contact?.company);
  late final _phone = TextEditingController(text: widget.contact?.phone);
  late final _email = TextEditingController(text: widget.contact?.email);
  late final _website = TextEditingController(text: widget.contact?.website);
  late final _linkedin = TextEditingController(text: widget.contact?.linkedin);
  late final _location = TextEditingController(text: widget.contact?.location);
  late final _notes = TextEditingController(text: widget.contact?.notes);
  bool _saving = false;

  List<TextEditingController> get _all => [
    _name,
    _title,
    _company,
    _phone,
    _email,
    _website,
    _linkedin,
    _location,
    _notes,
  ];

  @override
  void dispose() {
    for (final c in _all) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final now = DateTime.now();
    final existing = widget.contact;
    final base =
        existing ??
        Contact(
          id: const Uuid().v4(),
          source: ContactSource.manual,
          name: '',
          createdAt: now,
          updatedAt: now,
        );
    await ref
        .read(contactRepositoryProvider)
        .save(
          base.copyWith(
            name: _name.text.trim(),
            title: _title.text.trim(),
            company: _company.text.trim(),
            phone: _phone.text.trim(),
            email: _email.text.trim(),
            website: normalizeUrl(_website.text),
            linkedin: normalizeUrl(_linkedin.text),
            location: _location.text.trim(),
            notes: _notes.text.trim(),
            updatedAt: now,
          ),
        );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Contact saved')));
    context.pop();
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Delete contact?'),
        content: Text(
          '${widget.contact!.name} will be removed from your contacts.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialog, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref.read(contactRepositoryProvider).delete(widget.contact!.id);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final contact = widget.contact;

    return Scaffold(
      appBar: AppBar(
        title: Text(contact == null ? 'New contact' : 'Contact'),
        actions: [
          if (contact != null)
            IconButton(
              tooltip: 'Delete contact',
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
          TextButton(
            onPressed: _saving ? null : _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (contact != null) ...[
              _ContactHeader(contact: contact),
              if (contact.profilePending) ...[
                const SizedBox(height: 12),
                const StatusPill(
                  label: "Scanned offline · details load when you're online",
                  icon: Icons.cloud_off_outlined,
                  tone: PillTone.warning,
                ),
              ],
              _QuickActions(contact: contact),
              _InfoRows(contact: contact),
              const SizedBox(height: 24),
            ],
            _field(
              _name,
              'Name *',
              validator: validateName,
              capitalization: TextCapitalization.words,
            ),
            _field(_title, 'Title', capitalization: TextCapitalization.words),
            _field(
              _company,
              'Company',
              capitalization: TextCapitalization.words,
            ),
            _field(
              _phone,
              'Phone',
              validator: validatePhone,
              keyboard: TextInputType.phone,
            ),
            _field(
              _email,
              'Email',
              validator: validateEmail,
              keyboard: TextInputType.emailAddress,
            ),
            _field(
              _website,
              'Website',
              validator: validateUrl,
              keyboard: TextInputType.url,
            ),
            _field(
              _linkedin,
              'LinkedIn',
              validator: validateUrl,
              keyboard: TextInputType.url,
            ),
            _field(
              _location,
              'Location',
              capitalization: TextCapitalization.words,
            ),
            _field(
              _notes,
              'Notes',
              hint: 'Where and why you met',
              maxLines: 4,
              capitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: const Text('Save contact'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    FormFieldValidator<String>? validator,
    TextInputType? keyboard,
    TextCapitalization capitalization = TextCapitalization.none,
    String? hint,
    int maxLines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboard,
      textCapitalization: capitalization,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, hintText: hint),
    ),
  );
}

class _ContactHeader extends StatelessWidget {
  const _ContactHeader({required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: AppColors.avatarFor(contact.name),
          child: Text(
            contact.initials,
            style: theme.textTheme.titleLarge?.copyWith(color: AppColors.ink),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(contact.name, style: theme.textTheme.titleLarge),
              if (contact.headline.isNotEmpty)
                Text(
                  contact.headline,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              Text(
                _provenance(contact),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    final actions = [
      if (contact.phone.isNotEmpty)
        _ActionSpec(
          'Call',
          Icons.call_outlined,
          Uri(scheme: 'tel', path: contact.phone),
        ),
      if (contact.email.isNotEmpty)
        _ActionSpec(
          'Email',
          Icons.mail_outline,
          Uri(scheme: 'mailto', path: contact.email),
        ),
      if (contact.website.isNotEmpty)
        _ActionSpec('Website', Icons.language, Uri.parse(contact.website)),
    ];
    if (actions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          for (final action in actions) ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _launch(context, action.uri),
                icon: Icon(action.icon),
                label: Text(action.label),
              ),
            ),
            if (action != actions.last) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Future<void> _launch(BuildContext context, Uri uri) async {
    if (await canLaunchUrl(uri) &&
        await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      return;
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Could not open this action')),
        );
    }
  }
}

class _ActionSpec {
  const _ActionSpec(this.label, this.icon, this.uri);

  final String label;
  final IconData icon;
  final Uri uri;
}

class _InfoRows extends StatelessWidget {
  const _InfoRows({required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    final rows = [
      _InfoSpec('Email', contact.email, Icons.mail_outline),
      _InfoSpec('Phone', contact.phone, Icons.call_outlined),
      _InfoSpec('Company', contact.company, Icons.apartment_outlined),
      _InfoSpec('Location', contact.location, Icons.place_outlined),
      _InfoSpec('Website', contact.website, Icons.language),
      _InfoSpec('LinkedIn', contact.linkedin, Icons.work_outline),
    ].where((row) => row.value.isNotEmpty).toList();
    if (rows.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Card(
        child: Column(
          children: [
            for (final row in rows) ...[
              ListTile(
                leading: Icon(row.icon),
                title: Text(row.label),
                subtitle: Text(
                  row.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  tooltip: 'Copy ${row.label.toLowerCase()}',
                  icon: const Icon(Icons.copy),
                  onPressed: () => _copy(context, row.value),
                ),
              ),
              if (row != rows.last) const Divider(height: 1, indent: 56),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _copy(BuildContext context, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Copied')));
    }
  }
}

class _InfoSpec {
  const _InfoSpec(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;
}

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// "Added via QR scan · 5 Oct 2026" (PRD 4.6 provenance).
String _provenance(Contact c) {
  final when = c.scannedAt ?? c.createdAt;
  final date = '${when.day} ${_months[when.month - 1]} ${when.year}';
  final how = switch (c.source) {
    ContactSource.qr => 'Added via QR scan',
    ContactSource.vcard => 'Added via vCard QR',
    ContactSource.nfc => 'Added via NFC',
    ContactSource.manual => 'Added manually',
    ContactSource.nearby => 'Added via Nearby',
  };
  return '$how · $date';
}
