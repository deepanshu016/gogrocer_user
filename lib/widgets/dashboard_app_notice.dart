import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:user/models/businessLayer/global.dart' as global;

class DashboardAppNotice extends StatefulWidget {
  const DashboardAppNotice({super.key});

  @override
  State<DashboardAppNotice> createState() => _DashboardAppNoticeState();
}

class _DashboardAppNoticeState extends State<DashboardAppNotice> {
  @override
  Widget build(BuildContext context) {
    final shouldShowAppNotice = global.appNotice != null &&
        global.appNotice?.status == 1 &&
        global.appNotice?.notice != null &&
        (global.appNotice?.notice?.isNotEmpty ?? false);

    if (shouldShowAppNotice) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: 24,
        color: Colors.blueAccent,
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.only(
              left: 8, right: 8, top: 2, bottom: 4),
          child: global.languageCode == 'en'
              ? Marquee(
            key: const Key('1'),
            textDirection: TextDirection.ltr,
            text: '${global.appNotice?.notice}',
            style: const TextStyle(color: Colors.white),
          )
              : Directionality(
            textDirection: TextDirection.ltr,
            child: Marquee(
              key: const Key('2'),
              text: '${global.appNotice?.notice},',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }
    return const SizedBox();
  }
}
