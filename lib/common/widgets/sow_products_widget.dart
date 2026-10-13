import 'package:flutter/material.dart';

import '../models/work_order_model.dart';

import 'package:flutter/material.dart';

// Keep your existing WorkOrderProductModel import.

class WorkOrderProductsView extends StatefulWidget {
  final List<WorkOrderProductModel> products;

  const WorkOrderProductsView({
    super.key,
    required this.products,
  });

  @override
  State<WorkOrderProductsView> createState() =>
      _WorkOrderProductsViewState();
}

class _WorkOrderProductsViewState
    extends State<WorkOrderProductsView> {
  bool _isExpanded = false;

  final Set<int> _expandedItems = {};

  static const Color _blue = Color(0xFF2563EB);
  static const Color _dark = Color(0xFF142B4A);
  static const Color _muted = Color(0xFF75849B);

  @override
  Widget build(BuildContext context) {
    final totalQty = widget.products.fold<num>(
      0,
          (sum, item) => sum + item.quantity,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE3EAF5),
        ),
        boxShadow: [
          BoxShadow(
            color: _blue.withValues(alpha: .05),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // MAIN GRADIENT HEADER
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFBF953F), // Rich Gold
                    Color(0xFFB38728), // Deep Metallic Gold
                    Color(0xFFAA771C), // Dark Antique Gold
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .17),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: .25),
                      ),
                    ),
                    child: const Icon(
                      Icons.inventory_2_rounded,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Products & Equipment',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.products.length} products • '
                              '$totalQty total units',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: .85),
                          ),
                        ),
                      ],
                    ),
                  ),

                  AnimatedRotation(
                    turns: _isExpanded ? .5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .17),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ANIMATED PRODUCT LIST
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            alignment: Alignment.topCenter,
            child: _isExpanded
                ? Padding(
              padding: const EdgeInsets.all(12),
              child: widget.products.isEmpty
                  ? _buildEmptyState()
                  : Column(
                children: [
                  ...List.generate(
                    widget.products.length,
                        (index) {
                      final product =
                      widget.products[index];

                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index ==
                              widget.products.length - 1
                              ? 0
                              : 10,
                        ),
                        child: _buildProductCard(
                          product,
                          index,
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(
      WorkOrderProductModel product,
      int index,
      ) {
    final expanded = _expandedItems.contains(index);
    final color = _getProductColor(product.name);
    final icon = _getProductIcon(product.name);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: expanded
              ? color.withValues(alpha: .35)
              : const Color(0xFFE8EDF5),
          width: expanded ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: expanded ? .08 : .035),
            blurRadius: expanded ? 16 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(17),
              onTap: () {
                setState(() {
                  if (expanded) {
                    _expandedItems.remove(index);
                  } else {
                    _expandedItems.add(index);
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(13),
                child: Row(
                  children: [
                    // COLORED PRODUCT ICON
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: .10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 23,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // PRODUCT INFORMATION
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: _dark,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Product ID: ${product.id}',
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: _muted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // QUANTITY BADGE
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: .10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${product.quantity}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: color,
                            ),
                          ),
                          Text(
                            'QTY',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: color.withValues(alpha: .75),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 6),

                    AnimatedRotation(
                      turns: expanded ? .5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: _muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // EXPANDABLE DETAILS
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: expanded
                ? Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                13, 0, 13, 13,
              ),
              child: Column(
                children: [
                  Divider(
                    color: color.withValues(alpha: .13),
                    height: 18,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: _detailTile(
                          'PRODUCT ID',
                          '${product.id}',
                          Icons.tag_rounded,
                          color,
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: _detailTile(
                          'QUANTITY',
                          '${product.quantity}',
                          Icons.layers_rounded,
                          color,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: .055),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: color,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Product assigned to this work order',
                            style: TextStyle(
                              fontSize: 11,
                              color: _muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _detailTile(
      String label,
      String value,
      IconData icon,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FD),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: const Color(0xFFEDF1F7),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    color: _muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    color: _dark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 38,
            color: Colors.blue.shade200,
          ),
          const SizedBox(height: 10),
          const Text(
            'No Products Assigned',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: _dark,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Products will appear here once assigned.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: _muted,
            ),
          ),
        ],
      ),
    );
  }

  Color _getProductColor(String name) {
    final n = name.toLowerCase();

    if (n.contains('starlink') ||
        n.contains('dish') ||
        n.contains('router')) {
      return const Color(0xFF2563EB);
    }

    if (n.contains('mount') ||
        n.contains('bracket') ||
        n.contains('antenna')) {
      return const Color(0xFF9333EA);
    }

    if (n.contains('screw') ||
        n.contains('bolt') ||
        n.contains('hardware')) {
      return const Color(0xFFF97316);
    }

    if (n.contains('cable') ||
        n.contains('wire')) {
      return const Color(0xFF059669);
    }

    if (n.contains('power') ||
        n.contains('adapter')) {
      return const Color(0xFFE11D48);
    }

    return const Color(0xFF0891B2);
  }

  IconData _getProductIcon(String name) {
    final n = name.toLowerCase();

    if (n.contains('starlink') ||
        n.contains('dish') ||
        n.contains('router')) {
      return Icons.router_rounded;
    }

    if (n.contains('mount') ||
        n.contains('bracket') ||
        n.contains('antenna')) {
      return Icons.settings_input_antenna_rounded;
    }

    if (n.contains('screw') ||
        n.contains('bolt') ||
        n.contains('hardware')) {
      return Icons.handyman_rounded;
    }

    if (n.contains('cable') ||
        n.contains('wire')) {
      return Icons.cable_rounded;
    }

    if (n.contains('power') ||
        n.contains('adapter')) {
      return Icons.power_rounded;
    }

    return Icons.inventory_2_rounded;
  }
}
