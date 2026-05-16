import 'package:app/models/aura.dart';
import 'package:app/models/order.dart';
import 'package:app/models/user.dart';
import 'package:app/services/razorpay.dart';
import 'package:app/services/service.dart';
import 'package:app/utils/alert.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SlotBooking extends StatefulWidget {
  final AuraData item;
  const SlotBooking({super.key, required this.item});
  @override
  State<SlotBooking> createState() => SlotBookingState();
}

class SlotBookingState extends State<SlotBooking> {
  int? selectedSlotIndex;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void handlePaymentSuccess(PaymentSuccessResponse response) async {
    print(
      'PaymentSuccessResponse: ${response.paymentId}, ${response.signature}',
    );
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
    print('updated Order: ${order?.toJson()}');
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
      print('updated Order: ${order?.toJson()}');
    }
    print(response.error.toString());
    Alert.show("Payment Failed: ${response.message}", isError: true);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    // Assume TextTheme.of(context) has the appropriate styles, fallback added if null
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Choose your preferred date and time.",
                      style: textTheme.labelSmall,
                    ),
                    const SizedBox(height: 20),

                    // ── Date Picker ──
                    Text("Date", style: textTheme.labelSmall),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(
                            const Duration(days: 1),
                          ),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 60),
                          ),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                datePickerTheme: DatePickerThemeData(
                                  headerHeadlineStyle: textTheme.labelMedium,
                                  headerHelpStyle: GoogleFonts.cinzel(
                                    fontSize: 24,
                                    color: Colors.purple,
                                  ),
                                  weekdayStyle: textTheme.bodySmall,
                                  dayStyle: textTheme.bodySmall,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                colorScheme: const ColorScheme.light(),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    textStyle: textTheme.labelSmall,
                                    padding: const EdgeInsets.all(5),
                                  ), // Buttons
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selectedDate != null
                                ? Colors.purple.withValues(
                                    alpha: 0.4,
                                  ) // AppColors.primary
                                : Colors.grey.withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: selectedDate != null
                              ? Colors.purple.withValues(
                                  alpha: 0.04,
                                ) // AppColors.primary
                              : Colors.transparent,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 20,
                              color: selectedDate != null
                                  ? Colors
                                        .purple // AppColors.primary
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              selectedDate != null
                                  ? "${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}"
                                  : "Tap to pick a date",
                              style: textTheme.labelSmall?.copyWith(
                                color: selectedDate != null
                                    ? Colors.black87
                                    : Colors.grey,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.chevron_right,
                              color: selectedDate != null
                                  ? Colors
                                        .purple // AppColors.primary
                                  : Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Time Slots ──
                    Text("Available Time Slots", style: textTheme.labelSmall),
                    const SizedBox(height: 8),
                    if (item.slots != null)
                      ...List.generate(item.slots!.length, (index) {
                        final slot = item.slots![index];
                        final isSelected = selectedSlotIndex == index;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selectedSlotIndex = index;
                              });
                            },
                            borderRadius: BorderRadius.circular(5),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected
                                      ? Colors
                                            .purple // AppColors.primary
                                      : Colors.grey.withValues(alpha: 0.2),
                                  width: isSelected ? 1.5 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                color: isSelected
                                    ? Colors.purple.withValues(
                                        alpha: 0.06,
                                      ) // AppColors.primary
                                    : Colors.transparent,
                              ),
                              child: Row(
                                children: [
                                  Radio<int>(
                                    value: index,
                                    groupValue: selectedSlotIndex,
                                    activeColor:
                                        Colors.purple, // AppColors.primary
                                    onChanged: (val) {
                                      setState(() {
                                        selectedSlotIndex = val;
                                      });
                                    },
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          slot.name ?? 'N/A',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                            color: isSelected
                                                ? Colors
                                                      .purple // AppColors.primary
                                                : Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Text(
                                              slot.startTime ?? 'N/A',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isSelected
                                                    ? Colors.purple.withValues(
                                                        alpha: 0.7,
                                                      )
                                                    : Colors.grey.shade600,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 4,
                                                  ),
                                              child: Icon(
                                                Icons.arrow_forward,
                                                size: 12,
                                                color: Colors.grey.shade400,
                                              ),
                                            ),
                                            Text(
                                              slot.endTime ?? 'N/A',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isSelected
                                                    ? Colors.purple.withValues(
                                                        alpha: 0.7,
                                                      )
                                                    : Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: slot.capacity > 0
                                          ? Colors.green.withValues(alpha: 0.1)
                                          : Colors.red.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${slot.capacity} left',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: slot.capacity > 0
                                            ? Colors.green.shade700
                                            : Colors.red.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: (selectedSlotIndex != null && selectedDate != null)
                      ? () async {
                          //Navigator.pop(context);

                          // NOTE: Uncomment and fix these logic lines based on your actual imports
                          bool bought = await Service.order.bought(
                            item.id!,
                            "AURA_SCANNING",
                          );
                          if (bought) {
                            Alert.show(
                              "Your time slot is already booked.",
                              isError: false,
                            );
                          } else {
                            var payment = await Service.setting.get('PAYMENT');
                            dynamic user = await Service.identity.me();
                            var slot = item.slots![selectedSlotIndex!];

                            var orderData = OrderData(
                              context: "AURA_SCANNING",
                              contextid: item.id,
                              slotid: slot.id,
                              name: "Aura Scan - ${item.name} - ${slot.name}",
                              price: item.sale,
                              orderStatus: "INITIATED",
                              orderStatusReason:
                                  'Your order has been initiated and awaiting payment',
                              paymentStatus: "PENDING",
                              createdat: DateTime.now(),
                            );
                            var order = await Service.order.add(orderData);

                            if (order?.id == null) {
                              Alert.show(
                                "Failed to create order. Please try again.",
                                isError: true,
                              );
                            } else {
                              if (payment == 'ON') {
                                await Service.store.set(
                                  "latest_order_id",
                                  order!.id!,
                                );
                                var userData = UserData.fromJson(user);
                                RazorpayService.instance.startPayment(
                                  onSuccess: handlePaymentSuccess,
                                  onFailure: handlePaymentError,
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
                                        'Aura Scan - ${item.name!} - ${slot.name!}',
                                    'timeout': 300, // in seconds
                                    'prefill': {
                                      "name":
                                          "${userData.firstName ?? ''} ${userData.lastName ?? ''}",
                                      "contact": userData.phone,
                                      "email": userData.email,
                                    },
                                    'theme': {'color': '#5A2A82'},
                                    //"order_id": order.id,
                                  },
                                );
                                /* checkout(
                                  'Aura Scan - ${item.name!} - ${slot.name!}',
                                  userData,
                                ); */
                              }
                            }
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    textStyle: textTheme.labelSmall,
                    backgroundColor: Colors.purple, // AppColors.primary
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.grey.shade500,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.all(8),
                  ),
                  child: const Text("Pay Now"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
