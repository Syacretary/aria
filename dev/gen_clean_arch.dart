#!/usr/bin/env dart

// Generates the Clean Architecture skeleton for a new ARIA feature.
//
// Usage:
//   dart run dev/gen_clean_arch.dart <feature_name>
//
// Example:
//   dart run dev/gen_clean_arch.dart diary
//
// Why this exists: the architecture only stays consistent if adding a feature is
// cheaper than improvising one. This scaffolds the exact same three layers every
// existing feature uses (domain / data / presentation), with placeholder files
// that already import the right neighbours.
import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('Usage: dart run dev/gen_clean_arch.dart <feature_name>');
    exitCode = 64;
    return;
  }

  final feature = args.first.trim();
  if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(feature)) {
    stderr.writeln(
      'Feature name must be snake_case and start with a letter: "$feature"',
    );
    exitCode = 64;
    return;
  }

  final root = Directory('lib/features/$feature');
  if (root.existsSync()) {
    stderr.writeln(
      'lib/features/$feature already exists — refusing to touch it.',
    );
    exitCode = 73;
    return;
  }

  final pascal = _pascal(feature);
  final files = <String, String>{
    'domain/entities/${feature}_item.dart': _entity(pascal),
    'domain/repositories/${feature}_repository.dart': _repository(pascal),
    'domain/usecases/get_${feature}_items.dart': _usecase(pascal),
    'data/datasources/${feature}_datasource.dart': _datasource(pascal),
    'data/datasources/${feature}_mock_datasource.dart': _mockDatasource(pascal),
    'data/repositories/${feature}_repository_impl.dart': _repositoryImpl(
      pascal,
    ),
    'presentation/providers/${feature}_providers.dart': _providers(
      feature,
      pascal,
    ),
    'presentation/${feature}_page.dart': _page(pascal),
  };

  files.forEach((relative, contents) {
    final file = File('${root.path}/$relative')
      ..createSync(recursive: true)
      ..writeAsStringSync(contents);
    stdout.writeln('created ${file.path}');
  });

  stdout.writeln('''

Next steps:
  1. Add the entity fields you actually need to
     lib/features/$feature/domain/entities/${feature}_item.dart
  2. Register the page in lib/core/routing/app_router.dart and add a path to
     lib/core/routing/routes.dart
  3. Run: dart run build_runner build
  4. Run: flutter analyze && dart run custom_lint && flutter test

Reminder: ARIA's interaction rules are enforced by aria_lint. Open sheets with
AriaSheet.show() and wrap tappable surfaces in AriaTap — otherwise analyze will
flag you.
''');
}

String _pascal(String snake) => snake
    .split('_')
    .map(
      (part) => part.isEmpty ? part : part[0].toUpperCase() + part.substring(1),
    )
    .join();

String _entity(String pascal) =>
    '''
/// One $pascal record.
///
/// Pure Dart — no Flutter imports, so this stays unit-testable without a widget
/// binding.
class ${pascal}Item {
  const ${pascal}Item({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;
}
''';

String _repository(String pascal) =>
    '''
import '../../../../core/error/result.dart';
import '../entities/${_snake(pascal)}_item.dart';

/// Read/write contract for $pascal.
///
/// The presentation layer depends on this interface, never on the
/// implementation, so mock and real data swap without touching the UI.
abstract interface class ${pascal}Repository {
  Future<Result<List<${pascal}Item>>> getItems();
}
''';

String _usecase(String pascal) =>
    '''
import '../../../../core/error/result.dart';
import '../entities/${_snake(pascal)}_item.dart';
import '../repositories/${_snake(pascal)}_repository.dart';

/// Loads every $pascal item.
class Get${pascal}Items {
  const Get${pascal}Items(this._repository);

  final ${pascal}Repository _repository;

  Future<Result<List<${pascal}Item>>> call() => _repository.getItems();
}
''';

String _datasource(String pascal) =>
    '''
import '../dto/${_snake(pascal)}_item_dto.dart';

/// Data-source contract for $pascal.
abstract interface class ${pascal}Datasource {
  Future<List<${pascal}ItemDto>> fetchItems();
}
''';

String _mockDatasource(String pascal) =>
    '''
import '../dto/${_snake(pascal)}_item_dto.dart';
import '${_snake(pascal)}_datasource.dart';

/// Deterministic fake data used until the real source exists.
class ${pascal}MockDatasource implements ${pascal}Datasource {
  const ${pascal}MockDatasource();

  @override
  Future<List<${pascal}ItemDto>> fetchItems() async => const [];
}
''';

String _repositoryImpl(String pascal) =>
    '''
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/${_snake(pascal)}_item.dart';
import '../../domain/repositories/${_snake(pascal)}_repository.dart';
import '../datasources/${_snake(pascal)}_datasource.dart';

/// Maps datasource DTOs into domain entities and converts thrown errors into
/// [Failure]s, so the presentation layer only ever handles [Result].
class ${pascal}RepositoryImpl implements ${pascal}Repository {
  const ${pascal}RepositoryImpl(this._datasource);

  final ${pascal}Datasource _datasource;

  @override
  Future<Result<List<${pascal}Item>>> getItems() async {
    try {
      final dtos = await _datasource.fetchItems();
      return Ok(
        dtos
            .map((dto) => ${pascal}Item(id: dto.id, title: dto.title))
            .toList(growable: false),
      );
    } on Object catch (error) {
      return Err(UnknownFailure('Gagal memuat data.', error));
    }
  }
}
''';

String _providers(String feature, String pascal) =>
    '''
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/error/failure.dart';
import '../../data/datasources/${feature}_datasource.dart';
import '../../data/datasources/${feature}_mock_datasource.dart';
import '../../data/repositories/${feature}_repository_impl.dart';
import '../../domain/entities/${feature}_item.dart';
import '../../domain/repositories/${feature}_repository.dart';
import '../../domain/usecases/get_${feature}_items.dart';

final ${feature}DatasourceProvider = Provider<${pascal}Datasource>(
  (ref) => const ${pascal}MockDatasource(),
);

final ${feature}RepositoryProvider = Provider<${pascal}Repository>(
  (ref) => ${pascal}RepositoryImpl(ref.watch(${feature}DatasourceProvider)),
);

final get${pascal}ItemsProvider = Provider<Get${pascal}Items>(
  (ref) => Get${pascal}Items(ref.watch(${feature}RepositoryProvider)),
);

final ${feature}ItemsProvider =
    FutureProvider<List<${pascal}Item>>((ref) async {
  final result = await ref.watch(get${pascal}ItemsProvider)();
  return result.when(
    ok: (value) => value,
    err: (failure) => throw failure,
  );
});
''';

String _page(String pascal) =>
    '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/presentation/aria_empty_state.dart';
import '../../../core/presentation/aria_scaffold.dart';
import '../../../core/theme/app_spacing.dart';
import '../presentation/providers/${_snake(pascal)}_providers.dart';

/// $pascal page.
class ${pascal}Page extends ConsumerWidget {
  const ${pascal}Page({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(${_camel(pascal)}ItemsProvider);

    return AriaScaffold(
      title: '$pascal',
      child: items.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('\$error')),
        data: (data) {
          if (data.isEmpty) {
            return const AriaEmptyState(
              icon: Icons.inbox_outlined,
              title: 'Belum ada data',
              message: 'Mulai dengan menambahkan satu.',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.pageGutter),
            children: [
              for (final item in data)
                ListTile(title: Text(item.title)),
            ],
          );
        },
      ),
    );
  }
}
''';

/// `DiaryItem` -> `diary_item`
String _snake(String pascal) => pascal
    .replaceAllMapped(RegExp('([a-z0-9])([A-Z])'), (m) => '${m[1]}_${m[2]}')
    .toLowerCase();

/// `DiaryItem` -> `diaryItem`
String _camel(String pascal) => pascal[0].toLowerCase() + pascal.substring(1);
