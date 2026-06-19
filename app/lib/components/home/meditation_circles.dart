import 'package:app/components/home/meditation_item.dart';
import 'package:app/models/meditation.dart';
import 'package:app/services/identity.dart';
import 'package:flutter/material.dart';

class MeditationCircles extends StatelessWidget {
  final List<MeditationData> list;
  const MeditationCircles({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: FutureBuilder(
        future: Identity().isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var item in list)
                  MeditationItem(data: item, isLoggedIn: snapshot.data!),
              ],
            );
            /* return ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),

              //padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: list.length,
              itemBuilder: (context, index) {
                return MeditationItem(
                  data: list[index],
                  isLoggedIn: snapshot.data!,
                );
              },
            );*/
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
