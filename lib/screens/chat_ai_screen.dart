import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';
import '../core/ui/components.dart';

/// Ruang Cerita: percakapan pendamping untuk refleksi.
class ChatAiScreen extends StatefulWidget {
  const ChatAiScreen({super.key});

  @override
  State<ChatAiScreen> createState() => _ChatAiScreenState();
}

class _ChatAiScreenState extends State<ChatAiScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  int _conversationId = 0;

  late final AnimationController _dotAnimController;

  @override
  void initState() {
    super.initState();

    _dotAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _addWelcomeMessage();
  }

  /// Lift for one typing dot. Each dot gets a phase so they ripple.
  double _dotOffset(double phase) {
    final v = (_dotAnimController.value + phase) % 1.0;
    if (v >= 0.5) return 0;
    return -4 * math.sin(math.pi * (v / 0.5));
  }

  void _addWelcomeMessage() {
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'sender': 'ai',
          'text': 'Halo, aku di sini menemanimu. Ada yang ingin kamu ceritakan hari ini?',
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
      _messages.add({'sender': 'user', 'text': text, 'time': _formattedTime()});
      _controller.clear();
      _isTyping = true;
    });
    _dotAnimController.repeat();
    final token = _conversationId;

    _scrollToBottom();

    // Simulasi respons. Ganti dengan integrasi backend bila siap.
    Future.delayed(const Duration(seconds: 1, milliseconds: 200), () {
      if (!mounted || token != _conversationId) return;
      _dotAnimController
        ..stop()
        ..value = 0;
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

    if (lowered.contains('bunuh diri') ||
        lowered.contains('menyakiti diri') ||
        lowered.contains('mati saja') ||
        lowered.contains('mengakhiri hidup')) {
      return 'Kamu berharga dan tidak sendirian menghadapi ini. Jika ada dorongan menyakiti diri, hubungi bantuan sekarang:\n\n'
          'Hotline Kesehatan Jiwa Kemenkes: 119 ext. 8\n'
          'Layanan Sejiwa: 119\n\n'
          'Hubungi juga orang terdekat atau tenaga medis di sekitarmu.';
    }

    if (lowered.contains('cemas') ||
        lowered.contains('takut') ||
        lowered.contains('khawatir')) {
      return 'Terima kasih sudah berbagi. Rasa cemas itu wajar, dan kamu tidak sendirian. '
          'Coba tarik napas perlahan: hirup 4 detik, tahan 4 detik, hembuskan 4 detik. Bagaimana perasaanmu sekarang?';
    }
    if (lowered.contains('sedih') ||
        lowered.contains('nangis') ||
        lowered.contains('kecewa')) {
      return 'Aku turut merasakan apa yang kamu rasakan. Sedih adalah bagian dari proses. '
          'Izinkan dirimu merasakannya tanpa perlu buru-buru sembuh. Mau cerita lebih lanjut?';
    }
    if (lowered.contains('lelah') ||
        lowered.contains('capek') ||
        lowered.contains('penat') ||
        lowered.contains('burnout')) {
      return 'Lelah itu tanda bahwa kamu telah berusaha keras. Istirahat bukan berarti menyerah. '
          'Sudahkah kamu minum air hangat atau meluruskan punggung sejenak?';
    }
    if (lowered.contains('bahagia') ||
        lowered.contains('senang') ||
        lowered.contains('bangga')) {
      return 'Senang mendengarnya. Rayakan momen kecil ini. Apa yang paling membuatmu bersyukur hari ini?';
    }
    if (lowered.contains('tidur') ||
        lowered.contains('insomnia') ||
        lowered.contains('begadang')) {
      return 'Pikiran yang ramai sering membuat mata sulit terpejam. Coba redupkan lampu, jauhkan layar ponsel sejenak, dan fokus pada hembusan napas yang panjang.';
    }
    return 'Terima kasih sudah membagikan pikiranmu. Aku mendengarkan. '
        'Ceritakan lebih banyak jika kamu nyaman, atau kita bisa lakukan latihan relaksasi bersama.';
  }

  void _confirmClearMessages() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Mulai obrolan baru?'),
        content: const Text(
          'Percakapan saat ini akan dihapus dari layar demi privasimu.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _conversationId++;
              _dotAnimController
                ..stop()
                ..value = 0;
              setState(() {
                _messages.clear();
                _isTyping = false;
              });
              _addWelcomeMessage();
            },
            child: const Text('Hapus dan mulai'),
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
          duration: const Duration(milliseconds: 280),
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
    _dotAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildHeader(),
          _buildDisclaimerBanner(),
          Expanded(child: _buildMessageList()),
          if (_messages.length <= 2) _buildQuickPrompts(),
          _buildInputArea(),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Space.page,
        Space.md,
        Space.sm,
        Space.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ruang Cerita', style: AppText.displayMedium),
                const SizedBox(height: 2),
                Text(
                  'Pendamping refleksi, bukan terapis',
                  style: AppText.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Mulai ulang percakapan',
            onPressed: _messages.isEmpty ? null : _confirmClearMessages,
            icon: const Icon(Icons.refresh_rounded, size: 20),
          ),
          IconButton(
            tooltip: 'Tentang Ruang Cerita',
            onPressed: _showInfoDialog,
            icon: const Icon(Icons.info_outline_rounded, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimerBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        Space.page,
        Space.md,
        Space.page,
        Space.xs,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Space.md,
        vertical: Space.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.forestMist,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.shield_outlined,
            size: 16,
            color: AppColors.forestMid,
          ),
          const SizedBox(width: Space.sm),
          Expanded(
            child: Text(
              'Bukan pengganti konselor atau psikolog profesional.',
              style: AppText.caption.copyWith(color: AppColors.textBody),
            ),
          ),
        ],
      ),
    );
  }

  // ── Messages ───────────────────────────────────────────────

  Widget _buildMessageList() {
    if (_messages.isEmpty) {
      return const Center(
        child: QuietEmptyState(
          icon: Icons.forum_outlined,
          title: 'Belum ada percakapan',
          message: 'Tulis apa yang sedang kamu pikirkan untuk memulai.',
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: Space.page,
        vertical: Space.lg,
      ),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isTyping) {
          return _buildTypingIndicator();
        }

        final msg = _messages[index];
        return _buildMessageBubble(
          text: msg['text'] as String,
          time: msg['time'] as String,
          isUser: msg['sender'] == 'user',
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
      padding: const EdgeInsets.only(bottom: Space.lg),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            const _AssistantAvatar(size: 30),
            const SizedBox(width: Space.sm),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Semantics(
                  label: isUser ? 'Pesanmu' : 'Pesan pendamping',
                  child: GestureDetector(
                    onLongPress: () {
                      HapticFeedback.lightImpact();
                      Clipboard.setData(ClipboardData(text: text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pesan disalin')),
                      );
                    },
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width * 0.72,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: Space.lg,
                        vertical: Space.md,
                      ),
                      decoration: BoxDecoration(
                        color: isUser ? AppColors.forest : AppColors.surface,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: Radius.circular(isUser ? 18 : 6),
                          bottomRight: Radius.circular(isUser ? 6 : 18),
                        ),
                        border: isUser
                            ? null
                            : Border.all(color: AppColors.borderLight),
                      ),
                      child: Text(
                        text,
                        style: AppText.bodyMedium.copyWith(
                          color: isUser ? Colors.white : AppColors.textDark,
                          height: 1.55,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(time, style: AppText.caption),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AssistantAvatar(size: 30),
          const SizedBox(width: Space.sm),
          Semantics(
            label: 'Pendamping sedang menulis',
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Space.lg,
                vertical: Space.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(6),
                  bottomRight: Radius.circular(18),
                ),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: AnimatedBuilder(
                animation: _dotAnimController,
                builder: (context, child) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _dot(_dotOffset(0)),
                    const SizedBox(width: 5),
                    _dot(_dotOffset(0.16)),
                    const SizedBox(width: 5),
                    _dot(_dotOffset(0.32)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(double offsetY) {
    return Transform.translate(
      offset: Offset(0, offsetY),
      child: Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.forestMid,
        ),
      ),
    );
  }

  // ── Quick prompts ──────────────────────────────────────────

  Widget _buildQuickPrompts() {
    const prompts = [
      'Aku merasa cemas',
      'Aku sedih hari ini',
      'Butuh tenang sejenak',
      'Cara mulai mindfulness',
    ];

    return SizedBox(
      height: 56,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: Space.page,
          vertical: Space.sm,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: prompts.length,
        separatorBuilder: (_, _) => const SizedBox(width: Space.sm),
        itemBuilder: (_, i) => QuietPill(
          label: prompts[i],
          onTap: () => _sendQuickPrompt(prompts[i]),
        ),
      ),
    );
  }

  // ── Input ──────────────────────────────────────────────────

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        Space.page,
        Space.sm,
        Space.page,
        Space.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: 5,
                minLines: 1,
                textInputAction: TextInputAction.send,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
                decoration: const InputDecoration(
                  hintText: 'Tulis perasaanmu di sini',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: Space.sm),
            IconButton.filled(
              tooltip: 'Kirim pesan',
              onPressed: _sendMessage,
              icon: const Icon(Icons.arrow_upward_rounded, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.forest,
                foregroundColor: Colors.white,
                fixedSize: const Size(48, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Info dialog ────────────────────────────────────────────

  void _showInfoDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.eco_outlined, color: AppColors.forest, size: 28),
        title: const Text('Tentang Ruang Cerita'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ruang Cerita adalah percakapan dengan AI untuk menemanimu berefleksi dan menenangkan pikiran.',
            ),
            const SizedBox(height: Space.lg),
            _infoItem(
              Icons.medical_services_outlined,
              'Bukan pengganti konselor atau psikolog profesional.',
            ),
            const SizedBox(height: Space.sm),
            _infoItem(
              Icons.emergency_outlined,
              'Jika kamu mengalami krisis, hubungi layanan darurat atau profesional kesehatan mental.',
            ),
            const SizedBox(height: Space.sm),
            _infoItem(
              Icons.lock_outline_rounded,
              'Percakapan bersifat pribadi dan tidak disimpan permanen.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: AppColors.forestMid),
        const SizedBox(width: Space.sm),
        Expanded(child: Text(text, style: AppText.bodySmall)),
      ],
    );
  }
}

class _AssistantAvatar extends StatelessWidget {
  final double size;

  const _AssistantAvatar({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.forestMist,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.eco_rounded,
        size: size * 0.5,
        color: AppColors.forestDeep,
      ),
    );
  }
}
