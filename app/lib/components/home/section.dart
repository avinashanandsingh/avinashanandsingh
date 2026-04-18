import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class SectionBuilder<T> extends StatelessWidget {
  final Future<dynamic> future;
  final String title;
  final String? subtitle;
  final Widget Function(List<T> data) onSuccess;
  final Widget Function(Object? error) onError;
  final Widget? loading;

  const SectionBuilder({
    super.key,
    required this.future,
    required this.title,
    this.subtitle,
    required this.onSuccess,
    required this.onError,
    this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      /*  decoration: BoxDecoration(
        color: color ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(spacing),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ), */
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: AppColors.accentGold,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(title, style: Theme.of(context).textTheme.displayMedium),
                ],
              ),
              Row(
                children: [
                  Text(
                    "Explore",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade600,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle!, style: Theme.of(context).textTheme.titleSmall),
          ],
          FutureBuilder<dynamic>(
            future: future,
            builder: (context, snapshot) {
              print(snapshot);
              if (snapshot.hasData) {
                return onSuccess(snapshot.data!);
              } else if (snapshot.hasError) {
                return onError(snapshot.error!);
              } else {
                return loading ?? const CircularProgressIndicator();
              }
            },
          ),
        ],
      ),
    );
  }
}

/* FutureBuilder<dynamic>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return onSuccess(snapshot.data!);
        } else if (snapshot.hasError) {
          return onError(snapshot.error!);
        } else {
          return loading ?? const CircularProgressIndicator();
        }
      },
    ); */
