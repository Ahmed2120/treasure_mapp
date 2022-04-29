import 'dart:convert';

class Place{
  int? id;
  String name;
  double lat;
  double lon;
  String image;

  Place(this.name, this.lat, this.lon, this.image);

  Place.fromJson(Map<String, dynamic> json)
  : id = json['id'],
        name = json['name'],
        lat = json['lat'],
        lon = json['lon'],
        image = json['image'];

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'name': name,
      'lat': lat,
      'lon': lon,
      'image': image
    };
  }

}