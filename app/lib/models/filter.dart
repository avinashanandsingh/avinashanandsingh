class Filter {
  List<Criteria>? criteria;
  List<OrderBy>? orderBy;
  int? offset;
  int? limit;

  Filter({this.criteria, this.orderBy, this.offset, this.limit});

  // Object to JSON conversion
  Map<String, dynamic> toJson() {
    return {
      if (criteria != null) 'criteria': criteria,
      if (orderBy != null) 'orderBy': orderBy,
      if (offset != null) 'offset': offset,
      if (limit != null) 'limit': limit,
    };
  }
}

class Criteria {
  String? column;
  String? cop;
  String? lop;
  dynamic value;

  Criteria({this.column, this.cop, this.lop, this.value});

  // Object to JSON conversion
  Map<String, dynamic> toJson() {
    return {'column': column, 'cop': cop, 'lop': lop, 'value': value};
  }
}

class OrderBy {
  String? column;
  bool? asc = true;

  OrderBy({this.column, this.asc});

  // Object to JSON conversion
  Map<String, dynamic> toJson() {
    return {'column': column, 'asc': asc};
  }
}
