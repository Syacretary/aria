import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/motion/aria_haptics.dart';
import '../../../core/motion/aria_tap.dart';
import '../../../core/presentation/aria_scaffold.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/routing/routes.dart';
import '../domain/spot_check_models.dart';
import 'spot_check_providers.dart';

class SpotCheckTestPage extends ConsumerStatefulWidget {
  const SpotCheckTestPage({super.key});

  @override
  ConsumerState<SpotCheckTestPage> createState() => _SpotCheckTestPageState();
}

class _SpotCheckTestPageState extends ConsumerState<SpotCheckTestPage> {
  List<SpotCheckPrompt> _questions = const [];
  final List<SpotCheckAnswer> _answers = [];
  UsageTrend _trend = UsageTrend.unknown;
  int _index = 0;
  int? _selected;
  bool _loading = true;
  bool _memoryStarted = false;
  bool _memoryVisible = false;
  bool _saving = false;
  Timer? _memoryTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prepare());
  }

  Future<void> _prepare() async {
    try {
      final overview = await ref.read(spotCheckOverviewProvider.future);
      final recentIds = overview.sessions
          .take(2)
          .expand((session) => session.answers.map((answer) => answer.promptId))
          .toSet();
      final questions = SpotCheckQuestionBank.select(overview.trend, recentIds);
      if (!mounted) return;
      setState(() {
        _questions = questions;
        _trend = overview.trend;
        _loading = false;
      });
    } on Object {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _memoryTimer?.cancel();
    super.dispose();
  }

  Future<void> _next() async {
    final question = _questions[_index];
    final selected = _selected!;
    _answers.add(
      SpotCheckAnswer(
        promptId: question.id,
        value: question.options[selected],
        isCorrect: question.kind == SpotPromptKind.reflection
            ? null
            : selected == question.correctAnswer,
      ),
    );
    if (_index == _questions.length - 1) {
      setState(() => _saving = true);
      final store = ref.read(spotCheckStoreProvider);
      await store.saveSession(
        SpotCheckSession(
          completedAt: DateTime.now(),
          trend: _trend,
          answers: List.unmodifiable(_answers),
        ),
      );
      ref.invalidate(spotCheckOverviewProvider);
      if (mounted) context.go(Routes.spotCheck);
      return;
    }
    AriaHaptics.selection();
    setState(() {
      _index++;
      _selected = null;
      _memoryStarted = false;
      _memoryVisible = false;
    });
  }

  void _startMemory() {
    setState(() {
      _memoryStarted = true;
      _memoryVisible = true;
    });
    _memoryTimer?.cancel();
    _memoryTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _memoryVisible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading || _questions.isEmpty) {
      return AriaScaffold(
        title: 'Check-in singkat',
        subtitle: 'Menyiapkan pertanyaan',
        child: Center(
          child: _loading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Belum bisa menyiapkan check-in.'),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Kembali'),
                    ),
                  ],
                ),
        ),
      );
    }

    final question = _questions[_index];
    final isMemory = question.kind == SpotPromptKind.memory;
    final canAnswer = !isMemory || (_memoryStarted && !_memoryVisible);
    return AriaScaffold(
      title: 'Check-in singkat',
      subtitle: 'Pertanyaan ${_index + 1} dari ${_questions.length}',
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageGutter,
            AppSpacing.md,
            AppSpacing.pageGutter,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: AppRadius.pill,
                child: LinearProgressIndicator(
                  value: (_index + 1) / _questions.length,
                  minHeight: 6,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: SingleChildScrollView(
                    key: ValueKey(question.id),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _KindLabel(kind: question.kind),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          question.text,
                          style: theme.textTheme.headlineSmall,
                        ),
                        if (question.challenge != null) ...[
                          const SizedBox(height: AppSpacing.lg),
                          _ChallengeCard(
                            content: question.challenge!,
                            visible: !isMemory || _memoryVisible,
                          ),
                        ],
                        if (isMemory && !_memoryStarted) ...[
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Kata-kata akan tampil selama 4 detik. Ingat sebisamu, tanpa tekanan.',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          OutlinedButton.icon(
                            onPressed: _startMemory,
                            icon: const Icon(Icons.visibility_outlined),
                            label: const Text('Tampilkan kata'),
                          ),
                        ] else if (isMemory && _memoryVisible) ...[
                          const SizedBox(height: AppSpacing.md),
                          const LinearProgressIndicator(),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Perhatikan sebentar…',
                            style: theme.textTheme.bodySmall,
                          ),
                        ] else ...[
                          const SizedBox(height: AppSpacing.xl),
                          for (var i = 0; i < question.options.length; i++) ...[
                            _AnswerOption(
                              text: question.options[i],
                              selected: _selected == i,
                              onTap: () => setState(() => _selected = i),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: _saving || _selected == null || !canAnswer
                    ? null
                    : _next,
                child: Text(
                  _saving
                      ? 'Menyimpan di perangkat…'
                      : _index == _questions.length - 1
                      ? 'Selesai'
                      : 'Lanjut',
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Jawabanmu bersifat pribadi dan tersimpan lokal.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KindLabel extends StatelessWidget {
  const _KindLabel({required this.kind});
  final SpotPromptKind kind;

  @override
  Widget build(BuildContext context) {
    final label = switch (kind) {
      SpotPromptKind.reflection => 'REFLEKSI',
      SpotPromptKind.focus => 'LATIHAN FOKUS',
      SpotPromptKind.memory => 'LATIHAN INGATAN',
    };
    return Text(
      label,
      style: Theme.of(context).textTheme.labelSmall
          ?.copyWith(letterSpacing: 1.3),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.content, required this.visible});
  final String content;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: AppRadius.shellBorder,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: .6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        visible ? content : '•••••  ·  •••••  ·  ••••',
        textAlign: TextAlign.center,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

class _AnswerOption extends StatelessWidget {
  const _AnswerOption({
    required this.text,
    required this.selected,
    required this.onTap,
  });
  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AriaTap.card(
      onTap: onTap,
      semanticLabel: text,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant.withValues(alpha: .6),
          ),
          boxShadow: [
            if (!selected)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 20,
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
          ],
        ),
      ),
    );
  }
}
