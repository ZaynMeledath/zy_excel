import 'package:flutter/material.dart' show Size, MediaQuery, BuildContext;

Size realScreenSize = const Size(0, 0);
Size screenSize = const Size(0, 0);

double deviceBottomPadding = 0;
double customBottomPadding = 0;

bool isTablet = false;

void getInitialScreenSize({required BuildContext context}) {
  screenSize = MediaQuery.sizeOf(context);
  final padding = MediaQuery.paddingOf(context);
  final topPadding = padding.top;
  deviceBottomPadding = padding.bottom;
  customBottomPadding = deviceBottomPadding + 4;
  final safeArea = topPadding + deviceBottomPadding;
  realScreenSize = screenSize;
  screenSize = Size(screenSize.width, screenSize.height - safeArea);
}
