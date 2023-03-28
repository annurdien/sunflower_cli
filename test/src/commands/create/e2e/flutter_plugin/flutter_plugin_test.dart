@Tags(['e2e'])
library flutter_plugin_test;

import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:universal_io/io.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  test(
    'create flutter_plugin',
    timeout: const Timeout(Duration(minutes: 8)),
    withRunner((commandRunner, logger, updater, logs) async {
      final directory = Directory.systemTemp.createTempSync();
      const pluginName = 'very_good';
      final pluginDirectory = path.join(directory.path, pluginName);

      final result = await commandRunner.run(
        ['create', 'flutter_plugin', pluginName, '-o', directory.path],
      );
      expect(
        result,
        equals(ExitCode.success.code),
        reason: '`very_good create flutter_plugin` failed with $result',
      );

      await expectSuccessfulProcessResult(
        'dart',
        ['format', '--set-exit-if-changed', '.'],
        workingDirectory: pluginDirectory,
      );

      final analyzeResult = await expectSuccessfulProcessResult(
        'flutter',
        ['analyze', '.'],
        workingDirectory: pluginDirectory,
      );
      expect(analyzeResult.stdout, contains('No issues found!'));

      final packageDirectories = [
        path.join(pluginDirectory, pluginName),
        path.join(pluginDirectory, '${pluginName}_android'),
        path.join(pluginDirectory, '${pluginName}_ios'),
        path.join(pluginDirectory, '${pluginName}_linux'),
        path.join(pluginDirectory, '${pluginName}_macos'),
        path.join(pluginDirectory, '${pluginName}_web'),
        path.join(pluginDirectory, '${pluginName}_windows'),
        path.join(pluginDirectory, '${pluginName}_platform_interface'),
      ];

      for (final packageDirectory in packageDirectories) {
        final testResult = await expectSuccessfulProcessResult(
          'flutter',
          ['test', '--no-pub', '--coverage', '--reporter', 'compact'],
          workingDirectory: packageDirectory,
        );
        expect(testResult.stdout, contains('All tests passed!'));

        final testCoverageResult = await expectSuccessfulProcessResult(
          'genhtml',
          ['coverage/lcov.info', '-o', 'coverage'],
          workingDirectory: packageDirectory,
        );
        expect(testCoverageResult.stdout, contains('lines......: 100.0%'));
      }

      directory.deleteSync(recursive: true);
    }),
  );
}
