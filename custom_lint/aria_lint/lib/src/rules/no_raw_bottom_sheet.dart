import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Flags direct calls to Flutter's built-in bottom-sheet helpers.
///
/// House rule: every sheet in ARIA slides up with the same soft spring, the
/// same top radius and the same drag behaviour. That only holds if sheets are
/// opened through `AriaSheet.show()`. This rule makes the raw API a lint
/// error rather than a matter of reviewer diligence.
class NoRawBottomSheet extends DartLintRule {
  const NoRawBottomSheet() : super(code: _code);

  static const _code = LintCode(
    name: 'no_raw_bottom_sheet',
    problemMessage: 'Gunakan AriaSheet.show() untuk membuka bottom sheet.',
    correctionMessage:
        'AriaSheet.show() menerapkan spring lembut, radius, dan haptic yang '
        'konsisten. Ganti `showModalBottomSheet(...)` menjadi '
        '`AriaSheet.show(context: context, builder: ...)`.',
    errorSeverity: ErrorSeverity.WARNING,
  );

  static const _bannedFunctions = {
    'showModalBottomSheet',
    'showBottomSheet',
    'showGeneralDialog',
  };

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // `AriaSheet` is the implementation these rules exist to enforce, so it is
    // exempt — the same way `no_raw_gesture_tap` exempts the core layer.
    final path = resolver.source.fullName.replaceAll('\\', '/');
    if (path.contains('/core/motion/')) return;

    context.registry.addMethodInvocation((node) {
      if (_bannedFunctions.contains(node.methodName.name)) {
        reporter.atNode(node.methodName, _code);
      }
    });

    // Also catch `showModalBottomSheet<T>(...)` written as a function call
    // through a prefix (e.g. `material.showModalBottomSheet`).
    context.registry.addSimpleIdentifier((node) {
      if (!_bannedFunctions.contains(node.name)) return;
      // Only report bare identifiers, not the `methodName` of an invocation
      // (already handled above, and would otherwise double-report).
      if (node.parent is MethodInvocation) return;
      if (node.parent is FunctionExpressionInvocation) {
        reporter.atNode(node, _code);
      }
    });
  }
}
