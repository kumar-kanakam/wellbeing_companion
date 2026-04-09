import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../core/constants/app_colors.dart';

class VoiceVisualizer extends StatelessWidget {
  final bool isListening;
  final bool isSpeaking; // Add this for speaking state
  const VoiceVisualizer({super.key, this.isListening = false, this.isSpeaking = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isListening) 
          FadeInUp(
            duration: const Duration(milliseconds: 500),
            child: Text("I'm Listening...", 
              style: TextStyle(color: AppColors.primary, fontSize: 12.sp, fontWeight: FontWeight.bold)),
          ),
        // logic lo isListening thoti paatu isSpeaking kuda add cheyandi
if (isSpeaking) 
  Pulse(
    infinite: true,
    child: Icon(Icons.volume_up, color: AppColors.primary, size: 40.sp),
  ),
        SizedBox(height: 10.h),
        Stack(
          alignment: Alignment.center,
          children: [
            if (isListening)
              Pulse(
                infinite: true,
                child: Container(
                  width: 100.r,
                  height: 100.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.15),
                  ),
                ),
              ),
            Container(
              width: 75.r,
              height: 75.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 25,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Icon(Icons.mic_rounded, color: Colors.black, size: 35.sp),
            ),
          ],
        ),
      ],
    );
  }
}