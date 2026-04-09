class ChatState {
  final String text;
  final bool isListening;
  final bool isSpeaking;
  final String selectedPersona;

  ChatState({
    required this.text,
    this.isListening = false,
    this.isSpeaking = false,
    this.selectedPersona = "Mentor", // Default persona
  });

  // Data update cheyadaniki copyWith method
  ChatState copyWith({String? text, bool? isListening, bool? isSpeaking, String? selectedPersona}) {
    return ChatState(
      text: text ?? this.text,
      isListening: isListening ?? this.isListening,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      selectedPersona: selectedPersona ?? this.selectedPersona,
    );
  }
}