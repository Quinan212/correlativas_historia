import 'package:flutter/material.dart';

class BannerColapsableMapa extends SliverPersistentHeaderDelegate {
  BannerColapsableMapa({
    required this.topInset,
    this.expandedTitle,
    this.collapsedTitle,
  });

  final double topInset;
  final String? expandedTitle;
  final String? collapsedTitle;

  static const double _h1 = 56.0;
  static const double _h2 = 40.0;
  static const c1 = Color(0xFF005B7F);
  static const c2 = Color(0xFF004966);

  String get _expandedTitleSafe =>
      (expandedTitle == null || expandedTitle!.trim().isEmpty)
          ? 'Mapa de Correlatividades'
          : expandedTitle!;

  String get _collapsedTitleSafe =>
      (collapsedTitle == null || collapsedTitle!.trim().isEmpty)
          ? 'MAPA DE CORRELATIVIDADES'
          : collapsedTitle!;

  @override
  double get minExtent => topInset + _h2;

  @override
  double get maxExtent => topInset + _h1 + _h2;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final range = maxExtent - minExtent;
    final t = (maxExtent - shrinkOffset - minExtent) / range;
    final vis = t.clamp(0.0, 1.0);
    final smallT = 1.0 - vis;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final easedVis = reduceMotion ? vis : Curves.easeOut.transform(vis);
    final easedSmallT =
        reduceMotion ? smallT : Curves.easeOut.transform(smallT);

    return Material(
      color: c2,
      elevation: overlapsContent ? 2 : 0,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      child: Column(
        children: [
          SizedBox(
            height: topInset + (_h1 * vis),
            child: ClipRect(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [c1, c2],
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (easedVis > 0.01)
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 12,
                        child: Opacity(
                          opacity: easedVis,
                          child: Transform.translate(
                            offset:
                                Offset(0, reduceMotion ? 0 : (1 - vis) * 12),
                            child:
                                _ExpandedBannerText(title: _expandedTitleSafe),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: _h2,
            child: Container(
              width: double.infinity,
              color: c2,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.centerLeft,
              child: easedSmallT <= 0.01
                  ? const SizedBox.shrink()
                  : Opacity(
                      opacity: easedSmallT,
                      child: Text(
                        _collapsedTitleSafe,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
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
  bool shouldRebuild(covariant BannerColapsableMapa oldDelegate) {
    return oldDelegate.topInset != topInset ||
        oldDelegate.expandedTitle != expandedTitle ||
        oldDelegate.collapsedTitle != collapsedTitle;
  }
}

class _ExpandedBannerText extends StatelessWidget {
  const _ExpandedBannerText({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
