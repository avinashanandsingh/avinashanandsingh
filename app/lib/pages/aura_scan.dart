import 'package:app/models/aura.dart';
import 'package:app/models/order.dart';
import 'package:app/services/service.dart';
import 'package:app/utils/alert.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../components/layout.dart';
import '../theme/theme.dart';

class AuraScan extends StatefulWidget {
  final List<AuraData> data;
  const AuraScan({super.key, required this.data});

  @override
  State<AuraScan> createState() => _AuraScanPageState();
}

class _AuraScanPageState extends State<AuraScan> {
  late Razorpay _razorpay;
  late bool _isProcessing; // Add a flag
  @override
  void initState() {
    super.initState();
    _isProcessing = false;
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() => _isProcessing = false);

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

  void _handlePaymentError(PaymentFailureResponse response) async {
    setState(() => _isProcessing = false);
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

  void _handleExternalWallet(ExternalWalletResponse response) {
    Alert.show("External Wallet: ${response.walletName}", isError: true);
  }

  void _openCheckout(String desc, String phone, String email) {
    Map<String, dynamic> options = {
      'key': dotenv.env['RAZORPAY_KEY'] ?? '', // Replace with your key
      'currency': 'INR',
      'amount': 1 * 100, // amount in the smallest currency unit amount * 100
      'name': 'Booking for Aura Scan',
      'description': desc,
      'timeout': 300, // in seconds
      'prefill': {
        //"name": "${user['first_name'] ?? ''} ${user['last_name'] ?? ''}",
        "contact": phone,
        "email": email,
      },
      'theme': {'color': '#5A2A82'},
      //"order_id": order.id,
    };
    if (_isProcessing) return; // Prevent double clicks
    setState(() => _isProcessing = true);
    try {
      print(options.toString());
      _razorpay.open(options);
    } catch (e) {
      print('Error: $e');
    }
  }

  void _showScheduleDialog(AuraData item) {
    int? selectedSlotIndex;
    DateTime? selectedDate;
    double? price = (item.offer! > 0 && item.offer! <= item.price!)
        ? item.offer!
        : item.price!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            insetPadding: EdgeInsets.all(15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    item.name!,
                    style: TextTheme.of(context).headlineSmall,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "₹$price",
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Select your preferred slot and date.",
                      style: TextTheme.of(context).labelSmall,
                    ),
                    const SizedBox(height: 20),

                    // ── Date Picker ──
                    Text(
                      "Select Date",
                      style: TextTheme.of(context).labelSmall,
                    ),
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
                                  headerHeadlineStyle: TextTheme.of(
                                    context,
                                  ).labelMedium,
                                  headerHelpStyle: GoogleFonts.cinzel(
                                    fontSize: 24,
                                    color: Colors.purple,
                                  ),
                                  weekdayStyle: TextTheme.of(context).bodySmall,
                                  dayStyle: TextTheme.of(context).bodySmall,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                colorScheme: const ColorScheme.light(),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    textStyle: TextTheme.of(context).labelSmall,
                                    padding: EdgeInsets.all(5),
                                  ), // Buttons
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setDialogState(() => selectedDate = picked);
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
                                ? AppColors.primary.withValues(alpha: 0.4)
                                : Colors.grey.withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: selectedDate != null
                              ? AppColors.primary.withValues(alpha: 0.04)
                              : Colors.transparent,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 20,
                              color: selectedDate != null
                                  ? AppColors.primary
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              selectedDate != null
                                  ? "${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}"
                                  : "Tap to pick a date",
                              style: TextTheme.of(context).labelSmall!.copyWith(
                                color: selectedDate != null
                                    ? Colors.black87
                                    : Colors.grey,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.chevron_right,
                              color: selectedDate != null
                                  ? AppColors.primary
                                  : Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Time Slots ──
                    Text(
                      "Available Time Slots",
                      style: TextTheme.of(context).labelSmall,
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(item.slots!.length, (index) {
                      final slot = item.slots?[index];
                      final isSelected = selectedSlotIndex == index;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: InkWell(
                          onTap: () =>
                              setDialogState(() => selectedSlotIndex = index),
                          borderRadius: BorderRadius.circular(5),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.grey.withValues(alpha: 0.2),
                                width: isSelected ? 1.5 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.06)
                                  : Colors.transparent,
                            ),
                            child: Row(
                              children: [
                                Radio<int>(
                                  value: index,
                                  groupValue: selectedSlotIndex,
                                  activeColor: AppColors.primary,
                                  onChanged: (val) => setDialogState(
                                    () => selectedSlotIndex = val,
                                  ),
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
                                        slot!.name ?? 'N/A',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: isSelected
                                              ? AppColors.primary
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
                                                  ? AppColors.primary
                                                        .withValues(alpha: 0.7)
                                                  : Colors.grey.shade600,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
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
                                                  ? AppColors.primary
                                                        .withValues(alpha: 0.7)
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
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
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
                        Navigator.pop(dialogContext);
                        dynamic user = await Service.identity.me();
                        TimeslotData slot = item.slots![selectedSlotIndex!];
                        double? amount =
                            (item.offer! > 0 && item.offer! <= item.price!)
                            ? item.offer!
                            : item.price!;
                        OrderData orderData = OrderData(
                          context: "AURA_SCANNING",
                          contextid: item.id,
                          slotid: slot.id,
                          name: "Aura Scan - $item.name - $slot.name",
                          price: amount,
                          orderStatus: "INITIATED",
                          orderStatusReason:
                              'Your order has been initiated and awaiting payment',
                          paymentStatus: "PENDING",
                          createdat: DateTime.now(),
                        );
                        OrderData? order = await Service.order.add(orderData);
                        if (order?.id == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Failed to create order. Please try again.",
                              ),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        } else {
                          await Service.store.set(
                            "latest_order_id",
                            order!.id!,
                          );

                          _openCheckout(
                            'Aura Scan - ${item.name!} - ${slot.name!}',
                            user['phone'] ?? '',
                            user['email'] ?? '',
                          );
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  textStyle: TextTheme.of(context).labelSmall,
                  backgroundColor: AppColors.primary,
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
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      titleText: 'AURA SCAN',
      isSerif: false,
      showBack: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Choose option to scan your aura",
                style: TextTheme.of(context).headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                "Experience advanced aura analysis with our state-of-the-art machines.",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Multiline loop rendering
              for (var item in widget.data) ...[
                _buildMachineBox(item, Icons.radar_outlined),
                const SizedBox(height: 20),
              ],
              const SizedBox(height: 40),
              // Why Aura Scan Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.white, size: 24),
                        SizedBox(width: 10),
                        Text(
                          "Why Aura Scan?",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Understanding your energy field can help identify emotional blocks and optimize your overall well-being. Our non-invasive scanning technology provides instant feedback on your mental and spiritual state.",
                      style: TextStyle(color: Colors.white70, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMachineBox(AuraData item, IconData icon) {
    double? price = (item.offer! > 0 && item.offer! <= item.price!)
        ? item.offer!
        : item.price!;
    return GestureDetector(
      onTap: () => _showScheduleDialog(item),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.1),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Icon(
                  icon,
                  size: 120,
                  color: AppColors.primary.withValues(alpha: 0.03),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: AppColors.primary, size: 28),
                        ),
                        const Spacer(),
                        Text(
                          "₹$price",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      item.name!,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text(
                          "Book Now",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
