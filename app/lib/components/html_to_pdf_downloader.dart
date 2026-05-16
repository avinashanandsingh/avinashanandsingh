import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_native_html_to_pdf/flutter_native_html_to_pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HtmlToPdfDownloader extends StatefulWidget {
  final String htmlContent;
  final String documentName;
  final Widget? child;
  final ButtonStyle? buttonStyle;
  final VoidCallback? onSuccess;
  final Function(dynamic)? onError;

  const HtmlToPdfDownloader({
    super.key,
    required this.htmlContent,
    this.documentName = 'document',
    this.child,
    this.buttonStyle,
    this.onSuccess,
    this.onError,
  });

  @override
  State<HtmlToPdfDownloader> createState() => _HtmlToPdfDownloaderState();
}

class _HtmlToPdfDownloaderState extends State<HtmlToPdfDownloader> {
  bool _isGenerating = false;
  final _converter = HtmlToPdfConverter();

  Future<void> _generateAndDownloadPdf() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();

      final pdfFile = await _converter.convertHtmlToPdf(
        html: widget.htmlContent,
        targetDirectory: appDocDir.path,
        targetName: widget.documentName,
      );

      if (mounted) {
        if (widget.onSuccess != null) {
          widget.onSuccess!();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('PDF Generated Successfully!'),
              action: SnackBarAction(
                label: 'Open',
                onPressed: () async {
                  final uri = Uri.file(pdfFile.path);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        if (widget.onError != null) {
          widget.onError!(e);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to generate PDF: $e')));
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: widget.buttonStyle,
      onPressed: _isGenerating ? null : _generateAndDownloadPdf,
      child: _isGenerating
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : (widget.child ?? const Text('Download PDF')),
    );
  }
}
