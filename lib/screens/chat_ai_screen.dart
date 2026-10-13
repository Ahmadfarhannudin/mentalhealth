import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';

/// Ruang Cerita AI
/// Tampilan chat yang hangat, tenang, dan profesional.
/// Mengikuti palet alami aplikasi: sage, cream, sand, lavender lembut.
class ChatAiScreen extends StatefulWidget {
  const ChatAiScreen({super.key});

  @override
  State<ChatAiScreen> createState() => _ChatAiScreenState();
}

class _ChatAiScreenState extends State<ChatAiScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'sender': 'ai',
          'text': 'Halo, aku di sini mendampingimu. Ada yang ingin kamu ceritakan hari ini?',
          'time': _formattedTime(),
        });
      });
    });
  }

  String _formattedTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}.${now.minute.toString().padLeft(2, '0')}';
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'sender': 'user',
        'text': text,
        'time': _formattedTime(),
      });
      _controller.clear();
      _isTyping = true;
    });

    _scrollToBottom();

    // Simulasi respons AI (ganti dengan integrasi backend)
    Future.delayed(const Duration(seconds: 1, milliseconds: 200), () {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add({
          'sender': 'ai',
          'text': _generateAiResponse(text),
          'time': _formattedTime(),
        });
      });
      _scrollToBottom();
    });
  }

  String _generateAiResponse(String userText) {
    final lowered = userText.toLowerCase();

    // Deteksi krisis / butuh bantuan darurat
    if (lowered.contains('bunuh diri') ||
        lowered.contains('menyakiti diri') ||
        lowered.contains('mati saja') ||
        lowered.contains('mengakhiri hidup')) {
      return 'Kamu sangat berharga dan kamu tidak sendirian menghadapi ini. Jika kamu merasa kewalahan atau ada dorongan menyakiti diri, mohon segera hubungi layanan dukungan:\n\n• Hotline Kesehatan Jiwa Kemenkes: 119 ext 8\n• Layanan Sejiwa: 119\n• Hubungi teman terdekat atau tenaga profesional medis terdekat.';
    }

    if (lowered.contains('cemas') || lowered.contains('takut') || lowered.contains('khawatir')) {
      return 'Terima kasih sudah berbagi. Rasa cemas itu wajar, dan kamu tidak sendirian. Coba tarik napas perlahan: hirup 4 detik, tahan 4 detik, hembuskan 4 detik. Bagaimana perasaanmu sekarang?';
    }
    if (lowered.contains('sedih') || lowered.contains('nangis') || lowered.contains('kecewa')) {
      return 'Aku turut merasakan apa yang kamu rasakan. Sedih adalah bagian dari proses. Izinkan dirimu merasakannya tanpa perlu buru-buru sembuh. Mau cerita lebih lanjut?';
    }
    if (lowered.contains('lelah') || lowered.contains('capek') || lowered.contains('penat') || lowered.contains('burnout')) {
      return 'Lelah itu tanda bahwa kamu telah berusaha keras. Istirahat bukan berarti menyerah. Kamu pantas mendapatkan waktu untuk memulihkan diri. Sudahkah kamu minum air hangat atau meluruskan punggung sejenak?';
    }
    if (lowered.contains('bahagia') || lowered.contains('senang') || lowered.contains('bangga')) {
      return 'Senang mendengarnya! Rayakan momen kecil ini. Kebahagiaan yang kamu rasakan berharga, dan kamu layak merasakannya. Apa yang paling membuatmu bersyukur hari ini?';
    }
    if (lowered.contains('tidur') || lowered.contains('insomnia') || lowered.contains('begadang')) {
      return 'Pikiran yang ramai sering membuat mata sulit terpejam. Coba redupkan lampu, jauhkan layar ponsel sejenak, dan fokus pada hembusan napas yang panjang.';
    }
    return 'Terima kasih sudah membagikan pikiranmu. Aku mendengarkan. Ceritakan lebih banyak jika kamu merasa nyaman, atau kita bisa lakukan latihan relaksasi bersama.';
  }

  void _confirmClearMessages() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Mulai Obrolan Baru?',
          style: AppText.titleSmall,
        ),
        content: Text(
          'Percakapan saat ini akan dihapus dari layar demi privasimu.',
          style: AppText.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: AppText.labelLarge.copyWith(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.terracotta,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _messages.clear();
              });
              _addWelcomeMessage();
            },
            child: const Text('Hapus & Mulai Ulang'),
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _sendQuickPrompt(String prompt) {
    _controller.text = prompt;
    _sendMessage();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildDisclaimerBanner(),
            Expanded(
              child: _buildMessageList(),
            ),
            if (_messages.length <= 2) _buildQuickPrompts(),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // HEADER
  // =========================================================
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
      decoration: const BoxDecoration(
        color: AppColors.cream,
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.sagePale,
              border: Border.all(color: AppColors.sageLight, width: 1.5),
            ),
            child: const Icon(
              Icons.favorite_border_rounded,
              color: AppColors.sage,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ruang Cerita',
                  style: AppText.titleMedium.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.sage,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'AI siap mendampingi',
                      style: AppText.caption.copyWith(
                        color: AppColors.sageDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _messages.isEmpty ? null : _confirmClearMessages,
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.textMuted,
              size: 22,
            ),
            tooltip: 'Mulai Ulang Percakapan',
          ),
          IconButton(
            onPressed: () => _showInfoDialog(),
            icon: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.textMuted,
              size: 22,
            ),
            tooltip: 'Tentang Ruang Cerita',
          ),
        ],
      ),
    );
  }

  // =========================================================
  // DISCLAIMER BANNER
  // =========================================================
  Widget _buildDisclaimerBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.lavenderPale,
        border: Border(
          bottom: BorderSide(color: AppColors.lavenderLight, width: 1),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.shield_outlined,
            size: 14,
            color: AppColors.lavenderDark,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'AI bukan pengganti konselor atau psikolog profesional.',
              style: AppText.caption.copyWith(
                color: AppColors.lavenderDark,
                fontSize: 11.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // MESSAGE LIST
  // =========================================================
  Widget _buildMessageList() {
    if (_messages.isEmpty) {
      return const Center(
        child: Text(
          'Mulai percakapan...',
          style: TextStyle(color: AppColors.textLight),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final isUser = msg['sender'] == 'user';
        final isLast = index == _messages.length - 1;

        return Column(
          children: [
            _buildMessageBubble(
              text: msg['text'],
              time: msg['time'],
              isUser: isUser,
            ),
            if (isLast && _isTyping && !isUser)
              _buildTypingIndicator(),
          ],
        );
      },
    );
  }

  Widget _buildMessageBubble({
    required String text,
    required String time,
    required bool isUser,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.only(right: 8, bottom: 2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.sagePale,
              ),
              child: const Icon(
                Icons.spa_rounded,
                size: 16,
                color: AppColors.sage,
              ),
            ),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.74,
              ),
              child: Column(
                crossAxisAlignment:
                    isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onLongPress: () {
                      Clipboard.setData(ClipboardData(text: text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pesan disalin'),
                          duration: Duration(milliseconds: 1200),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isUser ? AppColors.sage : AppColors.surface,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(20),
                          topRight: const Radius.circular(20),
                          bottomLeft: Radius.circular(isUser ? 20 : 4),
                          bottomRight: Radius.circular(isUser ? 4 : 20),
                        ),
                        border: isUser
                            ? null
                            : Border.all(
                                color: AppColors.borderLight,
                                width: 1.2,
                              ),
                        boxShadow: isUser
                            ? null
                            : [
                                BoxShadow(
                                  color: AppColors.shadowLight,
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: Text(
                        text,
                        style: AppText.bodyMedium.copyWith(
                          color: isUser ? Colors.white : AppColors.textDark,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      time,
                      style: AppText.caption.copyWith(
                        fontSize: 10.5,
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.only(left: 8, bottom: 2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.sandLight,
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 17,
                color: AppColors.sageDark,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14, left: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderLight, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            const SizedBox(width: 4),
            _buildDot(1),
            const SizedBox(width: 4),
            _buildDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.sageLight.withValues(
          alpha: 0.4 + (index == 1 ? 0.4 : 0.0),
        ),
      ),
    );
  }

  // =========================================================
  // QUICK PROMPTS
  // =========================================================
  Widget _buildQuickPrompts() {
    final prompts = [
      'Aku merasa cemas',
      'Aku sedih hari ini',
      'Butuh tenang sejenak',
      'Ceritakan tentang mindfulness',
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: prompts.map((prompt) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                onPressed: () => _sendQuickPrompt(prompt),
                backgroundColor: AppColors.peachPale,
                side: const BorderSide(color: AppColors.peachLight, width: 1),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                label: Text(
                  prompt,
                  style: AppText.bodySmall.copyWith(
                    color: AppColors.terracotta,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // =========================================================
  // INPUT AREA
  // =========================================================
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
      decoration: const BoxDecoration(
        color: AppColors.cream,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border, width: 1.2),
                ),
                child: TextField(
                  controller: _controller,
                  maxLines: 5,
                  minLines: 1,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  style: AppText.bodyMedium.copyWith(
                    color: AppColors.textDark,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Tulis perasaanmu di sini...',
                    hintStyle: AppText.bodyMedium.copyWith(
                      color: AppColors.textLight,
                    ),
                    contentPadding: const EdgeInsets.fromLTRB(18, 12, 14, 12),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.sage,
                ),
                child: const Icon(
                  Icons.arrow_upward_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // INFO DIALOG
  // =========================================================
  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.sagePale,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                color: AppColors.sage,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Tentang Ruang Cerita',
              style: AppText.titleSmall.copyWith(fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ruang Cerita adalah fitur percakapan dengan AI yang dirancang untuk mendampingimu berefleksi dan menenangkan pikiran.',
              style: AppText.bodyMedium.copyWith(height: 1.55),
            ),
            const SizedBox(height: 12),
            Text(
              'Penting untuk diingat:',
              style: AppText.labelSmall.copyWith(color: AppColors.textDark),
            ),
            const SizedBox(height: 6),
            _buildInfoItem(
              'AI ini bukan pengganti konselor atau psikolog profesional.',
            ),
            _buildInfoItem(
              'Jika kamu mengalami krisis, segera hubungi layanan darurat atau profesional kesehatan mental.',
            ),
            _buildInfoItem(
              'Percakapan bersifat pribadi dan tidak disimpan secara permanen.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Mengerti',
              style: AppText.labelLarge.copyWith(color: AppColors.sage),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              color: AppColors.sage,
              fontWeight: FontWeight.w700,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppText.bodySmall.copyWith(height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
