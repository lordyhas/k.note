import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptions;

  /// No description provided for @untitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get untitled;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @titleHint.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleHint;

  /// No description provided for @navNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get navNotes;

  /// No description provided for @navTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get navTasks;

  /// No description provided for @navYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get navYou;

  /// No description provided for @notesGridView.
  ///
  /// In en, this message translates to:
  /// **'Grid view'**
  String get notesGridView;

  /// No description provided for @notesListView.
  ///
  /// In en, this message translates to:
  /// **'List view'**
  String get notesListView;

  /// No description provided for @notesSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get notesSearch;

  /// No description provided for @notesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search notes'**
  String get notesSearchHint;

  /// No description provided for @notesClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get notesClearSearch;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notesNew.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get notesNew;

  /// No description provided for @notesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Your notes couldn\'t be loaded'**
  String get notesLoadError;

  /// No description provided for @notesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notes yet. Tap + to write one.'**
  String get notesEmpty;

  /// No description provided for @notesNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No notes match \"{query}\"'**
  String notesNoMatch(String query);

  /// No description provided for @noteArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get noteArchive;

  /// No description provided for @noteMoveToBin.
  ///
  /// In en, this message translates to:
  /// **'Move to bin'**
  String get noteMoveToBin;

  /// No description provided for @noteChangeColor.
  ///
  /// In en, this message translates to:
  /// **'Change color'**
  String get noteChangeColor;

  /// No description provided for @noteSavingMode.
  ///
  /// In en, this message translates to:
  /// **'Saving mode'**
  String get noteSavingMode;

  /// No description provided for @noteArchived.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" archived'**
  String noteArchived(String title);

  /// No description provided for @noteMovedToBin.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" moved to the bin'**
  String noteMovedToBin(String title);

  /// No description provided for @noteArchiveFailed.
  ///
  /// In en, this message translates to:
  /// **'The note couldn\'t be archived'**
  String get noteArchiveFailed;

  /// No description provided for @noteUnarchiveFailed.
  ///
  /// In en, this message translates to:
  /// **'The note couldn\'t be unarchived'**
  String get noteUnarchiveFailed;

  /// No description provided for @noteMoveToBinFailed.
  ///
  /// In en, this message translates to:
  /// **'The note couldn\'t be moved to the bin'**
  String get noteMoveToBinFailed;

  /// No description provided for @noteRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'The note couldn\'t be restored'**
  String get noteRestoreFailed;

  /// No description provided for @noteSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'The note couldn\'t be saved'**
  String get noteSaveFailed;

  /// No description provided for @noteColorSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'The note color couldn\'t be saved'**
  String get noteColorSaveFailed;

  /// No description provided for @noteDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'The note couldn\'t be deleted'**
  String get noteDeleteFailed;

  /// No description provided for @editorDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get editorDone;

  /// No description provided for @editorColor.
  ///
  /// In en, this message translates to:
  /// **'Note color'**
  String get editorColor;

  /// No description provided for @editorColorTitle.
  ///
  /// In en, this message translates to:
  /// **'Change the note color'**
  String get editorColorTitle;

  /// No description provided for @binTitle.
  ///
  /// In en, this message translates to:
  /// **'Bin'**
  String get binTitle;

  /// No description provided for @binLoadError.
  ///
  /// In en, this message translates to:
  /// **'The bin couldn\'t be loaded'**
  String get binLoadError;

  /// No description provided for @binEmpty.
  ///
  /// In en, this message translates to:
  /// **'The bin is empty'**
  String get binEmpty;

  /// No description provided for @binDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Restore this note, or delete it forever? Deleting it forever can\'t be undone.'**
  String get binDialogContent;

  /// No description provided for @binDeleteForever.
  ///
  /// In en, this message translates to:
  /// **'Delete forever'**
  String get binDeleteForever;

  /// No description provided for @binRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get binRestore;

  /// No description provided for @archiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Archived notes'**
  String get archiveTitle;

  /// No description provided for @archiveLoadError.
  ///
  /// In en, this message translates to:
  /// **'Archived notes couldn\'t be loaded'**
  String get archiveLoadError;

  /// No description provided for @archiveEmpty.
  ///
  /// In en, this message translates to:
  /// **'No archived notes'**
  String get archiveEmpty;

  /// No description provided for @tasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasksTitle;

  /// No description provided for @tasksLoadError.
  ///
  /// In en, this message translates to:
  /// **'Your tasks couldn\'t be loaded'**
  String get tasksLoadError;

  /// No description provided for @tasksEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet. Tap + to add one.'**
  String get tasksEmpty;

  /// No description provided for @tasksActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get tasksActive;

  /// No description provided for @tasksCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed {count}'**
  String tasksCompleted(int count);

  /// No description provided for @tasksNew.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get tasksNew;

  /// No description provided for @taskDeleted.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" deleted'**
  String taskDeleted(String title);

  /// No description provided for @taskDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'The task couldn\'t be deleted'**
  String get taskDeleteFailed;

  /// No description provided for @taskRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'The task couldn\'t be restored'**
  String get taskRestoreFailed;

  /// No description provided for @taskUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'The task couldn\'t be updated'**
  String get taskUpdateFailed;

  /// No description provided for @taskSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'The task couldn\'t be saved'**
  String get taskSaveFailed;

  /// No description provided for @taskSaveFailedNamed.
  ///
  /// In en, this message translates to:
  /// **'The task \"{title}\" couldn\'t be saved'**
  String taskSaveFailedNamed(String title);

  /// No description provided for @taskQuickAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save this task. Tap ↑ to try again.'**
  String get taskQuickAddFailed;

  /// No description provided for @taskMarkCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark as completed'**
  String get taskMarkCompleted;

  /// No description provided for @taskMarkNotCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark as not completed'**
  String get taskMarkNotCompleted;

  /// No description provided for @taskMarkImportant.
  ///
  /// In en, this message translates to:
  /// **'Mark as important'**
  String get taskMarkImportant;

  /// No description provided for @taskRemoveImportance.
  ///
  /// In en, this message translates to:
  /// **'Remove importance'**
  String get taskRemoveImportance;

  /// No description provided for @dateToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dateToday;

  /// No description provided for @dateTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get dateTomorrow;

  /// No description provided for @dateYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dateYesterday;

  /// No description provided for @dueToday.
  ///
  /// In en, this message translates to:
  /// **'Due Today'**
  String get dueToday;

  /// No description provided for @dueTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Due Tomorrow'**
  String get dueTomorrow;

  /// No description provided for @dueOn.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String dueOn(String date);

  /// No description provided for @quickAddHint.
  ///
  /// In en, this message translates to:
  /// **'Add a task'**
  String get quickAddHint;

  /// No description provided for @quickAddSubmit.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get quickAddSubmit;

  /// No description provided for @setDueDate.
  ///
  /// In en, this message translates to:
  /// **'Set due date'**
  String get setDueDate;

  /// No description provided for @menuToday.
  ///
  /// In en, this message translates to:
  /// **'Today ({weekday})'**
  String menuToday(String weekday);

  /// No description provided for @menuTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow ({weekday})'**
  String menuTomorrow(String weekday);

  /// No description provided for @menuNextWeek.
  ///
  /// In en, this message translates to:
  /// **'Next week ({weekday})'**
  String menuNextWeek(String weekday);

  /// No description provided for @pickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get pickDate;

  /// No description provided for @removeDueDate.
  ///
  /// In en, this message translates to:
  /// **'Remove due date'**
  String get removeDueDate;

  /// No description provided for @remindMe.
  ///
  /// In en, this message translates to:
  /// **'Remind me'**
  String get remindMe;

  /// No description provided for @remindMeAt.
  ///
  /// In en, this message translates to:
  /// **'Remind me at {time}'**
  String remindMeAt(String time);

  /// No description provided for @reminderTomorrowAt.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow, {time}'**
  String reminderTomorrowAt(String time);

  /// No description provided for @reminderOn.
  ///
  /// In en, this message translates to:
  /// **'{date}, {time}'**
  String reminderOn(String date, String time);

  /// No description provided for @menuLaterToday.
  ///
  /// In en, this message translates to:
  /// **'Later today ({time})'**
  String menuLaterToday(String time);

  /// No description provided for @pickDateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Pick a date & time'**
  String get pickDateAndTime;

  /// No description provided for @removeReminder.
  ///
  /// In en, this message translates to:
  /// **'Remove reminder'**
  String get removeReminder;

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @repeatCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get repeatCustom;

  /// No description provided for @repeatNever.
  ///
  /// In en, this message translates to:
  /// **'Never repeat'**
  String get repeatNever;

  /// No description provided for @repeatDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get repeatDaily;

  /// No description provided for @repeatWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Weekdays'**
  String get repeatWeekdays;

  /// No description provided for @repeatWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get repeatWeekly;

  /// No description provided for @repeatMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get repeatMonthly;

  /// No description provided for @repeatYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get repeatYearly;

  /// No description provided for @repeatEveryDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every day} other{Every {count} days}}'**
  String repeatEveryDays(int count);

  /// No description provided for @repeatEveryWeeks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every week} other{Every {count} weeks}}'**
  String repeatEveryWeeks(int count);

  /// No description provided for @repeatEveryMonths.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every month} other{Every {count} months}}'**
  String repeatEveryMonths(int count);

  /// No description provided for @repeatEveryYears.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every year} other{Every {count} years}}'**
  String repeatEveryYears(int count);

  /// No description provided for @repeatOnDays.
  ///
  /// In en, this message translates to:
  /// **'{rule} on {days}'**
  String repeatOnDays(String rule, String days);

  /// No description provided for @repeatEveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Repeat every'**
  String get repeatEveryTitle;

  /// No description provided for @unitDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{day} other{days}}'**
  String unitDays(int count);

  /// No description provided for @unitWeeks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{week} other{weeks}}'**
  String unitWeeks(int count);

  /// No description provided for @unitMonths.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{month} other{months}}'**
  String unitMonths(int count);

  /// No description provided for @unitYears.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{year} other{years}}'**
  String unitYears(int count);

  /// No description provided for @fewer.
  ///
  /// In en, this message translates to:
  /// **'Fewer'**
  String get fewer;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @untitledTask.
  ///
  /// In en, this message translates to:
  /// **'Untitled task'**
  String get untitledTask;

  /// No description provided for @taskStepHint.
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get taskStepHint;

  /// No description provided for @taskAddStep.
  ///
  /// In en, this message translates to:
  /// **'Add step'**
  String get taskAddStep;

  /// No description provided for @taskRemoveStep.
  ///
  /// In en, this message translates to:
  /// **'Remove step'**
  String get taskRemoveStep;

  /// No description provided for @taskAddedToMyDay.
  ///
  /// In en, this message translates to:
  /// **'Added to My Day'**
  String get taskAddedToMyDay;

  /// No description provided for @taskAddToMyDay.
  ///
  /// In en, this message translates to:
  /// **'Add to My Day'**
  String get taskAddToMyDay;

  /// No description provided for @taskAddDueDate.
  ///
  /// In en, this message translates to:
  /// **'Add due date'**
  String get taskAddDueDate;

  /// No description provided for @taskAddFile.
  ///
  /// In en, this message translates to:
  /// **'Add file'**
  String get taskAddFile;

  /// No description provided for @taskFilesUnavailable.
  ///
  /// In en, this message translates to:
  /// **'File attachments are not available yet'**
  String get taskFilesUnavailable;

  /// No description provided for @taskNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get taskNoteHint;

  /// No description provided for @taskCreatedOn.
  ///
  /// In en, this message translates to:
  /// **'Created on {date}'**
  String taskCreatedOn(String date);

  /// No description provided for @taskColor.
  ///
  /// In en, this message translates to:
  /// **'Task color'**
  String get taskColor;

  /// No description provided for @taskDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete task'**
  String get taskDelete;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @logOutQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you want to log out?'**
  String get logOutQuestion;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @unknownName.
  ///
  /// In en, this message translates to:
  /// **'Unknown name'**
  String get unknownName;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @emailUpdates.
  ///
  /// In en, this message translates to:
  /// **'Email updates'**
  String get emailUpdates;

  /// No description provided for @emailUpdatesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send me updates by email'**
  String get emailUpdatesSubtitle;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About us'**
  String get aboutUs;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About this app'**
  String get aboutApp;

  /// No description provided for @lastUpdate.
  ///
  /// In en, this message translates to:
  /// **'Last update'**
  String get lastUpdate;

  /// No description provided for @betaVersion.
  ///
  /// In en, this message translates to:
  /// **'Beta version {version}'**
  String betaVersion(String version);

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @versionUnstable.
  ///
  /// In en, this message translates to:
  /// **'{version} (unstable)'**
  String versionUnstable(String version);

  /// No description provided for @checkingForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Checking for updates'**
  String get checkingForUpdates;

  /// No description provided for @licenses.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licenses;

  /// No description provided for @author.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get author;

  /// No description provided for @ourTeam.
  ///
  /// In en, this message translates to:
  /// **'Our team'**
  String get ourTeam;

  /// No description provided for @company.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get company;

  /// No description provided for @companyTagline.
  ///
  /// In en, this message translates to:
  /// **'Mobile app developers'**
  String get companyTagline;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'How can we help you?'**
  String get helpTitle;

  /// No description provided for @helpBody.
  ///
  /// In en, this message translates to:
  /// **'Having trouble? We\'re here to help, so please get in touch with us.'**
  String get helpBody;

  /// No description provided for @helpChat.
  ///
  /// In en, this message translates to:
  /// **'Chat with us'**
  String get helpChat;

  /// No description provided for @feedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Your feedback'**
  String get feedbackTitle;

  /// No description provided for @feedbackBody.
  ///
  /// In en, this message translates to:
  /// **'Tell us what you think of K.Note.'**
  String get feedbackBody;

  /// No description provided for @feedbackHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your feedback…'**
  String get feedbackHint;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @inviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite your friends'**
  String get inviteTitle;

  /// No description provided for @inviteBody.
  ///
  /// In en, this message translates to:
  /// **'Are you one of those who do everything at the last moment?'**
  String get inviteBody;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @pageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Sorry, we couldn\'t find this page!'**
  String get pageNotFound;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to K.Note'**
  String get welcome;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// No description provided for @createAccountToContinue.
  ///
  /// In en, this message translates to:
  /// **'Create an account to continue'**
  String get createAccountToContinue;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @invalidPassword.
  ///
  /// In en, this message translates to:
  /// **'At least 8 letters and digits, including one of each'**
  String get invalidPassword;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @signInWithFacebook.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Facebook'**
  String get signInWithFacebook;

  /// No description provided for @signedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get signedIn;

  /// No description provided for @alreadySignedIn.
  ///
  /// In en, this message translates to:
  /// **'You\'re already signed in as\n{email}'**
  String alreadySignedIn(String email);

  /// No description provided for @goToHome.
  ///
  /// In en, this message translates to:
  /// **'Go to home'**
  String get goToHome;

  /// No description provided for @authErrorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'This email address is not valid.'**
  String get authErrorInvalidEmail;

  /// No description provided for @authErrorUserDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled. Please contact support.'**
  String get authErrorUserDisabled;

  /// No description provided for @authErrorEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'An account already exists for this email.'**
  String get authErrorEmailInUse;

  /// No description provided for @authErrorNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'This sign-in method is not allowed. Please contact support.'**
  String get authErrorNotAllowed;

  /// No description provided for @authErrorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Please choose a stronger password.'**
  String get authErrorWeakPassword;

  /// No description provided for @authErrorUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account was found for this email. Please create one.'**
  String get authErrorUserNotFound;

  /// No description provided for @authErrorWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password, please try again.'**
  String get authErrorWrongPassword;

  /// No description provided for @authErrorInvalidCredential.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password, please try again.'**
  String get authErrorInvalidCredential;

  /// No description provided for @authErrorExpiredCredential.
  ///
  /// In en, this message translates to:
  /// **'Your sign-in has expired. Please try again.'**
  String get authErrorExpiredCredential;

  /// No description provided for @authErrorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a moment and try again.'**
  String get authErrorTooManyRequests;

  /// No description provided for @authErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check your network and try again.'**
  String get authErrorNetwork;

  /// No description provided for @authErrorGoogleNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Google Sign-In is not configured for this build of the app.'**
  String get authErrorGoogleNotConfigured;

  /// No description provided for @authErrorDifferentCredential.
  ///
  /// In en, this message translates to:
  /// **'An account already exists with a different sign-in method.'**
  String get authErrorDifferentCredential;

  /// No description provided for @authErrorInvalidVerification.
  ///
  /// In en, this message translates to:
  /// **'The verification code is not valid.'**
  String get authErrorInvalidVerification;

  /// No description provided for @authErrorSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed. Please try again.'**
  String get authErrorSignIn;

  /// No description provided for @authErrorSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign-up failed. Please try again.'**
  String get authErrorSignUp;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
