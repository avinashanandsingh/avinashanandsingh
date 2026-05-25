import 'dart:ui';

import 'package:app/components/audio_player_dialog.dart' as AudioDialog;
import 'package:app/models/meditation.dart';
import 'package:app/models/order.dart';
import 'package:app/models/user.dart';
import 'package:app/pages/home.dart';
import 'package:app/pages/user/signin.dart';
import 'package:app/services/razorpay.dart';
import 'package:app/services/service.dart';
import 'package:app/theme/theme.dart';
import 'package:app/utils/alert.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../helpers/globals.dart';

class MeditationItem extends StatefulWidget {
  final MeditationData data;
  final bool isLoggedIn;

  const MeditationItem({
    super.key,
    required this.data,
    required this.isLoggedIn,
  });
  @override
  State<MeditationItem> createState() => MeditationsItemState();
}

class MeditationsItemState extends State<MeditationItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void handlePaymentSuccess(PaymentSuccessResponse response) async {
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
      await Service.order.update(orderId!, orderData);
    }
    Alert.show("Payment Failed: ${response.message}", isError: true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () async {
              if (!widget.isLoggedIn) {
                navigatorKey.currentState?.push(
                  MaterialPageRoute(
                    builder: (context) => const SignIn(redirect: Home()),
                  ),
                );
                return;
              }
              if (widget.data.free!) {
                AudioDialog.show(
                  context,
                  url: widget.data.url!,
                  title: widget.data.title!.replaceAll("\n", " "),
                  author: "Meditation",
                  backgroundUrl:
                      "https://assets.mixkit.co/z8nazrerdw1dcdvnvykfp8c2yqmj",
                  mode: AudioDialog.BackgroundMode.video,
                );
              } else {
                bool bought = await Service.order.bought(
                  widget.data.id!,
                  "MEDITATION",
                );
                if (bought) {
                  AudioDialog.show(
                    context,
                    url: widget.data.url!,
                    title: widget.data.title!.replaceAll("\n", " "),
                    author: "Meditation",
                    backgroundUrl:
                        "https://assets.mixkit.co/z8nazrerdw1dcdvnvykfp8c2yqmj",
                    mode: AudioDialog.BackgroundMode.video,
                  );
                } else {
                  // Buy now start payment flow

                  OrderData orderData = OrderData(
                    context: "MEDITATION",
                    contextid: widget.data.id,
                    name: "Meditation Audio - ${widget.data.title}",
                    price: widget.data.sale,
                    orderStatus: "INITIATED",
                    orderStatusReason:
                        'Your order has been initiated and awaiting payment',
                    paymentStatus: "PENDING",
                    createdat: DateTime.now(),
                  );
                  var result = await Service.order.add(orderData);
                  if (result?.row == null) {
                    Alert.show(
                      "Failed to create order. Please try again.",
                      isError: true,
                    );
                    return;
                  }

                  var payment = await Service.setting.get(('PAYMENT'));
                  if (payment == 'ON') {
                    var payment = await Service.setting.get('PAYMENT');
                    dynamic user = await Service.identity.me();
                    if (payment == 'ON') {
                      await Service.store.set(
                        "latest_order_id",
                        result!.row!.id!,
                      );
                      UserData userData = UserData.fromJson(user);
                      RazorpayService.instance.startPayment(
                        options: {
                          'key':
                              dotenv.env['RAZORPAY_KEY'] ??
                              '', // Replace with your key
                          'currency': 'INR',
                          'amount':
                              1 *
                              100, // amount in the smallest currency unit amount * 100
                          'name': dotenv.env['COMPANY'] ?? '',
                          'description':
                              '${widget.data.title} Meditation Audio',
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
                        onSuccess: handlePaymentSuccess,
                        onFailure: handlePaymentError,
                      );
                    }
                  }
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.accentGold, width: 2),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(widget.data.thumbnail ?? ''),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(150),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.isLoggedIn
                              ? Icons.play_arrow_rounded
                              : Icons.lock_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.data.title ?? '',
            textAlign: TextAlign.center,
            style: TextTheme.of(context).labelSmall,
          ),
        ],
      ),
    );
  }
}
