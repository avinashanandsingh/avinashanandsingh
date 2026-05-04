class TimeslotData {
  String? id;
  String? serviceid;
  String? name;
  String? startTime;
  String? endTime;
  int? capacity;

  TimeslotData({
    this.id,
    this.serviceid,
    this.name,
    this.startTime,
    this.endTime,
    this.capacity,
  });

  factory TimeslotData.fromJson(Map<String, dynamic> json) {
    return TimeslotData(
      id: json['id'] as String?,
      serviceid: json['serviceid'] as String?,
      name: json['name'] as String?,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceid': serviceid,
      'name': name,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}

class AuraData {
  String? id;
  String? name;
  double? price;
  double? offer;
  List<TimeslotData>? slots;
  AuraData({this.id, this.name, this.price, this.offer, this.slots});

  factory AuraData.fromJson(Map<String, dynamic> json) {
    dynamic list = json['timeslots'];
    List<TimeslotData> lst = List.empty(growable: true);
    for (var slot in list) {
      lst.add(TimeslotData.fromJson(slot));
    }
    return AuraData(
      id: json['id'] as String?,
      name: json['name'] as String?,
      price: json['price'] as double?,
      offer: json['offer'] as double?,
      slots: lst,
    );
  }

  // Object to JSON conversion
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'offer': offer,
      'slots': slots!.map((e) => e.toJson()),
    };
  }
}
