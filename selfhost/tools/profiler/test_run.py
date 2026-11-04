import tempfile
import sys
import unittest
from unittest.mock import Mock, patch
from pathlib import Path

import run


class RunContracts(unittest.TestCase):
    @unittest.skipUnless(sys.platform == 'linux', 'Linux native profiler contract')
    def test_explicit_argv0_reaches_child_without_changing_binary_command(self):
        code = ('from pathlib import Path; '
                'print(Path("/proc/self/cmdline").read_bytes().split(b"\\0")[0].decode())')
        command = [sys.executable, '-c', code]
        with tempfile.TemporaryDirectory() as directory:
            for name, override, expected in [('default', None, sys.executable),
                                             ('override', 'compiler-work', 'compiler-work')]:
                result = run.execute(command, Path(directory)/name, directory, 5, {},
                                     argv0=override)
                self.assertEqual(result['returncode'], 0)
                self.assertFalse(result['timedOut'])
                self.assertEqual(result['command'], command)
                self.assertEqual(result['argv0'], expected)
                self.assertEqual((Path(directory)/name/'stdout').read_text(), expected+'\n')
                self.assertEqual((Path(directory)/name/'stderr').read_bytes(), b'')

    def test_invalid_argv0_rejected_before_launch(self):
        with tempfile.TemporaryDirectory() as directory, patch.object(run.subprocess, 'Popen') as launch:
            for invalid in ['', 'bad\0argument', 17, ['compiler-work']]:
                with self.subTest(invalid=invalid), self.assertRaises(ValueError):
                    run.execute(['dummy'], Path(directory)/'run', directory, 5, {}, argv0=invalid)
            launch.assert_not_called()
            self.assertFalse((Path(directory)/'run').exists())
        with self.assertRaises(ValueError):
            run.validate_argv0(None)

    def test_canceled_runner_kills_and_reaps_workload(self):
        child = Mock(pid=12345)
        with tempfile.TemporaryDirectory() as directory, \
             patch.object(run.subprocess, 'Popen', return_value=child), \
             patch.object(run.os, 'wait4', side_effect=KeyboardInterrupt), \
             patch.object(run.os, 'killpg') as kill, \
             patch.object(run.os, 'waitpid') as reap:
            with self.assertRaises(KeyboardInterrupt):
                run.execute(['dummy'], Path(directory)/'run', directory, 30, {})
            kill.assert_called_once_with(12345, run.signal.SIGKILL)
            reap.assert_called_once_with(12345, 0)

    def test_instrumented_unsampled_is_not_clean(self):
        row = dict(workload='x', variant='instrumented', mode='clean', correct=True,
                   diagnosticRuntime=True, timingKind='diagnostic', wallSeconds=2,
                   cpuSeconds=1.9, peakRssKiB=300)
        result = run.summarize([row])['x']['instrumented']
        self.assertEqual(result['cleanRuns'], 0)
        self.assertIsNone(result['clean']['cpuSeconds']['median'])
        self.assertEqual(result['instrumentedUnsampledWallSeconds'], [2])

    def test_incorrect_clean_run_excluded(self):
        row = dict(workload='x', variant='plain', mode='clean', correct=False,
                   wallSeconds=1, cpuSeconds=1, peakRssKiB=300)
        self.assertEqual(run.summarize([row])['x']['plain']['cleanRuns'], 0)

    def test_explicit_elapsed_contract_is_strict(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory)/'output'
            expected = dict(kind='prefix-integer-line', prefix='answer: 42\n')
            for content, good in [(b'answer: 42\n123\n', True),
                                  (b'answer: 43\n123\n', False),
                                  (b'answer: 42\n123\nextra\n', False),
                                  (b'answer: 42\n-1\n', False),
                                  (b'answer: 42\n123', False)]:
                path.write_bytes(content)
                self.assertEqual(run.output_matches(path, expected), good)

    def test_exact_output_checks_bytes_and_hash(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory)/'output'; path.write_bytes(b'42\n')
            expected = run.pin(path) | dict(kind='exact')
            self.assertTrue(run.output_matches(path, expected))
            path.write_bytes(b'43\n')
            self.assertFalse(run.output_matches(path, expected))
            with self.assertRaises(ValueError):
                run.verify(expected)


if __name__ == '__main__':
    unittest.main()
