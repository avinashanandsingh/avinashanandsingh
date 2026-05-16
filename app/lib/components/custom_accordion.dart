import 'package:flutter/material.dart';

class CustomAccordion extends StatefulWidget {
  final Widget title;
  final Widget content;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onToggle;
  final EdgeInsetsGeometry? headerPadding;
  final EdgeInsetsGeometry? contentPadding;
  final Decoration? decoration;

  const CustomAccordion({
    super.key,
    required this.title,
    required this.content,
    this.initiallyExpanded = false,
    this.onToggle,
    this.headerPadding,
    this.contentPadding,
    this.decoration,
  });

  @override
  State<CustomAccordion> createState() => _CustomAccordionState();
}

class _CustomAccordionState extends State<CustomAccordion>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _heightFactor;
  late Animation<double> _iconTurns;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _heightFactor = _controller.drive(CurveTween(curve: Curves.fastOutSlowIn));
    _iconTurns = _controller.drive(
      Tween<double>(
        begin: 0.0,
        end: 0.5,
      ).chain(CurveTween(curve: Curves.fastOutSlowIn)),
    );

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
    if (widget.onToggle != null) {
      widget.onToggle!(_isExpanded);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          widget.decoration ??
          BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).cardColor,
          ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: _handleTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: widget.headerPadding ?? const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(child: widget.title),
                  SizedBox(width: 8),
                  RotationTransition(
                    turns: _iconTurns,
                    child: const Icon(Icons.keyboard_arrow_down),
                  ),
                ],
              ),
            ),
          ),
          ClipRect(
            child: SizeTransition(
              sizeFactor: _heightFactor,
              child: Padding(
                padding:
                    widget.contentPadding ??
                    const EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      bottom: 16.0,
                    ),
                child: widget.content,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
