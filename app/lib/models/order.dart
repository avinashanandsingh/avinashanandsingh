import 'package:app/models/user.dart';
import 'package:intl/intl.dart';

class OrderData {
  String? id;
  String? orderid;
  String? context;
  String? contextid;
  dynamic contextData;
  String? slotid;
  DateTime? slotDate;
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
    this.contextData,
    this.slotid,
    this.slotDate,
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
      contextData: json['context_data'],
      slotid: json['slotid'] as String?,
      slotDate: json['slot_date'] != null
          ? DateTime.parse(json['slot_date'])
          : null,
      name: json['name'] as String?,
      price: double.parse(json['price']),
      orderStatus: json['order_status'] as String?,
      orderStatusReason: json['order_status_reason'] as String?,
      paymentStatus: json['payment_status'] as String?,
      paymentStatusReason: json['payment_status_reason'] as String?,
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

  String? get formattedPrice {
    String? formatted;
    final currency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );
    if (price != null) {
      formatted = currency.format(price);
    }
    return formatted;
  }

  String? get slotAt {
    String? formatted;
    final date = DateFormat('dd-MMM-yyy');
    if (createdat != null) {
      formatted = date.format(slotDate!);
    }
    return formatted;
  }

  String? get orderDate {
    String? formatted;
    final date = DateFormat('dd-MMM-yyy');
    if (createdat != null) {
      formatted = date.format(createdat!);
    }
    return formatted;
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (context != null) 'context': context,
      if (contextid != null) 'contextid': contextid,
      if (slotid != null) 'slotid': slotid,
      if (slotDate != null) 'slot_date': slotDate,
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
