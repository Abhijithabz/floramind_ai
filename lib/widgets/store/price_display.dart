import 'package:flutter/material.dart';

class PriceDisplay extends StatelessWidget {
  const PriceDisplay({
    super.key,
    required this.price,
    this.discountPrice,
    this.priceStyle,
  });

  final double price;
  final double? discountPrice;
  final TextStyle? priceStyle;

  bool get _hasDiscount => discountPrice != null && discountPrice! < price;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentPrice = _hasDiscount ? discountPrice! : price;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'Rs. ${currentPrice.toStringAsFixed(0)}',
          style: priceStyle ??
              theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w900,
              ),
        ),
        if (_hasDiscount) ...[
          const SizedBox(width: 10),
          Text(
            'Rs. ${price.toStringAsFixed(0)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ],
    );
  }
}
