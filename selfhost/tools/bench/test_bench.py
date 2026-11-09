"""Offline contract controls; no Bend compiler or benchmark is executed."""
import importlib.util
import json
from pathlib import Path
import sys
import tempfile
import unittest

HERE = Path(__file__).resolve().parent
# unittest.mock needs stdlib inspect, not this directory's inspect.py.
_import_path = sys.path[:]
try:
    sys.path[:] = [entry for entry in sys.path if Path(entry).resolve() != HERE]
    from unittest import mock
finally:
    sys.path[:] = _import_path

spec = importlib.util.spec_from_file_location('bench', HERE / 'bench.py')
B = importlib.util.module_from_spec(spec)
spec.loader.exec_module(B)


class Contracts(unittest.TestCase):
    def test_native_complete_oracle(self):
        point = dict(expectedStdout='complete\nresult\n', warmups=2, repetitions=17)
        self.assertEqual(B.observation(b'complete\nresult\n2\n17\n105\n', b'', 0, point, .11), 105)
        for stdout, stderr, status in [(b'complete\nresult\n2\n16\n105\n', b'', 0),
                                       (b'complete\nresult\n2\n17\n105\nextra', b'', 0),
                                       (b'complete\nresult\n2\n17\n105\n', b'warning', 0),
                                       (b'complete\nresult\n2\n17\n105\n', b'', 1)]:
            with self.assertRaises(ValueError):
                B.observation(stdout, stderr, status, point, .11)
        with self.assertRaises(ValueError):
            B.observation(b'complete\nresult\n2\n17\n120\n', b'', 0, point, .11)

    def test_unmatched_or_failed_round_has_no_ratio(self):
        rows = [dict(role='reference', round=0, correct=True, metricMs=10),
                dict(role='candidate', round=0, correct=True, metricMs=20),
                dict(role='candidate', round=1, correct=True, metricMs=1)]
        self.assertIsNone(B.summary(rows, ['reference', 'candidate'], 'reference', 2)['ratios'])
        rows.append(dict(role='reference', round=1, correct=False, metricMs=10))
        self.assertIsNone(B.summary(rows, ['reference', 'candidate'], 'reference', 2)['ratios'])
        self.assertEqual(B.summary(rows[:2], ['reference', 'candidate'], 'reference', 1)['ratios'], {'candidate': 2})

    def test_zero_work_and_low_resolution_not_ratio(self):
        rows = [dict(role='reference', round=0, correct=True, metricMs=1),
                dict(role='candidate', round=0, correct=True, metricMs=2)]
        self.assertIsNone(B.summary(rows, ['reference', 'candidate'], 'reference', 1, False)['ratios'])
        rows[-1]['lowResolution'] = True
        self.assertIsNone(B.summary(rows, ['reference', 'candidate'], 'reference', 1)['ratios'])

    def test_run_preserves_each_cases_catalog_eligibility(self):
        native = B.catalog(HERE / 'catalogs/native45/catalog.json')
        known = {row['id']: row for row in native['cases']}
        zero, positive = 'scalar-region-0', 'scalar-region-8192'
        for order in ((zero, positive), (positive, zero)):
            for positive_ms in (99, 100):
                with self.subTest(order=order, positive_ms=positive_ms), tempfile.TemporaryDirectory() as directory:
                    root = Path(directory)
                    roles = dict(reference=dict(target='qbe'), candidate=dict(target='x86'))
                    cases, commands = [], {}
                    for name in order:
                        products = {}
                        for role in roles:
                            artifact = str(root / f'{name}-{role}')
                            products[role] = dict(artifact=dict(file=artifact))
                            commands[artifact] = (name, role)
                        cases.append(dict(known[name], products=products))
                    manifest = dict(schema='bend-benchmark-manifest-v1', kind='programs',
                                    reference='reference', roles=roles, cases=cases,
                                    sets=dict(full=list(order)), cwd=str(root), inputs=[])
                    manifest_path = root / 'manifest.json'
                    B.save(manifest_path, manifest, fresh=True)
                    args = B.argparse.Namespace(manifest=manifest_path, budget=20, set='full',
                                                cases=None, rounds=2, scale=1, plan=False,
                                                guarded=True, cpu=3, out=root / 'run')

                    def fake_child(command, directory, deadline, cwd):
                        name, role = commands[command[0]]
                        point = known[name]['point']
                        ms = (1 if name == zero else positive_ms) * (2 if role == 'candidate' else 1)
                        directory.mkdir(parents=True)
                        stdout, stderr = directory / 'stdout', directory / 'stderr'
                        stdout.write_text(point['expectedStdout'] +
                                          f"{point['warmups']}\n{point['repetitions']}\n{ms}\n")
                        stderr.write_bytes(b'')
                        return dict(exitCode=0, timedOut=False, seconds=ms / 1000 + .01,
                                    stdout=B.pin(stdout), stderr=B.pin(stderr))

                    with mock.patch.object(B, 'child', side_effect=fake_child) as child, \
                            mock.patch.object(B.os, 'sched_getaffinity', return_value={3}), \
                            mock.patch.dict(B.os.environ, {}, clear=True), mock.patch('builtins.print'):
                        self.assertEqual(B.run(args), 0)
                    self.assertEqual(child.call_count, 8)
                    report = B.read(args.out / 'report.json')
                    self.assertTrue(report['complete'])
                    rows = {row['id']: row for row in report['cases']}
                    for name, row in rows.items():
                        eligible = known[name]['point']['ratioEligible']
                        self.assertEqual(row['summary']['ratioEligible'], eligible)
                        self.assertEqual(row['summary']['pairedRounds'], [0, 1])
                        self.assertTrue(all(sample['correct'] for sample in row['samples']))
                        for sample in row['samples']:
                            self.assertEqual(sample['lowResolution'], eligible and sample['elapsedMs'] < 100)
                    self.assertIsNone(rows[zero]['summary']['ratios'])
                    if positive_ms < 100:
                        self.assertIsNone(rows[positive]['summary']['ratios'])
                        self.assertFalse(report['aggregate']['complete'])
                    else:
                        self.assertEqual(rows[positive]['summary']['ratios'], {'candidate': 2})
                        self.assertTrue(report['aggregate']['complete'])
                        self.assertEqual(report['aggregate']['timedCases'], 1)
                        self.assertEqual(report['aggregate']['correctnessOnlyCases'], 1)
                        self.assertAlmostEqual(report['aggregate']['roles']['candidate']['geomean'], 2)

    def test_equal_source_weighting_is_distinct(self):
        cases = [dict(id=str(index), family='family', sourceGroup=source,
                      summary=dict(ratioEligible=True, ratios={'candidate': ratio}))
                 for index, (source, ratio) in enumerate([('a', 4), ('a', 4), ('b', 1)])]
        result = B.aggregate(cases, ['reference', 'candidate'], 'reference')['roles']['candidate']
        self.assertAlmostEqual(result['geomean'], 16 ** (1 / 3))
        self.assertAlmostEqual(result['equalSourceGeomean'], 2)

    def test_catalogs_and_native_oracles_preserved(self):
        js = B.catalog(HERE / 'catalogs/original45/catalog.json')
        native = B.catalog(HERE / 'catalogs/native45/catalog.json')
        old = B.catalog(HERE / 'catalogs/historical15/catalog.json')
        self.assertEqual((len(js['cases']), len(native['cases']), len(old['cases'])), (45, 45, 15))
        self.assertEqual({r['id'] for r in js['cases']}, {r['id'] for r in native['cases']})
        self.assertEqual(sum(row['point']['ratioEligible'] for row in native['cases']), 44)
        self.assertEqual(len({row['sourceGroup'] for row in native['cases']}), 23)
        for row in native['cases']:
            self.assertEqual(Path(row['expectedFile']['file']).read_text(), row['point']['expectedStdout'])

    def test_x86_freeze_uses_unchanged_native_catalog_and_runtime_contract(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory); binary=root/'program';binary.write_text('unexecuted fixture')
            catalog=HERE/'catalogs/native45/catalog.json'
            role=dict(host='native',stage='N1',target='x86',preparation='cache',policy='ordinary',status='fixture')
            product=dict(artifact=str(binary),runtimeArgumentConvention='bend-rts-v1')
            recipe=dict(kind='programs',catalog=str(catalog),reference='assembly',roles=dict(assembly=role),
                        cases=[dict(id='scalar-region-0',products=dict(assembly=product))])
            recipe_file=root/'recipe.json';recipe_file.write_text(json.dumps(recipe))
            frozen=B.freeze(recipe_file,root/'manifest.json')
            case=frozen['cases'][0]
            expected=next(row for row in B.catalog(catalog)['cases'] if row['id']==case['id'])
            self.assertEqual(case['point'],expected['point'])
            self.assertEqual(case['expectedFile'],expected['expectedFile'])
            self.assertFalse(case['point']['ratioEligible'])
            self.assertEqual(case['products']['assembly']['runtimeArgumentConvention'],'bend-rts-v1')

    def test_partial_acquisition_does_not_shrink_selection(self):
        manifest = dict(sets=dict(fast=['a', 'b']), cases=[dict(id='a')])
        with self.assertRaises(ValueError):
            B.select(manifest, 20)
        self.assertEqual(B.select(manifest, 20, names='a'), [dict(id='a')])

    def test_identity_and_fresh_output(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'value'
            path.write_text('first')
            frozen = B.pin(path)
            path.write_text('second')
            with self.assertRaises(ValueError):
                B.verify(frozen)
            with self.assertRaises(FileExistsError):
                B.save(path, {}, fresh=True)

    def test_conflicting_pins_not_last_writer_wins(self):
        first = dict(file='/example', bytes=1, sha256='a')
        second = dict(file='/example', bytes=1, sha256='b')
        self.assertEqual(B.unique_inputs([first, first]), [first])
        with self.assertRaises(ValueError):
            B.unique_inputs([first, second])

    def test_streaming_equality_includes_eof(self):
        with tempfile.TemporaryDirectory() as directory:
            a, b = Path(directory) / 'a', Path(directory) / 'b'
            a.write_bytes(b'x' * (1024 * 1024 + 10))
            b.write_bytes(a.read_bytes())
            self.assertTrue(B.same_bytes(a, b))
            b.write_bytes(b.read_bytes() + b'\n')
            self.assertFalse(B.same_bytes(a, b))


if __name__ == '__main__':
    unittest.main()
