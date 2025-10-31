import 'dart:math' as math;
import 'package:flutter/material.dart';

class TooltipIcon extends StatefulWidget {
  final Icon icon;
  final String tooltipMessage;
  final TextStyle textStyle;
  final Color backgroundColor;
  final double horizontalPadding;
  final double verticalPadding;
  final double verticalOffset;
  final double screenBuffer;

  const TooltipIcon({
    super.key,
    required this.icon,
    required this.tooltipMessage,
    this.textStyle = const TextStyle(color: Colors.white, fontSize: 14.0),
    this.backgroundColor = Colors.grey,
    this.horizontalPadding = 12.0,
    this.verticalPadding = 8.0,
    this.verticalOffset = 10.0,
    this.screenBuffer = 8.0,
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
    final iconSize = renderBox.size;
    final iconOffset = renderBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.of(context).size;

    // --- 1. Estimate Tooltip Size (required for positioning logic) ---
    // A reasonable max width for the tooltip might be half the screen or a fixed max
    final double maxTooltipWidth = math.min(400, screenSize.width / 2);
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: widget.tooltipMessage, style: widget.textStyle),
      maxLines: 5, // Allow multi-line, but limit
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxTooltipWidth);

    final tooltipWidth = textPainter.width + (2 * widget.horizontalPadding);
    final tooltipHeight = textPainter.height + (2 * widget.verticalPadding);

    // --- 2. Vertical Positioning (Top/Bottom decision) ---
    final spaceBelow = screenSize.height - iconOffset.dy - iconSize.height;
    final spaceAbove = iconOffset.dy;
    final showBelow = spaceBelow >= tooltipHeight + widget.verticalOffset || spaceBelow >= spaceAbove;

    double topPosition;
    if (showBelow) {
      topPosition = iconOffset.dy + iconSize.height + widget.verticalOffset;
    } else {
      topPosition = iconOffset.dy - tooltipHeight - widget.verticalOffset;
    }

    // Clamp Top/Bottom to screen boundaries
    topPosition = math.max(widget.screenBuffer, topPosition);
    topPosition = math.min(
        screenSize.height - tooltipHeight - widget.screenBuffer,
        topPosition
    );

    // --- 3. Horizontal Positioning (Left/Right clamping while centering on icon) ---

    // Calculate ideal left position (centered on the icon)
    double leftPosition = iconOffset.dx + (iconSize.width / 2) - (tooltipWidth / 2);

    // Clamp Left/Right to screen boundaries
    // Ensure the left side isn't < 0 + buffer
    leftPosition = math.max(widget.screenBuffer, leftPosition);
    // Ensure the right side isn't > screen width - buffer (adjust based on the tooltip's actual width)
    leftPosition = math.min(
        screenSize.width - tooltipWidth - widget.screenBuffer,
        leftPosition
    );
    // If the tooltip is wider than the screen minus buffers, this clamps it correctly.

    return OverlayEntry(
      builder: (context) => Positioned(
        top: topPosition,
        left: leftPosition,
        // We do *not* specify 'right' or 'bottom' so it wraps its content size.
        child: Material(
          elevation: 4.0,
          borderRadius: BorderRadius.circular(4.0),
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: widget.horizontalPadding,
                vertical: widget.verticalPadding),
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxTooltipWidth), child:Text(
              widget.tooltipMessage,
              style: widget.textStyle,
            )),
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
