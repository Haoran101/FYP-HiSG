class NavInfo {
  String? name;
  var lat;
  var lon;
  String? place_id;
  NavInfo({this.name, this.lat, this.lon, this.place_id});

  toJSON() {
    return {
      "name": this.name,
      "lat": this.lat,
      "lon": this.lon,
      "place_id": this.place_id,
    };
  }
}