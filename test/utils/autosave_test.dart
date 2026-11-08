import 'package:flutter_test/flutter_test.dart';

import 'package:knote/utils/autosave.dart';

void main() {
  const delay = Duration(milliseconds: 20);
  Future<void> wait() => Future<void>.delayed(delay * 3);

  test('saves once, after the edits stop', () async {
    var saves = 0;
    final autosave = Autosave(() => saves++, delay: delay);

    autosave.changed();
    autosave.changed();
    autosave.changed();
    expect(saves, 0);

    await wait();
    expect(saves, 1);
    expect(autosave.hasChanges, isFalse);
  });

  test('flush saves pending edits at once', () {
    var saves = 0;
    final autosave = Autosave(() => saves++, delay: delay);

    autosave.changed();
    autosave.flush();

    expect(saves, 1);
  });

  test('flush and dispose do nothing without edits', () async {
    var saves = 0;
    final autosave = Autosave(() => saves++, delay: delay);

    autosave.flush();
    autosave.changed();
    autosave.flush();
    autosave.dispose();
    await wait();

    expect(saves, 1, reason: 'the timer of the flushed edit was cancelled');
  });

  test('markSaved drops pending edits', () async {
    var saves = 0;
    final autosave = Autosave(() => saves++, delay: delay);

    autosave.changed();
    autosave.markSaved();
    await wait();
    autosave.dispose();

    expect(saves, 0);
  });
}
