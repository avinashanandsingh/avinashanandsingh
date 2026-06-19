import 'package:app/helpers/capitalize.dart';
import 'package:app/models/order.dart';
import 'package:app/pages/receipt.dart';
import 'package:app/services/service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/theme/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderCard extends StatelessWidget {
  final OrderData order;
  final VoidCallback? onTap;

  const OrderCard({super.key, required this.order, this.onTap});

  Color _getStatusColor(String status) {
    final lowerStatus = status.toLowerCase();
    if (lowerStatus.contains('confirmed') ||
        lowerStatus.contains('completed') ||
        lowerStatus.contains('paid')) {
      return Colors.green.shade700;
    } else if (lowerStatus.contains('pending') ||
        lowerStatus.contains('cancelled')) {
      return Colors.orange.shade700;
    } else if (lowerStatus.contains('failed') ||
        lowerStatus.contains('refunded')) {
      return AppColors.error;
    }
    return AppColors.primaryLight;
  }

  Widget _buildStatusChip(String label, String status) {
    final color = _getStatusColor(status);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 10,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withAlpha(50)),
          ),
          child: Text(
            status.toUpperCase(),
            style: GoogleFonts.lato(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.cardBackgroundDark : Colors.white;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 50 : 15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Order ID and Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            var out = await Service.order.get({
                              "criteria": [
                                {
                                  "column": "id",
                                  "cop": "eq",
                                  "value": order.id,
                                },
                              ],
                            });

                            /* navigatorKey.currentState?.push(
                              MaterialPageRoute(
                                builder: (context) => Receipt(order: out.row),
                              ),
                            ); */
                            var orderId = out.row?.orderid;
                            showDialog(
                              context: context,
                              fullscreenDialog: true,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Order: $orderId'),
                                  titlePadding: EdgeInsets.all(15),
                                  contentPadding: EdgeInsets.all(0),
                                  actionsPadding: EdgeInsets.all(10),

                                  content: Receipt(
                                    order: out.row,
                                    layout: false,
                                  ),
                                  actions: [
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor:
                                            Colors.white, // Text color
                                        backgroundColor: AppColors
                                            .primary, // Optional background
                                      ),
                                      onPressed: () => Navigator.pop(
                                        context,
                                      ), // Closes the dialog
                                      child: Text(
                                        'OK',
                                        style: TextTheme.of(context).labelSmall!
                                            .copyWith(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text(
                            'Order # ${order.orderid}',
                            style: TextTheme.of(context).labelSmall!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.orderDate!,
                          style: GoogleFonts.lato(
                            fontSize: 12,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    order.formattedPrice ?? '',
                    style: TextTheme.of(context).labelSmall!.copyWith(
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.accentGold : AppColors.primary,
                    ),
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1),
              ),

              // Body: Context and Slot
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.context!.replaceAll("_", " ").capitalize(),
                          style: TextTheme.of(context).headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        if (order.contextData != null) ...[
                          Text(
                            order.contextData['title'] ??
                                order.contextData['name'],
                          ),
                          const SizedBox(height: 4),
                        ],
                        Row(
                          children: [
                            if (order.name != null) ...[
                              Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: secondaryTextColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                order.name ?? '',
                                style: GoogleFonts.lato(
                                  fontSize: 13,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Footer: Statuses
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withAlpha(50)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withAlpha(20)
                        : Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatusChip('ORDER STATUS', order.orderStatus!),
                    Container(
                      height: 30,
                      width: 1,
                      color: isDark
                          ? Colors.white.withAlpha(20)
                          : Colors.grey.shade300,
                    ),
                    _buildStatusChip('PAYMENT STATUS', order.paymentStatus!),
                  ],
                ),
              ),
              if (order.file != null) ...[
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () async {
                        final Uri uri = Uri.parse(order.file!);
                        try {
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        } catch (e) {
                          debugPrint('Could not launch ${order.file}: $e');
                        }
                      },
                      icon: Icon(Icons.download),
                      label: Text(
                        "Download Report",
                        style: TextTheme.of(context).labelSmall,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
