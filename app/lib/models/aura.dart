class TimeslotData {
  String? id;
  String? serviceid;
  String? name;
  String? startTime;
  String? endTime;
  int capacity;

  TimeslotData({
    this.id = '',
    this.serviceid = '',
    this.name = '',
    this.startTime = '',
    this.endTime = '',
    this.capacity = 0,
  });

  factory TimeslotData.fromJson(Map<String, dynamic> json) {
    return TimeslotData(
      id: json['id'] as String?,
      serviceid: json['serviceid'] as String?,
      name: json['name'] as String?,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      capacity: (json['capacity'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceid': serviceid,
      'name': name,
      'startTime': startTime,
      'endTime': endTime,
      'capacity': capacity,
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
      price: double.parse(json['price']),
      offer: double.parse(json['offer']),
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
