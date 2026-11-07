import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/motion/aria_motion.dart';
import '../../../../core/motion/aria_sheet.dart';
import '../../../../core/motion/aria_tap.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/aria_semantic_colors.dart';
import '../../domain/entities/aria_message.dart';
import '../providers/home_providers.dart';

/// The companion chat, opened from the "Ngobrol" button on Beranda.
///
/// Demonstrates the house interaction principle end to end: opened through
/// [AriaSheet.show] (soft spring, drag to dismiss, light haptic on open), with
/// every send button wrapped in [AriaTap].
///
/// The conversation is local state in iteration 1 — replies come from the mock
/// repository, so wiring a real model later is a repository change only.
class NgobrolSheet extends ConsumerStatefulWidget {
  const NgobrolSheet({super.key, required this.initialMessage});

  final AriaMessage initialMessage;

  /// Opens as a sheet. Callers should use this rather than instantiating.
  static Future<void> show(
    BuildContext context, {
    required AriaMessage initialMessage,
  }) {
    return AriaSheet.show<void>(
      context: context,
      builder: (_) => NgobrolSheet(initialMessage: initialMessage),
    );
  }

  @override
  ConsumerState<NgobrolSheet> createState() => _NgobrolSheetState();
}

class _NgobrolSheetState extends ConsumerState<NgobrolSheet> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatTurn> _turns = [];
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _turns.add(_ChatTurn.aria(widget.initialMessage.text));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() {
      _turns.add(_ChatTurn.user(text));
      _sending = true;
      _controller.clear();
    });
    _scrollToEnd();

    final repository = ref.read(ariaCompanionRepositoryProvider);
    final result = await repository.reply(text);

    if (!mounted) return;
    setState(() {
      _sending = false;
      result.when(
        ok: (msg) => _turns.add(_ChatTurn.aria(msg.text)),
        err: (failure) => _turns.add(_ChatTurn.system(failure.message)),
      );
    });
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: AriaMotion.scrollToEnd,
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ngobrol dengan ARIA', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Tanyakan apa saja soal kebiasaan digitalmu.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.42,
            ),
            child: ListView.separated(
              controller: _scrollController,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _turns.length + (_sending ? 1 : 0),
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                if (index >= _turns.length) return const _TypingIndicator();
                return _Bubble(turn: _turns[index]);
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _Composer(controller: _controller, sending: _sending, onSend: _send),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.ariaColors;

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            minLines: 1,
            maxLines: 3,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => onSend(),
            decoration: InputDecoration(
              hintText: 'Tulis pesan…',
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHigh,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              border: const OutlineInputBorder(
                borderRadius: AppRadius.pill,
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        AriaTap.button(
          onTap: sending ? null : onSend,
          borderRadius: AppRadius.pill,
          child: AnimatedContainer(
            duration: AriaMotion.medium,
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: sending
                  ? colors.companion.withValues(alpha: 0.5)
                  : colors.companion,
              shape: BoxShape.circle,
            ),
            child: sending
                ? Padding(
                    padding: const EdgeInsets.all(14),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onPrimary,
                    ),
                  )
                : Icon(
                    Icons.arrow_upward_rounded,
                    color: theme.colorScheme.onPrimary,
                  ),
          ),
        ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.turn});

  final _ChatTurn turn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.ariaColors;

    final (alignment, background, textColor) = switch (turn.author) {
      _Author.user => (
        CrossAxisAlignment.end,
        colors.companion,
        theme.colorScheme.onPrimary,
      ),
      _Author.aria => (
        CrossAxisAlignment.start,
        colors.companionSurface,
        theme.colorScheme.onSurface,
      ),
      _Author.system => (
        CrossAxisAlignment.center,
        theme.colorScheme.errorContainer,
        theme.colorScheme.onErrorContainer,
      ),
    };

    return Column(
      crossAxisAlignment: alignment,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.78,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(AppRadius.lg),
                topRight: const Radius.circular(AppRadius.lg),
                bottomLeft: Radius.circular(
                  turn.author == _Author.user ? AppRadius.lg : AppRadius.xs,
                ),
                bottomRight: Radius.circular(
                  turn.author == _Author.user ? AppRadius.xs : AppRadius.lg,
                ),
              ),
            ),
            child: Text(
              turn.text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor,
                height: 1.45,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: context.ariaColors.companionSurface,
          borderRadius: AppRadius.pill,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.6,
                color: context.ariaColors.companion,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'ARIA sedang menulis…',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One line of the conversation.
class _ChatTurn {
  const _ChatTurn(this.author, this.text);

  factory _ChatTurn.user(String text) => _ChatTurn(_Author.user, text);
  factory _ChatTurn.aria(String text) => _ChatTurn(_Author.aria, text);
  factory _ChatTurn.system(String text) => _ChatTurn(_Author.system, text);

  final _Author author;
  final String text;
}

enum _Author { user, aria, system }
