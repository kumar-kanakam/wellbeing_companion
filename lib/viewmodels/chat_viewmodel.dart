import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';
import 'package:deepgram_speech_to_text/deepgram_speech_to_text.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';

import '../core/constants/app_strings.dart';
import '../models/chat_state.dart';

final chatProvider = StateNotifierProvider<ChatViewModel, ChatState>((ref) => ChatViewModel());

class ChatViewModel extends StateNotifier<ChatState> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final String _dgApiKey = "0c80c38808827e6a5cd30646b978cbe48c933e5e";
  bool _isBrainActive = false;
  ChatViewModel() : super(ChatState(text: AppStrings.initialText)) {
    _initOldWakeWord();
  }

  // --- 1. RESTORED PREVIOUS WAKE WORD LOGIC ---
  int _sttRetryCount = 0; // Prevent infinite error loops
  // Class variables lo add cheyandi
DeepgramLiveListener? _liveListener;
Future<void> _initOldWakeWord() async {
  bool available = await _speech.initialize(
    // Inside _initOldWakeWord
onStatus: (status) {
  print('STT Status: $status | Brain Active: $_isBrainActive');
  
  // If we just woke up the brain, IGNORE all incoming status changes from STT
  if (_isBrainActive) return; 

  if (status == 'done' || status == 'notListening') {
    if (state.isListening && !state.isSpeaking) {
      Future.delayed(const Duration(milliseconds: 800), () {
        _startListeningForWakeWord();
      });
    }
  }
},
    onError: (e) {
      print('STT Error: ${e.errorMsg}');
      if (e.errorMsg == 'error_client') {
        _sttRetryCount++;
        // If it fails too many times, wait longer
        if (_sttRetryCount > 3) {
          _speech.stop();
          Future.delayed(const Duration(seconds: 2), () => _initOldWakeWord());
        }
      }
    },
  );

  if (available) {
    _sttRetryCount = 0;
    state = state.copyWith(isListening: true, text: "Say 'Hey App'...");
    _startListeningForWakeWord();
  }
}


void _startListeningForWakeWord() {
  if (_speech.isListening) return;

  _speech.listen(
    onResult: (result) {
      String recognizedText = result.recognizedWords.toLowerCase();
      print("Heard: $recognizedText");

      // Logic updated to trigger on both 'hey app' and 'hello app'
      if (recognizedText.contains("hey app") || recognizedText.contains("hello app")) {
        _handleWakeWordDetected();
      }
    },
    listenMode: stt.ListenMode.dictation,
    cancelOnError: true,
    partialResults: true,
  );
}

  void _handleWakeWordDetected() async {
  _isBrainActive = true; // VENTANE LOCK CHEYALI
  print("Waking up the Brain... (Mic Locked)");
  
  await _speech.cancel(); // cancel() is more aggressive than stop()
  
  // Mic resources fully release avvadaniki wait cheyandi
  await Future.delayed(const Duration(milliseconds: 1000)); 
  
  _initDeepgram(); 
}
  // --- 2. DEEPGRAM LISTENING (FIXED INTERRUPTIONS) ---
  void _initDeepgram() async {
  state = state.copyWith(text: "I'm listening...", isListening: true);
  
  final deepgram = Deepgram(_dgApiKey);
  
  // Audio configuration ni spastam ga specify cheyali
  const recordConfig = RecordConfig(
    encoder: AudioEncoder.pcm16bits,
    sampleRate: 16000,
    numChannels: 1,
  );

  final micStream = await _recorder.startStream(recordConfig);

  _liveListener = deepgram.listen.liveListener(
  micStream, 
  queryParams: {
    'model': 'nova-2',
    'smart_format': true,
    'endpointing': 500,
    'encoding': 'linear16', // IDHI MISS AVVAKUDADHU
    'sample_rate': 16000,
  }
);

  _liveListener?.stream.listen((res) {
  final transcript = res.transcript;
  if (transcript != null && transcript.trim().isNotEmpty) {
    state = state.copyWith(text: transcript);
    print("Deepgram transcript: $transcript");

    // Check if Deepgram has finalized the sentence
    if (res.map['is_final'] == true || res.map['speech_final'] == true) {
      print("Final Sentence Detected: $transcript");
      _recorder.stop(); 
      processCommand(transcript);
    }
  }
}, onError: (err) {
    print("Deepgram Stream Error: $err");
    _initOldWakeWord(); // Error vasthe thirigi passive mode ki vellipovali
  });

  _liveListener?.start();
}

  // --- 3. BACKEND & ELEVENLABS ---
  Future<void> processCommand(String command) async {
  state = state.copyWith(text: "Thinking...", isSpeaking: false);
  
  try {
    final url = "http://192.168.108.145:8000/chat?user_msg=${Uri.encodeComponent(command)}&persona=${state.selectedPersona}";
    final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final String aiReply = data['reply'] ?? "No response";
      final String audioBase64 = data['audio'] ?? "";

      state = state.copyWith(text: aiReply);

      if (audioBase64.isNotEmpty) {
        state = state.copyWith(isSpeaking: true);
        final Uint8List audioBytes = base64Decode(audioBase64);
        await _audioPlayer.play(BytesSource(audioBytes));

        // Audio ayipoyaka matrame lock release cheyali
        await _audioPlayer.onPlayerComplete.first;
      } else {
        // Voice rakapothe text chudadaniki 4s gap ivvandi
        await Future.delayed(const Duration(seconds: 4));
      }
    }
  } catch (e) {
    print("Error: $e");
    state = state.copyWith(text: "I'm having trouble connecting.");
  } finally {
    // KACHITANGA RESET: Door open for 'Hey App'
    _isBrainActive = false; 
    state = state.copyWith(isSpeaking: false, isListening: true);
    Future.delayed(const Duration(milliseconds: 500), () {
      _initOldWakeWord(); 
    });
  }
}

  Future<void> updatePersona(String newPersona) async {
    state = state.copyWith(selectedPersona: newPersona);
  }
}