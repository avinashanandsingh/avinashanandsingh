import 'dart:convert';

import 'package:app/components/custom_form_field.dart';
import 'package:app/components/label.dart';
import 'package:app/components/loader.dart';
import 'package:app/models/enroll.dart';
import 'package:app/models/qna.dart';
import 'package:app/models/schedule.dart';
import 'package:app/pages/home.dart';
import 'package:app/services/service.dart';
import 'package:app/utils/alert.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app/helpers/globals.dart';

class UserQnA {
  final String? id;
  final String? question;
  //final String? type;
  List<OptionData>? options;
  String? answer;
  UserQnA({this.id, this.question, this.options});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'options': options,
    };
  }
}

class QnaForm extends StatefulWidget {
  final List<QnaData> data;
  final String? courseId;
  final String? scheduleId;

  const QnaForm({
    super.key,
    required this.data,
    required this.courseId,
    this.scheduleId,
  });

  @override
  State<QnaForm> createState() => QnaFormState();
}

class QnaFormState extends State<QnaForm> {
  List<UserQnA> model = List.empty(growable: true);
  @override
  void initState() {
    super.initState();

    for (var item in widget.data) {
      model.add(
        UserQnA(
          id: item.id,
          //type: item.type,
          question: item.title,
          options: item.options,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var item in widget.data) ...[
            Label(text: item.title!),
            if (item.type! == "Open Ended") ...[
              CustomFormField(
                hintText: 'Write your answer here',
                type: FieldType.multiline,
                onChanged: (value) {
                  model.where((q) => q.id == item.id).first.answer = value;
                },
              ),
            ],
            if (item.type! == "Single Choice") ...[
              RadioGroup<String>(
                groupValue: model.where((q) => q.id == item.id).first.answer,
                onChanged: (String? value) {
                  setState(() {
                    model.where((q) => q.id == item.id).first.answer = value!;
                  });
                },
                child: Column(
                  children: <Widget>[
                    for (var o in item.options!) ...[
                      RadioListTile<String>(
                        value: o.title!,
                        title: Text(o.title!),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            if (item.type! == "Multiple Choice") ...[
              for (var o in item.options!) ...[
                CheckboxListTile(
                  value: model
                      .where((q) => q.id == item.id)
                      .first
                      .options
                      ?.where((e) => e.id == o.id)
                      .first
                      .isChecked,
                  title: Text(
                    o.title!,
                    style: TextTheme.of(context).labelSmall,
                  ),
                  onChanged: (value) {
                    setState(() {
                      model
                              .where((q) => q.id == item.id)
                              .first
                              .options
                              ?.where((e) => e.id == o.id)
                              .first
                              .isChecked =
                          value;
                    });
                  },
                ),
              ],
            ],
            const SizedBox(height: 16),
          ],
          ElevatedButton(
            onPressed: () async {
              Loader.show();
              EnrollData enrol = EnrollData();
              enrol.courseId = widget.courseId;
              var course = await Service.course.get({
                "criteria": [
                  {"column": "id", "cop": "eq", "value": widget.courseId},
                ],
              });

              ScheduleData? schedule = await Service.schedule.get({
                "criteria": [
                  {"column": "courseid", "cop": "eq", "value": widget.courseId},
                  {
                    "column": "status",
                    "cop": "eq",
                    "lop": "AND",
                    "value": "ACTIVE",
                  },
                ],
              });

              enrol.scheduleId = schedule?.id;
              var today = DateTime.now();
              enrol.enrolledat = DateFormat("yyyy-MM-dd").format(today);
              if ((course?.validity ?? 0) > 0) {
                var exp = today.add(Duration(days: course?.validity ?? 0));
                enrol.expiredat = DateFormat("yyyy-MM-dd").format(exp);
              }
              for (var item in model) {
                item.options?.removeWhere((z) => z.isChecked == false);
              }

              String qnaData = jsonEncode(
                model.map((u) => u.toJson()).toList(),
              );
              enrol.qna = qnaData;

              var result = await Service.course.enroll(enrol);

              Loader.hide();
              if (result['errors'] != null) {
                dynamic error = result!['errors']![0];
                String msg =
                    error?['extensions']?['originalError']?['message'] ??
                    error?['message'];
                Alert.show(msg, isError: true);
              } else {
                navigatorKey.currentState?.push(
                  MaterialPageRoute(builder: (context) => Home()),
                );
              }
            },
            style: ButtonStyle(
              padding: WidgetStatePropertyAll(EdgeInsets.all(8)),
            ),
            child: Text(
              'Submit',
              style: TextTheme.of(
                context,
              ).labelSmall!.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
