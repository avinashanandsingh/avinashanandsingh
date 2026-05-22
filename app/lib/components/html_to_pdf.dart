import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_native_html_to_pdf/flutter_native_html_to_pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_filex/open_filex.dart';

class HtmlToPdf extends StatefulWidget {
  final String htmlContent;
  final String documentName;
  final Widget? child;
  final ButtonStyle? buttonStyle;
  final VoidCallback? onSuccess;
  final Function(dynamic)? onError;
  final bool isPrint;

  const HtmlToPdf({
    super.key,
    required this.htmlContent,
    this.documentName = 'document',
    this.child,
    this.buttonStyle,
    this.onSuccess,
    this.onError,
    this.isPrint = false,
  });

  @override
  State<HtmlToPdf> createState() => HtmlToPdfState();
}

class HtmlToPdfState extends State<HtmlToPdf> {
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
        if (widget.isPrint) {
          await Printing.layoutPdf(
            onLayout: (format) async => pdfFile.readAsBytes(),
            name: widget.documentName,
          );
          if (widget.onSuccess != null) {
            widget.onSuccess!();
          }
        } else if (widget.onSuccess != null) {
          widget.onSuccess!();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('PDF Generated Successfully!'),
              action: SnackBarAction(
                label: 'Open',
                onPressed: () async {
                  print(pdfFile.path);
                  //final uri = Uri.file(pdfFile.path);
                  //if (await canLaunchUrl(uri)) {
                  //await launchUrl(uri);
                  //}
                  final result = await OpenFilex.open(pdfFile.path);
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
          : (widget.child ?? Text(widget.isPrint ? 'Print' : 'Download')),
    );
  }
}
