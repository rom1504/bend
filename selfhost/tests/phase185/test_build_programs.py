"""Transport controls with mocked builders/processes; no compiler or target runs."""
import argparse
import importlib.util
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('p185_build', Path(__file__).with_name('build-programs.py'))
B = importlib.util.module_from_spec(spec)
spec.loader.exec_module(B)


class BuildPrograms(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        (self.root / 'selfhost/build').mkdir(parents=True)
        self.case = B.bench.catalog(B.CATALOG)['cases'][0]
        self.runtime = self.pin_file('runtime.o')
        source, api = self.pin_file('compiler.bend'), self.pin_file('api.mjs')
        authority = self.root / 'api.json'
        B.common.write_json(authority, dict(kind='bend-checked-hosted-api', complete=True,
                                          checked=True, source=source, api=api))
        self.report = dict(kind='phase185-checked-native-emission', complete=True, target='qbe',
            inputs=[source, api, B.common.pin(authority), self.case['source']],
            rows=[dict(id=self.case['id'], source=self.case['source'],
                       product=self.pin_file('program.ssa'), complete=True, verified=True)])
        self.emission = self.root / 'emission.json'
        self.calls = []

    def pin_file(self, name):
        path = self.root / name
        path.write_text('Unexecuted metadata fixture\n')
        return B.common.pin(path)

    def build(self, args):
        self.assertIsNone(args.source)
        self.assertIsNone(args.image)
        self.assertIsNone(args.image_key)
        self.assertEqual(args.runtime_key, 'qbe-runtime')
        self.assertEqual(args.target, self.report['target'])
        self.assertEqual(args.ir, Path(self.report['rows'][0]['product']['file']))
        args.out.mkdir()
        binary = args.out / 'program'
        binary.write_text('Unexecuted ELF fixture\n')
        result = dict(kind='bend-native-build', complete=True, changedInputs=[], inputs=[],
                      binary=B.common.pin(binary), runtimeArgumentConvention='bend-rts-v1')
        B.common.write_json(args.out / 'report.json', result)
        return result

    def mock_run(self, command, *, cwd, stdout, stderr, seconds):
        self.calls.append(command)
        self.assertEqual(command[1:8], ['+RTS', '--threads', '1', '--gpu', 'off', '-RTS', '--RTS'])
        self.assertEqual(command[8:], ['1', '0', *map(str, self.case['point']['runtimeArgs'])])
        stdout.write_text(self.case['point']['expectedStdout'] + '0\n1\n0\n')
        stderr.write_bytes(b'')
        return dict(complete=True, command=command, timedOut=False, exitCode=0, seconds=.001,
                    stdout=B.common.pin(stdout), stderr=B.common.pin(stderr))

    def execute(self, runner=None):
        B.common.write_json(self.emission, self.report)
        args = argparse.Namespace(emission=self.emission, role='candidate',
            out=self.root / 'selfhost/build/products', seconds=30, guarded=True)
        document = dict(_manifest=B.common.pin(B.ASSETS))
        with patch.object(B, 'ROOT', self.root), patch.object(B.os, 'sched_getaffinity', return_value={3}), \
             patch.dict(B.os.environ, {}, clear=True), \
             patch.object(B.assets, 'load_assets', return_value=document), \
             patch.object(B.assets, 'asset', return_value=self.runtime), \
             patch.object(B.native, 'build', side_effect=self.build), \
             patch.object(B.common, 'run', side_effect=runner or self.mock_run):
            result = B.execute(args)
        return result, args.out

    def test_qbe_and_x86_freeze_exact_products(self):
        for target in ('qbe', 'x86'):
            with self.subTest(target=target):
                self.report['target'] = target
                self.report['rows'][0]['product'] = self.pin_file('program.ssa' if target == 'qbe' else 'program.s')
                result, out = self.execute()
                self.assertEqual(result, 0)
                manifest = B.bench.read(out / 'programs.manifest.json')
                self.assertEqual(manifest['roles']['candidate']['target'], target)
                product = manifest['cases'][0]['products']['candidate']
                self.assertEqual(product['generatedSource'], self.report['rows'][0]['product'])
                self.assertEqual(product['runtimeArgumentConvention'], 'bend-rts-v1')
                out.rename(out.with_name(target))

    def test_wrong_output_retains_failed_receipt_without_manifest(self):
        def wrong(*args, **kwargs):
            result = self.mock_run(*args, **kwargs)
            kwargs['stdout'].write_text('wrong\n')
            result['stdout'] = B.common.pin(kwargs['stdout'])
            return result
        result, out = self.execute(wrong)
        self.assertEqual(result, 1)
        self.assertFalse((out / 'programs.manifest.json').exists())
        self.assertTrue((out / self.case['id'] / 'oracle-process.json').is_file())

    def test_incomplete_emission_refused(self):
        self.report['complete'] = False
        with self.assertRaisesRegex(ValueError, 'Complete checked emission'):
            self.execute()
        self.assertEqual(self.calls, [])

    def test_source_mismatch_refused(self):
        self.report['rows'][0]['source'] = self.pin_file('wrong-source.bend')
        with self.assertRaisesRegex(ValueError, 'source differs from native45'):
            self.execute()
        self.assertEqual(self.calls, [])


if __name__ == '__main__':
    unittest.main()
