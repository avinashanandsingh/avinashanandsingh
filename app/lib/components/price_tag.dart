import 'package:app/theme/theme.dart';
import 'package:flutter/material.dart';

class PriceTag extends StatelessWidget {
  final double offer;
  final double? price;

  const PriceTag({super.key, required this.offer, this.price});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Current Price
        if (offer > 0) ...[
          Text(
            '₹${offer.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ] else ...[
          Text(
            '₹${price!.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],

        // Strike-through Price (if it exists)
        if (price != null && offer > 0 && price! > offer)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              '₹${price!.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18 * 0.8, // Slightly smaller
                color: AppColors.primaryLight,
                decoration: TextDecoration.lineThrough, // The strike-through
              ),
            ),
          ),
      ],
    );
  }
}
