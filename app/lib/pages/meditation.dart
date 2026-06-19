import 'package:app/components/home/meditation_item.dart';
import 'package:app/components/layout.dart';
import 'package:flutter/material.dart';
import 'package:app/models/meditation.dart';
import 'package:app/models/user.dart';
import 'package:app/services/service.dart';
import 'package:app/theme/theme.dart';

class Meditation extends StatefulWidget {
  final bool isLoggedIn;
  const Meditation({super.key, required this.isLoggedIn});
  @override
  State<Meditation> createState() => MeditationState();
}

class MeditationState extends State<Meditation> {
  final ScrollController scroller = ScrollController();
  List<MeditationData> list = List.empty(growable: true);
  late AppTheme theme = AppTheme();
  int page = 1;
  int offset = 0;
  int limit = 5;
  bool isLoading = false;
  bool isLoggedIn = false;
  @override
  void initState() {
    super.initState();
    isLoggedIn = false;
    fetchData(); // Initial load
    scroller.addListener(() {
      // Check if user is at the bottom
      if (scroller.position.pixels >= scroller.position.maxScrollExtent &&
          !isLoading) {
        fetchData();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    // Simulate API call
    var result = await Service.meditation.list({
      "criteria": [
        {"column": "status", "cop": "eq", "value": "ACTIVE"},
      ],
      "offset": offset,
      "limit": limit,
    });
    if (result.isNotEmpty) {
      setState(() {
        list.addAll(result);
        page++;
        offset = (page - 1) * limit;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      titleText: 'Meditations',
      showHeader: true,
      isSerif: false,
      showBottomNav: true,
      showActions: false,
      showBack: true,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: ListView.builder(
          controller: scroller,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length + (isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == list.length) {
              return Center(
                child: CircularProgressIndicator(),
              ); // Bottom loader
            }
            return Padding(
              padding: EdgeInsetsGeometry.all(15),
              child: MeditationItem(
                isLoggedIn: false,
                data: list[index],
                vertical: false,
              ),
            );
          },
        ),
      ),
    );
  }
}
