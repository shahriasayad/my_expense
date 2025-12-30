import 'package:flutter/material.dart';
import 'responsive_layout.dart';

/// Responsive UI Components and Builders
class ResponsiveWidgets {
  /// Build a responsive container that scales based on screen size
  static Widget responsiveContainer({
    required BuildContext context,
    required Widget child,
    EdgeInsets? padding,
    Color? backgroundColor,
    BorderRadius? borderRadius,
  }) {
    return Container(
      width: ResponsiveLayout.getContainerWidth(context),
      padding:
          padding ??
          EdgeInsets.all(
            ResponsiveLayout.getResponsiveHorizontalPadding(context),
          ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  /// Build responsive card with adaptive padding
  static Widget responsiveCard({
    required BuildContext context,
    required Widget child,
    EdgeInsets? padding,
    double? elevation,
    Color? shadowColor,
  }) {
    return Card(
      elevation: elevation ?? 2,
      shadowColor: shadowColor,
      child: Padding(
        padding:
            padding ??
            EdgeInsets.all(
              ResponsiveLayout.getResponsiveHorizontalPadding(context),
            ),
        child: child,
      ),
    );
  }

  /// Build responsive grid view
  static Widget responsiveGridView({
    required BuildContext context,
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    ScrollPhysics? physics,
    bool shrinkWrap = true,
  }) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveLayout.getCardGridColumns(context),
        crossAxisSpacing: ResponsiveLayout.getResponsiveGap(context),
        mainAxisSpacing: ResponsiveLayout.getResponsiveGap(context),
      ),
      itemCount: itemCount,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      shrinkWrap: shrinkWrap,
      itemBuilder: itemBuilder,
    );
  }

  /// Build responsive button
  static Widget responsiveButton({
    required BuildContext context,
    required VoidCallback onPressed,
    required String label,
    IconData? icon,
    bool isFullWidth = true,
  }) {
    final button = icon != null
        ? ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(label),
          )
        : ElevatedButton(onPressed: onPressed, child: Text(label));

    return isFullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }

  /// Build responsive spacing
  static SizedBox responsiveSpacing({
    required BuildContext context,
    bool horizontal = false,
  }) {
    final size = ResponsiveLayout.getResponsiveGap(context);
    return horizontal ? SizedBox(width: size) : SizedBox(height: size);
  }

  /// Build responsive padding wrapper
  static Widget responsivePadding({
    required BuildContext context,
    required Widget child,
    bool horizontal = true,
    bool vertical = true,
  }) {
    final hPadding = horizontal
        ? ResponsiveLayout.getResponsiveHorizontalPadding(context)
        : 0.0;
    final vPadding = vertical
        ? ResponsiveLayout.getResponsiveVerticalPadding(context)
        : 0.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
      child: child,
    );
  }

  /// Build responsive list view
  static Widget responsiveListView({
    required BuildContext context,
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    bool shrinkWrap = false,
  }) {
    return ListView.separated(
      itemCount: itemCount,
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap
          ? const NeverScrollableScrollPhysics()
          : const AlwaysScrollableScrollPhysics(),
      separatorBuilder: (context, index) =>
          ResponsiveWidgets.responsiveSpacing(context: context),
      itemBuilder: itemBuilder,
    );
  }

  /// Build responsive text with adaptive font size
  static Text responsiveText(
    String text, {
    required BuildContext context,
    TextStyle? baseStyle,
    double mobileFontSize = 14,
    double? tabletFontSize,
    double? desktopFontSize,
    TextAlign textAlign = TextAlign.start,
  }) {
    final fontSize = ResponsiveLayout.getResponsiveFontSize(
      context,
      mobileSize: mobileFontSize,
      tabletSize: tabletFontSize,
      desktopSize: desktopFontSize,
    );

    return Text(
      text,
      style: (baseStyle ?? const TextStyle()).copyWith(fontSize: fontSize),
      textAlign: textAlign,
    );
  }

  /// Build responsive heading
  static Text responsiveHeading(
    String text, {
    required BuildContext context,
    FontWeight fontWeight = FontWeight.bold,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontSize: ResponsiveLayout.getResponsiveFontSize(
          context,
          mobileSize: 20,
          tabletSize: 24,
          desktopSize: 28,
        ),
        fontWeight: fontWeight,
      ),
    );
  }

  /// Build responsive subheading
  static Text responsiveSubheading(
    String text, {
    required BuildContext context,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontSize: ResponsiveLayout.getResponsiveFontSize(
          context,
          mobileSize: 16,
          tabletSize: 18,
          desktopSize: 20,
        ),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// Build responsive flex layout that adapts to screen size
  static Widget responsiveFlex({
    required BuildContext context,
    required List<Widget> children,
    Axis direction = Axis.horizontal,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
  }) {
    if (ResponsiveLayout.isMobile(context) && direction == Axis.horizontal) {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children.asMap().entries.map((entry) {
          return Column(
            children: [
              entry.value,
              if (entry.key < children.length - 1)
                ResponsiveWidgets.responsiveSpacing(context: context),
            ],
          );
        }).toList(),
      );
    }

    return Flex(
      direction: direction,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children.asMap().entries.map((entry) {
        return Expanded(
          child: Row(
            children: [
              Expanded(child: entry.value),
              if (entry.key < children.length - 1)
                ResponsiveWidgets.responsiveSpacing(
                  context: context,
                  horizontal: true,
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Build responsive dialog
  static void showResponsiveDialog({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
  }) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.all(
          ResponsiveLayout.getResponsiveHorizontalPadding(context),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(
              ResponsiveLayout.getResponsiveHorizontalPadding(context),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveLayout.getResponsiveFontSize(
                      context,
                      mobileSize: 18,
                      tabletSize: 20,
                      desktopSize: 22,
                    ),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: ResponsiveLayout.getResponsiveVerticalPadding(
                    context,
                  ),
                ),
                content,
                if (actions != null) ...[
                  SizedBox(
                    height: ResponsiveLayout.getResponsiveVerticalPadding(
                      context,
                    ),
                  ),
                  Wrap(
                    spacing: ResponsiveLayout.getResponsiveGap(context),
                    runSpacing: ResponsiveLayout.getResponsiveGap(context),
                    children: actions,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build responsive bottom sheet
  static void showResponsiveBottomSheet({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = true,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: isScrollControlled,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(
          ResponsiveLayout.getResponsiveHorizontalPadding(context),
        ),
        child: child,
      ),
    );
  }

  /// Build responsive icon
  static Icon responsiveIcon(
    IconData icon, {
    required BuildContext context,
    Color? color,
  }) {
    return Icon(
      icon,
      size: ResponsiveLayout.getResponsiveIconSize(context),
      color: color,
    );
  }
}
