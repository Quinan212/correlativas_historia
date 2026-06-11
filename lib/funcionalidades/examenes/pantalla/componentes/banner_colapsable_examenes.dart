import 'package:flutter/material.dart';

class BannerColapsableExamenes extends SliverPersistentHeaderDelegate {
  BannerColapsableExamenes({
    required this.topInset,
    required this.title,
  });

  final double topInset;
  final String title;

  static const double _h1 = 56.0;
  static const double _h2 = 40.0;
  static const c1 = Color(0xFF005B7F);
  static const c2 = Color(0xFF004966);

  @override
  double get minExtent => topInset + _h2;

  @override
  double get maxExtent => topInset + _h1 + _h2;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final isPhone = MediaQuery.sizeOf(context).width < 600;
    if (isPhone) {
      return _buildPhoneBanner(context, shrinkOffset, overlapsContent);
    }
    return _buildDesktopBanner(context, shrinkOffset, overlapsContent);
  }

  Widget _buildPhoneBanner(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
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
                            child: _ExpandedBannerText(
                              title: title,
                              showSubtitle: false,
                            ),
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
                        'CALENDARIO ACADÉMICO',
                        style: const TextStyle(
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

  Widget _buildDesktopBanner(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
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
      child: Stack(
        children: [
          Column(
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
                                offset: Offset(
                                  0,
                                  reduceMotion ? 0 : (1 - vis) * 12,
                                ),
                                child: _ExpandedBannerText(title: title),
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
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  alignment: Alignment.centerLeft,
                  child: easedSmallT <= 0.01
                      ? const SizedBox.shrink()
                      : Opacity(
                          opacity: easedSmallT,
                          child: Text(
                            title.toUpperCase(),
                            style: const TextStyle(
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
          Positioned(
            top: topInset + 4,
            left: 4,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white70,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'EXÁMENES Y COLOQUIOS',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant BannerColapsableExamenes oldDelegate) {
    return oldDelegate.topInset != topInset || oldDelegate.title != title;
  }
}

class _ExpandedBannerText extends StatelessWidget {
  const _ExpandedBannerText({
    required this.title,
    this.showSubtitle = true,
  });

  final String title;
  final bool showSubtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showSubtitle) ...[
          Text(
            'CALENDARIO ACADÉMICO',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 2),
        ],
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
