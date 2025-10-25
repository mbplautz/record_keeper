import 'package:flutter/material.dart';

class TooltipIcon extends StatefulWidget {
  final Icon icon;
  final String tooltipMessage;

  const TooltipIcon({
    super.key,
    required this.icon,
    required this.tooltipMessage,
  });

  @override
  State<TooltipIcon> createState() => _TooltipIconState();
}

class _TooltipIconState extends State<TooltipIcon> {
  OverlayEntry? _overlayEntry;

  // This method creates and shows the tooltip overlay.
  void _showTooltip() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  // This method removes the tooltip overlay.
  void _hideTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // This method builds the visual content of the tooltip.
  OverlayEntry _createOverlayEntry() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        top: offset.dy - 50, // Adjust vertical position as needed
        left: offset.dx + (size.width / 2) - (widget.tooltipMessage.length * 4), // Center horizontally
        child: Material(
          elevation: 4.0,
          borderRadius: BorderRadius.circular(4.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Text(
              widget.tooltipMessage,
              style: const TextStyle(color: Colors.white, fontSize: 14.0),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hideTooltip(); // Ensure the overlay is removed when the widget is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _showTooltip(), // Show on tap down
      onTapUp: (_) => _hideTooltip(), // Hide on tap up
      onTapCancel: _hideTooltip, // Hide if tap is canceled
      child: widget.icon,
    );
  }
}
