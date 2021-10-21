part of data.model;


class LocationData{
  final String? town;
  final String? province;
  final String? country;
  final String? address;
  final String? gpsLocation;
  final String? gpsCurrentLocation;

  LocationData({this.town, this.province, this.country, this.address,
    this.gpsLocation, this.gpsCurrentLocation});

  final _table = "LOCATIONS";
  String get tableName => _table;
}