"""Offline controls: fake child processes; no native programs execute."""
import argparse
import copy
import importlib.util
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('p185_runtime', Path(__file__).with_name('runtime-loop.py'))
R = importlib.util.module_from_spec(spec)
spec.loader.exec_module(R)


class RuntimeLoop(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        (self.root / 'selfhost/build').mkdir(parents=True)
        self.case = copy.deepcopy(next(c for c in R.B.catalog(R.CATALOG)['cases'] if c['id'] == 'scalar-region-8192'))
        self.roles = ['old-qbe', 'own-c', 'new-qbe', 'old-x86', 'new-x86']
        self.case['products'] = {}
        for role in self.roles:
            file = self.root / role
            file.write_text('Unexecuted metadata fixture')
            self.case['products'][role] = dict(artifact=R.B.pin(file), runtimeArgumentConvention='bend-rts-v1')
        self.manifest = self.root / 'manifest.json'
        self.document = dict(schema='bend-benchmark-manifest-v1', kind='programs', cwd=str(self.root),
            roles={r: dict(target='c' if r == 'own-c' else 'x86' if 'x86' in r else 'qbe') for r in self.roles},
            reference=self.roles[0], inputs=[p['artifact'] for p in self.case['products'].values()], cases=[self.case])
        self.save()
        self.calls = []

    def save(self):
        R.B.save(self.manifest, self.document)

    def child(self, command, directory, deadline, cwd):
        directory.mkdir(parents=True)
        role = Path(command[0]).name
        count, warmups = map(int, command[-4:-2])
        self.assertEqual(command[1:-4], ['+RTS', '--threads', '1', '--gpu', 'off', '-RTS', '--RTS'])
        self.assertEqual(warmups, self.case['point']['warmups'])
        self.assertEqual(command[-2:], list(map(str, self.case['point']['runtimeArgs'])))
        factor = [125, 250, 500, 1000, 2000][self.roles.index(role)]
        elapsed = count * factor // self.case['point']['repetitions']
        self.calls.append((directory.parts[-3], role, count))
        stdout, stderr = directory / 'stdout', directory / 'stderr'
        stdout.write_text(self.case['point']['expectedStdout'] + f'{warmups}\n{count}\n{elapsed}\n')
        stderr.write_bytes(b'')
        return dict(exitCode=0, timedOut=False, seconds=elapsed / 1000 + .001,
                    stdout=R.B.pin(stdout), stderr=R.B.pin(stderr))

    def run_mocked(self, child=None):
        out = self.root / 'selfhost/build/run'
        a = argparse.Namespace(manifest=self.manifest, out=out, cases=None, rounds=5,
            seconds=60, target_ms=250, cpu=3, guarded=True)
        with patch.object(R, 'ROOT', self.root), patch.object(R.os, 'sched_getaffinity', return_value={3}), \
             patch.dict(R.os.environ, {}, clear=True), patch.object(R.B, 'child', side_effect=child or self.child):
            result = R.run(a)
        return result, R.B.read(out / 'report.json')

    def test_five_roles_calibrate_and_rotate_with_exact_inputs(self):
        result, report = self.run_mocked()
        self.assertTrue(result['complete'], report)
        self.assertTrue(report['positionBalanced'])
        item = report['cases'][0]
        original = self.case['point']['repetitions']
        # Millisecond quantization makes the final count depend on the pilot
        # seed. Check convergence and normalized cost, not that exact count.
        for role, factor in zip(self.roles, [125, 250, 500, 1000, 2000]):
            pilots = [p for p in item['pilots'] if p['role'] == role]
            self.assertGreater(len(pilots), 1)
            self.assertLessEqual(pilots[0]['repetitions'], 16)
            self.assertEqual(pilots[-1]['repetitions'], item['calibration'][role])
            self.assertGreaterEqual(pilots[-1]['elapsedMs'], 250)
            self.assertLessEqual(pilots[-1]['elapsedMs'], 500)
            for sample in (s for s in item['samples'] if s['role'] == role):
                self.assertEqual(sample['repetitions'], item['calibration'][role])
                self.assertAlmostEqual(sample['metricMs'], factor / original,
                                       delta=1 / sample['repetitions'])
        counts = [item['calibration'][role] for role in self.roles]
        self.assertTrue(all(a > b for a, b in zip(counts, counts[1:])))
        self.assertGreater(item['calibration']['old-qbe'], original)
        self.assertLess(item['calibration']['new-x86'], original)
        self.assertEqual([s['role'] for s in item['samples']],
                         [role for i in range(5) for role in self.roles[i:] + self.roles[:i]])
        self.assertTrue(all(s['elapsedMs'] >= 100 for s in item['samples']))
        self.assertEqual(report['selectedCaseIds'], ['scalar-region-8192'])

    def test_wrong_output_retained_without_ratio(self):
        def wrong(*args):
            result = self.child(*args)
            Path(result['stdout']['file']).write_text('wrong\n')
            result['stdout'] = R.B.pin(result['stdout']['file'])
            return result
        result, report = self.run_mocked(wrong)
        self.assertFalse(result['complete'])
        self.assertIsNone(report['cases'][0]['summary']['ratios'])
        self.assertIn('process', report['cases'][0]['pilots'][0])

    def test_changed_catalog_point_refused(self):
        self.document['cases'][0]['point']['runtimeArgs'][0] += 1
        self.save()
        with self.assertRaisesRegex(ValueError, 'differs from native45'):
            R.load(self.manifest)

    def test_count_extremes(self):
        self.assertEqual(R.next_count(8, 20000, 250), 1)
        self.assertEqual(R.next_count(10, 0, 250), 100)
        self.assertEqual(R.next_count(R.MAX_COUNT, 0, 250), R.MAX_COUNT)


if __name__ == '__main__':
    unittest.main()
