import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class DateTimeSelector extends StatefulWidget {
  final String? heading;
  final DateTime? selectedDate;
  final Function? onPressed;

  const DateTimeSelector({super.key, this.heading, this.selectedDate, this.onPressed});

  @override
  State<DateTimeSelector> createState() => _DateTimeSelectorState();
}

class _DateTimeSelectorState extends State<DateTimeSelector> {

  _DateTimeSelectorState();

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      height: 80,
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.heading!,
              style: textTheme.bodySmall,
            ),
            const Spacer(),
            SizedBox(
              height: 40,
              child: Row(
                children: [
                  Text(
                    widget.selectedDate != null ? DateFormat('EE, dd MMM').format(widget.selectedDate!).toString() : AppLocalizations.of(context)!.lbl_select_date,
                    style: textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Center(
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
