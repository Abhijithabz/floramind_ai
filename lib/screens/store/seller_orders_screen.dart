import 'package:flutter/material.dart';

import '../dashboard/widgets/dashboard_background.dart';
import '../../widgets/store/order_card.dart';
import '../../widgets/store/store_section_header.dart';
import 'garden_store_controller.dart';

class SellerOrdersScreen extends StatelessWidget {
  const SellerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GardenStoreController.instance;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Orders'),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: DashboardBackground()),
          SafeArea(
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                final orders = controller.orders;
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final contentWidth = constraints.maxWidth >= 1240
                          ? 1160.0
                          : constraints.maxWidth;
                      final columns = constraints.maxWidth >= 1100 ? 2 : 1;

                      return Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: contentWidth),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const StoreSectionHeader(
                                title: 'Sample orders',
                                subtitle:
                                    'Frontend-only order cards. Real order processing will be connected later.',
                              ),
                              const SizedBox(height: 14),
                              if (orders.isEmpty)
                                const _EmptyState()
                              else
                                LayoutBuilder(
                                  builder: (context, orderConstraints) {
                                    final gap = 14.0;
                                    final cardWidth = columns == 1
                                        ? orderConstraints.maxWidth
                                        : ((orderConstraints.maxWidth - gap) / 2)
                                            .clamp(260.0, 520.0)
                                            .toDouble();

                                    return Wrap(
                                      spacing: gap,
                                      runSpacing: gap,
                                      children: orders
                                          .map(
                                            (order) => SizedBox(
                                              width: cardWidth,
                                              child: OrderCard(order: order),
                                            ),
                                          )
                                          .toList(),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: colorScheme.surface.withValues(alpha: 0.76),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 44,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 12),
          const Text('No sample orders yet'),
        ],
      ),
    );
  }
}
