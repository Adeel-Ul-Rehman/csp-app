import 'package:flutter/material.dart';


class PerformanceOptimizer {
  // ============================================================
  // 1. IMAGE OPTIMIZATION
  // ============================================================
  static ImageProvider optimizeImage(String path, {int? width, int? height}) {
    return NetworkImage(
      path,
      scale: 1.0,
      headers: {
        'Cache-Control': 'max-age=604800', // 7 days cache
      },
    );
  }

  // ============================================================
  // 2. WIDGET OPTIMIZATION
  // ============================================================

  // Use const constructors where possible
  static const Widget emptySizedBox = SizedBox.shrink();

  // Use RepaintBoundary for complex widgets
  static Widget wrapWithRepaintBoundary(Widget child) {
    return RepaintBoundary(
      child: child,
    );
  }

  // Use AutomaticKeepAlive for tabs
  static Widget wrapWithKeepAlive(Widget child) {
    return AutomaticKeepAlive(
      child: child,
    );
  }

  // ============================================================
  // 3. LISTVIEW OPTIMIZATION
  // ============================================================
  static Widget optimizedListView({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    double? itemExtent,
    ScrollController? controller,
    EdgeInsets? padding,
    bool shrinkWrap = false,
  }) {
    return ListView.builder(
      controller: controller,
      padding: padding ?? const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      shrinkWrap: shrinkWrap,
      cacheExtent: 500, // Preload more items for smooth scrolling
      semanticChildCount: itemCount,
      addAutomaticKeepAlives: true,
      addRepaintBoundaries: true,
      addSemanticIndexes: true,
    );
  }

  // ============================================================
  // 4. LAZY LOADING
  // ============================================================
  static Widget lazyLoadingWidget({
    required Widget child,
    required bool shouldLoad,
    Widget? loadingWidget,
  }) {
    return shouldLoad
        ? child
        : loadingWidget ??
            const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A73E8)),
              ),
            );
  }

  // ============================================================
  // 5. MEMORY MANAGEMENT
  // ============================================================
  static void clearMemory() {
    // Clear image cache
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    // Force garbage collection (hint to Dart VM)
    // Note: This is just a hint, not guaranteed
    debugPrint('🧹 Memory cleared');
  }

  // ============================================================
  // 6. BUILD OPTIMIZATION
  // ============================================================
  static Widget optimizedBuild({
    required Widget child,
    bool useRepaintBoundary = true,
    bool useSemantics = true,
  }) {
    Widget result = child;

    if (useRepaintBoundary) {
      result = RepaintBoundary(child: result);
    }

    if (!useSemantics) {
      result = ExcludeSemantics(
        excluding: true,
        child: result,
      );
    }

    return result;
  }

  // ============================================================
  // 7. TEXT OPTIMIZATION
  // ============================================================
  static TextStyle optimizedTextStyle({
    required TextStyle style,
    bool useNativeFont = true,
  }) {
    if (useNativeFont) {
      return style.merge(const TextStyle(
        fontFamilyFallback: ['Roboto', 'Arial', 'sans-serif'],
      ));
    }
    return style;
  }
}
