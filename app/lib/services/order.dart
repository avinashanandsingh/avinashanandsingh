import 'package:app/models/order.dart';
import 'package:app/services/api.dart';
import 'package:app/utils/result.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Order {
  final String url = dotenv.env['URL'] ?? '';
  final ApiService api = ApiService();

  Future<Result<OrderData>> list(dynamic filter) async {
    //print('called ${filter?.toJson()}');
    Result<OrderData> out = Result<OrderData>(succeed: false);
    List<OrderData> data = [];
    dynamic body = {
      "query":
          r'query list ($filter: Filter!) { orders(filter: $filter) { count rows { id context contextid context_data name price order_status order_status_reason payment_status payment_status_reason paymentid orderid signature createdat } } }',
      "variables": {"filter": filter ?? {}},
    };

    dynamic result = await api.post(url, body);
    if (result['errors'] != null) {
      dynamic error = result!['errors']![0];
      String msg =
          error?['extensions']?['originalError']?['message'] ??
          error?['message'];
      out.succeed = false;
      out.message = msg;
    } else {
      dynamic rows = result?['data']['orders']?['rows'];
      for (var row in rows) {
        data.add(OrderData.fromJson(row));
      }
      out.succeed = true;
      out.data = data;
    }
    return out;
  }

  Future<OrderData?> add(OrderData order) async {
    OrderData? data;
    dynamic body = {
      "query":
          r'mutation add ($input: OrderIn!) { newOrder(input: $input) { id orderid } }',
      "variables": {
        "input": {
          if (order.context != null) 'context': order.context,
          if (order.contextid != null) 'contextid': order.contextid,
          if (order.slotid != null) 'slotid': order.slotid,
          if (order.price != null) 'price': order.price,
          if (order.orderStatus != null) 'order_status': order.orderStatus,
          if (order.orderStatusReason != null)
            'order_status_reason': order.orderStatusReason,
          if (order.paymentStatus != null)
            'payment_status': order.paymentStatus,
          if (order.paymentStatusReason != null)
            'payment_status_reason': order.paymentStatusReason,
          if (order.paymentid != null) 'paymentid': order.paymentid,
          if (order.orderid != null) 'orderid': order.orderid,
          if (order.signature != null) 'signature': order.signature,
        },
      },
    };
    dynamic result = await api.post(url, body);
    if (result != null) {
      dynamic row = result?['data']['newOrder'];
      data = OrderData.fromJson(row);
    }
    return data;
  }

  Future<OrderData?> update(String id, OrderData order) async {
    OrderData? data;
    dynamic body = {
      "query":
          r'mutation update ($id: UUID!, $input: OrderIn!) { updateOrder(id: $id, input: $input) { id orderid } }',
      "variables": {
        "id": id,
        "input": {
          if (order.orderStatus != null) 'order_status': order.orderStatus,
          if (order.orderStatusReason != null)
            'order_status_reason': order.orderStatusReason,
          if (order.paymentStatus != null)
            'payment_status': order.paymentStatus,
          if (order.paymentStatusReason != null)
            'payment_status_reason': order.paymentStatusReason,
          if (order.paymentid != null) 'paymentid': order.paymentid,
          if (order.orderid != null) 'orderid': order.orderid,
          if (order.signature != null) 'signature': order.signature,
        },
      },
    };

    dynamic result = await api.post(url, body);
    if (result != null) {
      dynamic row = result?['data']['updateOrder'];
      data = OrderData.fromJson(row);
    }
    return data;
  }

  Future<bool> bought(String id, String context) async {
    bool flag = false;
    dynamic body = {
      "query":
          r'query bought ($id: UUID!, $context: Context!) { bought(id: $id, context: $context) }',
      "variables": {"id": id, "context": context},
    };
    dynamic result = await api.post(url, body);
    if (result != null) {
      flag = result?['data']['bought'];
    }
    return flag;
  }
}
