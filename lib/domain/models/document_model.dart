/// Models that are stored as Firestore documents.
abstract class DataToMap {
  Map<String, dynamic> asMap();
  void toDisplay();

  /*String autoGenerateUniqueId(String constantKey){
     final DateTime now = DateTime.now();
     final String formatted = DateFormat('yyyyMMddHms').format(now);
     print(formatted); // something like 2013-04-20
     return constantKey.trim()+formatted;
   }*/
}

abstract class DocumentModel extends DataToMap {}
