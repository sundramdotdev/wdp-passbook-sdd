/// Responsive Layout Breakpoints for WDP Passbook.
/// Supported devices:
/// - Mobile: < 600px
/// - Tablet: 600px - 1023px
/// - Desktop: >= 1024px
class AppBreakpoints {
  static const double mobileMax = 599.0;
  static const double tabletMin = 600.0;
  static const double tabletMax = 1023.0;
  static const double desktopMin = 1024.0;

  static bool isMobile(double width) => width < tabletMin;
  static bool isTablet(double width) => width >= tabletMin && width < desktopMin;
  static bool isDesktop(double width) => width >= desktopMin;
}
