import 'package:flutter/foundation.dart';

import 'models/event.dart';

abstract final class Routes {
  static const shell = '/';
  static const detail = '/event';
  static const form = '/event/form';
}

class DetailArgs {
  const DetailArgs({
    required this.event,
    required this.profile,
    required this.onChanged,
    required this.onDelete,
    required this.onGoToTab,
  });

  final Event event;
  final Profile profile;
  final ValueChanged<Event> onChanged;
  final ValueChanged<String> onDelete;
  final ValueChanged<int> onGoToTab;
}

class FormArgs {
  const FormArgs({this.event});

  /// null = new event, otherwise edit.
  final Event? event;
}
