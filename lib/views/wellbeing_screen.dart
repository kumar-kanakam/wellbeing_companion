import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:wellbeing_companion/models/chat_state.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_colors.dart';
import '../viewmodels/chat_viewmodel.dart';
import '../widgets/voice_visualizer.dart';

class WellBeingScreen extends ConsumerWidget {
  const WellBeingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. watch ippudu ChatState object ni return chesthundi
    final chatState = ref.watch(chatProvider); 
    
    // 2. Boolean logic updated to use object properties
    final bool isLoading = chatState.text == AppStrings.loadingText;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Gradient Glow
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 200.r,
              height: 200.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.05),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  SizedBox(height: 25.h),
                  _buildTopBar(),
                  SizedBox(height: 15.h), // Chinna gap
                // --- IKKADA USE CHEYANDI ---
                _buildPersonaChips(ref, chatState),
                  const Spacer(),
                  Expanded(
                    child: Center(
                      child: FadeIn(
                        // 3. chatState.text change ayinappudu re-animate avthundi
                        key: ValueKey(chatState.text), 
                        child: _buildMainResponse(chatState.text),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // 4. Passing both listening and speaking states
                  VoiceVisualizer(
                    isListening: chatState.isListening || isLoading,
                    isSpeaking: chatState.isSpeaking, 
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    "Try: \"${AppStrings.wakeWord}, how are you?\"",
                    style: TextStyle(color: AppColors.textGrey, fontSize: 13.sp, letterSpacing: 0.5),
                  ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("AI Companion", style: TextStyle(color: AppColors.primary, fontSize: 12.sp, fontWeight: FontWeight.bold, letterSpacing: 1)),
            Text(AppStrings.appTitle, style: TextStyle(color: AppColors.textWhite, fontSize: 26.sp, fontWeight: FontWeight.w900)),
          ],
        ),
        CircleAvatar(
          backgroundColor: AppColors.cardColor,
          child: Icon(Icons.bolt, color: AppColors.primary, size: 20.sp),
        )
      ],
    );
  }
  Widget _buildPersonaChips(WidgetRef ref, ChatState chatState) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: ['Mentor', 'Peer', 'Coach'].map((persona) {
      // ViewModel lo unna selectedPersona tho match ayithe 'selected' true avthundi
      final bool isSelected = chatState.selectedPersona == persona;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: ChoiceChip(
          label: Text(persona),
          selected: isSelected, 
          onSelected: (bool selected) {
            if (selected) {
              // ViewModel lo persona update cheyamani cheptham
              ref.read(chatProvider.notifier).updatePersona(persona);
            }
          },
          selectedColor: AppColors.primary,
          backgroundColor: AppColors.cardColor,
          // Selected ayithe black text, lekapothe white
          labelStyle: TextStyle(
            color: isSelected ? Colors.black : Colors.white, 
            fontSize: 12.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      );
    }).toList(),
  );
}

  Widget _buildMainResponse(String text) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: AppColors.cardColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(32.r),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textWhite,
          fontSize: 20.sp,
          height: 1.5,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }
}