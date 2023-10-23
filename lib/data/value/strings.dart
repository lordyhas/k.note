
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

enum LangState{fr, en}

class Language{
  //final LangState currentLang;
  String? defaultSystemLocale;
  Language(this._currentLangState){
    defaultSystemLocale = Platform.localeName;
  }

  final LangState _currentLangState;




  LangState get currentLangState => _currentLangState;
  //static Map<String, Map<String, String>> str;


  Map<String, Map<String,String>> _string = {
    'fr' : {
      '_':'Exemple par defaut',
      'xx':'','default':'Par défaut',

      'tooltip_open_menu':"Ouvrir le Menu",
      'tooltip_search':"Faire une recherche",
      'tooltip_profile':"mon profil",
      'tooltip_reserve':"voir mes réservation",

      'home':'Acceuil',
      'label':"Trouvez une boutique proche de vous",



      'setting_name':'Paramètre',
      'set_name':'Paramètre',
      'set_lang':'Langue',
      'setting_pref':'Préférence',
      'set_contrib':"Contribuez à la translation",
      'set_sync_title':'Synchronisation',
      'sync': "Sync",
      'sync_mail': "Sync with mail",
      'notify': "Notification",
      'set_about_title': "À propos & Autre",

      'restaurant' : "Restaurant",
      //'restaurant_title' : "Restaurant",
      'rest_title' : "Restaurant",
      'rest_collection' : "Menu de restaurants",
      'rest_meal' : "Repas",
      'rest_' : "",


      'shop':"Boutique",
      'shop_dress':"Boutique d'habillement",
      'shop_kit':"Boutique Cuisine",
      'shop_phone':"Boutique de smartphone",
      'shop_com':"Boutique des ordinateurs",
      'product':"Produit",
      'prod_elect':"Electronique",
      'prod_kit':"Cuisine",
      'prod_clo':"Habillement",
      'prod_fur':"Meuble",

      'about': "À propos",
      'about_update': "Dernière mise à jour",
      'about_licence': "Licence",
      'about_author': "Auteur",
      'about_company': "Compagnie",
      'about_add': "Address",

      'about_exploress': "Info sur l'exploress",
      'about_exploress_app': "À propos de  l'application",


      'choose_lang': " Changer la langue",

      'my_account' : "Mon Compte",

      'xxx':"",

      'xxxx':"",
    },
    'en' : {
      '_':'Default Example',
      'xx':'','default':'default',

      'tooltip_open_menu':"Open Menu",
      'tooltip_search':"to search",
      'tooltip_profile':"my profile",
      'tooltip_reserve':"see my product reserved",

      'home':'Home',
      'label':"Find shop near to you",


      'setting_name':'Setting',
      'set_name':'Setting',
      'set_lang':'Language',
      'setting_pref':'Preference',
      'set_contrib':"help the translation app",
      'set_sync_title':'Synchronisation',
      'sync': "Sync",
      'sync_mail': "Sync with mail",
      'notify': "Notification",
      'set_about_title': "About & Other",

      'restaurant' : "Restaurant",
      'rest_title' : "Restaurant",
      'rest_collection' : "Restaurant's menu",
      'rest_meal' : "Meal",
      'rest_' : "",

      'shop':"Shop",
      'shop_dress':"Dress Shop",
      'shop_kit':"Kitchenware Store",
      'shop_phone':"Phones Shop",
      'shop_com':"Computers Shop",

      'product':"Product",
      'prod_elect':"Electronics",
      'prod_kit':"Cuisine",
      'prod_clo':"Clothes",
      'prod_fur':"Furniture",

      'about': "About",
      'about_update': "Last Update",
      'about_licence': "Licence",
      'about_author': "Author",
      'about_company': "Company",
      'about_add': "Address",

      'about_exploress': "What is exploress",
      'about_exploress_app': "About this App",


      'choose_lang': " Change language",

      'my_account' : "My Account",

      'xxx': "",

      'xxxx' : "",

    }
  };

  Map<String, String>? get strings {
    switch(_currentLangState){
      case LangState.en:
        return _string['en'];
      case LangState.fr:
        return _string['fr'] ;
      default:
        if(defaultSystemLocale != null &&
            defaultSystemLocale!.contains('fr'))
          return _string['fr'];
        return _string['en'];
    }
  }
}

class LanguageBloc extends Cubit<Language> {
  LanguageBloc([LangState? langState]) : super(Language(LangState.values[1],));

  static Language langFrench = Language(LangState.fr);
  static Language langEnglish = Language(LangState.en);

  /// Toggles the current Lang between en and fr.
  void toggleLangEnToFr() {
    emit((state.currentLangState == LangState.en) ? langFrench : langEnglish);
  }
  void switchLang(LangState lang){
    emit(Language(lang));
  }
  set switchTo(LangState lang){
    emit(Language(lang));
  }
}