import 'package:flutter/material.dart';

ThemeData temaMensajesLaboratorioSage(BuildContext context) {
  final base = Theme.of(context);
  final mobile = MediaQuery.sizeOf(context).width < 900;
  final messageTextStyle =
      base.textTheme.bodyMedium?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ) ??
      const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        height: 1.2,
      );

  return base.copyWith(
    snackBarTheme: base.snackBarTheme.copyWith(
      backgroundColor: const Color(0xFF2A6DEB),
      contentTextStyle: messageTextStyle,
      actionTextColor: Colors.white,
      disabledActionTextColor: const Color(0xFFD9E6FF),
      closeIconColor: Colors.white,
      elevation: 8,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF8DB6FF), width: 1),
      ),
      insetPadding: EdgeInsets.fromLTRB(16, 8, 16, mobile ? 38 : 20),
    ),
  );
}
