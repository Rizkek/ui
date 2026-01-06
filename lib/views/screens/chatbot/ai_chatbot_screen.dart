import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AiChatbotScreen extends StatefulWidget {
  const AiChatbotScreen({super.key});

  @override
  State<AiChatbotScreen> createState() => _AiChatbotScreenState();
}

class _AiChatbotScreenState extends State<AiChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Welcome message
    _messages.add(
      ChatMessage(
        text:
            'Halo! Saya AIra, asisten digital yang siap membantu kamu! Apakah ada yang ingin kamu tanyakan tentang keamanan internet?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
      );
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate AI response
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _messages.add(
          ChatMessage(
            text: _getMockAiResponse(text),
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isTyping = false;
      });
      _scrollToBottom();
    });
  }

  String _getMockAiResponse(String userMessage) {
    final lowerMsg = userMessage.toLowerCase();

    // Greeting
    if (lowerMsg.contains('halo') ||
        lowerMsg.contains('hai') ||
        lowerMsg.contains('hi')) {
      return 'Halo juga! Ada yang bisa saya bantu hari ini? 😊\n\nSaya bisa membantu kamu dengan:\n• Analisis tren deteksi\n• Edukasi risiko konten\n• Saran aktivitas alternatif\n• Mini-counseling CBT';
    }

    // YouTube Detection Analysis
    if (lowerMsg.contains('youtube') && lowerMsg.contains('terdeteksi')) {
      return '📊 **Analisis YouTube**\n\nDari data kamu, YouTube terdeteksi 12x minggu ini, mayoritas Medium Risk. Ini biasanya dari thumbnail video suggestive di recommendation feed.\n\n🧩 **Trigger yang perlu diwaspadai:**\n• Scroll feed tanpa tujuan spesifik\n• Waktu bosan (sore & malam)\n• Setelah stres dari aktivitas lain\n\n✅ **Strategi pencegahan:**\n• Set tujuan spesifik sebelum buka YouTube\n• Gunakan Search langsung, hindari feed\n• Aktifkan Restricted Mode di settings\n\nMau saya bantu set reminder untuk habit baru?';
    }

    // Trend Analysis
    if (lowerMsg.contains('tren') ||
        lowerMsg.contains('statistik') ||
        lowerMsg.contains('data')) {
      return '📈 **Analisis Tren Perilaku**\n\n7 Hari Terakhir:\n• Total deteksi: 45\n• Puncak aktivitas: Malam (20:00-23:00)\n• Aplikasi tersering: Instagram, YouTube\n• Risk level: 60% Low, 30% Medium, 10% High\n\n🎯 **Insight:**\nKamu cenderung terpapar lebih banyak saat lelah atau menjelang tidur. Ini pola umum yang bisa dicegah dengan:\n\n1. Set "digital curfew" jam 22:00\n2. Ganti scrolling dengan aktivitas relaksasi\n3. Gunakan mode fokus saat belajar/kerja\n\nMau saya buatkan action plan?';
    }

    // CBT Counseling
    if (lowerMsg.contains('stres') ||
        lowerMsg.contains('bosan') ||
        lowerMsg.contains('susah')) {
      return '🧠 **Mini-Counseling CBT**\n\nSaya paham kamu sedang merasa tidak nyaman. Mari kita lihat situasinya dengan pendekatan CBT:\n\n**1. Identifikasi Pemicu:**\nApa yang membuatmu merasa seperti ini? (stres, bosan, kesepian, dll)\n\n**2. Pola Pikir:**\nKonten digital sering jadi pelarian sementara, tapi tidak menyelesaikan akar masalah.\n\n**3. Alternatif Sehat:**\n• Physical: Jalan kaki 10 menit\n• Creative: Journaling, gambar\n• Social: Chat teman/keluarga\n• Spiritual: Meditasi, doa\n\nMana yang paling mungkin kamu lakukan sekarang?';
    }

    // Parent Mode
    if (lowerMsg.contains('orang tua') || lowerMsg.contains('parent')) {
      return '👨‍👩‍👧 **Mode Orang Tua**\n\nOrang tua bisa memantau aktivitas digital kamu untuk memastikan keamanan. Fitur yang tersedia:\n\n✓ Dashboard deteksi real-time\n✓ Laporan mingguan\n✓ PIN lock untuk monitoring\n✓ Notifikasi High Risk\n\nIni bukan untuk mengontrol, tapi untuk melindungi dan mendukung pertumbuhan digital yang sehat. Komunikasi terbuka dengan orang tua sangat penting!\n\nAda yang ingin kamu diskusikan tentang ini?';
    }

    // NSFW Education
    if (lowerMsg.contains('nsfw') ||
        lowerMsg.contains('pornografi') ||
        lowerMsg.contains('konten')) {
      return '🛡️ **Edukasi Konten NSFW**\n\nSistem deteksi kami menggunakan AI dengan 3 level:\n\n🟡 **Low Risk**: Borderline, suggestive ringan\n🟠 **Medium**: Semi-pornografi, erotis\n🔴 **High**: Pornografi eksplisit\n\n**Dampak Paparan Berulang:**\n• Mengubah persepsi relasi\n• Menurunkan kontrol impuls\n• Membentuk kebiasaan adiktif\n• Memengaruhi kesehatan mental\n\n**Kenapa Penting Dicegah:**\nOtak remaja masih berkembang, khususnya area decision-making. Paparan dini dapat mengubah pola reward system secara permanen.\n\nIngat: Butuh bantuan bukan berarti lemah. It takes strength to ask for help! 💪';
    }

    // Tips & Strategies
    if (lowerMsg.contains('tips') ||
        lowerMsg.contains('saran') ||
        lowerMsg.contains('cara')) {
      return '💡 **Tips Kontrol Digital**\n\n**Strategi Jangka Pendek:**\n1. 30-Second Rule: Tunggu 30 detik sebelum buka app\n2. Physical Distance: Taruh HP jauh saat belajar\n3. Notification Off: Matikan notif non-esensial\n\n**Strategi Jangka Panjang:**\n1. Build New Habits: Ganti scrolling dengan baca\n2. Accountability Partner: Ajak teman sama-sama\n3. Reward System: Beri hadiah untuk milestone\n\n**Emergency Plan:**\nSaat dorongan kuat muncul:\n→ Segera pindah ruangan\n→ Call trusted person\n→ Buka chatbot ini untuk dukungan\n\nMau fokus ke strategi yang mana?';
    }

    // Safety
    if (lowerMsg.contains('aman')) {
      return 'Paradise selalu menjaga keamanan digital kamu! 🛡️\n\nSistem proteksi aktif 24/7:\n✓ Real-time AI detection\n✓ CBT intervention otomatis\n✓ Activity logging\n✓ Parent notification (jika aktif)\n\nKamu juga bisa:\n• Cek history kapan saja\n• Analisis tren perilaku\n• Dapatkan counseling mini\n\nIngat: Kamu tidak sendirian dalam journey ini! 💙';
    }

    // Thanks
    if (lowerMsg.contains('terima kasih') || lowerMsg.contains('thanks')) {
      return 'Sama-sama! Senang bisa membantu. 🌟\n\nJangan ragu untuk chat kapan saja kamu:\n• Butuh support\n• Ingin analisis data\n• Mau curhat\n• Cari saran aktivitas\n\nI\'m here for you! Stay strong! 💪✨';
    }

    // Default
    return 'Terima kasih atas pertanyaannya! 🤗\n\nSaya di sini untuk membantu kamu dengan:\n• Analisis deteksi & tren\n• Edukasi risiko konten\n• Mini-counseling CBT\n• Saran aktivitas alternatif\n• Support & motivation\n\nCoba tanyakan tentang:\n"Kenapa YouTube sering terdeteksi?"\n"Bagaimana tren deteksi saya?"\n"Tips untuk kontrol digital?"\n\nAda yang ingin kamu bahas?';
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Header Background
          Container(
            height: 160,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4A90E2), Color(0xFF8E2DE2)],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Custom Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: const Icon(
                          Icons.smart_toy_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AIra Assistant',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4ADE80),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF4ADE80,
                                      ).withOpacity(0.5),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Online',
                                style: GoogleFonts.raleway(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Chat Area
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      children: [
                        Expanded(child: _buildMessagesArea()),
                        _buildInputArea(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesArea() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length) {
          return _buildTypingIndicator();
        }
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFE0E7FF),
              child: const Icon(
                Icons.smart_toy_rounded,
                size: 18,
                color: Color(0xFF6366F1),
              ),
            ),
            const SizedBox(width: 12),
          ],

          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: message.isUser
                    ? const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                      )
                    : null,
                color: message.isUser ? null : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(24),
                  topRight: const Radius.circular(24),
                  bottomRight: Radius.circular(message.isUser ? 4 : 24),
                  bottomLeft: Radius.circular(message.isUser ? 24 : 4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: message.isUser
                        ? const Color(0xFF3B82F6).withOpacity(0.3)
                        : Colors.grey.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: GoogleFonts.raleway(
                      color: message.isUser
                          ? Colors.white
                          : const Color(0xFF334155),
                      fontSize: 15,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                    style: GoogleFonts.outfit(
                      color: message.isUser
                          ? Colors.white.withOpacity(0.7)
                          : const Color(0xFF94A3B8),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (message.isUser) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFDBEAFE),
              child: const Icon(
                Icons.person,
                size: 18,
                color: Color(0xFF3B82F6),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFFE0E7FF),
            child: const Icon(
              Icons.smart_toy_rounded,
              size: 18,
              color: Color(0xFF6366F1),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
                bottomRight: Radius.circular(24),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(200),
                const SizedBox(width: 4),
                _buildTypingDot(400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int delay) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(DateTime.now().millisecondsSinceEpoch + delay),
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      onEnd: () {
        if (mounted) setState(() {});
      },
      builder: (context, opacity, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(opacity),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _messageController,
                style: GoogleFonts.outfit(
                  color: const Color(0xFF1E293B),
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'Tanya sesuatu...',
                  hintStyle: GoogleFonts.raleway(
                    color: const Color(0xFF94A3B8),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A90E2), Color(0xFF8E2DE2)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4A90E2).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
