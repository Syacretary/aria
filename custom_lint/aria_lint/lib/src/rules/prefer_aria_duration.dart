import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Flags raw millisecond durations passed to animation APIs.
///
/// House rule: all motion timings come from `AriaMotion`, so the app has one
/// rhythm. A literal `Duration(milliseconds: 350)` scattered in a feature is
/// how a design system decays — this rule asks for the named constant instead.
class PreferAriaDuration extends DartLintRule {
  const PreferAriaDuration() : super(code: _code);

  static const _code = LintCode(
    name: 'prefer_aria_duration',
    problemMessage: 'Gunakan konstanta AriaMotion (fast/medium/slow/deliberate) alih-alih durasi literal.',
    correctionMessage:
        'Contoh: `AriaMotion.medium` atau `AriaMotion.slow`. Jika butuh nilai '
        'baru, tambahkan dulu ke AriaMotion agar seluruh app tetap seirama.',
    errorSeverity: ErrorSeverity.WARNING,
  );

  /// Widget/API names whose `Duration` arguments represent motion timing.
  static const _animationApis = {
    'AnimatedContainer',
    'AnimatedOpacity',
    'AnimatedScale',
    'AnimatedAlign',
    'AnimatedPadding',
    'AnimatedPositioned',
    'AnimatedSwitcher',
    'AnimatedCrossFade',
    'AnimatedDefaultTextStyle',
    'TweenAnimationBuilder',
    'AnimatedBuilder',
    'AnimationController',
    'PageRouteBuilder',
  };

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      final typeName = node.constructorName.type.name.lexeme;
      if (!_animationApis.contains(typeName)) return;

      for (final argument in node.argumentList.arguments) {
        if (argument is! NamedExpression) continue;
        if (argument.name.label.name != 'duration') continue;
        if (_isLiteralDuration(argument.expression)) {
          reporter.atNode(argument, _code);
        }
      }
    });
  }

  /// True when the expression is a `Duration(...)` built from number literals
  /// rather than a named constant.
  bool _isLiteralDuration(Expression expression) {
    if (expression is! InstanceCreationExpression) return false;
    final created = expression.constructorName.type.name.lexeme;
    if (created != 'Duration') return false;
    return expression.argumentList.arguments.any(
      (arg) => arg is NamedExpression && arg.expression is IntegerLiteral,
    );
  }
}
