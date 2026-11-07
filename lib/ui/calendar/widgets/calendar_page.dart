import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:knote/data/services/firestore_service.dart';
import 'package:knote/domain/models/task.dart';
import 'package:knote/ui/auth/bloc/authentication_bloc.dart';
import 'package:knote/ui/core/localization/l10n.dart';
import 'package:knote/ui/core/preferences_scope.dart';
import 'package:knote/ui/core/themes/app_colors.dart';
import 'package:knote/ui/tasks/widgets/task_editor_page.dart';

/// A month of the user's tasks, placed on their due date (or on their
/// reminder date when they have no due date). Selecting a day lists its
/// tasks; tapping one opens it.
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key, this.firebaseManager, this.today});
  static const routeName = "calendar";

  /// Tests pass one backed by a fake Firestore.
  final FirestoreService? firebaseManager;

  /// The date shown as today; tests pass a fixed one.
  final DateTime? today;

  /// The day a task is shown on, or null if it has no date.
  static DateTime? dayOf(CheckList task) {
    final date = task.dueDate ?? task.reminderTime;
    return date == null ? null : DateUtils.dateOnly(date);
  }

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late final Stream<List<CheckList>> _tasks;
  late DateTime _today;
  late DateTime _month;
  late DateTime _selected;

  /// Side by side from this width, one above the other below.
  static const _wideLayout = 840.0;

  @override
  void initState() {
    super.initState();
    final service = widget.firebaseManager ??
        FirestoreService.user(context.read<AuthenticationBloc>().state.user);
    _tasks = service.watchTasks();
    _today = DateUtils.dateOnly(widget.today ?? DateTime.now());
    _selected = _today;
    _month = DateTime(_today.year, _today.month);
  }

  void _showMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
  }

  void _goToToday() {
    setState(() {
      _selected = _today;
      _month = DateTime(_today.year, _today.month);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text(l10n.calendar),
        actions: [
          IconButton(
            tooltip: l10n.calendarToday,
            onPressed: _goToToday,
            icon: const Icon(Icons.today),
          ),
        ],
      ),
      body: StreamBuilder<List<CheckList>>(
        stream: _tasks,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(l10n.calendarLoadError));
          }
          final byDay = <DateTime, List<CheckList>>{};
          for (final task in snapshot.data ?? const <CheckList>[]) {
            final day = CalendarPage.dayOf(task);
            if (day != null) (byDay[day] ??= []).add(task);
          }
          final grid = _MonthGrid(
            month: _month,
            today: _today,
            selected: _selected,
            tasksByDay: byDay,
            onPrevious: () => _showMonth(-1),
            onNext: () => _showMonth(1),
            onSelect: (day) => setState(() {
              _selected = day;
              _month = DateTime(day.year, day.month);
            }),
          );
          final list = _DayTasks(
            day: _selected,
            tasks: byDay[_selected] ?? const [],
            loading: !snapshot.hasData,
          );
          final wideList = _DayTasks(
            day: _selected,
            tasks: byDay[_selected] ?? const [],
            loading: !snapshot.hasData,
            scrollable: true,
          );
          return LayoutBuilder(builder: (context, constraints) {
            if (constraints.maxWidth >= _wideLayout) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 480,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: grid,
                    ),
                  ),
                  Expanded(child: wideList),
                ],
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [grid, list],
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.today,
    required this.selected,
    required this.tasksByDay,
    required this.onPrevious,
    required this.onNext,
    required this.onSelect,
  });

  final DateTime month;
  final DateTime today;
  final DateTime selected;
  final Map<DateTime, List<CheckList>> tasksByDay;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = AppColors.of(context);
    final material = MaterialLocalizations.of(context);
    // 0 = Sunday, as in MaterialLocalizations.narrowWeekdays.
    final firstWeekday = PreferencesScope.firstDayOfWeekIndex(context);
    final leading =
        (DateTime(month.year, month.month).weekday % 7 - firstWeekday) % 7;
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final cells = ((leading + daysInMonth) / 7).ceil() * 7;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: l10n.calendarPreviousMonth,
              onPressed: onPrevious,
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Text(
                toBeginningOfSentenceCase(
                    DateFormat.yMMMM(l10n.localeName).format(month)),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              tooltip: l10n.calendarNextMonth,
              onPressed: onNext,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: ExcludeSemantics(
                  child: Text(
                    material.narrowWeekdays[(firstWeekday + i) % 7],
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.textMuted),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (var i = 0; i < cells; i++)
              if (i < leading || i >= leading + daysInMonth)
                const SizedBox.shrink()
              else
                _DayCell(
                  day: DateTime(month.year, month.month, i - leading + 1),
                  today: today,
                  selected: selected,
                  tasks: tasksByDay[
                          DateTime(month.year, month.month, i - leading + 1)] ??
                      const [],
                  onSelect: onSelect,
                ),
          ],
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.today,
    required this.selected,
    required this.tasks,
    required this.onSelect,
  });

  final DateTime day;
  final DateTime today;
  final DateTime selected;
  final List<CheckList> tasks;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = AppColors.of(context);
    final isSelected = day == selected;
    final isToday = day == today;
    final open = tasks.where((task) => !task.isAllChecked).length;
    final label = '${DateFormat.yMMMMEEEEd(l10n.localeName).format(day)}, '
        '${l10n.calendarDayTasks(tasks.length)}';
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      excludeSemantics: true,
      child: InkResponse(
        key: ValueKey('calendar-day-${day.year}-${day.month}-${day.day}'),
        onTap: () => onSelect(day),
        radius: 24,
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? colors.link.withValues(alpha: 0.35) : null,
            border: isToday ? Border.all(color: colors.link, width: 1.5) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${day.day}',
                  style: TextStyle(
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  )),
              const SizedBox(height: 2),
              SizedBox(
                height: 6,
                child: tasks.isEmpty
                    ? null
                    : DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: open > 0 ? colors.accent : colors.textMuted,
                        ),
                        child: const SizedBox.square(dimension: 6),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayTasks extends StatelessWidget {
  const _DayTasks({
    required this.day,
    required this.tasks,
    required this.loading,
    this.scrollable = false,
  });

  final DateTime day;
  final List<CheckList> tasks;
  final bool loading;

  /// Whether the list scrolls on its own (wide layout) or is laid out in
  /// full inside the page's scroll view.
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = AppColors.of(context);
    final sorted = [...tasks]..sort((a, b) {
        if (a.isAllChecked != b.isAllChecked) return a.isAllChecked ? 1 : -1;
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      });
    final tiles = [
      for (final task in sorted)
        ListTile(
          leading: Icon(
            task.isAllChecked
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: task.isAllChecked ? colors.textMuted : colors.text,
          ),
          title: Text(
            task.title,
            style: task.isAllChecked
                ? TextStyle(
                    color: colors.textMuted,
                    decoration: TextDecoration.lineThrough,
                  )
                : null,
          ),
          subtitle: task.reminderTime == null
              ? null
              : Text(DateFormat.Hm(l10n.localeName).format(task.reminderTime!)),
          onTap: () => GoRouter.of(context)
              .pushNamed(TaskEditorPage.routeName, extra: task),
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: scrollable ? MainAxisSize.max : MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(
            toBeginningOfSentenceCase(
                DateFormat.MMMMEEEEd(l10n.localeName).format(day)),
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        if (loading)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (sorted.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l10n.calendarNoTasks,
                style: TextStyle(color: colors.textMuted)),
          )
        else if (scrollable)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: tiles,
            ),
          )
        else
          ...tiles,
      ],
    );
  }
}
