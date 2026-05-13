import 'package:flutter/material.dart';
import '../theme/theme.dart';

class CustomTabView extends StatelessWidget {
  final TabController controller;
  final List<Widget> tabs;
  final List<Widget> children;
  final double? height;

  const CustomTabView({
    super.key,
    required this.controller,
    required this.tabs,
    required this.children,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            controller: controller,
            isScrollable: true,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            tabs: tabs,
          ),
          SizedBox(
            height: height ?? MediaQuery.of(context).size.height * 1.2,
            child: TabBarView(controller: controller, children: children),
          ),
        ],
      ),
    );
  }
}
