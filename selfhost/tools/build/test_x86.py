"""Metadata and mocked byte-transport checks; no compiler or target is executed."""
import os
from pathlib import Path
import sys
import unittest
from unittest.mock import patch

sys.dont_write_bytecode = True
import assets
import native
import request
import test_build as fixtures
from common import pin


class X86Controls(unittest.TestCase):
    file = fixtures.BuildFixtures.file
    script = fixtures.BuildFixtures.script
    save = fixtures.BuildFixtures.save
    args = fixtures.BuildFixtures.args

    def setUp(self):
        fixtures.BuildFixtures.setUp(self)
        self.doc['assets'].pop('qbe')
        self.doc['toolchains']['x86'] = self.doc['toolchains'].pop('qbe')
        self.doc['images']['producer'].update(targets=['x86'], protocol='native-x86-source-v1',
                                             runtimeArgumentConvention='bend-rts-v1')
        self.doc['runtimePolicies'] = {'qbe-runtime': dict(runtimeABI=11102, runtimeArgumentConvention='bend-rts-v1')}
        self.save()
        self.calls = []
        self.assembly = b'.text\n# exact assembly fixture\n\n'

    def xargs(self, **changes):
        values = dict(target='x86', output_protocol='native-x86-source-v1')
        values.update(changes)
        return self.args(**values)

    def fake_run(self, command, *, cwd, stdout, stderr, seconds, **kwargs):
        command = list(map(str, command)); self.calls.append(command)
        if command[0] == str(self.producer):
            Path(stdout).write_bytes(self.assembly)
        else:
            Path(stdout).write_bytes(b'')
            if '-o' in command:
                Path(command[command.index('-o')+1]).write_bytes(b'opaque mocked product')
        Path(stderr).write_bytes(b'')
        return dict(complete=True, exitCode=0, timedOut=False, seconds=0,
                    stdout=pin(stdout), stderr=pin(stderr), command=command)

    def test_native_request_modes_and_provider_rts(self):
        with patch.dict(os.environ, {}, clear=True):
            cache = request.plan(self.xargs())
            live = request.plan(self.xargs(mode='live'))
        prefix = [str(self.producer), '+RTS', '--threads', '1', '--gpu', 'off', '-RTS', '--RTS', 'x86']
        self.assertEqual(cache['command'], prefix+[str(self.source), str(self.base), 'cache', str(self.carrier), self.doc['preparedBase']['stamp']])
        self.assertEqual(live['command'], prefix+[str(self.source), str(self.base), 'live', '', ''])
        self.doc['images']['producer'].pop('runtimeArgumentConvention'); self.save()
        self.assertEqual(request.plan(self.xargs())['command'][1:7], ['--threads','1','--gpu','off','--','x86'])

    def test_plan_requires_no_qbe_and_preserves_target_runtime_policy(self):
        self.doc['images']['producer'].pop('runtimeArgumentConvention'); self.save()
        planned = native.build(self.xargs(plan=True))
        self.assertEqual(planned['target'], 'x86')
        self.assertEqual(planned['runtimeABI'], 11102)
        self.assertEqual(planned['runtimeArgumentConvention'], 'bend-rts-v1')
        self.assertNotIn('qbeCommand', planned)
        self.assertNotIn('expectedQbe', planned)
        self.assertNotIn('sourceIR', planned)
        self.assertNotIn(str(self.qbe), [row['file'] for row in planned['inputs']])
        self.assertEqual(planned['compilerCommand'][1:7], ['--threads','1','--gpu','off','--','x86'])
        self.assertFalse(self.xargs().out.exists())

    def test_wrong_protocol_host_abi_and_missing_machine_policy_refused(self):
        with self.assertRaisesRegex(ValueError, 'target'):
            request.plan(self.xargs(target='qbe'))
        self.doc['images']['producer'].update(host='js', protocol='hosted-api-v1', checked=True); self.save()
        with self.assertRaisesRegex(ValueError, 'native emitter'):
            request.plan(self.xargs(host='js'))
        self.doc['runtimePolicies']['qbe-runtime'].pop('runtimeABI'); self.save()
        with self.assertRaisesRegex(ValueError, 'runtimeABI'):
            native.build(self.xargs(plan=True))
        self.doc['runtimePolicies']['qbe-runtime']['runtimeABI'] = 11101; self.save()
        with self.assertRaisesRegex(ValueError, 'runtimeABI'):
            native.build(self.xargs(plan=True))
        with self.assertRaisesRegex(ValueError, 'toolchain'):
            assets.native_toolchain({'toolchains': {'qbe': self.doc['toolchains']['x86']}}, 'x86')

    def test_runtime_abi_conflicts_and_explicit_override_need_identity(self):
        self.doc['assets']['qbe-runtime']['runtimeABI'] = 11101
        with self.assertRaisesRegex(ValueError, 'Conflicting'):
            assets.runtime_provider(self.doc, 'qbe-runtime')
        for value in [True, 0, -1, '11102']:
            with self.assertRaises(ValueError): assets.runtime_abi({'runtimeABI': value})
        with self.assertRaisesRegex(ValueError, 'explicit --runtime'):
            native.build(self.xargs(plan=True, runtime_abi=11102))
        result = native.build(self.xargs(plan=True, runtime=self.runtime, runtime_abi=11102,
                                        runtime_argument_convention='bend-rts-v1'))
        self.assertEqual(result['runtimeABI'], 11102)

    def test_mocked_emission_preserves_complete_bytes_and_derived_generation(self):
        expected = self.file('expected.s', self.assembly)
        with patch('native.run', side_effect=self.fake_run):
            result = native.build(self.xargs(expected=expected, output_stage='N1', output_protocol=None))
        self.assertTrue(result['complete'], result)
        self.assertTrue(result['comparedToReference'])
        self.assertEqual(Path(result['assembly']['file']).read_bytes(), self.assembly)
        self.assertEqual([row['label'] for row in result['jobs']], ['compiler','assemble','link'])
        self.assertEqual(result['imageBinding']['targets'], ['x86'])
        self.assertEqual(result['imageBinding']['protocol'], 'native-x86-source-v1')
        self.assertEqual(result['imageBinding']['stage'], 'N1')
        self.assertEqual(result['imageBinding']['linkedRuntimeABI'], 11102)

    def test_derived_protocol_defaults_and_explicit_seed_overrides(self):
        self.assertEqual(native.derived_protocol('qbe'), 'qbe-source-v1')
        self.assertEqual(native.derived_protocol('x86'), 'native-x86-source-v1')
        self.assertEqual(native.derived_protocol('qbe', 'native-x86-source-v1'), 'native-x86-source-v1')
        self.assertEqual(native.derived_protocol('qbe', 'native-c-source-v1'), 'native-c-source-v1')
        self.assertEqual(native.derived_protocol('x86', 'qbe-source-v1'), 'qbe-source-v1')

    def test_raw_assembly_does_not_need_an_emitter(self):
        assembly = self.file('supplied.s', self.assembly)
        with patch('native.run', side_effect=self.fake_run):
            result = native.build(self.xargs(ir=assembly, source=None, image_key=None, host=None, stage=None))
        self.assertTrue(result['complete'], result)
        self.assertEqual([row['label'] for row in result['jobs']], ['assemble','link'])
        self.assertEqual(result['sourceAssembly'], pin(assembly))
        self.assertEqual(Path(result['assembly']['file']).read_bytes(), self.assembly)

    def test_request_capture_uses_assembly_suffix_and_complete_bytes(self):
        expected = self.file('expected.s', self.assembly)
        with patch('request.run', side_effect=self.fake_run):
            result = request.execute(self.xargs(expected=expected))
        self.assertTrue(result['complete'], result)
        self.assertTrue(result['byteExact'])
        self.assertEqual(Path(result['product']['file']).name, 'program.s')
        self.assertEqual(Path(result['product']['file']).read_bytes(), self.assembly)

    def test_emitter_stderr_prevents_assembly_and_preserves_partial_output(self):
        def diagnostic(command, **kwargs):
            row = self.fake_run(command, **kwargs)
            Path(kwargs['stderr']).write_bytes(b'error: source refused\n')
            row['stderr'] = pin(kwargs['stderr'])
            return row
        with patch('native.run', side_effect=diagnostic):
            result = native.build(self.xargs())
        self.assertFalse(result['complete'])
        self.assertEqual(len(self.calls), 1)
        self.assertEqual(Path(result['compilerStderr']['file']).read_bytes(), b'error: source refused\n')
        self.assertEqual(Path(result['assembly']['file']).read_bytes(), self.assembly)
        self.assertFalse((self.xargs().out/'program.o').exists())


if __name__ == '__main__': unittest.main()
