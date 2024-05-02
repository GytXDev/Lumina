import 'package:flutter/material.dart';
import 'package:lumina/colors/extension/extension_theme.dart';

class CustomListTile extends StatelessWidget {
  const CustomListTile({
    super.key,
    required this.title,
    required this.leading,
    this.subTitle,
    this.trailing,
  });

  final String title;
  final IconData leading;
  final String? subTitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {},
      contentPadding: const EdgeInsets.fromLTRB(25, 10, 10, 10),
      title: Text(title),
      subtitle: subTitle != null
          ? Text(
              subTitle!,
              style: TextStyle(
                color: context.theme.greyColor,
              ),
            )
          : null,
      leading: Icon(leading),
      trailing: trailing,
    );
  }
}
