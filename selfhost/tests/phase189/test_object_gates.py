"""Mocked object bootstrap/qualification gates; no compiler or target executes."""
import copy
import json
from pathlib import Path
import sys
import unittest
from unittest.mock import patch

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
import bootstrap
import native
import qualification
import request
import test_x86 as fixtures
from common import pin, write_json


class ObjectGateFixtures(unittest.TestCase):
    file = fixtures.X86ObjectControls.file
    script = fixtures.X86ObjectControls.script
    save = fixtures.X86ObjectControls.save
    args = fixtures.X86ObjectControls.args
    xargs = fixtures.X86ObjectControls.xargs
    oargs = fixtures.X86ObjectControls.oargs
    setUp = fixtures.X86ObjectControls.setUp


class ObjectBootstrapGates(ObjectGateFixtures):
    def setUp(self):
        super().setUp()
        self.builds, self.emissions = [], []
        self.different_stage = self.failed_stage = None

    def fake_build(self, args):
        self.builds.append(copy.copy(args))
        args.out.mkdir()
        data = self.object_bytes + (b'\x00' if args.output_stage == self.different_stage else b'')
        (args.out / 'program.o').write_bytes(data)
        (args.out / 'program').write_bytes(b'opaque fixture ELF ' + args.output_stage.encode())
        report = dict(complete=args.output_stage != self.failed_stage)
        write_json(args.out / 'report.json', report)
        return report

    def fake_execute(self, args):
        self.emissions.append(copy.copy(args))
        args.out.mkdir()
        data = Path(args.expected).read_bytes() + (b'\x00' if self.different_stage == 'O3' else b'')
        (args.out / 'program.o').write_bytes(data)
        report = dict(complete=self.failed_stage != 'O3')
        write_json(args.out / 'report.json', report)
        return report

    def chain(self, args):
        with patch.object(native, 'build', side_effect=self.fake_build), \
             patch.object(request, 'execute', side_effect=self.fake_execute):
            return bootstrap.chain(args)

    def test_object_fixed_point_executes_n2_and_preserves_binary_reference(self):
        reference = self.file('reference.o', self.object_bytes)
        args = self.oargs(expected=reference, expected_emission='object')
        report = self.chain(args)
        self.assertTrue(report['complete'], report)
        self.assertTrue(report['objectFixedPoint'])
        self.assertEqual(report['emit'], 'object')
        self.assertEqual(report['emissionFormat'], request.X86_OBJECT_FORMAT)
        self.assertNotIn('assemblyFixedPoint', report)
        self.assertFalse(report['semanticsQualified'])
        self.assertFalse(report['selected'])
        self.assertEqual([row['stage'] for row in report['generations']], ['N1', 'N2', 'O3'])
        self.assertEqual(report['machineIdentity'], {'program.o': True, 'program': False})
        self.assertEqual(self.builds[1].image, args.out / 'n1/program')
        self.assertEqual(self.builds[1].image_receipt, args.out / 'n1/report.json')
        self.assertEqual(self.builds[1].expected, args.out / 'n1/program.o')
        final, = self.emissions
        self.assertEqual((final.host, final.stage, final.image_key), ('native', 'N2', None))
        self.assertEqual(final.image, args.out / 'n2/program')
        self.assertEqual(final.image_receipt, args.out / 'n2/report.json')
        self.assertEqual(final.expected, args.out / 'n2/program.o')
        self.assertEqual(final.out, args.out / 'o3')
        self.assertTrue(all(a.emit == 'object' for a in self.builds + self.emissions))
        self.assertFalse(list(args.out.glob('**/program.s')))
        self.assertEqual((args.out / 'o3/program.o').read_bytes(), self.object_bytes)

    def test_object_difference_at_any_generation_prevents_fixed_point(self):
        reference = self.file('reference.o', self.object_bytes)
        for stage in ('N1', 'N2', 'O3'):
            with self.subTest(stage=stage):
                self.builds.clear(); self.emissions.clear()
                self.different_stage = stage
                args = self.oargs(expected=reference, out=self.root / ('selfhost/build/diff-' + stage))
                report = self.chain(args)
                self.assertFalse(report['complete'])
                self.assertNotIn('objectFixedPoint', report)
                self.assertIn(stage + ' object differs', report['error'])
                self.assertEqual(len(self.emissions), int(stage == 'O3'))

    def test_failed_generation_is_not_an_object_fixed_point(self):
        for stage in ('N1', 'N2', 'O3'):
            with self.subTest(stage=stage):
                self.failed_stage = stage
                report = self.chain(self.oargs(out=self.root / ('selfhost/build/failed-' + stage)))
                self.assertFalse(report['complete'])
                self.assertNotIn('objectFixedPoint', report)


class ObjectQualificationGates(ObjectGateFixtures):
    def setUp(self):
        super().setUp()
        # Retain the actual 64 independent sources/oracles; only relocate their
        # paths so the synthetic image/assets workspace can authenticate them.
        self.catalog = json.loads(qualification.CATALOG.read_text())
        for case in self.catalog['cases']:
            for key in ('source', 'stdoutFile'):
                if key in case:
                    case[key]['file'] = str(ROOT / case[key]['file'])
        self.catalog_path = self.root / 'catalog.json'
        write_json(self.catalog_path, self.catalog)
        self.doc['upstream'] = self.catalog['upstream']
        self.doc['qualificationCatalog'] = pin(self.catalog_path)
        self.doc['assets'].pop('assembler')
        self.save()
        self.by_source = {c['source']['file']: c for c in self.catalog['cases']}
        self.by_name = {c['name']: c for c in self.catalog['cases']}
        self.defect = None

    def qargs(self, **changes):
        args = self.oargs(source=None, suite='all', case=None, build_seconds=3,
                          execute_seconds=3, program_engine_key='bun', catalog=None)
        for key, value in changes.items():
            setattr(args, key, value)
        return args

    def fake_run(self, command, *, stdout, stderr, **kwargs):
        command = list(map(str, command))
        self.calls.append(command)
        output, diagnostic, code = b'', b'', 0
        if command[0] == str(self.producer):
            self.assertEqual(command[-6], 'x86-object')
            case = self.by_source[command[-5]]
            if 'refusal' in case:
                rule = case['refusal']
                diagnostic = (rule['prefix'] + ('' if rule['exact'] else ' mocked reason') + '\n').encode()
                code = 1
                if self.defect == 'refusal-stage':
                    diagnostic = b'assembly: unrecognized request\n'
                elif self.defect == 'refusal-crash':
                    code = -9
                elif self.defect == 'refusal-output':
                    output = b'\x00'
            else:
                output = self.object_bytes
        elif command[0] == str(self.linker):
            Path(command[command.index('-o') + 1]).write_bytes(b'opaque mocked ELF')
        else:
            self.assertEqual(Path(command[0]).name, 'program')
            case = self.by_name[Path(command[0]).parent.parent.name.split('-', 1)[1]]
            output = case['expect']['stdout'].encode()
            diagnostic = case['expect']['stderr'].encode()
            code = case['expect']['exitCode']
            if self.defect == 'output-newline':
                output = output.rstrip(b'\n')
        Path(stdout).write_bytes(output)
        Path(stderr).write_bytes(diagnostic)
        return dict(started=1, complete=code == 0, exitCode=code, timedOut=False,
                    seconds=0, stdout=pin(stdout), stderr=pin(stderr), command=command)

    def qualify(self, args):
        with patch.object(request, 'run', side_effect=self.fake_run), \
             patch.object(native, 'run', side_effect=self.fake_run):
            return qualification.qualify(args)

    def test_full64_object_gate_keeps_oracles_refusals_and_catalog_binding(self):
        report = self.qualify(self.qargs())
        self.assertTrue(report['complete'], report)
        self.assertTrue(report['passed'], report['rows'])
        self.assertEqual(report['counts'], {'pass': 64, 'fail': 0, 'unsupported': 0})
        self.assertEqual(report['selected'], [c['id'] for c in self.catalog['cases']])
        self.assertEqual(report['catalog'], pin(self.catalog_path))
        self.assertEqual(report['emit'], 'object')
        self.assertEqual(report['emissionFormat'], request.X86_OBJECT_FORMAT)
        self.assertFalse(report['fullConformance'])
        self.assertNotIn(str(self.assembler), [p['file'] for p in report['inputs']])
        self.assertEqual(len(self.calls), 64 + 61 * 2)
        negative = [row for row in report['rows'] if 'expectedStage' in row]
        self.assertEqual(len(negative), 3)
        self.assertEqual({row['expectedStage'] for row in negative}, {'source-admission', 'backend-admission'})
        positive = next(row for row in report['rows'] if 'build' in row)
        build = json.loads(Path(positive['build']['file']).read_text())
        self.assertEqual([job['label'] for job in build['jobs']], ['link', 'execute'])
        self.assertTrue(build['outputExact'])
        self.assertFalse(list(self.qargs().out.glob('**/program.s')))

    def test_object_route_preserves_complete_output_and_refusal_failures(self):
        for defect in ('output-newline', 'refusal-stage', 'refusal-crash', 'refusal-output'):
            with self.subTest(defect=defect):
                self.defect = defect
                case = 'nt-reverse' if defect == 'output-newline' else 'negative-type'
                args = self.qargs(case=[case], out=self.root / ('selfhost/build/' + defect))
                report = self.qualify(args)
                self.assertTrue(report['complete'])
                self.assertFalse(report['passed'])
                self.assertEqual(report['counts'], {'pass': 0, 'fail': 1, 'unsupported': 0})

    def test_object_plan_checks_stage_and_bound_catalog_before_output(self):
        args = self.qargs(plan=True)
        report = qualification.qualify(args)
        self.assertEqual(len(report['supported']), 64)
        self.assertFalse(args.out.exists())
        with self.assertRaisesRegex(ValueError, 'Host/stage'):
            qualification.qualify(self.qargs(plan=True, stage='N1'))
        self.catalog_path.write_text(self.catalog_path.read_text() + '\n')
        with self.assertRaisesRegex(ValueError, 'Changed input'):
            qualification.qualify(args)
        self.assertFalse(args.out.exists())


if __name__ == '__main__':
    unittest.main()
