import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../components/layout.dart';
import '../theme/theme.dart';

class AuraScan extends StatefulWidget {
  const AuraScan({super.key});

  @override
  State<AuraScan> createState() => _AuraScanPageState();
}

class _AuraScanPageState extends State<AuraScan> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    //_razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    //_razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    //_razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Payment Successful!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment Failed: ${response.message}"),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External Wallet: ${response.walletName}")),
    );
  }

  void _openCheckout(int amount, String machineName) {
    var options = {
      'key': 'rzp_test_YOUR_KEY', // Replace with your key
      'amount': amount * 100, // amount in the smallest currency unit
      'name': 'Booking for Aura Scan',
      'description': 'Aura Scan - $machineName',
      'timeout': 300, // in seconds
      'prefill': {'contact': '9876543210', 'email': 'user@example.com'},
      'theme': {'color': '#5A2A82'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  static const List<Map<String, String>> _timeSlots = [
    {
      'name': 'Morning Slot A',
      'start': '09:00 AM',
      'end': '10:00 AM',
      'capacity': '5',
    },
    {
      'name': 'Morning Slot B',
      'start': '10:00 AM',
      'end': '11:00 AM',
      'capacity': '5',
    },
    {
      'name': 'Morning Slot C',
      'start': '11:00 AM',
      'end': '12:00 PM',
      'capacity': '3',
    },
    {
      'name': 'Afternoon Slot A',
      'start': '02:00 PM',
      'end': '03:00 PM',
      'capacity': '5',
    },
    {
      'name': 'Afternoon Slot B',
      'start': '03:00 PM',
      'end': '04:00 PM',
      'capacity': '4',
    },
    {
      'name': 'Afternoon Slot C',
      'start': '04:00 PM',
      'end': '05:00 PM',
      'capacity': '3',
    },
  ];

  void _showScheduleDialog(String machineName, int price) {
    int? selectedSlotIndex;
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    machineName,
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
                    const Text(
                      "Select Date",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
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
                              style: TextStyle(
                                color: selectedDate != null
                                    ? Colors.black87
                                    : Colors.grey,
                                fontWeight: selectedDate != null
                                    ? FontWeight.w500
                                    : FontWeight.normal,
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
                    const Text(
                      "Available Time Slots",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(_timeSlots.length, (index) {
                      final slot = _timeSlots[index];
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
                                        slot['name']!,
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
                                            slot['start']!,
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
                                            slot['end']!,
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
                                    color: int.parse(slot['capacity']!) > 0
                                        ? Colors.green.withValues(alpha: 0.1)
                                        : Colors.red.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${slot['capacity']} left',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: int.parse(slot['capacity']!) > 0
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
                    ? () {
                        Navigator.pop(dialogContext);
                        _openCheckout(price, machineName);
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
                child: const Text("Book Now"),
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
            children: [
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
              _buildMachineBox(
                "Machine 1",
                500,
                "Standard aura analysis with basic chakra alignment report.",
                Icons.radar_outlined,
              ),
              const SizedBox(height: 20),
              _buildMachineBox(
                "Machine 2",
                750,
                "Advanced deep-scan technology with comprehensive energy field visualization.",
                Icons.biotech_outlined,
              ),
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

  Widget _buildMachineBox(
    String name,
    int price,
    String description,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: () => _showScheduleDialog(name, price),
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
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text(
                          "Click to Schedule",
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
