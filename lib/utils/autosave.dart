import 'dart:async';

/// Saves an editor's content shortly after the user stops typing, and on
/// demand (leaving the page, app sent to the background).
///
/// Call [changed] on every edit and [flush] when the content must be saved
/// now. [flush] only calls the save function when something changed since
/// the last save, so opening a note and leaving it writes nothing.
class Autosave {
  Autosave(this._save, {this.delay = const Duration(seconds: 1)});

  final void Function() _save;

  /// Pause in typing after which the content is saved.
  final Duration delay;

  Timer? _timer;
  bool _hasChanges = false;

  /// Whether there are edits that are not saved yet.
  bool get hasChanges => _hasChanges;

  void changed() {
    _hasChanges = true;
    _timer?.cancel();
    _timer = Timer(delay, flush);
  }

  void flush() {
    _timer?.cancel();
    _timer = null;
    if (!_hasChanges) return;
    _hasChanges = false;
    _save();
  }

  /// Forgets pending edits, when they were saved some other way.
  void markSaved() {
    _timer?.cancel();
    _timer = null;
    _hasChanges = false;
  }

  /// Saves pending edits and stops the timer.
  void dispose() => flush();
}
