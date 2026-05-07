import 'package:app/models/user.dart';

class OrderData {
  String? id;
  String? orderid;
  String? context;
  String? contextid;
  String? slotid;
  String? name;
  double? price;
  String? orderStatus;
  String? orderStatusReason;
  String? paymentStatus;
  String? paymentStatusReason;
  String? paymentid;
  String? signature;
  UserData? creator;
  DateTime? createdat;
  UserData? updater;
  DateTime? updatedat;
  OrderData({
    this.id,
    this.context,
    this.contextid,
    this.slotid,
    this.name,
    this.price,
    this.orderStatus,
    this.orderStatusReason,
    this.paymentStatus,
    this.paymentStatusReason,
    this.paymentid,
    this.orderid,
    this.signature,
    this.creator,
    this.createdat,
    this.updater,
    this.updatedat,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      id: json['id'] as String?,
      context: json['context'] as String?,
      contextid: json['contextid'] as String?,
      slotid: json['slotid'] as String?,
      name: json['name'] as String?,
      price: json['price'] as double?,
      orderStatus: json['orderStatus'] as String?,
      orderStatusReason: json['orderStatusReason'] as String?,
      paymentStatus: json['paymentStatus'] as String?,
      paymentStatusReason: json['paymentStatusReason'] as String?,
      paymentid: json['paymentid'] as String?,
      orderid: json['orderid'] as String?,
      signature: json['signature'] as String?,
      creator: json['creator'] != null
          ? UserData.fromJson(json['creator'])
          : null,
      createdat: json['createdat'] != null
          ? DateTime.parse(json['createdat'])
          : null,
      updater: json['updater'] != null
          ? UserData.fromJson(json['updater'])
          : null,
      updatedat: json['updatedat'] != null
          ? DateTime.parse(json['updatedat'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (slotid != null) 'id': id,
      if (slotid != null) 'context': context,
      if (slotid != null) 'contextid': contextid,
      if (slotid != null) 'slotid': slotid,
      if (price != null) 'price': price,
      if (orderStatus != null) 'order_status': orderStatus,
      if (orderStatusReason != null) 'order_status_reason': orderStatusReason,
      if (paymentStatus != null) 'payment_status': paymentStatus,
      if (paymentStatusReason != null)
        'payment_status_reason': paymentStatusReason,
      if (paymentid != null) 'paymentid': paymentid,
      if (orderid != null) 'orderid': orderid,
      if (signature != null) 'signature': signature,
    };
  }
}
