"""Synthetic metadata only; no compiler or native program is executed."""
import argparse
import copy
import importlib.util
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch


def module(name, filename):
    spec = importlib.util.spec_from_file_location(name, Path(__file__).with_name(filename))
    value = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(value)
    return value


M = module('p185_merge_emissions', 'merge-emissions.py')
BUILDER = module('p185_build_programs', 'build-programs.py')


class MergeEmissions(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.build = self.root / 'selfhost/build'
        self.build.mkdir(parents=True)
        self.emitter = self.file('emit.mjs', 'unexecuted emitter fixture')
        engine = self.file('engine', 'unexecuted engine fixture')
        source = self.file('compiler.bend', 'unexecuted checked source fixture')
        api = self.file('api.mjs', 'unexecuted API fixture')
        authority = self.json('api.json', dict(kind='bend-checked-hosted-api', complete=True,
            checked=True, source=source, api=api, inputs=[source, engine]))
        base = self.file('base.bend', 'base fixture')
        carrier = self.file('base.carrier', 'carrier fixture')
        binding = self.json('binding.json', dict(kind='phase175-prepared-base',
            base=base, carrier=carrier, engine=engine, stamp='frozen-fixture-stamp'))
        cases = [dict(id=f'case-{i:02}', source=self.file(f'case-{i}.bend', f'source {i}'),
                      expectedFile=self.file(f'case-{i}.expected', f'{i}\n'),
                      point=dict(expectedStdout=f'{i}\n')) for i in range(45)]
        catalog = self.json('catalog.json', dict(cases=cases))
        self.catalog = Path(catalog['file'])
        self.prefix = [self.emitter, engine, authority, source, api, binding, base, carrier, catalog]
        self.paths = {}
        for name, selected, partial in [('partial', cases, True), ('supplement', cases[-1:], False)]:
            root = self.build / name
            root.mkdir()
            rows = []
            for case in selected:
                complete = not (partial and case == cases[-1])
                row = dict(id=case['id'], source=case['source'], complete=complete)
                if complete:
                    product = root / case['id'] / 'program.ssa'
                    product.parent.mkdir()
                    product.write_text('unexecuted output for ' + case['id'])
                    row.update(verified=True, product=M.C.pin(product))
                rows.append(row)
            report = dict(kind='phase185-checked-native-emission', target='qbe',
                complete=not partial, inputs=self.prefix + [c['source'] for c in selected], rows=rows)
            path = root / 'report.json'
            M.C.write_json(path, report)
            self.paths[name] = path
            guard_method = self.file(name + '-guard.py', 'guard fixture')
            support = self.file(name + '-support.py', 'support fixture')
            as_path = lambda pin: dict(path=pin['file'], bytes=pin['bytes'], sha256=pin['sha256'])
            guard = dict(kind='build-retention-disk-guard-v1', complete=not partial,
                returncode=-9 if partial else 0, wallSeconds=180.07 if partial else 3,
                artifactRoots=[str(root)], rssLimitBytes=2 * 1024**3, diskReserveBytes=5 * 1024**3,
                method=dict(cpu='3', guard=as_path(guard_method), support=as_path(support),
                    commandFiles=list(map(as_path, [engine, self.emitter, authority, binding]))),
                command=[engine['file'], self.emitter['file'], '--api', authority['file'],
                    '--binding', binding['file'], '--target', 'qbe', '--cases',
                    'all' if partial else cases[-1]['id'], '--out', str(root)])
            if partial:
                guard['stoppedFor'] = 'deadline'
            guard_path = self.build / (name + '-guard.json')
            M.C.write_json(guard_path, guard)
            self.paths[name + '_guard'] = guard_path
        self.args = argparse.Namespace(**self.paths, out=self.build / 'merged')
        self.before = {path: path.read_bytes() for path in self.paths.values()}

    def file(self, name, text):
        path = self.root / name
        path.write_text(text)
        return M.C.pin(path)

    def json(self, name, value):
        path = self.root / name
        M.C.write_json(path, value)
        return M.C.pin(path)

    def change(self, key, fn):
        path = self.paths[key]
        value = M.B.read(path)
        fn(value)
        M.C.write_json(path, value)

    def merge(self):
        with patch.object(M, 'ROOT', self.root), patch.object(M, 'CATALOG', self.catalog), \
             patch.object(M, 'EMITTER', Path(self.emitter['file'])):
            return M.merge(self.args)

    def refused(self, pattern):
        with self.assertRaisesRegex(ValueError, pattern):
            self.merge()
        self.assertFalse(self.args.out.exists())

    def test_complete_union_passes_downstream_reader_and_preserves_parents(self):
        result = self.merge()
        self.assertEqual(result['rows'], 45)
        self.assertFalse(result['targetsRun'])
        with patch.object(BUILDER, 'CATALOG', self.catalog):
            report, authority, _, _ = BUILDER.emission(result['report'])
        self.assertTrue(report['complete'])
        self.assertTrue(authority['checked'])
        self.assertEqual(report['merge']['partialGuard']['stoppedFor'], 'deadline')
        self.assertEqual(report['rows'][-1]['parentEmission'], M.C.pin(self.paths['supplement']))
        self.assertEqual(len({row['id'] for row in report['rows']}), 45)
        for path, original in self.before.items():
            self.assertEqual(path.read_bytes(), original)

    def test_unverified_or_errored_completed_row_refused(self):
        self.change('partial', lambda r: r['rows'][2].update(error='emitter failure'))
        self.refused('errored row')

    def test_changed_product_refused(self):
        report = M.B.read(self.paths['partial'])
        Path(report['rows'][0]['product']['file']).write_text('tampered output')
        self.refused('Changed or noncanonical identity')

    def test_changed_api_transitive_input_refused(self):
        Path(self.prefix[3]['file']).write_text('tampered compiler source')
        self.refused('Changed or noncanonical identity')

    def test_missing_or_duplicate_case_refused(self):
        self.change('supplement', lambda r: r['rows'].append(copy.deepcopy(r['rows'][0])))
        self.refused('Expected ordered')

    def test_incomplete_supplement_refused(self):
        self.change('supplement', lambda r: r['rows'][0].update(complete=False))
        self.refused('Incomplete, unverified or errored row')

    def test_non_deadline_partial_refused(self):
        self.change('partial_guard', lambda r: r.update(stoppedFor='rss'))
        self.refused('180-second deadline guard')

    def test_guard_wrong_output_scope_refused(self):
        self.change('partial_guard', lambda r: r['command'].__setitem__(-1, str(self.build / 'wrong')))
        self.refused('authenticate this emission scope')

    def test_different_target_refused(self):
        self.change('supplement', lambda r: r.update(target='x86'))
        self.refused('Invalid emitted product')

    def test_valid_but_different_binding_identity_refused(self):
        binding = M.B.read(self.prefix[5]['file'])
        binding['stamp'] = 'different-semantic-binding'
        other = self.json('other-binding.json', binding)
        self.change('supplement', lambda r: r['inputs'].__setitem__(5, other))
        self.refused('binding or catalog identity differs')

    def test_stale_guard_command_pin_refused(self):
        self.change('partial_guard', lambda r: r['method']['commandFiles'][1].update(sha256='0' * 64))
        self.refused('Changed or noncanonical identity')


if __name__ == '__main__':
    unittest.main()
