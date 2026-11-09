"""Bootstrap routing and complete-byte checks using mocks; no target executes."""
import argparse
import contextlib
import copy
import io
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.dont_write_bytecode = True
import bootstrap
from common import pin, write_json


class BootstrapControls(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        (self.root / 'selfhost').mkdir()
        self.source = self.root / 'compiler.bend'
        self.source.write_text('# exact profile source\n')
        self.seed = self.root / 'seed'
        self.seed.write_bytes(b'opaque seed identity')
        self.receipt = self.root / 'seed.json'
        self.receipt.write_text('{}\n')
        self.args = argparse.Namespace(target='x86', workspace=self.root, seconds=60,
            plan=False, out=self.root / 'selfhost/build/chain', image=self.seed,
            image_receipt=self.receipt, image_key=None, host='native', stage='N0',
            source=self.source, expected=None, runtime=self.root / 'runtime.o',
            runtime_key='qbe-runtime', runtime_abi=11102,
            runtime_argument_convention='bend-rts-v1')
        self.planned = dict(inputs=[pin(self.source), pin(self.seed), pin(self.receipt)],
                            source=pin(self.source), image=pin(self.seed))
        self.builds, self.emissions = [], []
        self.failed_stage = self.different_stage = None
        self.assembly = b'.text\n# exact complete assembly\n\n'

    def fake_build(self, args):
        self.builds.append(copy.copy(args))
        args.out.mkdir()
        (args.out / 'program.ssa').write_bytes(b'# exact QBE\n')
        assembly = self.assembly + (b'# changed\n' if self.different_stage == args.output_stage else b'')
        (args.out / 'program.s').write_bytes(assembly)
        # Object and ELF equality are deliberately independent of emitted assembly.
        (args.out / 'program.o').write_bytes(args.output_stage.encode())
        (args.out / 'program').write_bytes(b'opaque mocked ELF '+args.output_stage.encode())
        report = dict(complete=self.failed_stage != args.output_stage)
        write_json(args.out / 'report.json', report)
        return report

    def fake_execute(self, args):
        self.emissions.append(copy.copy(args))
        args.out.mkdir()
        emitted = 'program.s' if args.target == 'x86' else 'program.ssa'
        data = Path(args.expected).read_bytes()
        if self.different_stage == 'S3':
            data += b'# changed\n'
        (args.out / emitted).write_bytes(data)
        report = dict(complete=self.failed_stage != 'S3')
        write_json(args.out / 'report.json', report)
        return report

    def run_chain(self):
        with patch.object(bootstrap.requests, 'plan', return_value=self.planned), \
             patch.object(bootstrap.native, 'build', side_effect=self.fake_build), \
             patch.object(bootstrap.requests, 'execute', side_effect=self.fake_execute):
            return bootstrap.chain(self.args)

    def test_x86_uses_actual_generations_assembly_protocol_and_full_comparisons(self):
        reference = self.root / 'reference.s'
        reference.write_bytes(self.assembly)
        self.args.expected = reference
        report = self.run_chain()
        self.assertTrue(report['complete'], report)
        self.assertEqual(report['kind'], 'bend-native-bootstrap-chain')
        self.assertEqual(report['target'], 'x86')
        self.assertTrue(report['assemblyFixedPoint'])
        self.assertNotIn('qbeFixedPoint', report)
        self.assertEqual([row['stage'] for row in report['generations']], ['N1', 'N2', 'S3'])
        self.assertEqual(report['source'], pin(self.source))
        self.assertEqual(report['producer'], pin(self.seed))
        self.assertEqual(report['producerStage'], 'N0')
        self.assertEqual(report['machineIdentity'], {'program.s': True, 'program.o': False, 'program': False})
        self.assertFalse(report['semanticsQualified'])
        self.assertFalse(report['selected'])
        first, second = self.builds
        final, = self.emissions
        self.assertEqual(first.image, self.seed)
        self.assertEqual(first.expected, reference)
        self.assertEqual((second.host, second.stage, second.image_key), ('native', 'N1', None))
        self.assertEqual(second.image, self.args.out / 'n1/program')
        self.assertEqual(second.image_receipt, self.args.out / 'n1/report.json')
        self.assertEqual(second.expected, self.args.out / 'n1/program.s')
        self.assertEqual((final.host, final.stage, final.image_key), ('native', 'N2', None))
        self.assertEqual(final.image, self.args.out / 'n2/program')
        self.assertEqual(final.image_receipt, self.args.out / 'n2/report.json')
        self.assertEqual(final.expected, self.args.out / 'n2/program.s')
        self.assertEqual(final.out, self.args.out / 's3')
        for args in self.builds:
            self.assertEqual(args.output_protocol, 'native-x86-source-v1')
            self.assertEqual(args.runtime_abi, 11102)
            self.assertEqual(args.runtime_argument_convention, 'bend-rts-v1')
            self.assertIsNone(args.ir)
            self.assertTrue(args.retain_ir)
        for args in self.builds + self.emissions:
            self.assertEqual(args.target, 'x86')
            self.assertEqual(args.source, self.source)
            self.assertGreater(args.seconds, 0)
            self.assertLessEqual(args.seconds, self.args.seconds)

    def test_qbe_paths_protocol_and_fields_are_preserved(self):
        self.args.target = 'qbe'
        report = self.run_chain()
        self.assertTrue(report['complete'], report)
        self.assertTrue(report['qbeFixedPoint'])
        self.assertNotIn('assemblyFixedPoint', report)
        self.assertEqual([row['stage'] for row in report['generations']], ['N1', 'N2', 'Q3'])
        self.assertEqual(set(report['machineIdentity']), {'program.ssa', 'program.s', 'program.o', 'program'})
        self.assertEqual(self.builds[1].expected, self.args.out / 'n1/program.ssa')
        self.assertTrue(all(args.output_protocol == 'qbe-source-v1' for args in self.builds))
        self.assertEqual(self.emissions[0].out, self.args.out / 'q3')
        self.assertEqual(self.emissions[0].expected, self.args.out / 'n2/program.ssa')

    def test_different_n1_reference_stops_before_n2(self):
        self.args.expected = self.root / 'wrong.s'
        self.args.expected.write_bytes(self.assembly.rstrip())
        report = self.run_chain()
        self.assertFalse(report['complete'])
        self.assertIn('N1 assembly differs', report['error'])
        self.assertEqual(len(self.builds), 1)
        self.assertFalse(self.emissions)
        self.assertNotIn('assemblyFixedPoint', report)

    def test_different_n2_assembly_stops_before_s3(self):
        self.different_stage = 'N2'
        report = self.run_chain()
        self.assertFalse(report['complete'])
        self.assertIn('N2 assembly differs', report['error'])
        self.assertFalse(self.emissions)
        self.assertNotIn('assemblyFixedPoint', report)

    def test_different_s3_assembly_cannot_claim_fixed_point(self):
        self.different_stage = 'S3'
        report = self.run_chain()
        self.assertFalse(report['complete'])
        self.assertIn('S3 assembly differs', report['error'])
        self.assertEqual(len(self.emissions), 1)
        self.assertNotIn('assemblyFixedPoint', report)

    def test_failed_native_generation_cannot_claim_fixed_point(self):
        self.failed_stage = 'N1'
        report = self.run_chain()
        self.assertFalse(report['complete'])
        self.assertIn('N1 generation failed', report['error'])
        self.assertEqual(len(self.builds), 1)
        self.assertFalse(self.emissions)

    def test_failed_final_emission_cannot_claim_fixed_point(self):
        self.failed_stage = 'S3'
        report = self.run_chain()
        self.assertFalse(report['complete'])
        self.assertIn('N2 S3 execution failed', report['error'])
        self.assertNotIn('assemblyFixedPoint', report)

    def test_cli_accepts_optional_explicit_runtime_abi(self):
        argv = ['bootstrap.py', '--assets', 'assets.json', '--image-key', 'producer', '--host', 'native',
                '--stage', 'N0', '--source', 'compiler.bend', '--out', 'out',
                '--target', 'x86', '--runtime', 'runtime.o', '--runtime-abi', '11102']
        with patch.object(sys, 'argv', argv), patch.object(bootstrap, 'chain', return_value={'complete': True}) as run, \
             contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(bootstrap.main(), 0)
        self.assertEqual(run.call_args.args[0].runtime_abi, 11102)


if __name__ == '__main__':
    unittest.main()
