import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'src/rules/no_raw_bottom_sheet.dart';
import 'src/rules/no_raw_gesture_tap.dart';
import 'src/rules/prefer_aria_duration.dart';

/// Entry point for the `aria_lint` plugin.
///
/// These rules are what turn ARIA's Motion & Feel principles from a
/// convention into a guarantee: any future feature that reaches for a raw
/// Flutter animation primitive gets flagged at author time and is redirected
/// to the shared wrapper.
PluginBase createPlugin() => _AriaLintPlugin();

class _AriaLintPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => const [
    NoRawBottomSheet(),
    NoRawGestureTap(),
    PreferAriaDuration(),
  ];
}
