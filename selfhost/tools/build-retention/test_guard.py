"""Bounded guard controls: simulated disk pressure, never fill the filesystem."""
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import time
import unittest

spec = importlib.util.spec_from_file_location('retention_guard', Path(__file__).with_name('guard.py'))
G = importlib.util.module_from_spec(spec)
spec.loader.exec_module(G)


class Values:
    def __init__(self, *values):
        self.values = list(values)
        self.last = values[-1]

    def __call__(self, *_args):
        if self.values:
            self.last = self.values.pop(0)
        return self.last


class GuardTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix='bend-disk-guard-test-')
        self.root = Path(self.temporary.name)
        self.output, self.artifacts = self.root/'guard', self.root/'artifacts'
        self.lock = self.root/'execution.lock'

    def tearDown(self):
        self.temporary.cleanup()

    def guard(self, **kwargs):
        options = dict(disk_bytes=2*G.MIB, reserve_bytes=5*G.MIB,
                       filesystem=self.root, free_bytes=lambda:100*G.MIB,
                       rss_mib=128, available_mib=1, lock_path=self.lock,
                       scan_seconds=.01)
        options.update(kwargs)
        return G.DiskGuard(**options)

    def run_job(self, guard, code='pass', seconds=5):
        with guard:
            return guard.run([sys.executable, '-B', '-c', code], self.output,
                             time.monotonic()+seconds, run_roots=[self.artifacts])

    def receipt(self):
        return json.loads((self.output/'process.json').read_text())

    def test_success_counts_outputs_without_claiming_qualification(self):
        code = f'from pathlib import Path; p=Path({str(self.artifacts)!r}); p.mkdir(); (p/"result").write_text("ok")'
        report = self.run_job(self.guard(), code)
        self.assertTrue(report['complete'])
        self.assertEqual(report['returncode'], 0)
        self.assertGreater(report['peakRunAllocatedBytes'], 0)
        self.assertEqual(report, self.receipt())
        retention = json.loads((self.output/'retention.json').read_text())
        self.assertEqual((retention['state'], retention['outcome']), ('finished', 'succeeded'))
        self.assertFalse(retention['closed'])
        self.assertFalse(retention['automaticDeletion'])

    def test_admission_is_under_existing_lock_and_denies_before_launch(self):
        inode = None
        guard = self.guard(free_bytes=lambda:6*G.MIB)
        with guard:
            inode = self.lock.stat().st_ino
            with self.assertRaises(RuntimeError):
                with self.guard():
                    pass
            report = guard.run([sys.executable, '-c', f'open({str(self.artifacts)!r},"w").write("bad")'],
                               self.output, time.monotonic()+5, run_roots=[self.artifacts])
        self.assertEqual(self.lock.stat().st_ino, inode)
        self.assertEqual(report['stoppedFor'], 'disk-admission')
        self.assertIsNone(report['returncode'])
        self.assertFalse(self.artifacts.exists())
        self.assertFalse(report['complete'])
        self.assertIn('finished', self.receipt())

    def test_run_without_lock_is_rejected(self):
        with self.assertRaisesRegex(RuntimeError, 'under the shared'):
            self.guard().run(['ignored'], self.output, time.monotonic()+1, run_roots=[self.artifacts])
        self.assertFalse(self.output.exists())

    def test_disk_reserve_stops_only_owned_process(self):
        unrelated = subprocess.Popen([sys.executable, '-c', 'import time; time.sleep(30)'])
        try:
            report = self.run_job(self.guard(free_bytes=Values(10*G.MIB,10*G.MIB,4*G.MIB)),
                                  'import time; time.sleep(30)')
            self.assertEqual(report['stoppedFor'], 'disk-reserve')
            self.assertFalse(report['complete'])
            self.assertIsNotNone(report['returncode'])
            self.assertIsNone(unrelated.poll())
            self.assertLess(report['wallSeconds'], 3)
        finally:
            unrelated.terminate()
            unrelated.wait(timeout=2)

    def test_declared_root_budget_stops_even_when_global_free_increases(self):
        report = self.run_job(self.guard(free_bytes=Values(10*G.MIB,10*G.MIB,20*G.MIB),
                                        usage_bytes=lambda _:3*G.MIB), 'import time; time.sleep(30)')
        self.assertEqual(report['stoppedFor'], 'disk-budget')
        self.assertEqual(report['peakFilesystemDecreaseBytes'], 0)
        self.assertEqual(report['peakRunAllocatedBytes'], 3*G.MIB)

    def test_external_disk_decrease_is_conservatively_charged(self):
        report = self.run_job(self.guard(free_bytes=Values(20*G.MIB,20*G.MIB,17*G.MIB),
                                        usage_bytes=lambda _:0), 'import time; time.sleep(30)')
        self.assertEqual(report['stoppedFor'], 'disk-budget')
        self.assertEqual(report['peakRunAllocatedBytes'], 0)

    def test_nonzero_exit_is_failed_not_qualified(self):
        report = self.run_job(self.guard(), 'raise SystemExit(7)')
        self.assertEqual(report['returncode'], 7)
        self.assertFalse(report['complete'])
        self.assertEqual(json.loads((self.output/'retention.json').read_text())['outcome'], 'failed')

    def test_final_budget_check_covers_already_exited_child(self):
        class ImmediateChild:
            pid = 2147483647
            def poll(self): return 0
            def wait(self, timeout=None): return 0
        from unittest.mock import patch
        with patch.object(G.subprocess, 'Popen', return_value=ImmediateChild()):
            report = self.run_job(self.guard(usage_bytes=lambda _:3*G.MIB))
        self.assertEqual(report['returncode'], 0)
        self.assertEqual(report['stoppedFor'], 'disk-budget')
        self.assertFalse(report['complete'])

    def test_deadline_still_stops_owned_child(self):
        report = self.run_job(self.guard(), 'import time; time.sleep(30)', seconds=.05)
        self.assertEqual(report['stoppedFor'], 'deadline')
        self.assertFalse(report['complete'])

    def test_fresh_and_nonoverlapping_roots_required(self):
        self.artifacts.mkdir()
        with self.guard() as guard:
            with self.assertRaisesRegex(ValueError, 'Fresh'):
                guard.run(['ignored'], self.output, time.monotonic()+1, run_roots=[self.artifacts])
            with self.assertRaisesRegex(ValueError, 'overlap'):
                guard.run(['ignored'], self.output, time.monotonic()+1, run_roots=[self.output/'child'])

    def test_symlinks_not_followed_and_hardlinks_counted_once(self):
        self.artifacts.mkdir()
        data = self.artifacts/'data'
        data.write_bytes(b'x'*8192)
        os.link(data, self.artifacts/'alias')
        external = self.root/'external'
        external.mkdir()
        (external/'unrelated').write_bytes(b'x'*16384)
        link = self.artifacts/'external'
        link.symlink_to(external, target_is_directory=True)
        expected = sum(p.lstat().st_blocks*512 for p in [self.artifacts, data, link])
        self.assertEqual(G.allocated_bytes([self.artifacts]), expected)
        self.assertEqual(G.allocated_bytes([self.artifacts, self.artifacts]), expected)


if __name__ == '__main__':
    unittest.main()
