import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DocA4Page extends StatelessWidget {
  const DocA4Page({
    super.key,
    required this.width,
    required this.pageNumber,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final double width;
  final int pageNumber;
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final pageMinHeight = width * 1.414;

    return Container(
      constraints: BoxConstraints(maxWidth: width, minHeight: pageMinHeight),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFDFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD4DCE8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x260A1222),
            blurRadius: 30,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -46,
            top: -46,
            child: _SoftCircle(
              size: 150,
              color: Color(0x143A86D9),
            ),
          ),
          const Positioned(
            left: -22,
            bottom: -28,
            child: _SoftCircle(
              size: 100,
              color: Color(0x10218CC8),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'PÁGINA $pageNumber',
                      style: GoogleFonts.manrope(
                        color: const Color(0xFF5B6E8E),
                        fontSize: 11,
                        letterSpacing: 0.45,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFCFE0F6)),
                        color: const Color(0xFFEFF6FF),
                      ),
                      child: Text(
                        '$pageNumber',
                        style: GoogleFonts.oswald(
                          fontSize: 19,
                          height: 1,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1B5FA8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                EncabezadoDocumento(title: title, subtitle: subtitle),
                const SizedBox(height: 12),
                for (var i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i != children.length - 1) const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EncabezadoDocumento extends StatelessWidget {
  const EncabezadoDocumento({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0E3B7A),
              Color(0xFF1B69B7),
              Color(0xFF2C8FC8),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 6, color: const Color(0x66FFFFFF)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.oswald(
                      color: Colors.white,
                      fontSize: 31,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.55,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: GoogleFonts.manrope(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 4, color: const Color(0x9960D1F0)),
          ],
        ),
      ),
    );
  }
}

class DocTagRow extends StatelessWidget {
  const DocTagRow({super.key, required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F7FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD9E4F4)),
      ),
      child: Wrap(
        spacing: 7,
        runSpacing: 7,
        children: [
          for (final tag in tags)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFE0E7F2)),
              ),
              child: Text(
                tag,
                style: GoogleFonts.manrope(
                  color: const Color(0xFF23426D),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DocLiteralBlock extends StatelessWidget {
  const DocLiteralBlock({
    super.key,
    required this.heading,
    required this.paragraphs,
    this.accent = const Color(0xFF1F6BB8),
  });

  final String heading;
  final List<String> paragraphs;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFE0E7F1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 5,
                height: 20,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  heading,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    height: 1.1,
                    color: const Color(0xFF1A2A45),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          for (var i = 0; i < paragraphs.length; i++) ...[
            Text(
              paragraphs[i],
              style: GoogleFonts.manrope(
                fontSize: 12.4,
                height: 1.45,
                color: const Color(0xFF3B4C67),
                fontWeight: FontWeight.w600,
              ),
            ),
            if (i != paragraphs.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _SoftCircle extends StatelessWidget {
  const _SoftCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
