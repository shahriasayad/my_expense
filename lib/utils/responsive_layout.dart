import 'package:flutter/material.dart';

/// Responsive design utilities for the My Expense app
/// Provides breakpoints and helper methods for responsive layouts
class ResponsiveLayout {
  // Breakpoints for different screen sizes
  static const double mobileBreakpoint = 480;
  static const double tabletBreakpoint = 768;
  static const double desktopBreakpoint = 1024;
  static const double largeDesktopBreakpoint = 1440;

  /// Check if device is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < tabletBreakpoint;
  }

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tabletBreakpoint && width < desktopBreakpoint;
  }

  /// Check if device is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < tabletBreakpoint) {
      return const EdgeInsets.all(12);
    } else if (width < desktopBreakpoint) {
      return const EdgeInsets.all(20);
    } else {
      return const EdgeInsets.all(32);
    }
  }

  /// Get responsive horizontal padding
  static double getResponsiveHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < tabletBreakpoint) {
      return 12;
    } else if (width < desktopBreakpoint) {
      return 20;
    } else {
      return 32;
    }
  }

  /// Get responsive vertical padding
  static double getResponsiveVerticalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < tabletBreakpoint) {
      return 12;
    } else if (width < desktopBreakpoint) {
      return 16;
    } else {
      return 24;
    }
  }

  /// Get responsive font size
  static double getResponsiveFontSize(
    BuildContext context, {
    required double mobileSize,
    double? tabletSize,
    double? desktopSize,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width < tabletBreakpoint) {
      return mobileSize;
    } else if (width < desktopBreakpoint) {
      return tabletSize ?? mobileSize + 2;
    } else {
      return desktopSize ?? mobileSize + 4;
    }
  }

  /// Get number of columns for grid based on screen size
  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < tabletBreakpoint) {
      return 1;
    } else if (width < desktopBreakpoint) {
      return 2;
    } else if (width < largeDesktopBreakpoint) {
      return 3;
    } else {
      return 4;
    }
  }

  /// Get number of columns for card grid
  static int getCardGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < tabletBreakpoint) {
      return 2; // Mobile: 2 cards per row
    } else if (width < desktopBreakpoint) {
      return 4; // Tablet: 4 cards per row
    } else {
      return 4; // Desktop: 4 cards per row
    }
  }

  /// Get responsive width for containers
  static double getContainerWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < tabletBreakpoint) {
      return width;
    } else if (width < desktopBreakpoint) {
      return width * 0.95;
    } else {
      return width * 0.85;
    }
  }

  /// Get maximum width for content
  static double getMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < tabletBreakpoint) {
      return width;
    } else if (width < desktopBreakpoint) {
      return 600;
    } else {
      return 1000;
    }
  }

  /// Get responsive gap/spacing
  static double getResponsiveGap(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < tabletBreakpoint) {
      return 8;
    } else if (width < desktopBreakpoint) {
      return 12;
    } else {
      return 16;
    }
  }

  /// Get responsive chart height
  static double getChartHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    if (width < tabletBreakpoint) {
      return height * 0.3;
    } else if (width < desktopBreakpoint) {
      return height * 0.35;
    } else {
      return height * 0.4;
    }
  }

  /// Get responsive icon size
  static double getResponsiveIconSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < tabletBreakpoint) {
      return 20;
    } else if (width < desktopBreakpoint) {
      return 24;
    } else {
      return 28;
    }
  }

  /// Check if should show sidebar
  static bool shouldShowSidebar(BuildContext context) {
    return isDesktop(context);
  }

  /// Get orientation
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Get viewport size
  static Size getViewportSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }
}
