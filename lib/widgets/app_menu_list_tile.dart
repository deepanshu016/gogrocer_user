import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppMenuListTile extends StatefulWidget {
  final Function()? onPressed;
  final String? label;
  final String? leadingIconUrl;
  final IconData? icon;

  const AppMenuListTile({super.key, required this.label, this.leadingIconUrl, required this.onPressed, this.icon});

  @override
  State<AppMenuListTile> createState() => _AppMenuListTileState();
}

class _AppMenuListTileState extends State<AppMenuListTile> {

  _AppMenuListTileState();

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest),
      onPressed: () => widget.onPressed!(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.icon != null
                ? Icon(
              widget.icon,
                    size: 28,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : SvgPicture.asset(
              widget.leadingIconUrl!,
                    height: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            const SizedBox(width: 16),
            Text(
              widget.label!,
              style: textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
            )
          ],
        ),
      ),
    );
  }
}
