import 'package:app/components/custom_form_field.dart';
import 'package:app/components/custom_select_field.dart';
import 'package:app/components/label.dart';
import 'package:app/models/qna.dart';
import 'package:app/models/schedule.dart';
import 'package:app/services/service.dart';
import 'package:flutter/material.dart';

class UserQnA {
  final String? questionId;
  List<OptionData>? options;
  String? answer;
  UserQnA({this.questionId, this.options});
}

class QnaForm extends StatefulWidget {
  final List<QnaData> data;
  final String? courseId;

  const QnaForm({super.key, required this.data, this.courseId});

  @override
  State<QnaForm> createState() => QnaFormState();
}

class QnaFormState extends State<QnaForm> {
  List<UserQnA> model = List.empty(growable: true);
  late Future<List<ScheduleData>> scheduleList = Future.value([]);
  @override
  void initState() {
    super.initState();
    if (mounted) {
      scheduleList = Service.schedule.list(widget.courseId!);
    }
    for (var item in widget.data) {
      model.add(UserQnA(questionId: item.id, options: item.options));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Label(text: "Select a Schedule/Batch"),
          CustomSelectField<ScheduleData>(
            options: scheduleList,
            onSelected: (value) {
              print(value?.id!);
            },
          ),
          SizedBox(height: 16),
          for (var item in widget.data) ...[
            Label(text: item.title!),
            if (item.type! == "Open Ended") ...[
              CustomFormField(
                hintText: 'Write your answer here',
                type: FieldType.multiline,
                onChanged: (value) {
                  model.where((q) => q.questionId == item.id).first.answer =
                      value;
                },
              ),
            ],
            if (item.type! == "Single Choice") ...[
              RadioGroup<String>(
                groupValue: model
                    .where((q) => q.questionId == item.id)
                    .first
                    .answer,
                onChanged: (String? value) {
                  setState(() {
                    model.where((q) => q.questionId == item.id).first.answer =
                        value!;
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
                      .where((q) => q.questionId == item.id)
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
                              .where((q) => q.questionId == item.id)
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
            onPressed: () {
              print('clicked');
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
