import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/presentation/aria_markdown_text.dart';
import '../../../core/theme/app_spacing.dart';
import 'providers/home_providers.dart';

/// Full-screen ARIA conversation using the configured companion repository.
class CompanionChatPage extends ConsumerStatefulWidget {
  const CompanionChatPage({super.key});

  @override
  ConsumerState<CompanionChatPage> createState() => _CompanionChatPageState();
}

class _CompanionChatPageState extends ConsumerState<CompanionChatPage> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final List<(String, bool)> _messages = [
    (
      'Aku di sini. Kita bisa melihat kebiasaan digitalmu dengan tenang, tanpa menghakimi.',
      false,
    ),
  ];
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() {
      _messages.add((text, true));
      _controller.clear();
      _sending = true;
    });
    final result = await ref.read(ariaCompanionRepositoryProvider).reply(text);
    if (!mounted) return;
    result.when(
      ok: (message) => setState(() {
        _messages.add((message.text, false));
        _sending = false;
      }),
      err: (failure) => setState(() {
        _messages.add((failure.message, false));
        _sending = false;
      }),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Ngobrol dengan ARIA'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: Stack(
        children: [
          const Positioned(
            top: -260,
            left: -70,
            right: -70,
            child: IgnorePointer(
              child: _ChatAmbientGlow(),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(AppSpacing.pageGutter),
                    itemCount: _messages.length + (_sending ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        return const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }
                      final (text, user) = _messages[index];
                      return Align(
                        alignment: user
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.sizeOf(context).width * .82,
                          ),
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: user
                                ? theme.colorScheme.primaryContainer
                                : theme.colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: user
                              ? Text(text)
                              : AriaMarkdownText(
                                  text,
                                  style:
                                      theme.textTheme.bodyMedium ??
                                      const TextStyle(),
                                  color: theme.colorScheme.onSurface,
                                ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          minLines: 1,
                          maxLines: 4,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _send(),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: theme.colorScheme.surfaceContainerLowest,
                            hintText: 'Ceritakan yang sedang kamu rasakan…',
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(24)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      IconButton.filled(
                        onPressed: _sending ? null : _send,
                        icon: const Icon(Icons.arrow_upward_rounded),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatAmbientGlow extends StatelessWidget {
  const _ChatAmbientGlow();

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      height: 520,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(0, -0.35),
          colors: isLight
              ? const [
                  Color(0xB3FFFFFF),
                  Color(0x99FFD36E),
                  Color(0x66F5EBD9),
                  Color(0x00F5EBD9),
                ]
              : const [
                  Color(0x22FFFFFF),
                  Color(0x18FFD36E),
                  Color(0x15E8DCBE),
                  Color(0x00E8DCBE),
                ],
          stops: const [0, 0.32, 0.68, 1],
        ),
      ),
    );
  }
}
