// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get undo => 'Undo';

  @override
  String get retry => 'Retry';

  @override
  String get remove => 'Remove';

  @override
  String get moreOptions => 'More options';

  @override
  String get untitled => 'Untitled';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get titleHint => 'Title';

  @override
  String get navNotes => 'Notes';

  @override
  String get navTasks => 'Tasks';

  @override
  String get navYou => 'You';

  @override
  String get notesGridView => 'Grid view';

  @override
  String get notesListView => 'List view';

  @override
  String get notesSearch => 'Search';

  @override
  String get notesSearchHint => 'Search notes';

  @override
  String get notesClearSearch => 'Clear search';

  @override
  String get notifications => 'Notifications';

  @override
  String get notesNew => 'New note';

  @override
  String get notesLoadError => 'Your notes couldn\'t be loaded';

  @override
  String get notesEmpty => 'No notes yet. Tap + to write one.';

  @override
  String notesNoMatch(String query) {
    return 'No notes match \"$query\"';
  }

  @override
  String get noteArchive => 'Archive';

  @override
  String get noteMoveToBin => 'Move to bin';

  @override
  String get noteChangeColor => 'Change color';

  @override
  String get noteSavingMode => 'Saving mode';

  @override
  String noteArchived(String title) {
    return '\"$title\" archived';
  }

  @override
  String noteMovedToBin(String title) {
    return '\"$title\" moved to the bin';
  }

  @override
  String get noteArchiveFailed => 'The note couldn\'t be archived';

  @override
  String get noteUnarchiveFailed => 'The note couldn\'t be unarchived';

  @override
  String get noteMoveToBinFailed => 'The note couldn\'t be moved to the bin';

  @override
  String get noteRestoreFailed => 'The note couldn\'t be restored';

  @override
  String get noteSaveFailed => 'The note couldn\'t be saved';

  @override
  String get noteColorSaveFailed => 'The note color couldn\'t be saved';

  @override
  String get noteDeleteFailed => 'The note couldn\'t be deleted';

  @override
  String get editorDone => 'Done';

  @override
  String get editorColor => 'Note color';

  @override
  String get editorColorTitle => 'Change the note color';

  @override
  String get binTitle => 'Bin';

  @override
  String get binLoadError => 'The bin couldn\'t be loaded';

  @override
  String get binEmpty => 'The bin is empty';

  @override
  String get binDialogContent =>
      'Restore this note, or delete it forever? Deleting it forever can\'t be undone.';

  @override
  String get binDeleteForever => 'Delete forever';

  @override
  String get binRestore => 'Restore';

  @override
  String get archiveTitle => 'Archived notes';

  @override
  String get archiveLoadError => 'Archived notes couldn\'t be loaded';

  @override
  String get archiveEmpty => 'No archived notes';

  @override
  String get tasksTitle => 'Tasks';

  @override
  String get tasksLoadError => 'Your tasks couldn\'t be loaded';

  @override
  String get tasksEmpty => 'No tasks yet. Tap + to add one.';

  @override
  String get tasksActive => 'Active';

  @override
  String tasksCompleted(int count) {
    return 'Completed $count';
  }

  @override
  String get tasksNew => 'New task';

  @override
  String taskDeleted(String title) {
    return '\"$title\" deleted';
  }

  @override
  String get taskDeleteFailed => 'The task couldn\'t be deleted';

  @override
  String get taskRestoreFailed => 'The task couldn\'t be restored';

  @override
  String get taskUpdateFailed => 'The task couldn\'t be updated';

  @override
  String get taskSaveFailed => 'The task couldn\'t be saved';

  @override
  String taskSaveFailedNamed(String title) {
    return 'The task \"$title\" couldn\'t be saved';
  }

  @override
  String get taskQuickAddFailed =>
      'Couldn\'t save this task. Tap ↑ to try again.';

  @override
  String get taskMarkCompleted => 'Mark as completed';

  @override
  String get taskMarkNotCompleted => 'Mark as not completed';

  @override
  String get taskMarkImportant => 'Mark as important';

  @override
  String get taskRemoveImportance => 'Remove importance';

  @override
  String get dateToday => 'Today';

  @override
  String get dateTomorrow => 'Tomorrow';

  @override
  String get dateYesterday => 'Yesterday';

  @override
  String get dueToday => 'Due Today';

  @override
  String get dueTomorrow => 'Due Tomorrow';

  @override
  String dueOn(String date) {
    return 'Due $date';
  }

  @override
  String get quickAddHint => 'Add a task';

  @override
  String get quickAddSubmit => 'Add';

  @override
  String get setDueDate => 'Set due date';

  @override
  String menuToday(String weekday) {
    return 'Today ($weekday)';
  }

  @override
  String menuTomorrow(String weekday) {
    return 'Tomorrow ($weekday)';
  }

  @override
  String menuNextWeek(String weekday) {
    return 'Next week ($weekday)';
  }

  @override
  String get pickDate => 'Pick a date';

  @override
  String get removeDueDate => 'Remove due date';

  @override
  String get remindMe => 'Remind me';

  @override
  String remindMeAt(String time) {
    return 'Remind me at $time';
  }

  @override
  String reminderTomorrowAt(String time) {
    return 'Tomorrow, $time';
  }

  @override
  String reminderOn(String date, String time) {
    return '$date, $time';
  }

  @override
  String menuLaterToday(String time) {
    return 'Later today ($time)';
  }

  @override
  String get pickDateAndTime => 'Pick a date & time';

  @override
  String get removeReminder => 'Remove reminder';

  @override
  String get repeat => 'Repeat';

  @override
  String get repeatCustom => 'Custom';

  @override
  String get repeatNever => 'Never repeat';

  @override
  String get repeatDaily => 'Daily';

  @override
  String get repeatWeekdays => 'Weekdays';

  @override
  String get repeatWeekly => 'Weekly';

  @override
  String get repeatMonthly => 'Monthly';

  @override
  String get repeatYearly => 'Yearly';

  @override
  String repeatEveryDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count days',
      one: 'Every day',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count weeks',
      one: 'Every week',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count months',
      one: 'Every month',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count years',
      one: 'Every year',
    );
    return '$_temp0';
  }

  @override
  String repeatOnDays(String rule, String days) {
    return '$rule on $days';
  }

  @override
  String get repeatEveryTitle => 'Repeat every';

  @override
  String unitDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'days',
      one: 'day',
    );
    return '$_temp0';
  }

  @override
  String unitWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'weeks',
      one: 'week',
    );
    return '$_temp0';
  }

  @override
  String unitMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'months',
      one: 'month',
    );
    return '$_temp0';
  }

  @override
  String unitYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'years',
      one: 'year',
    );
    return '$_temp0';
  }

  @override
  String get fewer => 'Fewer';

  @override
  String get more => 'More';

  @override
  String get untitledTask => 'Untitled task';

  @override
  String get taskStepHint => 'Step';

  @override
  String get taskAddStep => 'Add step';

  @override
  String get taskRemoveStep => 'Remove step';

  @override
  String get taskAddedToMyDay => 'Added to My Day';

  @override
  String get taskAddToMyDay => 'Add to My Day';

  @override
  String get taskAddDueDate => 'Add due date';

  @override
  String get taskAddFile => 'Add file';

  @override
  String get taskFilesUnavailable => 'File attachments are not available yet';

  @override
  String get taskNoteHint => 'Add note';

  @override
  String taskCreatedOn(String date) {
    return 'Created on $date';
  }

  @override
  String get taskColor => 'Task color';

  @override
  String get taskDelete => 'Delete task';

  @override
  String get logOut => 'Log out';

  @override
  String get logOutQuestion => 'Do you want to log out?';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get changePassword => 'Change password';

  @override
  String get calendar => 'Calendar';

  @override
  String get unknownName => 'Unknown name';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get emailUpdates => 'Email updates';

  @override
  String get emailUpdatesSubtitle => 'Send me updates by email';

  @override
  String get aboutUs => 'About us';

  @override
  String get aboutApp => 'About this app';

  @override
  String get lastUpdate => 'Last update';

  @override
  String betaVersion(String version) {
    return 'Beta version $version';
  }

  @override
  String get version => 'Version';

  @override
  String versionUnstable(String version) {
    return '$version (unstable)';
  }

  @override
  String get checkingForUpdates => 'Checking for updates';

  @override
  String get licenses => 'Licenses';

  @override
  String get author => 'Author';

  @override
  String get ourTeam => 'Our team';

  @override
  String get company => 'Company';

  @override
  String get companyTagline => 'Mobile app developers';

  @override
  String get address => 'Address';

  @override
  String get none => 'None';

  @override
  String get helpTitle => 'How can we help you?';

  @override
  String get helpBody =>
      'Having trouble? We\'re here to help, so please get in touch with us.';

  @override
  String get helpChat => 'Chat with us';

  @override
  String get feedbackTitle => 'Your feedback';

  @override
  String get feedbackBody => 'Tell us what you think of K.Note.';

  @override
  String get feedbackHint => 'Enter your feedback…';

  @override
  String get send => 'Send';

  @override
  String get inviteTitle => 'Invite your friends';

  @override
  String get inviteBody =>
      'Are you one of those who do everything at the last moment?';

  @override
  String get share => 'Share';

  @override
  String get pageNotFound => 'Sorry, we couldn\'t find this page!';

  @override
  String get welcome => 'Welcome to K.Note';

  @override
  String get signInToContinue => 'Sign in to continue';

  @override
  String get createAccountToContinue => 'Create an account to continue';

  @override
  String get emailLabel => 'Email address';

  @override
  String get passwordLabel => 'Password';

  @override
  String get invalidEmail => 'Enter a valid email address';

  @override
  String get invalidPassword =>
      'At least 8 letters and digits, including one of each';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get logIn => 'Log in';

  @override
  String get signUp => 'Sign up';

  @override
  String get or => 'OR';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get signInWithFacebook => 'Sign in with Facebook';

  @override
  String get signedIn => 'Signed in';

  @override
  String alreadySignedIn(String email) {
    return 'You\'re already signed in as\n$email';
  }

  @override
  String get goToHome => 'Go to home';

  @override
  String get authErrorInvalidEmail => 'This email address is not valid.';

  @override
  String get authErrorUserDisabled =>
      'This account has been disabled. Please contact support.';

  @override
  String get authErrorEmailInUse => 'An account already exists for this email.';

  @override
  String get authErrorNotAllowed =>
      'This sign-in method is not allowed. Please contact support.';

  @override
  String get authErrorWeakPassword => 'Please choose a stronger password.';

  @override
  String get authErrorUserNotFound =>
      'No account was found for this email. Please create one.';

  @override
  String get authErrorWrongPassword => 'Incorrect password, please try again.';

  @override
  String get authErrorInvalidCredential =>
      'Incorrect email or password, please try again.';

  @override
  String get authErrorExpiredCredential =>
      'Your sign-in has expired. Please try again.';

  @override
  String get authErrorTooManyRequests =>
      'Too many attempts. Please wait a moment and try again.';

  @override
  String get authErrorNetwork =>
      'No internet connection. Check your network and try again.';

  @override
  String get authErrorGoogleNotConfigured =>
      'Google Sign-In is not configured for this build of the app.';

  @override
  String get authErrorDifferentCredential =>
      'An account already exists with a different sign-in method.';

  @override
  String get authErrorInvalidVerification =>
      'The verification code is not valid.';

  @override
  String get authErrorSignIn => 'Sign-in failed. Please try again.';

  @override
  String get authErrorSignUp => 'Sign-up failed. Please try again.';
}
