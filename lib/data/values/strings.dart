
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum LanguageCode{none ,fr, en}


class Language{
  final Locale locale;
  const Language(this.locale);

  String get code => locale.languageCode;
  String get value {
    if(code.contains('fr')) {
      return 'french';
    } else {
      return 'english';
    }
  }

  @override
  String toString() {
    return "";
  }

  static const List<Locale> locales = [Locale('en'), Locale('fr'),];

}

class LanguageBloc extends Cubit<Language> {
  LanguageBloc([Locale? locale])
      : super(Language(locale ?? _defaultLocale()));

  Locale get locale => state.locale;


  /// Toggles the current Lang between en and fr.
  ///
  void changeLanguage(LanguageCode languageCode){
    switch(languageCode){

      case LanguageCode.none:
        emit(Language(_defaultLocale()));
        break;
      default:
        emit(Language(localeFromCode[languageCode]!));
        break;
    }
  }

  void changeLocale(Locale locale){
    emit(Language(locale));
  }

  Map<LanguageCode, Locale> localeFromCode = {
    LanguageCode.en : const Locale('en'),
    LanguageCode.fr : const Locale('fr'),
  };

  static Locale _defaultLocale(){
    String defaultSystemLocale = Platform.localeName;
    if(defaultSystemLocale.contains('fr')) {
      return const Locale('fr');
    } else {
      return const Locale('en');
    }
    //(defaultSystemLocale.contains('en'))
  }

}