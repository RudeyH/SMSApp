import 'package:flutter/material.dart';

class StickySearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final EdgeInsetsGeometry margin;

  const StickySearchBar({
    super.key,
    required this.controller,
    this.hintText = 'Search...',
    this.onChanged,
    this.margin = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Handle color opacity using .withValues() if available
    Color surfaceColor = theme.colorScheme.surface;
    // Use reflection-style check to stay safe for older SDKs
    try {
      // ignore: deprecated_member_use
      surfaceColor = surfaceColor.withValues(alpha: 0.95);
    } catch (_) {
      // ignore: deprecated_member_use
      surfaceColor = surfaceColor.withOpacity(0.95);
    }

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
