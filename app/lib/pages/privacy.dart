import 'package:app/components/layout.dart';
import 'package:app/models/page.dart';
import 'package:app/services/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class Privacy extends StatelessWidget {
  const Privacy({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Privacy Policy'),
          titleTextStyle: TextTheme.of(context).headlineMedium,
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: FutureBuilder(
            future: Service.page.get('PRIVACY_POLICY'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              } else if (snapshot.hasData) {
                PageData me = snapshot.data!;
                return HtmlWidget(
                  me.body,
                  textStyle: const TextStyle(fontSize: 16, height: 1.6),
                );
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }
}
