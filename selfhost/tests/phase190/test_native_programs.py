"""Metadata controls with mocked native builders/processes; no target execution."""
import argparse
import importlib.util
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('p190_native', Path(__file__).with_name('native-programs.py'))
N = importlib.util.module_from_spec(spec)
spec.loader.exec_module(N)


class NativePrograms(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        (self.root / 'selfhost/build').mkdir(parents=True)
        self.case = N.bench.catalog(N.CATALOG)['cases'][0]
        self.runtime = self.pin_file('runtime.o')
        self.image = self.pin_file('compiler')
        self.receipt = self.pin_file('image-receipt.json', '{}\n')
        self.asset_path = self.root / 'assets.json'
        self.asset_path.write_text('{}\n')
        self.base = self.pin_file('base.bend')
        self.carrier = self.pin_file('prepared-base.bend')
        self.compiler_source = self.pin_file('compiler.bend')
        self.calls, self.builds, self.plans = [], [], []

    def pin_file(self, name, text='Unexecuted metadata fixture\n'):
        file = self.root / name
        file.write_text(text)
        return N.common.pin(file)

    def arguments(self):
        return argparse.Namespace(workspace=self.root, assets=self.asset_path,
            host='native', stage='N2', target='x86', emit='object',
            image=Path(self.image['file']), image_receipt=Path(self.receipt['file']), image_key=None,
            role='candidate', cases=self.case['id'], out=self.root / 'selfhost/build/products',
            seconds=30, guarded=True, source=None, ir=None, plan=False,
            runtime=None, runtime_key='qbe-runtime', runtime_argument_convention=None,
            runtime_abi=None, expected=None, expected_stdout=None, retain_ir=True,
            output_stage=None, output_protocol=None, preparation='cache', mode='cache',
            backend=None, base=None, carrier=None, stamp=None, all=False)

    def plan(self, args):
        self.plans.append(args)
        self.assertEqual(args.host, 'native')
        self.assertEqual(args.stage, 'N2')
        self.assertEqual(args.target, 'x86')
        self.assertEqual(args.emit, 'object')
        self.assertEqual(args.source, Path(self.case['source']['file']))
        self.assertEqual(args.image, Path(self.image['file']))
        self.assertEqual(args.image_receipt, Path(self.receipt['file']))
        self.assertEqual(args.assets, self.asset_path)
        return dict(kind='bend-build-request-plan', host='native', stage='N2', target='x86',
            emit='object', source=self.case['source'], image=self.image, mode='cache',
            imageMetadata=dict(host='native', stage='N2', sourceIdentity=self.compiler_source),
            base=self.base, carrier=self.carrier, stamp='fixture-stamp',
            inputs=[self.image, self.receipt, self.base, self.carrier, self.case['source']])

    def build(self, args):
        self.builds.append(args)
        self.assertIsNone(args.ir)
        self.assertEqual(args.runtime_key, 'qbe-runtime')
        planned = self.plan(args)
        args.out.mkdir(parents=True)
        binary, obj = args.out / 'program', args.out / 'program.o'
        binary.write_text('Unexecuted executable fixture\n')
        obj.write_text('Unexecuted object fixture\n')
        result = dict(kind='bend-native-build', complete=True, changedInputs=[],
            inputs=planned['inputs'], request=planned, host='native', stage='N2',
            target='x86', emit='object', binary=N.common.pin(binary), object=N.common.pin(obj),
            retainedObject=N.common.pin(obj), runtime=self.runtime, runtimeABI=11102,
            runtimeArgumentConvention='bend-rts-v1', emissionFormat=N.request.X86_OBJECT_FORMAT,
            assemblerSkipped=True, jobs=[dict(label='compiler'), dict(label='link')])
        N.common.write_json(args.out / 'report.json', result)
        return result

    def mock_run(self, command, *, cwd, stdout, stderr, seconds):
        self.calls.append(command)
        self.assertEqual(command[1:8], ['+RTS', '--threads', '1', '--gpu', 'off', '-RTS', '--RTS'])
        self.assertEqual(command[8:], ['1', '0', *map(str, self.case['point']['runtimeArgs'])])
        stdout.write_text(self.case['point']['expectedStdout'] + '0\n1\n0\n')
        stderr.write_bytes(b'')
        return dict(complete=True, exitCode=0, seconds=.001,
            stdout=N.common.pin(stdout), stderr=N.common.pin(stderr))

    def execute(self, *, builder=None, runner=None, args=None):
        args = args or self.arguments()
        document = dict(_manifest=N.common.pin(self.asset_path))
        with patch.object(N, 'ROOT', self.root), \
             patch.object(N.os, 'sched_getaffinity', return_value={3}), \
             patch.dict(N.os.environ, {}, clear=True), \
             patch.object(N.assets, 'load_assets', return_value=document), \
             patch.object(N.assets, 'asset', return_value=self.runtime), \
             patch.object(N.request, 'plan', side_effect=self.plan), \
             patch.object(N.native, 'build', side_effect=builder or self.build), \
             patch.object(N.common, 'run', side_effect=runner or self.mock_run):
            result = N.execute(args)
        return result, args.out

    def test_fresh_native_object_freezes_actual_producer(self):
        result, out = self.execute()
        self.assertEqual(result, 0)
        manifest = N.bench.read(out / 'programs.manifest.json')
        role = manifest['roles']['candidate']
        self.assertEqual((role['host'], role['stage'], role['target']), ('native', 'N2', 'x86'))
        self.assertEqual(role['compiler'], self.image)
        self.assertEqual(role['runtime'], self.runtime)
        row = manifest['cases'][0]
        self.assertEqual(row['source'], self.case['source'])
        self.assertEqual(row['expectedFile'], self.case['expectedFile'])
        self.assertEqual(Path(row['products']['candidate']['generatedSource']['file']).suffix, '.o')
        self.assertEqual(len(self.calls), 1)

    def reject_build_change(self, change):
        def builder(args):
            result = self.build(args)
            change(result)
            N.common.write_json(args.out / 'report.json', result)
            return result
        result, out = self.execute(builder=builder)
        self.assertEqual(result, 1)
        self.assertFalse((out / 'programs.manifest.json').exists())
        self.assertEqual(self.calls, [])

    def test_assembler_fallback_refused(self):
        self.reject_build_change(lambda r: r['jobs'].append(dict(label='assemble')))

    def test_wrong_source_refused(self):
        wrong = self.pin_file('wrong-source.bend')
        self.reject_build_change(lambda r: r['request'].update(source=wrong))

    def test_wrong_runtime_refused(self):
        wrong = self.pin_file('wrong-runtime.o')
        self.reject_build_change(lambda r: r.update(runtime=wrong))

    def test_wrong_target_refused(self):
        self.reject_build_change(lambda r: r.update(target='qbe'))

    def test_wrong_image_refused(self):
        wrong = self.pin_file('wrong-compiler')
        self.reject_build_change(lambda r: r['request'].update(image=wrong))

    def test_wrong_runtime_abi_refused(self):
        self.reject_build_change(lambda r: r.update(runtimeABI=11101))

    def test_non_object_product_refused(self):
        wrong = self.pin_file('program.s')
        self.reject_build_change(lambda r: r.update(object=wrong))

    def test_frozen_partition_selection(self):
        catalog = N.bench.catalog(N.CATALOG)
        development, partition = N.select_cases('development', catalog)
        heldout, _ = N.select_cases('heldout', catalog)
        all_cases, _ = N.select_cases('all', catalog)
        self.assertEqual([case['id'] for case in development], [
            'local-fold', 'coverage-numeric-recurrence-256', 'variation-ray-active-64-2440',
            'coverage-map-churn-32', 'coverage-expression-32', 'tree-bitonic'])
        self.assertEqual(len(heldout), 39)
        self.assertEqual(len(all_cases), 45)
        self.assertEqual(set(partition['development']).intersection(partition['heldout']), set())
        with self.assertRaisesRegex(ValueError, 'duplicate'):
            N.select_cases(self.case['id'] + ',' + self.case['id'], catalog)
        with self.assertRaisesRegex(ValueError, 'Unknown'):
            N.select_cases('not-native45', catalog)

    def test_wrong_output_count_refused(self):
        def wrong(*args, **kwargs):
            result = self.mock_run(*args, **kwargs)
            kwargs['stdout'].write_text(self.case['point']['expectedStdout'] + '0\n2\n0\n')
            result['stdout'] = N.common.pin(kwargs['stdout'])
            return result
        result, out = self.execute(runner=wrong)
        self.assertEqual(result, 1)
        self.assertFalse((out / 'programs.manifest.json').exists())
        self.assertEqual(len(self.calls), 1)

    def test_wrong_complete_value_refused(self):
        def wrong(*args, **kwargs):
            result = self.mock_run(*args, **kwargs)
            kwargs['stdout'].write_text('wrong complete value\n0\n1\n0\n')
            result['stdout'] = N.common.pin(kwargs['stdout'])
            return result
        result, out = self.execute(runner=wrong)
        self.assertEqual(result, 1)
        self.assertFalse((out / 'programs.manifest.json').exists())
        self.assertEqual(len(self.calls), 1)


if __name__ == '__main__':
    unittest.main()
