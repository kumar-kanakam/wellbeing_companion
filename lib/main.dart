import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:wellbeing_companion/views/wellbeing_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      child: ScreenUtilInit(
        designSize: const Size(360, 690), // Standard Mobile Size
        minTextAdapt: true,
        builder: (_, child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          home: WellBeingScreen(),
        ),
      ),
    ),
  );
}
