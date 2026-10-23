import tempfile
import unittest
from unittest.mock import Mock, patch
from pathlib import Path

import run


class RunContracts(unittest.TestCase):
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
