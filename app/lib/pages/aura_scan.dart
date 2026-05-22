import 'package:app/components/custom_accordion.dart';
import 'package:app/components/layout.dart';
import 'package:app/components/slot_booking.dart';
import 'package:app/models/aura.dart';
import 'package:flutter/material.dart';
import '../theme/theme.dart';

class AuraScan extends StatelessWidget {
  final List<AuraData> data;
  const AuraScan({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Layout(
      titleText: 'Aura Scanning Service',
      showHeader: true,
      isSerif: false,
      showBottomNav: true,
      showActions: false,
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
              for (var item in data) ...[
                //_buildMachineBox(item, Icons.radar_outlined),
                CustomAccordion(
                  initiallyExpanded: false,
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name ?? '',
                          style: TextTheme.of(context).headlineSmall,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(
                            alpha: 0.1,
                          ), // Replace with AppColors.primary.withOpacity(0.1)
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "₹${item.sale}",
                          style: const TextStyle(
                            color:
                                Colors.purple, // Replace with AppColors.primary
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  content: SlotBooking(item: item),
                  onToggle: (isExpanded) {},
                ),
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
}
