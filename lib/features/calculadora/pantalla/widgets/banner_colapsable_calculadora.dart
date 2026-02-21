import 'package:flutter/material.dart';

class BannerColapsableCalculadora extends SliverPersistentHeaderDelegate {
  BannerColapsableCalculadora({required this.topInset, required this.subtitle});

  final double topInset;
  final String subtitle;

  static const double _h1 = 56.0;
  static const double _h2 = 40.0;

  static const c1 = Color(0xFF005B7F);
  static const c2 = Color(0xFF004966);

  @override
  double get minExtent => topInset + _h2;

  @override
  double get maxExtent => topInset + _h1 + _h2;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final range = maxExtent - minExtent;
    final t = (maxExtent - shrinkOffset - minExtent) / range;
    final vis = t.clamp(0.0, 1.0);

    final smallT = 1.0 - vis;
    final smallOpacity = Curves.easeIn.transform(smallT);

    return Material(
      elevation: overlapsContent ? 4 : 0,
      child: Column(
        children: [
          SizedBox(
            height: _h1 * vis,
            child: Opacity(
              opacity: Curves.easeOut.transform(vis),
              child: Transform.translate(
                offset: Offset(0, (1 - vis) * -8),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(top: topInset).add(
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  color: c1,
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '¿Puedo Cursar?',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            color: c2,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Opacity(
              opacity: smallOpacity,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant BannerColapsableCalculadora old) =>
      old.topInset != topInset || old.subtitle != subtitle;
}