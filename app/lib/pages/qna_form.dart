import 'dart:convert';

import 'package:app/components/custom_form_field.dart';
import 'package:app/components/label.dart';
import 'package:app/components/loader.dart';
import 'package:app/helpers/enroll.dart';
import 'package:app/models/course.dart';
import 'package:app/models/enroll.dart';
import 'package:app/models/order.dart';
import 'package:app/models/qna.dart';
import 'package:app/models/schedule.dart';
import 'package:app/models/user.dart';
import 'package:app/pages/home.dart';
import 'package:app/services/razorpay.dart';
import 'package:app/services/service.dart';
import 'package:app/utils/alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app/helpers/globals.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class UserQnA {
  final String? id;
  final String? question;
  //final String? type;
  List<OptionData>? options;
  String? answer;
  UserQnA({this.id, this.question, this.options});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'options': options,
    };
  }
}

class QnaForm extends StatefulWidget {
  final List<QnaData> data;
  final CourseData? course;
  final String? scheduleId;

  const QnaForm({
    super.key,
    required this.data,
    required this.course,
    this.scheduleId,
  });

  @override
  State<QnaForm> createState() => QnaFormState();
}

class QnaFormState extends State<QnaForm> {
  List<UserQnA> model = List.empty(growable: true);
  bool paid = false;
  @override
  void initState() {
    super.initState();
    paid = false;
    for (var item in widget.data) {
      model.add(
        UserQnA(
          id: item.id,
          //type: item.type,
          question: item.title,
          options: item.options,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var item in widget.data) ...[
            Label(text: item.title!),
            if (item.type! == "Open Ended") ...[
              CustomFormField(
                hintText: 'Write your answer here',
                type: FieldType.multiline,
                onChanged: (value) {
                  model.where((q) => q.id == item.id).first.answer = value;
                },
              ),
            ],
            if (item.type! == "Single Choice") ...[
              RadioGroup<String>(
                groupValue: model.where((q) => q.id == item.id).first.answer,
                onChanged: (String? value) {
                  setState(() {
                    model.where((q) => q.id == item.id).first.answer = value!;
                  });
                },
                child: Column(
                  children: <Widget>[
                    for (var o in item.options!) ...[
                      RadioListTile<String>(
                        value: o.title!,
                        title: Text(o.title!),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            if (item.type! == "Multiple Choice") ...[
              for (var o in item.options!) ...[
                CheckboxListTile(
                  value: model
                      .where((q) => q.id == item.id)
                      .first
                      .options
                      ?.where((e) => e.id == o.id)
                      .first
                      .isChecked,
                  title: Text(
                    o.title!,
                    style: TextTheme.of(context).labelSmall,
                  ),
                  onChanged: (value) {
                    setState(() {
                      model
                              .where((q) => q.id == item.id)
                              .first
                              .options
                              ?.where((e) => e.id == o.id)
                              .first
                              .isChecked =
                          value;
                    });
                  },
                ),
              ],
            ],
            const SizedBox(height: 16),
          ],
          ElevatedButton(
            onPressed: () async {
              Loader.show();
              for (var item in model) {
                item.options?.removeWhere((z) => z.isChecked == false);
              }
              String qnaData = jsonEncode(
                model.map((u) => u.toJson()).toList(),
              );
              var result = await EnrollHelper.initiate(
                widget.course!.id!,
                qnaData: qnaData,
              );
              Loader.hide();
              if (result.succeed) {
                checkout();
                if (paid) {
                  Loader.show();
                  EnrollHelper.enrolled(result.id!);
                  setState(() {
                    paid = false;
                  });
                  Alert.show("Your enrollment is complete.", isError: false);
                  Loader.hide();
                  navigatorKey.currentState?.push(
                    MaterialPageRoute(builder: (context) => Home()),
                  );
                }
              } else {
                Alert.show(result.message!, isError: true);
              }
            },
            style: ButtonStyle(
              padding: WidgetStatePropertyAll(EdgeInsets.all(8)),
            ),
            child: Text(
              'Submit',
              style: TextTheme.of(
                context,
              ).labelSmall!.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void checkout() async {
    bool bought = await Service.order.bought(widget.course!.id!, "COURSE");
    if (bought) {
      Alert.show(
        "You're enrolled! Jump back into your learning.",
        isError: false,
      );
    } else {
      var payment = await Service.setting.get('PAYMENT');
      dynamic user = await Service.identity.me();

      var orderData = OrderData(
        context: "COURSE",
        contextid: widget.course!.id!,
        price: widget.course!.sale,
        orderStatus: "INITIATED",
        orderStatusReason: 'Your order has been initiated and awaiting payment',
        paymentStatus: "PENDING",
        createdat: DateTime.now(),
      );
      var result = await Service.order.add(orderData);

      if (result!.succeed) {
        if (payment == 'ON') {
          await Service.store.set("latest_order_id", result.row!.id!);
          var userData = UserData.fromJson(user);
          RazorpayService.instance.startPayment(
            onSuccess: handlePaymentSuccess,
            onFailure: handlePaymentError,
            options: {
              'key': dotenv.env['RAZORPAY_KEY'] ?? '', // Replace with your key
              'currency': 'INR',
              'amount':
                  1 * 100, // amount in the smallest currency unit amount * 100
              'name': dotenv.env['COMPANY'] ?? '',
              'description': "Course - ${widget.course!.title}",
              'timeout': 300, // in seconds
              'prefill': {
                "name":
                    "${userData.firstName ?? ''} ${userData.lastName ?? ''}",
                "contact": userData.phone,
                "email": userData.email,
              },
              'theme': {'color': '#5A2A82'},
              'modal': {'confirm_close': true, 'handle_back': true},
            },
          );
        }
      } else {
        Alert.show("Failed to create order. Please try again.", isError: true);
      }
    }
  }

  void handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() {
      paid = true;
    });
    String? orderId = await Service.store.get("latest_order_id");
    OrderData orderData = OrderData(
      orderStatus: "CONFIRMED",
      orderStatusReason: 'Your payment was successful and order is confirmed',
      paymentStatus: "PAID",
      paymentStatusReason: 'Your payment was successful',
      paymentid: response.paymentId,
      signature: response.signature,
      updatedat: DateTime.now(),
    );
    OrderData? order = await Service.order.update(orderId!, orderData);
    if (order?.id == null) {
      Alert.show(
        "Payment was successful but failed to update order. Please contact support.",
        isError: true,
      );
    } else {
      Alert.show(
        "Payment Successful! Your order is confirmed.",
        isError: false,
      );
    }
  }

  void handlePaymentError(PaymentFailureResponse response) async {
    if (response.code == 0) {
      String? orderId = await Service.store.get("latest_order_id");
      OrderData orderData = OrderData(
        paymentStatus: "CANCELLED",
        paymentStatusReason: response.message,
        updatedat: DateTime.now(),
      );
      OrderData? order = await Service.order.update(orderId!, orderData);
      if (order != null) {
        Alert.show("Payment cancelled.", isError: false);
      }
    }
    Alert.show("Payment Failed: ${response.message}", isError: true);
  }
}
