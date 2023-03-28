@Tags(['e2e'])
library flame_game_test;

import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:universal_io/io.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  test(
    'create flame_game',
    timeout: const Timeout(Duration(minutes: 5)),
    withRunner((commandRunner, logger, updater, logs) async {
      final directory = Directory.systemTemp.createTempSync();

      final result = await commandRunner.run(
        [
          'create',
          'flame_game',
          'very_good_flame_game',
          '-o',
          directory.path,
        ],
      );
      expect(result, equals(ExitCode.success.code));

      final workingDirectory = path.join(
        directory.path,
        'very_good_flame_game',
      );

      await expectSuccessfulProcessResult(
        'dart',
        ['format', '--set-exit-if-changed', '.'],
        workingDirectory: workingDirectory,
      );

      final analyzeResult = await expectSuccessfulProcessResult(
        'flutter',
        ['analyze', '.'],
        workingDirectory: workingDirectory,
      );
      expect(analyzeResult.stdout, contains('No issues found!'));

      final testResult = await expectSuccessfulProcessResult(
        'flutter',
        ['test', '--no-pub', '--coverage', '--reporter', 'compact'],
        workingDirectory: workingDirectory,
      );
      expect(testResult.stdout, contains('All tests passed!'));

      final testCoverageResult = await expectSuccessfulProcessResult(
        'genhtml',
        ['coverage/lcov.info', '-o', 'coverage'],
        workingDirectory: workingDirectory,
      );
      expect(testCoverageResult.stdout, contains('lines......: 97.8%'));
    }),
  );
}
