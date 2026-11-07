import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Flags tappable widgets created without [AriaTap].
///
/// A bare `GestureDetector`/`InkWell` with an `onTap` gives the user no
/// haptic and no press scale. This rule keeps that from creeping in: every
/// interactive surface in the app should feel the same way under the finger.
///
/// Scope is limited to feature code (`lib/features/**`) — the core layer's own
/// primitives are allowed to build on raw widgets, since they *are* the
/// implementation of the house rule.
class NoRawGestureTap extends DartLintRule {
  const NoRawGestureTap() : super(code: _code);

  static const _code = LintCode(
    name: 'no_raw_gesture_tap',
    problemMessage: 'Bungkus gesture ini dengan AriaTap agar haptic & press scale konsisten.',
    correctionMessage:
        'Ganti `GestureDetector(onTap: ...)` atau `InkWell(onTap: ...)` menjadi '
        '`AriaTap(onTap: ...)` (atau `AriaTap.button` / `AriaTap.card`).',
    errorSeverity: ErrorSeverity.WARNING,
  );

  static const _targetWidgets = {'GestureDetector', 'InkWell', 'InkResponse'};

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Only police feature code. Core/ is exempt because it implements the
    // behaviour these rules exist to enforce.
    final path = resolver.source.fullName.replaceAll('\\', '/');
    if (!path.contains('/lib/features/')) return;

    context.registry.addInstanceCreationExpression((node) {
      final typeName = node.constructorName.type.name.lexeme;
      if (!_targetWidgets.contains(typeName)) return;
      if (_hasTapCallback(node.argumentList)) {
        reporter.atNode(node.constructorName, _code);
      }
    });
  }

  bool _hasTapCallback(ArgumentList args) {
    for (final argument in args.arguments) {
      if (argument is! NamedExpression) continue;
      // `onTap`, `onDoubleTap`, `onLongPress` all imply an interactive
      // surface that owes the user feedback.
      final name = argument.name.label.name;
      if (name == 'onTap' ||
          name == 'onDoubleTap' ||
          name == 'onLongPress' ||
          name == 'onTapDown') {
        return true;
      }
    }
    return false;
  }
}
