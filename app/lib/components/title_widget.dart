import 'package:flutter/material.dart';

class TitleWidget extends StatelessWidget {
  final String title;

  const TitleWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Text(
        title,
        overflow: TextOverflow.ellipsis,
        style: TextTheme.of(context).bodyMedium,
      ),
    );
  }
}
