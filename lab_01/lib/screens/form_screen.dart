import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/event.dart';
import '../utils/format.dart';

typedef _Values = ({
  String title,
  String place,
  String limit,
  String description,
  bool online,
  EventCategory? category,
  DateTime? when,
});

const _auto = AutovalidateMode.onUserInteraction;

class FormScreen extends StatefulWidget {
  const FormScreen({super.key, this.event});

  /// null = new event, otherwise edit.
  final Event? event;

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _timeKey = GlobalKey<FormFieldState<String>>();

  final _title = TextEditingController();
  final _place = TextEditingController();
  final _limit = TextEditingController();
  final _dateText = TextEditingController();
  final _timeText = TextEditingController();
  final _desc = TextEditingController();

  final _titleFocus = FocusNode();
  final _placeFocus = FocusNode();
  final _limitFocus = FocusNode();
  final _descFocus = FocusNode();

  EventCategory? _category;
  bool _online = false;
  DateTime? _date;
  TimeOfDay? _time;
  bool _saving = false;
  late final _Values _initial;

  @override
  void initState() {
    super.initState();
    final base =
        widget.event ?? Event.empty(); // defaults come from Event.empty()
    _title.text = base.title;
    _place.text = base.place;
    _limit.text = base.limit.toString();
    _desc.text = base.description ?? '';
    _online = base.online;
    if (widget.event case final e?) {
      _category = e.category;
      _date = DateUtils.dateOnly(e.when);
      _time = TimeOfDay.fromDateTime(e.when);
      _dateText.text = formatDay(e.when);
      _timeText.text = formatHm(e.when.hour, e.when.minute);
    }
    _initial = _values();
  }

  @override
  void dispose() {
    for (final c in [_title, _place, _limit, _dateText, _timeText, _desc]) {
      c.dispose();
    }
    for (final f in [_titleFocus, _placeFocus, _limitFocus, _descFocus]) {
      f.dispose();
    }
    super.dispose();
  }

  DateTime? _combine() {
    final d = _date;
    final t = _time;
    if (d == null || t == null) return null;
    return DateTime(d.year, d.month, d.day, t.hour, t.minute);
  }

  _Values _values() => (
    title: _title.text.trim(),
    place: _place.text.trim(),
    limit: _limit.text.trim(),
    description: _desc.text.trim(),
    online: _online,
    category: _category,
    when: _combine(),
  );

  /// Current values vs. the ones the form opened with.
  bool get _dirty => _values() != _initial;

  // Controllers already hold the change; rebuild so PopScope.canPop is re-read.
  void _touch() => setState(() {});

  String? _validateTitle(String? v) {
    final t = v?.trim() ?? '';
    return (t.length < 3 || t.length > 60)
        ? 'Title must be 3–60 characters'
        : null;
  }

  String? _validatePlace(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return _online ? 'Link is required' : 'Place is required';
    if (_online && !t.contains('://')) return 'Link must contain ://';
    return null;
  }

  String? _validateLimit(String? v) {
    final n = int.tryParse(v?.trim() ?? '');
    if (n == null || n < 1 || n > 500) return 'Enter a number from 1 to 500';
    final count = widget.event?.count ?? 0;
    if (n < count) return 'Not below the current count ($count)';
    return null;
  }

  String? _validateCategory(EventCategory? c) =>
      c == null ? 'Pick a category' : null;

  String? _validateDate(String? v) => _date == null ? 'Pick a date' : null;

  String? _validateTime(String? v) {
    if (_time == null) return 'Pick a time';
    final when = _combine();
    final isNew = widget.event == null;
    if (isNew && when != null && !when.isAfter(DateTime.now())) {
      return 'Must be in the future';
    }
    return null;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null || !mounted) return; // Cancel keeps the old value
    setState(() {
      _date = picked;
      _dateText.text = formatDay(picked);
    });
    if (_time != null) _timeKey.currentState?.validate();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked == null || !mounted) return; // Cancel keeps the old value
    setState(() {
      _time = picked;
      _timeText.text = formatHm(picked.hour, picked.minute);
    });
  }

  Event _build() {
    final base = widget.event ?? Event.empty();
    final desc = _desc.text.trim();
    return base.copyWith(
      id: widget.event?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: _title.text.trim(),
      category: _category ?? base.category,
      when: _combine() ?? base.when,
      limit: int.tryParse(_limit.text.trim()) ?? base.limit,
      place: _place.text.trim(),
      online: _online,
      description: desc,
      clearDescription: desc.isEmpty,
    );
  }

  Future<void> _save() async {
    if (_saving) return; // a double tap does not save twice
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    Navigator.of(context).pop(_build());
  }

  Future<void> _onPop(bool didPop, Object? result) async {
    if (didPop) return;
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard changes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (discard == true && mounted) Navigator.of(context).pop();
  }

  void _unfocus(PointerDownEvent _) =>
      FocusManager.instance.primaryFocus?.unfocus();

  @override
  Widget build(BuildContext context) {
    final isNew = widget.event == null;
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: _onPop,
      child: Scaffold(
        appBar: AppBar(title: Text(isNew ? 'New event' : 'Edit event')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            autovalidateMode: _auto,
            onChanged: _touch,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _title,
                  focusNode: _titleFocus,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 60,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  validator: _validateTitle,
                  autovalidateMode: _auto,
                  onTapOutside: _unfocus,
                  onFieldSubmitted: (_) => _placeFocus.requestFocus(),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<EventCategory>(
                  initialValue: _category,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final c in EventCategory.values)
                      DropdownMenuItem(value: c, child: Text(c.label)),
                  ],
                  validator: _validateCategory,
                  autovalidateMode: _auto,
                  onChanged: (c) => setState(() => _category = c),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Online event'),
                  subtitle: const Text('The place becomes a link'),
                  value: _online,
                  onChanged: (v) => setState(() => _online = v),
                ),
                TextFormField(
                  controller: _place,
                  focusNode: _placeFocus,
                  decoration: InputDecoration(
                    labelText: _online ? 'Meeting link' : 'Place',
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: _online
                      ? TextInputType.url
                      : TextInputType.text,
                  textInputAction: TextInputAction.next,
                  validator: _validatePlace,
                  autovalidateMode: _auto,
                  onTapOutside: _unfocus,
                  onFieldSubmitted: (_) => _limitFocus.requestFocus(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _dateText,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        validator: _validateDate,
                        autovalidateMode: _auto,
                        onTap: _pickDate,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        key: _timeKey,
                        controller: _timeText,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Time',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.schedule),
                        ),
                        validator: _validateTime,
                        autovalidateMode: _auto,
                        onTap: _pickTime,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _limit,
                  focusNode: _limitFocus,
                  decoration: const InputDecoration(
                    labelText: 'Capacity',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.next,
                  validator: _validateLimit,
                  autovalidateMode: _auto,
                  onTapOutside: _unfocus,
                  onFieldSubmitted: (_) => _descFocus.requestFocus(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _desc,
                  focusNode: _descFocus,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                  minLines: 2,
                  maxLines: 4,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.done,
                  onTapOutside: _unfocus,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
