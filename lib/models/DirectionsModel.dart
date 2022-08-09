class DirectionModel {
  String address;
  bool favorite;
  String key;
  String name;


  DirectionModel._({this.address, this.favorite, this.key, this.name});

  factory DirectionModel.fromJson(Map<String, dynamic> json) {
    return new DirectionModel._(
      address: json['address'],
      favorite: json['favorite'] as bool,
      key: json['key'],
      name: json['name']
    );
  }
}