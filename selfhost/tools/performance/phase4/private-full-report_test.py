"""Failure-boundary tests only; fixtures do not claim compiler observations."""
import contextlib
import hashlib
import importlib.util
import io
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

FILE = Path(__file__).with_name('private-full-report.py')
spec = importlib.util.spec_from_file_location('full_report', FILE)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class AuditFailureTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        # Synthetic records are rejection fixtures only, never compiler evidence.
        source, expected = self.root / 'source.bend', self.root / 'h.mjs'
        source.write_text('source fixture')
        expected.write_text('expected fixture')
        self.plan = {'version': 1, 'source': str(source), 'sourceSha256': hashlib.sha256(source.read_bytes()).hexdigest(), 'expectedH': str(expected), 'expectedHSha256': hashlib.sha256(expected.read_bytes()).hexdigest(), 'runs': []}
        self.run = self.root / 'run'
        (self.run / 'request').mkdir(parents=True)
        request = {'input': str(source), 'mode': 'library'}
        verdict = {'status': 'ok', 'checked': True, 'phase': 'compile', 'exitCode': 0}
        resource = ['--stack-size=4096', '--max-old-space-size=12288']
        image = {'file': str(self.root / 'image/manifest.json'), 'sha256': '1' * 64}
        launch = {'kind': 'bend-private-compiler-launch', 'complete': True, 'status': 0, 'signal': None, 'timedOut': False, 'outputLimit': False, 'proofStatus': 'fixedpoint', 'result': verdict, 'request': request, 'resourceArgs': resource, 'timeoutMs': 3600000, 'imageManifest': image}
        result = {'kind': 'bend-private-compiler-request', 'complete': True, 'proofStatus': 'fixedpoint', 'result': verdict, 'request': request, 'node': {'args': resource}, 'affinity': 'Cpus_allowed_list:\t2', 'imageManifest': image}
        measurement = {'kind': 'phase4-private-full-source', 'version': 1, 'complete': True, 'returncode': 0, 'inputsUnchanged': True}
        for name, record in [('measurement.json', measurement), ('request/launch.json', launch), ('request/result.json', result), ('request/request.json', request)]:
            (self.run / name).write_text(json.dumps(record))
        for name in ['stdout', 'stderr', 'request/worker.stdout', 'request/worker.stderr']:
            (self.run / name).write_text('')
        self.plan['runs'] = [{'id': 'synthetic-rejection-fixture', 'variant': 'control', 'imageSha256': '2' * 64, 'directory': str(self.run)}]

    def execute(self, value):
        file, out = self.root / 'plan.json', self.root / 'archive'
        file.write_text(json.dumps(value))
        with contextlib.redirect_stdout(io.StringIO()):
            status = module.main(file, out)
        report = json.loads((out / 'comparison.json').read_bytes())
        self.assertEqual(status, 1)
        self.assertIs(report['complete'], False)
        self.assertNotIn('summary', report)
        self.assertTrue(report['errors'])
        return report

    def test_missing_result_retains_failed_row_and_other_records(self):
        (self.run / 'request/result.json').unlink()
        report = self.execute(self.plan)
        self.assertEqual(len(report['rows']), 1)
        self.assertIn('Missing required', report['rows'][0]['error'])
        archive = json.loads((self.root / 'archive/manifest.json').read_bytes())
        self.assertTrue(any(x['source'].endswith('/measurement.json') for x in archive['files']))

    def test_false_checked_flag_is_not_success(self):
        for name in ['launch', 'result']:
            file = self.run / 'request' / (name + '.json')
            record = json.loads(file.read_bytes())
            record['result']['checked'] = False
            file.write_text(json.dumps(record))
        report = self.execute(self.plan)
        self.assertIn('successful checked emission', report['rows'][0]['error'])

    def test_cross_image_result_is_refused(self):
        file = self.run / 'request/result.json'
        record = json.loads(file.read_bytes())
        record['imageManifest']['sha256'] = '0' * 64
        file.write_text(json.dumps(record))
        report = self.execute(self.plan)
        self.assertIn('Cross-image', report['rows'][0]['error'])

    def test_duplicate_observation_not_counted_as_two_samples(self):
        # Stub only successful row auditing to isolate plan-inventory logic.
        self.plan['runs'].append({**self.plan['runs'][0], 'id': 'same-observation-again'})
        with patch.object(module, 'audit_row', return_value={'passed': True}):
            report = self.execute(self.plan)
        self.assertEqual(len(report['rows']), 2)
        self.assertIn('Duplicate observation', report['rows'][1]['error'])

    def test_wrong_shaped_plan_still_writes_incomplete_report(self):
        report = self.execute({'version': 1, 'runs': None})
        self.assertEqual(report['rows'], [])
        self.assertEqual(report['errors'][0]['run'], 'plan')

    def test_wrong_shaped_run_retains_placeholder_row(self):
        self.plan['runs'] = [None]
        report = self.execute(self.plan)
        self.assertEqual(len(report['rows']), 1)
        self.assertIn('Malformed run', report['rows'][0]['error'])

    def test_existing_archive_not_overwritten(self):
        output = self.root / 'archive'
        output.mkdir()
        (output / 'keep').write_text('old')
        with self.assertRaises(FileExistsError):
            module.main(self.root / 'unused-plan.json', output)
        self.assertEqual((output / 'keep').read_text(), 'old')

    def test_final_audit_rechecks_missing_paths(self):
        archive = module.Archive(self.root)
        file = self.root / 'appeared'
        archive.absent(str(file))
        file.write_text('new')
        with self.assertRaisesRegex(ValueError, 'Missing input appeared'):
            archive.finish()

    def test_nonfinite_or_malformed_timings_refused(self):
        for value in [None, True, '3', float('nan'), float('inf'), -1]:
            with self.assertRaises(ValueError):
                module.finite(value, 'timing')


if __name__ == '__main__':
    unittest.main(verbosity=2)
