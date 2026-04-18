import 'package:flutter/material.dart';

class Logo extends StatefulWidget {
  final String imageUrl;
  final double height;
  final Color placeholderColor;

  const Logo({
    super.key,
    required this.imageUrl,
    this.height = 60,
    this.placeholderColor = Colors.white,
  });

  @override
  State<Logo> createState() => LogoState();
}

class LogoState extends State<Logo> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchLogo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        } else if (snapshot.hasError) {
          return _buildErrorWidget();
        } else if (!snapshot.hasData) {
          return _buildErrorWidget();
        }

        return Image.network(
          widget.imageUrl,
          width: 60,
          height: widget.height,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, progress) => child,
          errorBuilder: (context, error, stackTrace) => _placeholder(),
          webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
        );
      },
    );
  }

  Widget _placeholder() {
    return Center(
      child: Icon(
        Icons.image_outlined,
        color: Colors.grey[400],
        size: widget.height * 0.8,
      ),
    );
  }

  Future<String> _fetchLogo() async {
    // Optionally validate or cache the image URL before showing
    return widget.imageUrl;
  }

  Widget _buildLoadingWidget() => const Center(child: SizedBox(height: 20));
  Widget _buildErrorWidget() => Center(
    child: Icon(Icons.broken_image_outlined, color: widget.placeholderColor),
  );
}
