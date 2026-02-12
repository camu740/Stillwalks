import 'package:flutter/material.dart';

class ShopShortcutButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;
  final bool isCompact;

  const ShopShortcutButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconColor = Colors.white,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: iconColor.withOpacity(0.5), width: 1),
            boxShadow: [
              BoxShadow(
                color: iconColor.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6), // Dark background like Shop Items
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            bottomLeft: Radius.circular(30),
          ),
          border: Border(
            top: BorderSide(color: iconColor.withOpacity(0.5), width: 1.5), // Colored border
            bottom: BorderSide(color: iconColor.withOpacity(0.5), width: 1.5),
            left: BorderSide(color: iconColor.withOpacity(0.5), width: 1.5),
          ),
          boxShadow: [
            BoxShadow(
              color: iconColor.withOpacity(0.2), // Colored glow/shadow
              blurRadius: 8,
              offset: const Offset(-2, 0), 
            ),
          ],
        ),
        child: Icon(
          icon,
          color: iconColor, // Colored Icon
          size: 28,
        ),
      ),
    );
  }
}
