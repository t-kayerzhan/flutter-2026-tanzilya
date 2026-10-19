import 'package:flutter/material.dart';

import '../models/event.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.events,
    required this.themeMode,
    required this.onProfile,
    required this.onThemeMode,
  });

  final Profile profile;
  final List<Event> events;
  final ThemeMode themeMode;
  final ValueChanged<Profile> onProfile;
  final ValueChanged<ThemeMode> onThemeMode;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  static final _groupPattern = RegExp(r'^[A-Z]{2,4}-\d{4}$');

  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.profile.name);
  late final _group = TextEditingController(text: widget.profile.group);
  final _groupFocus = FocusNode();

  @override
  void didUpdateWidget(ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // e.g. "Reset data" in the drawer changed the model under us
    if (widget.profile.name != oldWidget.profile.name) {
      _name.text = widget.profile.name;
    }
    if (widget.profile.group != oldWidget.profile.group) {
      _group.text = widget.profile.group;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _group.dispose();
    _groupFocus.dispose();
    super.dispose();
  }

  String? _validateName(String? v) =>
      (v?.trim().length ?? 0) < 2 ? 'Enter your name (2+ characters)' : null;

  String? _validateGroup(String? v) =>
      _groupPattern.hasMatch(v?.trim() ?? '') ? null : 'Use the format IT-2302';

  void _commit() {
    _formKey.currentState?.validate();
    final name = _validateName(_name.text) == null
        ? _name.text.trim()
        : widget.profile.name;
    final group = _validateGroup(_group.text) == null
        ? _group.text.trim()
        : widget.profile.group;
    widget.onProfile(widget.profile.copyWith(name: name, group: group));
  }

  String _modeLabel(ThemeMode mode) => switch (mode) {
    ThemeMode.system => 'System',
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lists = widget.events
        .where((e) => e.contains(widget.profile.name))
        .length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                validator: _validateName,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                onFieldSubmitted: (_) {
                  _commit();
                  _groupFocus.requestFocus();
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _group,
                focusNode: _groupFocus,
                decoration: const InputDecoration(
                  labelText: 'Group',
                  hintText: 'IT-2302',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.characters,
                validator: _validateGroup,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                onFieldSubmitted: (_) => _commit(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'You are on $lists ${lists == 1 ? 'list' : 'lists'}',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 24),
        Text('Theme', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final mode in ThemeMode.values)
              ChoiceChip(
                label: Text(_modeLabel(mode)),
                selected: widget.themeMode == mode,
                onSelected: (_) => widget.onThemeMode(mode),
              ),
          ],
        ),
      ],
    );
  }
}
