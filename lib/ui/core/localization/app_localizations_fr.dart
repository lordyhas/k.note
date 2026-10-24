// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get undo => 'Annuler';

  @override
  String get retry => 'Réessayer';

  @override
  String get remove => 'Retirer';

  @override
  String get moreOptions => 'Plus d\'options';

  @override
  String get untitled => 'Sans titre';

  @override
  String get comingSoon => 'Bientôt disponible';

  @override
  String get titleHint => 'Titre';

  @override
  String get navNotes => 'Notes';

  @override
  String get navTasks => 'Tâches';

  @override
  String get navYou => 'Moi';

  @override
  String get notesGridView => 'Affichage en grille';

  @override
  String get notesListView => 'Affichage en liste';

  @override
  String get notesSearch => 'Rechercher';

  @override
  String get notesSearchHint => 'Rechercher dans les notes';

  @override
  String get notesClearSearch => 'Effacer la recherche';

  @override
  String get notifications => 'Notifications';

  @override
  String get notesNew => 'Nouvelle note';

  @override
  String get notesLoadError => 'Impossible de charger vos notes';

  @override
  String get notesEmpty =>
      'Aucune note pour l\'instant. Touchez + pour en écrire une.';

  @override
  String notesNoMatch(String query) {
    return 'Aucune note ne correspond à « $query »';
  }

  @override
  String get noteArchive => 'Archiver';

  @override
  String get noteMoveToBin => 'Mettre à la corbeille';

  @override
  String get noteChangeColor => 'Changer la couleur';

  @override
  String get noteSavingMode => 'Mode d\'enregistrement';

  @override
  String noteArchived(String title) {
    return '« $title » archivée';
  }

  @override
  String noteMovedToBin(String title) {
    return '« $title » mise à la corbeille';
  }

  @override
  String get noteArchiveFailed => 'Impossible d\'archiver la note';

  @override
  String get noteUnarchiveFailed => 'Impossible de désarchiver la note';

  @override
  String get noteMoveToBinFailed =>
      'Impossible de mettre la note à la corbeille';

  @override
  String get noteRestoreFailed => 'Impossible de restaurer la note';

  @override
  String get noteSaveFailed => 'Impossible d\'enregistrer la note';

  @override
  String get noteColorSaveFailed =>
      'Impossible d\'enregistrer la couleur de la note';

  @override
  String get noteDeleteFailed => 'Impossible de supprimer la note';

  @override
  String get editorDone => 'Terminé';

  @override
  String get editorColor => 'Couleur de la note';

  @override
  String get editorColorTitle => 'Changer la couleur de la note';

  @override
  String get binTitle => 'Corbeille';

  @override
  String get binLoadError => 'Impossible de charger la corbeille';

  @override
  String get binEmpty => 'La corbeille est vide';

  @override
  String get binDialogContent =>
      'Restaurer cette note ou la supprimer définitivement ? La suppression définitive est irréversible.';

  @override
  String get binDeleteForever => 'Supprimer définitivement';

  @override
  String get binRestore => 'Restaurer';

  @override
  String get archiveTitle => 'Notes archivées';

  @override
  String get archiveLoadError => 'Impossible de charger les notes archivées';

  @override
  String get archiveEmpty => 'Aucune note archivée';

  @override
  String get tasksTitle => 'Tâches';

  @override
  String get tasksLoadError => 'Impossible de charger vos tâches';

  @override
  String get tasksEmpty =>
      'Aucune tâche pour l\'instant. Touchez + pour en ajouter une.';

  @override
  String get tasksActive => 'En cours';

  @override
  String tasksCompleted(int count) {
    return 'Terminées $count';
  }

  @override
  String get tasksNew => 'Nouvelle tâche';

  @override
  String taskDeleted(String title) {
    return '« $title » supprimée';
  }

  @override
  String get taskDeleteFailed => 'Impossible de supprimer la tâche';

  @override
  String get taskRestoreFailed => 'Impossible de restaurer la tâche';

  @override
  String get taskUpdateFailed => 'Impossible de mettre à jour la tâche';

  @override
  String get taskSaveFailed => 'Impossible d\'enregistrer la tâche';

  @override
  String taskSaveFailedNamed(String title) {
    return 'Impossible d\'enregistrer la tâche « $title »';
  }

  @override
  String get taskQuickAddFailed =>
      'Impossible d\'enregistrer cette tâche. Touchez ↑ pour réessayer.';

  @override
  String get taskMarkCompleted => 'Marquer comme terminée';

  @override
  String get taskMarkNotCompleted => 'Marquer comme non terminée';

  @override
  String get taskMarkImportant => 'Marquer comme importante';

  @override
  String get taskRemoveImportance => 'Retirer l\'importance';

  @override
  String get dateToday => 'Aujourd\'hui';

  @override
  String get dateTomorrow => 'Demain';

  @override
  String get dateYesterday => 'Hier';

  @override
  String get dueToday => 'Échéance aujourd\'hui';

  @override
  String get dueTomorrow => 'Échéance demain';

  @override
  String dueOn(String date) {
    return 'Échéance le $date';
  }

  @override
  String get quickAddHint => 'Ajouter une tâche';

  @override
  String get quickAddSubmit => 'Ajouter';

  @override
  String get setDueDate => 'Ajouter une échéance';

  @override
  String menuToday(String weekday) {
    return 'Aujourd\'hui ($weekday)';
  }

  @override
  String menuTomorrow(String weekday) {
    return 'Demain ($weekday)';
  }

  @override
  String menuNextWeek(String weekday) {
    return 'La semaine prochaine ($weekday)';
  }

  @override
  String get pickDate => 'Choisir une date';

  @override
  String get removeDueDate => 'Supprimer l\'échéance';

  @override
  String get remindMe => 'Me le rappeler';

  @override
  String remindMeAt(String time) {
    return 'Me le rappeler à $time';
  }

  @override
  String reminderTomorrowAt(String time) {
    return 'Demain, $time';
  }

  @override
  String reminderOn(String date, String time) {
    return '$date, $time';
  }

  @override
  String menuLaterToday(String time) {
    return 'Plus tard dans la journée ($time)';
  }

  @override
  String get pickDateAndTime => 'Choisir une date et une heure';

  @override
  String get removeReminder => 'Supprimer le rappel';

  @override
  String get repeat => 'Répéter';

  @override
  String get repeatCustom => 'Personnaliser';

  @override
  String get repeatNever => 'Ne jamais répéter';

  @override
  String get repeatDaily => 'Tous les jours';

  @override
  String get repeatWeekdays => 'Jours de semaine';

  @override
  String get repeatWeekly => 'Toutes les semaines';

  @override
  String get repeatMonthly => 'Tous les mois';

  @override
  String get repeatYearly => 'Tous les ans';

  @override
  String repeatEveryDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tous les $count jours',
      one: 'Tous les jours',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Toutes les $count semaines',
      one: 'Toutes les semaines',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tous les $count mois',
      one: 'Tous les mois',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tous les $count ans',
      one: 'Tous les ans',
    );
    return '$_temp0';
  }

  @override
  String repeatOnDays(String rule, String days) {
    return '$rule, le $days';
  }

  @override
  String get repeatEveryTitle => 'Répéter tous les';

  @override
  String unitDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'jours',
      one: 'jour',
    );
    return '$_temp0';
  }

  @override
  String unitWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'semaines',
      one: 'semaine',
    );
    return '$_temp0';
  }

  @override
  String unitMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'mois',
      one: 'mois',
    );
    return '$_temp0';
  }

  @override
  String unitYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ans',
      one: 'an',
    );
    return '$_temp0';
  }

  @override
  String get fewer => 'Moins';

  @override
  String get more => 'Plus';

  @override
  String get untitledTask => 'Tâche sans titre';

  @override
  String get taskStepHint => 'Étape';

  @override
  String get taskAddStep => 'Ajouter une étape';

  @override
  String get taskRemoveStep => 'Supprimer l\'étape';

  @override
  String get taskAddedToMyDay => 'Ajoutée à Ma journée';

  @override
  String get taskAddToMyDay => 'Ajouter à Ma journée';

  @override
  String get taskAddDueDate => 'Ajouter une échéance';

  @override
  String get taskAddFile => 'Ajouter un fichier';

  @override
  String get taskFilesUnavailable =>
      'Les pièces jointes ne sont pas encore disponibles';

  @override
  String get taskNoteHint => 'Ajouter une note';

  @override
  String taskCreatedOn(String date) {
    return 'Créée le $date';
  }

  @override
  String get taskColor => 'Couleur de la tâche';

  @override
  String get taskDelete => 'Supprimer la tâche';

  @override
  String get logOut => 'Se déconnecter';

  @override
  String get logOutQuestion => 'Voulez-vous vous déconnecter ?';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get changePassword => 'Modifier le mot de passe';

  @override
  String get calendar => 'Calendrier';

  @override
  String get unknownName => 'Nom inconnu';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get emailUpdates => 'Avis par e-mail';

  @override
  String get emailUpdatesSubtitle => 'M\'envoyer des avis par e-mail';

  @override
  String get aboutUs => 'À propos de nous';

  @override
  String get aboutApp => 'À propos de l\'application';

  @override
  String get lastUpdate => 'Dernière mise à jour';

  @override
  String betaVersion(String version) {
    return 'Version bêta $version';
  }

  @override
  String get version => 'Version';

  @override
  String versionUnstable(String version) {
    return '$version (instable)';
  }

  @override
  String get checkingForUpdates => 'Recherche de mises à jour';

  @override
  String get licenses => 'Licences';

  @override
  String get author => 'Auteur';

  @override
  String get ourTeam => 'Notre équipe';

  @override
  String get company => 'Entreprise';

  @override
  String get companyTagline => 'Développeurs d\'applications mobiles';

  @override
  String get address => 'Adresse';

  @override
  String get none => 'Aucune';

  @override
  String get helpTitle => 'Comment pouvons-nous vous aider ?';

  @override
  String get helpBody =>
      'Un problème ? Nous sommes là pour vous aider, n\'hésitez pas à nous contacter.';

  @override
  String get helpChat => 'Discuter avec nous';

  @override
  String get feedbackTitle => 'Votre avis';

  @override
  String get feedbackBody => 'Dites-nous ce que vous pensez de K.Note.';

  @override
  String get feedbackHint => 'Écrivez votre avis…';

  @override
  String get send => 'Envoyer';

  @override
  String get inviteTitle => 'Invitez vos amis';

  @override
  String get inviteBody =>
      'Êtes-vous de ceux qui font tout au dernier moment ?';

  @override
  String get share => 'Partager';

  @override
  String get pageNotFound => 'Désolé, cette page est introuvable !';

  @override
  String get welcome => 'Bienvenue sur K.Note';

  @override
  String get signInToContinue => 'Connectez-vous pour continuer';

  @override
  String get createAccountToContinue => 'Créez un compte pour continuer';

  @override
  String get emailLabel => 'Adresse e-mail';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get invalidEmail => 'Saisissez une adresse e-mail valide';

  @override
  String get invalidPassword =>
      'Au moins 8 lettres et chiffres, dont au moins un de chaque';

  @override
  String get showPassword => 'Afficher le mot de passe';

  @override
  String get hidePassword => 'Masquer le mot de passe';

  @override
  String get logIn => 'Se connecter';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get or => 'OU';

  @override
  String get signInWithGoogle => 'Se connecter avec Google';

  @override
  String get signInWithFacebook => 'Se connecter avec Facebook';

  @override
  String get signedIn => 'Connexion réussie';

  @override
  String alreadySignedIn(String email) {
    return 'Vous êtes déjà connecté avec\n$email';
  }

  @override
  String get goToHome => 'Aller à l\'accueil';

  @override
  String get authErrorInvalidEmail => 'Cette adresse e-mail n\'est pas valide.';

  @override
  String get authErrorUserDisabled =>
      'Ce compte a été désactivé. Veuillez contacter l\'assistance.';

  @override
  String get authErrorEmailInUse =>
      'Un compte existe déjà pour cette adresse e-mail.';

  @override
  String get authErrorNotAllowed =>
      'Cette méthode de connexion n\'est pas autorisée. Veuillez contacter l\'assistance.';

  @override
  String get authErrorWeakPassword =>
      'Veuillez choisir un mot de passe plus robuste.';

  @override
  String get authErrorUserNotFound =>
      'Aucun compte n\'existe pour cette adresse e-mail. Veuillez en créer un.';

  @override
  String get authErrorWrongPassword =>
      'Mot de passe incorrect, veuillez réessayer.';

  @override
  String get authErrorInvalidCredential =>
      'E-mail ou mot de passe incorrect, veuillez réessayer.';

  @override
  String get authErrorExpiredCredential =>
      'Votre connexion a expiré. Veuillez réessayer.';

  @override
  String get authErrorTooManyRequests =>
      'Trop de tentatives. Patientez un instant puis réessayez.';

  @override
  String get authErrorNetwork =>
      'Pas de connexion internet. Vérifiez votre réseau et réessayez.';

  @override
  String get authErrorGoogleNotConfigured =>
      'La connexion Google n\'est pas configurée pour cette version de l\'application.';

  @override
  String get authErrorDifferentCredential =>
      'Un compte existe déjà avec une autre méthode de connexion.';

  @override
  String get authErrorInvalidVerification =>
      'Le code de vérification n\'est pas valide.';

  @override
  String get authErrorSignIn => 'La connexion a échoué. Veuillez réessayer.';

  @override
  String get authErrorSignUp => 'L\'inscription a échoué. Veuillez réessayer.';
}
