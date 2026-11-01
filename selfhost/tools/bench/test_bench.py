"""Offline contract controls; no Bend compiler or benchmark is executed."""
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

HERE = Path(__file__).resolve().parent
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
