import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/config/app_config.dart';
import '../application/card_providers.dart';
import '../domain/business_card.dart';
import '../domain/card_validators.dart';

/// Creates or edits the user's card (PRD 4.1, 4.2).
class CardEditorScreen extends ConsumerStatefulWidget {
  const CardEditorScreen({super.key});

  @override
  ConsumerState<CardEditorScreen> createState() => _CardEditorScreenState();
}

class _LinkFields {
  _LinkFields([CardLink? link])
      : label = TextEditingController(text: link?.label),
        url = TextEditingController(text: link?.url);

  final TextEditingController label;
  final TextEditingController url;

  void dispose() {
    label.dispose();
    url.dispose();
  }
}

class _CardEditorScreenState extends ConsumerState<CardEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  BusinessCard? _existing;

  late final _name = TextEditingController(text: _existing?.name);
  late final _slug = TextEditingController(text: _existing?.slug);
  late final _title = TextEditingController(text: _existing?.title);
  late final _company = TextEditingController(text: _existing?.company);
  late final _phone = TextEditingController(text: _existing?.phone);
  late final _email = TextEditingController(text: _existing?.email);
  late final _website = TextEditingController(text: _existing?.website);
  late final _linkedin = TextEditingController(text: _existing?.linkedin);
  late final _location = TextEditingController(text: _existing?.location);
  late final _bio = TextEditingController(text: _existing?.bio);
  late final List<_LinkFields> _links;

  late bool _showPhone;
  late bool _showEmail;
  bool _slugEdited = false;
  String? _slugError;
  bool _saving = false;

  bool get _isNew => _existing == null;

  @override
  void initState() {
    super.initState();
    _existing = ref.read(myCardProvider).value;
    _links = [for (final link in _existing?.links ?? <CardLink>[]) _LinkFields(link)];
    _showPhone = !(_existing?.hidePhone ?? false);
    _showEmail = !(_existing?.hideEmail ?? false);
  }

  @override
  void dispose() {
    for (final c in [_name, _slug, _title, _company, _phone, _email, _website, _linkedin, _location, _bio]) {
      c.dispose();
    }
    for (final l in _links) {
      l.dispose();
    }
    super.dispose();
  }

  void _onNameChanged(String name) {
    if (_isNew && !_slugEdited) _slug.text = suggestSlug(name);
  }

  Future<void> _save() async {
    _slugError = null;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    if (_isNew && !await _claimSlug()) {
      if (mounted) setState(() => _saving = false);
      return;
    }

    final card = BusinessCard(
      id: _existing?.id ?? const Uuid().v4(),
      slug: _existing?.slug ?? _slug.text.trim(),
      name: _name.text.trim(),
      title: _title.text.trim(),
      company: _company.text.trim(),
      phone: _phone.text.trim(),
      email: _email.text.trim(),
      website: normalizeUrl(_website.text),
      linkedin: normalizeUrl(_linkedin.text),
      location: _location.text.trim(),
      bio: _bio.text.trim(),
      links: [
        for (final l in _links)
          if (l.url.text.trim().isNotEmpty)
            CardLink(label: l.label.text.trim(), url: normalizeUrl(l.url.text)),
      ],
      isPublic: _existing?.isPublic ?? true,
      hidePhone: !_showPhone,
      hideEmail: !_showEmail,
      updatedAt: DateTime.now(),
    );

    try {
      await ref.read(cardRepositoryProvider).save(card);
      if (mounted) context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save: $e')));
    }
  }

  /// Checks the profile link with the server (PRD 4.1). The offline-only
  /// build has no server and skips the check.
  Future<bool> _claimSlug() async {
    final remote = ref.read(cardRemoteProvider);
    if (remote == null) return true;
    final slug = _slug.text.trim();
    try {
      if (await remote.isSlugAvailable(slug)) return true;
      String? suggestion;
      for (final candidate in ['$slug-1', '$slug-2', '$slug-card']) {
        if (validateSlug(candidate) == null && await remote.isSlugAvailable(candidate)) {
          suggestion = candidate;
          break;
        }
      }
      _slugError = suggestion == null
          ? 'This link is taken. Try another.'
          : 'This link is taken. Try "$suggestion".';
    } catch (_) {
      _slugError = 'Connect to the internet to claim your link.';
    }
    _formKey.currentState?.validate();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'Create card' : 'Edit card'),
        actions: [
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
            const _Section('About you'),
            _field(_name, 'Name *', validator: validateName, onChanged: _onNameChanged,
                capitalization: TextCapitalization.words, autofocus: _isNew),
            if (_isNew)
              _field(_slug, 'Profile link',
                  // Server-side result from _claimSlug, shown like any other error.
                  validator: (v) => validateSlug(v) ?? _slugError,
                  prefix: '${AppConfig.profileBaseUrl}/',
                  helper: 'Permanent. Your QR code points here.',
                  onChanged: (_) {
                    _slugEdited = true;
                    _slugError = null;
                  })
            else
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.link),
                title: Text(AppConfig.profileUrl(_existing!.slug)),
                subtitle: const Text('Your link and QR code never change'),
              ),
            _field(_title, 'Title', capitalization: TextCapitalization.words),
            _field(_company, 'Company', capitalization: TextCapitalization.words),
            _field(_location, 'Location', capitalization: TextCapitalization.words),
            _field(_bio, 'Short bio', maxLines: 3, maxLength: 280),
            const _Section('Contact'),
            _field(_phone, 'Phone', validator: validatePhone, keyboard: TextInputType.phone),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Show phone on public profile'),
              value: _showPhone,
              onChanged: (v) => setState(() => _showPhone = v),
            ),
            _field(_email, 'Email', validator: validateEmail, keyboard: TextInputType.emailAddress),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Show email on public profile'),
              value: _showEmail,
              onChanged: (v) => setState(() => _showEmail = v),
            ),
            const _Section('Links'),
            _field(_website, 'Website', validator: validateUrl, keyboard: TextInputType.url),
            _field(_linkedin, 'LinkedIn', validator: validateUrl, keyboard: TextInputType.url),
            for (final (i, link) in _links.indexed)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _field(link.label, 'Label')),
                  const SizedBox(width: 8),
                  Expanded(flex: 3, child: _field(link.url, 'URL', validator: validateUrl, keyboard: TextInputType.url)),
                  IconButton(
                    tooltip: 'Remove link',
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () => setState(() => _links.removeAt(i).dispose()),
                  ),
                ],
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => setState(() => _links.add(_LinkFields())),
                icon: const Icon(Icons.add),
                label: const Text('Add link'),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_isNew ? 'Publish card' : 'Save changes'),
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
    ValueChanged<String>? onChanged,
    TextInputType? keyboard,
    TextCapitalization capitalization = TextCapitalization.none,
    String? prefix,
    String? helper,
    int maxLines = 1,
    int? maxLength,
    bool autofocus = false,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: controller,
          validator: validator,
          onChanged: onChanged,
          keyboardType: keyboard,
          textCapitalization: capitalization,
          maxLines: maxLines,
          maxLength: maxLength,
          autofocus: autofocus,
          decoration: InputDecoration(labelText: label, prefixText: prefix, helperText: helper),
        ),
      );
}

class _Section extends StatelessWidget {
  const _Section(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 12),
        child: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            )),
      );
}
