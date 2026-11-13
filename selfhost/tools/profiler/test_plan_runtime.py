"""Metadata-only runtime profile planning controls; fixtures are not executables."""
import argparse
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import run
import compare

spec = importlib.util.spec_from_file_location('plan_runtime', Path(__file__).with_name('plan-runtime.py'))
planner = importlib.util.module_from_spec(spec)
spec.loader.exec_module(planner)


def fixture(root):
    def file(name, text):
        p = root/name
        p.write_text(text)
        return run.pin(p)
    source = file('source.bend', 'metadata fixture')
    oracle = file('expected', '42\n')
    sampler = file('sampler.so', 'metadata fixture; not a shared library')
    point = dict(expectedStdout='42\n', repetitions=1000, warmups=1,
                 runtimeArgs=[12, 34], ratioEligible=True)
    roles = {r: dict(target='x86') for r in ('parent', 'candidate')}
    products = {r: dict(artifact=file(r, 'metadata '+r), runtimeArgumentConvention='bend-rts-v1') for r in roles}
    document = dict(schema='bend-benchmark-manifest-v1', kind='programs', cwd=str(root), roles=roles,
                    inputs=[source, oracle, *[p['artifact'] for p in products.values()]],
                    cases=[dict(id='local-pair', point=point, source=source, expectedFile=oracle, products=products)])
    run.save(root/'programs.json', document)
    samples = []
    for role, cpu in [('parent', 1.0), ('candidate', .5)]:
        process = dict(command=planner.command(products[role], point, 1000), cpuSeconds=cpu,
                       seconds=1.1, exitCode=0, timedOut=False,
                       stdout=file(role+'.stdout', '42\n1\n1000\n1000\n'), stderr=file(role+'.stderr', ''))
        samples.append(dict(role=role, repetitions=1000, warmups=1, correct=True,
                            lowResolution=False, process=process))
    timing = dict(complete=True, changedInputs=[], roles=roles,
                  inputs=[run.pin(root/'programs.json'), *document['inputs']],
                  cases=[dict(id='local-pair', point=point, summary=dict(complete=True), samples=samples)])
    run.save(root/'timing.json', timing)
    run.save(root/'sampler.json', dict(complete=True, returncode=0, sampler=sampler,
                                     samplerScope='all_created_threads'))
    return argparse.Namespace(manifest=root/'programs.json', timing=root/'timing.json',
        sampler=root/'sampler.so', sampler_receipt=root/'sampler.json', cases='local-pair',
        roles='parent,candidate', seconds_per_run=2.9, periods_us='8000,13000', clean_rounds=1,
        cpu=3, out=root/'plan', capture_out=root/'capture', guard_out=root/'guard')


class RuntimePlanning(unittest.TestCase):
    def test_per_role_counts_have_separate_workload_identity(self):
        with tempfile.TemporaryDirectory() as directory:
            a = fixture(Path(directory))
            with patch.object(run, 'execute') as execute, patch.object(planner.B, 'child') as child:
                plan = planner.prepare(a)
                execute.assert_not_called()
                child.assert_not_called()
            self.assertFalse(plan['targetsRun'])
            self.assertEqual([r['repetitions'] for r in plan['estimates']], [2900, 5800])
            frozen = json.loads((a.out/'manifest.json').read_text())
            self.assertEqual(len({w['name'] for w in frozen['workloads']}), 2)
            identities = []
            for work, estimate in zip(frozen['workloads'], plan['estimates']):
                variant, = work['variants']
                identities.append(compare._source_identity(variant, frozen['cwd']))
                self.assertEqual(variant['command'][-4:], [str(estimate['repetitions']), '1', '12', '34'])
                self.assertEqual(variant['expected']['stdout']['prefix'], '42\n1\n'+str(estimate['repetitions'])+'\n')
                self.assertEqual(variant['runtimeArgumentConvention'], 'bend-rts-v1')
            self.assertNotEqual(*identities)
            self.assertNotIn('--reference', plan['offlineCommands'][0])
            self.assertFalse(a.capture_out.exists())
            self.assertFalse(a.guard_out.exists())

    def test_reject_mismatched_command_output_or_executable(self):
        for mutation in ('command', 'stdout', 'binary', 'manifest', 'sampler', 'cpu'):
            with self.subTest(mutation=mutation), tempfile.TemporaryDirectory() as directory:
                a = fixture(Path(directory))
                timing = json.loads(a.timing.read_text())
                process = timing['cases'][0]['samples'][0]['process']
                if mutation == 'command':
                    process['command'][-1] = '35'
                elif mutation == 'stdout':
                    path = Path(process['stdout']['file'])
                    path.write_text('42\n1\n999\n1000\n')
                    process['stdout'] = run.pin(path)
                elif mutation == 'binary':
                    (Path(directory)/'parent').write_text('changed binary')
                elif mutation == 'manifest':
                    timing['inputs'] = timing['inputs'][1:]
                elif mutation == 'sampler':
                    a.sampler.write_text('different sampler')
                elif mutation == 'cpu':
                    process['cpuSeconds'] = 0
                run.save(a.timing, timing)
                with self.assertRaises(ValueError):
                    planner.prepare(a)
                self.assertFalse(a.out.exists())

    def test_reject_unsafe_selection_or_nested_output(self):
        with tempfile.TemporaryDirectory() as directory:
            a = fixture(Path(directory))
            a.roles = 'parent,../candidate'
            with self.assertRaises(ValueError):
                planner.prepare(a)
            a.roles = 'parent,candidate'
            a.capture_out = a.out/'capture'
            with self.assertRaises(ValueError):
                planner.prepare(a)


if __name__ == '__main__':
    unittest.main()
