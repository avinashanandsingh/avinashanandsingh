import 'package:app/helpers/capitalize.dart';
import 'package:app/models/order.dart';
//import 'package:app/pages/dashboard.dart';
//import 'package:app/pages/home.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../components/layout.dart';
//import '../components/html_to_pdf.dart';
//import '../components/loader.dart';
//import '../utils/alert.dart';

class Receipt extends StatefulWidget {
  final OrderData? order;
  const Receipt({super.key, this.order});

  @override
  State<Receipt> createState() => ReceiptState();
}

class ReceiptState extends State<Receipt> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeIn),
      ),
    );

    _glowAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _generateHtmlReceipt() {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Booking Confirmation - Coach Avinash</title>
  <style>
    body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; color: #240F47; margin: 40px; background-color: #f7f9fa; }
    .receipt { border: 1px solid #E2E8F0; padding: 40px; border-radius: 16px; max-width: 600px; margin: auto; background-color: #ffffff; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05); }
    .header { text-align: center; border-bottom: 2px solid #5A2A82; padding-bottom: 24px; }
    .logo { font-size: 28px; font-weight: bold; color: #5A2A82; letter-spacing: 2px; }
    .status { background-color: #DEF7EC; color: #03543F; padding: 6px 16px; border-radius: 20px; display: inline-block; font-size: 14px; font-weight: bold; margin-top: 12px; text-transform: uppercase; }
    .title { font-size: 22px; margin-top: 24px; font-weight: bold; text-align: center; color: #240F47; }
    .details-table { width: 100%; border-collapse: collapse; margin-top: 30px; }
    .details-table td { padding: 12px 0; border-bottom: 1px solid #EDF2F7; font-size: 14px; }
    .details-table td.label { color: #7A8B99; font-weight: 500; }
    .details-table td.value { text-align: right; font-weight: bold; color: #240F47; }
    .total-row td { border-top: 2px dashed #5A2A82; font-size: 18px; font-weight: bold; padding-top: 20px; color: #5A2A82; border-bottom: none; }
    .footer { text-align: center; margin-top: 40px; color: #7A8B99; font-size: 12px; border-top: 1px solid #E2E8F0; padding-top: 20px; }
  </style>
</head>
<body>
  <div class="receipt">
    <div class="header">
      <div class="logo">Coach Avinash</div>
      <div class="status">Booking Confirmed</div>
    </div>
    <div class="title">Official Payment Receipt</div>
    <table class="details-table">
      <tr>
        <td class="label">Booking ID</td>
        <td class="value">#${widget.order?.orderid}</td>
      </tr>
      <tr>
        <td class="label">Course/Service</td>
        <td class="value">${(widget.order?.context ?? '').replaceAll('_', ' ').capitalize()}</td>
      </tr>
      <tr>
        <td class="label">Date & Time</td>
        <td class="value">${widget.order?.slotAt}</td>
      </tr>
      <tr>
        <td class="label">Time Slot</td>
        <td class="value">${widget.order?.name}</td>
      </tr>
      <tr>
        <td class="label">Customer Name</td>
        <td class="value">${widget.order?.creator?.fullName}</td>
      </tr>
      <tr>
        <td class="label">Email Address</td>
        <td class="value">${widget.order?.creator?.email}</td>
      </tr>
      <tr>
        <td class="label">Mobile Number</td>
        <td class="value">${widget.order?.creator?.phone}</td>
      </tr>
      <tr>
        <td class="label">Transaction ID</td>
        <td class="value">${widget.order?.paymentid}</td>
      </tr>
      <!--<tr>
        <td class="label">Payment Method</td>
        <td class="value"></td>
      </tr>-->
      <tr class="total-row">
        <td>Total Amount Paid</td>
        <td class="value">₹${widget.order?.price!.toStringAsFixed(2)}</td>
      </tr>
    </table>
    <div class="footer">
      Thank you for your purchase. A copy of this receipt has been sent to your email.<br>
      For queries, reach out to support@avinash.cc
    </div>
  </div>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.accentGold : AppColors.primary;
    final cardBg = isDark ? AppColors.cardBackgroundDark : Colors.white;

    return Layout(
      titleText: 'CONFIRMATION',
      isSerif: true,
      showBottomNav: false,
      showBack: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF1E0E35), const Color(0xFF121212)]
                : [AppColors.primary.withAlpha(20), Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Success Animated Checkmark Banner ──
              if (widget.order?.orderStatus! == "CONFIRMED" ||
                  widget.order?.paymentStatus! == "PAID") ...[
                Center(
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _glowAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value * _glowAnimation.value,
                            child: Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green.shade500.withValues(
                                  alpha: 0.15,
                                ),
                                border: Border.all(
                                  color: Colors.green.shade400.withValues(
                                    alpha: 0.4,
                                  ),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.shade400.withValues(
                                      alpha: 0.2,
                                    ),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green,
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Text(
                          "Order is confirmed.",
                          style: TextTheme.of(context).headlineSmall!.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.accentGold
                                : AppColors.primary,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          "Thank you for your order; we truly value your patronage.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 28),

              // ── Interactive Receipt Card ──
              FadeTransition(
                opacity: _fadeAnimation,
                child: ClipPath(
                  clipper: ReceiptSideCutoutClipper(
                    cutoutPosition: 0.65,
                    cutoutRadius: 12,
                  ),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.3 : 0.08,
                          ),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Header Strip of the card
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                primaryColor,
                                primaryColor.withValues(alpha: 0.5),
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                        ),

                        // Top Section Content
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'BOOKING ID',
                                        style: GoogleFonts.lato(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? AppColors.textSecondaryDark
                                              : AppColors.textSecondary,
                                          letterSpacing: 1.1,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '#${widget.order?.orderid}',
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? Colors.white
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Brand name badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "COACH AVINASH",
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        color: primaryColor,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Course Name
                              Text(
                                (widget.order?.context ?? '')
                                    .replaceAll('_', ' ')
                                    .capitalize(),
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.accentGold
                                      : AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Date and Time slots
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 16,
                                    color: primaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    (widget.order?.slotAt ??
                                            widget.order?.orderDate) ??
                                        '',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 16,
                                    color: primaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      (widget.order?.name ??
                                              widget
                                                  .order
                                                  ?.contextData['title']) ??
                                          '',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // User details section
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.black.withValues(alpha: 0.3)
                                      : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : Colors.grey.shade200,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'PARTICIPANT DETAILS',
                                      style: GoogleFonts.lato(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondary,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                widget
                                                        .order
                                                        ?.creator
                                                        ?.fullName ??
                                                    '',
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: isDark
                                                      ? Colors.white
                                                      : Colors.black87,
                                                ),
                                              ),
                                              Text(
                                                '${widget.order?.creator?.email}  •  ${widget.order?.creator?.phone}',
                                                style: GoogleFonts.inter(
                                                  fontSize: 11,
                                                  color: isDark
                                                      ? AppColors
                                                            .textSecondaryDark
                                                      : AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Dashed Divider positioned exactly between side cutouts
                        CustomPaint(
                          size: const Size(double.infinity, 1),
                          painter: DashedLinePainter(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.15)
                                : Colors.grey.shade300,
                            dashWidth: 6,
                            dashSpace: 4,
                          ),
                        ),

                        // Bottom Section Content (Payment / Price)
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Bill Summary title
                              Text(
                                'BILLING SUMMARY',
                                style: GoogleFonts.lato(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Price breakdown rows
                              _buildSummaryRow(
                                'Price',
                                '₹${widget.order?.price?.toStringAsFixed(2)}',
                                isDark,
                              ),
                              const SizedBox(height: 8),
                              _buildSummaryRow(
                                'Discount / Offer',
                                '-₹0.00',
                                isDark,
                                isDiscount: true,
                              ),

                              //const SizedBox(height: 8),
                              //_buildSummaryRow('Taxes & Fees', '₹0.00', isDark),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Divider(height: 1),
                              ),

                              // Total Row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Paid',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '₹${widget.order?.price?.toStringAsFixed(2)}',
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: isDark
                                          ? AppColors.accentGold
                                          : AppColors.primary,
                                    ),
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
              ),
              const SizedBox(height: 28),

              // ── Interactive Buttons (Download PDF, Email, Calendar) ──
              /* FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Symmetrical 2x2 Grid of Actions
                    Row(
                      children: [
                        Expanded(
                          child: HtmlToPdf(
                            htmlContent: _generateHtmlReceipt(),
                            isPrint: false,
                            documentName: 'receipt_${widget.order?.orderid}',
                            buttonStyle: ElevatedButton.styleFrom(
                              backgroundColor: isDark
                                  ? AppColors.cardBackgroundDark
                                  : Colors.white,
                              foregroundColor: primaryColor,
                              side: BorderSide(
                                color: primaryColor.withValues(alpha: 0.5),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.picture_as_pdf_outlined,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'PDF Receipt',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: HtmlToPdf(
                            htmlContent: _generateHtmlReceipt(),
                            documentName: 'receipt_${widget.order?.orderid}',
                            isPrint: true,
                            buttonStyle: ElevatedButton.styleFrom(
                              backgroundColor: isDark
                                  ? AppColors.cardBackgroundDark
                                  : Colors.white,
                              foregroundColor: primaryColor,
                              side: BorderSide(
                                color: primaryColor.withValues(alpha: 0.5),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.print_outlined, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Print Receipt',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ), */
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    bool isDark, {
    bool isDiscount = false,
  }) {
    Color valColor = isDark ? Colors.white70 : Colors.black87;
    if (isDiscount) {
      valColor = Colors.green;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: isDiscount ? FontWeight.bold : FontWeight.w500,
            color: valColor,
          ),
        ),
      ],
    );
  }
}

// ── Receipt side-cutout clipper ──────────────────────────────────────────────
class ReceiptSideCutoutClipper extends CustomClipper<Path> {
  final double cutoutPosition; // fraction of height (e.g. 0.65)
  final double cutoutRadius;

  ReceiptSideCutoutClipper({
    required this.cutoutPosition,
    required this.cutoutRadius,
  });

  @override
  Path getClip(Size size) {
    var path = Path();
    double w = size.width;
    double h = size.height;
    double cy = h * cutoutPosition;

    path.moveTo(0, 0);
    // Left edge down to cutout
    path.lineTo(0, cy - cutoutRadius);
    // Left cutout (arc inwards)
    path.arcToPoint(
      Offset(0, cy + cutoutRadius),
      radius: Radius.circular(cutoutRadius),
      clockwise: true,
    );
    // Left edge to bottom-left
    path.lineTo(0, h);

    // Bottom edge
    path.lineTo(w, h);

    // Right edge up to cutout
    path.lineTo(w, cy + cutoutRadius);
    // Right cutout (arc inwards)
    path.arcToPoint(
      Offset(w, cy - cutoutRadius),
      radius: Radius.circular(cutoutRadius),
      clockwise: true,
    );
    // Right edge to top-right
    path.lineTo(w, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ── Dashed Divider Line Painter ──────────────────────────────────────────────
class DashedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;

  DashedLinePainter({
    required this.color,
    this.dashWidth = 6.0,
    this.dashSpace = 4.0,
    this.strokeWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
