import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class AIVetScreen extends StatefulWidget {
  const AIVetScreen({super.key});

  @override
  State<AIVetScreen> createState() => _AIVetScreenState();
}

class _AIVetScreenState extends State<AIVetScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Added 'isAudio' to track voice notes vs text
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  final FlutterTts _flutterTts = FlutterTts();
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;

  // 🚨 PASTE YOUR REAL API KEY HERE!
  static const String _apiKey = 'AIzaSyCIK0o1AsQhYiQR7tzcCgKstaoSAD6uFxo';

  late final GenerativeModel _model;
  late final ChatSession _chat;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _initAI();
    _initTts();

    // Animation for the recording mic
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  void _initAI() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system(
          "You are FarmMate AI, an expert veterinary and agricultural assistant. "
              "You help farmers diagnose livestock issues, manage breeding, and optimize milk production. "
              "IMPORTANT STRICT RULE: You MUST answer ALL questions strictly in the Urdu language using the Urdu alphabet script. "
              "Use simple, conversational Urdu. Write in short sentences and use commas (،) and full stops (۔) frequently so the text-to-speech engine pauses naturally."
      ),
    );
    _chat = _model.startChat();

    _messages.add({
      'sender': 'ai',
      'text': 'السلام علیکم! میں آپ کا فارم میٹ اے آئی ڈاکٹر ہوں۔ آج میں آپ کے جانوروں کی کیا مدد کر سکتا ہوں؟',
      'isAudio': 'false'
    });
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("ur-PK");
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setPitch(1.1);
  }

  Future<void> _toggleRecording() async {
    await _flutterTts.stop();

    if (_isRecording) {
      final path = await _audioRecorder.stop();
      setState(() => _isRecording = false);

      if (path != null) {
        await _sendAudioMessage(path);
      }
    } else {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        final path = '${dir.path}/voice_note.m4a';

        await _audioRecorder.start(
            const RecordConfig(encoder: AudioEncoder.aacLc),
            path: path
        );

        setState(() => _isRecording = true);
      }
    }
  }

  Future<void> _sendAudioMessage(String audioPath) async {
    setState(() {
      // ✅ Now marks this as an audio message for the UI
      _messages.add({'sender': 'user', 'text': '', 'isAudio': 'true'});
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final audioFile = File(audioPath);
      final audioBytes = await audioFile.readAsBytes();

      final prompt = TextPart("Please listen to this farmer's audio message and reply in Urdu.");
      final audioPart = DataPart('audio/mp4', audioBytes);

      final response = await _chat.sendMessage(Content.multi([prompt, audioPart]));
      final responseText = response.text ?? "معاف کیجئے، مجھے سمجھ نہیں آیا۔";

      if (!mounted) return;

      setState(() {
        _messages.add({'sender': 'ai', 'text': responseText, 'isAudio': 'false'});
        _isLoading = false;
      });
      _scrollToBottom();

      await _flutterTts.speak(responseText);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add({'sender': 'ai', 'text': 'ERROR: $e', 'isAudio': 'false'});
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    await _flutterTts.stop();

    setState(() {
      _messages.add({'sender': 'user', 'text': text, 'isAudio': 'false'});
      _isLoading = true;
    });
    _textController.clear();
    _scrollToBottom();

    try {
      final response = await _chat.sendMessage(Content.text(text));
      final responseText = response.text ?? "معاف کیجئے، مجھے سمجھ نہیں آیا۔";

      if (!mounted) return;

      setState(() {
        _messages.add({'sender': 'ai', 'text': responseText, 'isAudio': 'false'});
        _isLoading = false;
      });
      _scrollToBottom();

      await _flutterTts.speak(responseText);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add({'sender': 'ai', 'text': 'ERROR: $e', 'isAudio': 'false'});
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _flutterTts.stop();
    _audioRecorder.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.smart_toy_rounded, color: Colors.green, size: 24),
                ),
                const SizedBox(width: 10),
                const Text("FarmMate AI", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
          ),

          // Chat Area
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['sender'] == 'user';
                final isAudio = msg['isAudio'] == 'true';
                return _buildChatBubble(msg['text']!, isUser, isAudio);
              },
            ),
          ),

          // Thinking Indicator
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.green, strokeWidth: 2)),
                  const SizedBox(width: 8),
                  Text("سوچ رہا ہے...", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                ],
              ),
            ),

          // Input Bar
          _buildInputBar(),
        ],
      ),
    );
  }

  // ✅ PREMIUM WHATSAPP-STYLE INPUT BAR
  Widget _buildInputBar() {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          // Record Button
          GestureDetector(
            onTap: _toggleRecording,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isRecording ? Colors.redAccent : Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow: _isRecording ? [BoxShadow(color: Colors.redAccent.withOpacity(0.4), blurRadius: 10, spreadRadius: 2)] : [],
              ),
              child: Icon(
                _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                color: _isRecording ? Colors.white : Colors.green,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Text Input OR Recording Status
          Expanded(
            child: _isRecording
                ? Row(
              children: [
                FadeTransition(
                  opacity: _pulseController,
                  child: const Icon(Icons.circle, color: Colors.redAccent, size: 12),
                ),
                const SizedBox(width: 8),
                const Text("آواز ریکارڈ ہو رہی ہے...", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              ],
            )
                : TextField(
              controller: _textController,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 16),
              decoration: const InputDecoration(
                hintText: "یہاں لکھیں...",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),

          // Send Button
          if (!_isRecording)
            Container(
              margin: const EdgeInsets.only(left: 8),
              decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                onPressed: _sendMessage,
              ),
            ),
        ],
      ),
    );
  }

  // ✅ PREMIUM CHAT BUBBLES
  Widget _buildChatBubble(String text, bool isUser, bool isAudio) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? Colors.green : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(24),
            topRight: const Radius.circular(24),
            bottomLeft: isUser ? const Radius.circular(24) : const Radius.circular(4),
            bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(24),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        // If it's an audio message, show a waveform! Otherwise, show text.
        child: isAudio ? _buildAudioWaveform() : Text(
          text,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  // ✅ WHATSAPP-STYLE WAVEFORM UI
  Widget _buildAudioWaveform() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
        const SizedBox(width: 10),
        ...List.generate(7, (index) {
          // Generates a fake audio waveform visual
          final heights = [10.0, 18.0, 24.0, 14.0, 20.0, 12.0, 8.0];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: heights[index],
            width: 3,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.7), borderRadius: BorderRadius.circular(5)),
          );
        }),
        const SizedBox(width: 10),
        const Text("0:00", style: TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}