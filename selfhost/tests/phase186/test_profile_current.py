"""Offline guard/deadline controls; dispatcher execution is always mocked."""
import argparse
import importlib.util
import json
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('profile_current', Path(__file__).with_name('profile-current.py'))
M = importlib.util.module_from_spec(spec)
spec.loader.exec_module(M)


class GuardedProfile(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.manifest = self.root / 'manifest.json'
        self.manifest.write_text('{}')
        self.args = argparse.Namespace(guarded=True, cpu=3, seconds=80, manifest=self.manifest,
            role='p185-qbe', case=[['tree-bitonic', '7800']], out=self.root / 'selfhost/build/profile')

    def invoke(self, affinity={3}, environment=None):
        def prepare(a, out):
            jobs = out / 'jobs.json'
            jobs.write_text('{}')
            return jobs

        with patch.object(M.P, 'ROOT', self.root), \
             patch.object(M.P.L.os, 'sched_getaffinity', return_value=affinity), \
             patch.dict(M.P.L.os.environ, environment or {}, clear=True), \
             patch.object(M, 'prepare', side_effect=prepare), \
             patch.object(M.D, 'main', side_effect=lambda: list(sys.argv)):
            return M.execute(self.args)

    def test_guarded_dispatch_preserves_single_lane_and_remaining_deadline(self):
        command = self.invoke()
        self.assertIn('--guarded', command)
        self.assertEqual(command[command.index('--cpu') + 1], '3')
        remaining = float(command[command.index('--seconds') + 1])
        self.assertGreater(remaining, 0)
        self.assertLess(remaining, 80)
        self.assertEqual(Path(command[command.index('--out') + 1]), self.args.out / 'controller')
        self.assertTrue((self.args.out / 'preparation.json').is_file())

    def test_wrong_affinity_cannot_prepare_or_dispatch(self):
        with self.assertRaisesRegex(ValueError, 'CPU3'):
            self.invoke(affinity={0})
        self.assertFalse(self.args.out.exists())

    def test_missing_guard_cannot_prepare_or_dispatch(self):
        self.args.guarded = False
        with self.assertRaisesRegex(ValueError, 'CPU3'):
            self.invoke()
        self.assertFalse(self.args.out.exists())

    def test_outer_deadline_headroom_required(self):
        self.args.seconds = 90
        with self.assertRaisesRegex(ValueError, 'at most80'):
            self.invoke()
        self.assertFalse(self.args.out.exists())

    def test_ambient_runtime_options_refused(self):
        with self.assertRaisesRegex(ValueError, 'BENDRTS'):
            self.invoke(environment={'BENDRTS': '--threads 8'})
        self.assertFalse(self.args.out.exists())


class ManifestRolesAndReceipts(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.args = argparse.Namespace(manifest=self.root / 'manifest.json',
            role='actual-candidate-name', case=[['witness', '2000']])

    def run_prepare(self, target, jobs=None, cases=None):
        document = dict(roles={self.args.role: dict(target=target)}, cases=cases or [])
        def planner(a):
            a.out.mkdir(parents=True)
            (a.out / 'jobs.json').write_text(json.dumps(dict(jobs=jobs or [])))
        with patch.object(M.P.L, 'load', return_value=document), \
             patch.object(M.P, 'prepare', side_effect=planner) as planned:
            output = M.prepare(self.args, self.root / 'out')
            return planned.call_args.args[0], json.loads(output.read_text())

    def test_sampler_uses_target_not_role_spelling(self):
        planned, jobs = self.run_prepare('c')
        self.assertIn('phase159', str(planned.sampler))
        self.assertEqual(planned.role, 'actual-candidate-name')
        self.assertEqual(jobs['selectedRole'], 'actual-candidate-name')
        self.assertEqual(jobs['selectedTarget'], 'c')

    def test_c_spelling_does_not_override_x86_metadata(self):
        self.args.role = 'c'
        planned, _ = self.run_prepare('x86')
        self.assertIn('phase183', str(planned.sampler))

    def test_unknown_role_cannot_plan(self):
        with patch.object(M.P.L, 'load', return_value=dict(roles={'other': dict(target='qbe')})), \
             patch.object(M.P, 'prepare') as planner:
            with self.assertRaisesRegex(ValueError, 'Unknown manifest role'):
                M.prepare(self.args, self.root / 'out')
        planner.assert_not_called()

    def fixture(self, verified=True):
        source = self.root / 'source.bend'; source.write_text('witness')
        assembly = self.root / 'emission/witness/program.s'
        assembly.parent.mkdir(parents=True); assembly.write_text('assembly')
        binary = self.root / 'machine/program'; binary.parent.mkdir(); binary.write_bytes(b'ELF fixture')
        report = self.root / 'emission/report.json'
        row = dict(id='witness', source=M.P.B.pin(source), product=M.P.B.pin(assembly),
                   complete=True, verified=verified)
        report.write_text(json.dumps(dict(kind='phase185-checked-native-emission',
            target='x86', complete=True, rows=[row])))
        product = dict(artifact=M.P.B.pin(binary), generatedSource=M.P.B.pin(assembly),
                       inputs=[M.P.B.pin(report)])
        case = dict(id='witness', source=row['source'], products={self.args.role: product})
        return report, product, case

    def test_batch_receipt_binds_source_and_binary_without_combined_claim(self):
        report, product, case = self.fixture()
        build = self.root / 'machine/report.json'
        build.write_text(json.dumps(dict(request=None, sourceAssembly=product['generatedSource'],
                                        binary=product['artifact'])))
        product['inputs'].append(M.P.B.pin(build))
        job = dict(name='witness-owners', command=['owners.py', '--assembly',
            product['generatedSource']['file'], '--build-receipt', str(build)])
        _, jobs = self.run_prepare('x86', jobs=[job], cases=[case])
        self.assertNotIn('--build-receipt', jobs['jobs'][0]['command'])
        omission = jobs['ownerReceiptOmissions'][0]
        self.assertEqual(omission['separateEmissionReceipt'], M.P.B.pin(report))
        self.assertEqual(omission['binary'], product['artifact'])
        self.assertEqual(omission['generatedSource'], product['generatedSource'])

    def test_unverified_emission_row_refused(self):
        _, product, case = self.fixture(verified=False)
        with self.assertRaisesRegex(ValueError, 'authenticated separate emission'):
            M.separate_emission(case, product)

    def test_changed_receipt_refused(self):
        report, product, case = self.fixture()
        report.write_text('{}')
        with self.assertRaisesRegex(ValueError, 'Changed frozen input'):
            M.separate_emission(case, product)

    def test_separate_native_emission_receipt_remains_supported(self):
        report, product, case = self.fixture()
        report.write_text(json.dumps(dict(kind='bend-build-request', complete=True, target='x86',
            source=case['source'], product=product['generatedSource'], changedInputs=[])))
        product['inputs'] = [M.P.B.pin(report)]
        self.assertEqual(M.separate_emission(case, product), M.P.B.pin(report))

    def test_other_source_cannot_supply_matching_assembly_receipt(self):
        _, product, case = self.fixture()
        case['source'] = dict(case['source'], sha256='0' * 64)
        with self.assertRaisesRegex(ValueError, 'authenticated separate emission'):
            M.separate_emission(case, product)


if __name__ == '__main__':
    unittest.main()
