import 'package:lumina/colors/extension/extension_theme.dart';
import 'package:flutter/material.dart';

import '../coloors.dart';

showLoadingDialog({
  required BuildContext context,
  required String message,
  bool barrierDismissible = true,
}) async {
  return await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const CircularProgressIndicator(
                  color: Coolors.blueDark,
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 15,
                      color: context.theme.greyColor,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      );
    },
  );
}
