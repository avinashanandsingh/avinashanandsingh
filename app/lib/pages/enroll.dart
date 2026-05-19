import 'package:app/models/course.dart';
import 'package:app/pages/qna_form.dart';
import 'package:app/services/service.dart';
import 'package:flutter/material.dart';

class Enroll extends StatefulWidget {
  final CourseData course;
  const Enroll({super.key, required this.course});

  @override
  State<Enroll> createState() => EnrollState();
}

class EnrollState extends State<Enroll> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Enrolment - QnA'),
          centerTitle: false,
          titleTextStyle: TextTheme.of(context).headlineMedium,
        ),
        body: SingleChildScrollView(
          child: FutureBuilder(
            future: Service.qna.list(widget.course.id!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              } else if (snapshot.hasData) {
                return QnaForm(data: snapshot.data!, course: widget.course);
              } else {
                return Container();
              }
            },
          ),
        ),
      ),
    );
  }
}
