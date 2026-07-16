part of 'lista_materias.dart';

class _BannerAviso extends StatelessWidget {
  const _BannerAviso({
    required this.message,
    required this.isZeus,
  });

  final String message;
  final bool isZeus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isZeus ? 14 : 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFE8F4FD),
        borderRadius: BorderRadius.circular(isZeus ? 16 : 12),
        border: Border.all(
          color: isDark ? const Color(0xFF2B6CB0) : const Color(0xFF90CDF4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: isDark ? const Color(0xFF90CDF4) : const Color(0xFF2B6CB0),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color:
                    isDark ? const Color(0xFFE2E8F0) : const Color(0xFF2D3748),
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
