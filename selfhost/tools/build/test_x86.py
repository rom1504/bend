"""Metadata and mocked byte-transport checks; no compiler or target is executed."""
import os
import argparse
from pathlib import Path
import struct
import sys
import unittest
from unittest.mock import patch

sys.dont_write_bytecode = True
import assets
import bootstrap
import native
import qualification
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


class X86ObjectControls(unittest.TestCase):
    """Only mocked child transport; the ELF header is fixture data, not codegen."""
    file = fixtures.BuildFixtures.file
    script = fixtures.BuildFixtures.script
    save = fixtures.BuildFixtures.save
    args = fixtures.BuildFixtures.args
    xargs = X86Controls.xargs
    fake_run = X86Controls.fake_run

    def setUp(self):
        X86Controls.setUp(self)
        header = (b'\x7fELF\x02\x01\x01' + b'\x00' * 9 +
                  struct.pack('<HHIQQQIHHHHHH', 1, 62, 1, 0, 0, 64, 0, 64, 0, 0, 64, 1, 0))
        self.object_bytes = header + b'\x00' * 64 + b'\x00\x80\xff\n\n'
        self.assembly = self.object_bytes

    def oargs(self, **changes):
        return self.xargs(**dict(emit='object', **changes))

    def test_object_request_keeps_five_source_arguments(self):
        with patch.dict(os.environ, {}, clear=True):
            cached = request.plan(self.oargs())
            live = request.plan(self.oargs(mode='live'))
        prefix = [str(self.producer), '+RTS', '--threads', '1', '--gpu', 'off', '-RTS', '--RTS', 'x86-object']
        self.assertEqual(cached['command'], prefix + [str(self.source), str(self.base), 'cache', str(self.carrier), self.doc['preparedBase']['stamp']])
        self.assertEqual(live['command'], prefix + [str(self.source), str(self.base), 'live', '', ''])
        self.assertEqual(cached['emissionFormat'], request.X86_OBJECT_FORMAT)
        self.assertEqual(cached['imageMetadata']['protocol'], 'native-x86-source-v1')
        default = request.plan(self.xargs())
        self.assertEqual(default['command'][-6], 'x86')
        self.assertNotIn('emissionFormat', default)

    def test_object_plan_does_not_require_or_pin_assembler(self):
        self.doc['assets'].pop('assembler'); self.save()
        result = native.build(self.oargs(plan=True))
        self.assertTrue(result['assemblerSkipped'])
        self.assertEqual(result['runtimeABI'], 11102)
        self.assertEqual(result['emissionFormat'], request.X86_OBJECT_FORMAT)
        self.assertNotIn(str(self.assembler), [row['file'] for row in result['inputs']])
        self.assertNotIn('sourceAssembly', result)
        self.assertIn('sourceObject', result)
        self.assertIn('expectedObject', result)
        self.assertFalse(self.oargs().out.exists())

    def test_object_build_preserves_binary_and_skips_assembler(self):
        expected = self.file('expected.o', self.object_bytes)
        with patch('native.run', side_effect=self.fake_run):
            result = native.build(self.oargs(expected=expected, output_stage='N1', output_protocol=None))
        self.assertTrue(result['complete'], result)
        self.assertEqual([job['label'] for job in result['jobs']], ['compiler', 'link'])
        self.assertEqual(Path(result['object']['file']).read_bytes(), self.object_bytes)
        self.assertEqual(result['objectDigest'], {k: pin(expected)[k] for k in ('bytes', 'sha256')})
        self.assertEqual(result['retainedObject'], result['object'])
        self.assertTrue(result['comparedToReference'])
        self.assertEqual(result['objectHeader']['elfType'], 'ET_REL')
        self.assertEqual(result['imageBinding']['protocol'], 'native-x86-source-v1')
        self.assertEqual(result['imageBinding']['producerEmissionFormat'], request.X86_OBJECT_FORMAT)
        self.assertEqual(result['imageBinding']['linkedRuntimeABI'], 11102)
        self.assertFalse((self.oargs().out/'program.s').exists())
        self.assertNotIn('assembly', result)
        self.assertNotIn('assemblyDigest', result)
        self.assertIn(str(self.runtime), self.calls[-1])
        self.assertIn('-no-pie', self.calls[-1])

    def test_object_request_captures_binary_suffix_and_exact_reference(self):
        expected = self.file('expected.o', self.object_bytes)
        with patch('request.run', side_effect=self.fake_run):
            result = request.execute(self.oargs(expected=expected))
        self.assertTrue(result['complete'], result)
        self.assertTrue(result['byteExact'])
        self.assertEqual(Path(result['product']['file']).name, 'program.o')
        self.assertEqual(Path(result['product']['file']).read_bytes(), self.object_bytes)
        self.assertEqual(result['objectHeader']['sectionCount'], 1)
        self.assertIn('no text decoding', result['byteContract'])

    def test_supplied_object_only_links(self):
        source = self.file('supplied.o', self.object_bytes)
        with patch('native.run', side_effect=self.fake_run):
            result = native.build(self.oargs(ir=source, source=None, image_key=None, host=None, stage=None, retain_ir=False))
        self.assertTrue(result['complete'], result)
        self.assertEqual([job['label'] for job in result['jobs']], ['link'])
        self.assertEqual(result['sourceObject'], pin(source))
        self.assertEqual(Path(result['object']['file']).read_bytes(), self.object_bytes)
        self.assertNotIn('retainedObject', result)

    def test_object_mode_is_explicit_and_target_bound(self):
        for function in (request.plan, native.build):
            with self.assertRaisesRegex(ValueError, 'requires --target x86'):
                function(self.oargs(target='qbe', plan=True))
        parser = argparse.ArgumentParser()
        request.arguments(parser, source_required=False)
        parsed = parser.parse_args(['--assets', str(self.manifest), '--out', str(self.oargs().out),
                                    '--target', 'x86', '--emit', 'object', '--expected-object', 'reference.o'])
        self.assertEqual(parsed.emit, 'object')
        self.assertEqual(parsed.expected, Path('reference.o'))
        raw = self.file('object-named.s', self.object_bytes)
        result = native.build(self.xargs(plan=True, ir=raw, source=None, image_key=None, host=None, stage=None))
        self.assertIn('sourceAssembly', result)
        self.assertNotIn('emissionFormat', result)

    def test_elf_header_rejects_wrong_architecture_kind_and_truncation(self):
        cases = [b'.text\n', self.object_bytes[:63]]
        for offset, replacement in [(4,b'\x01'), (5,b'\x02'), (16,b'\x02\x00'),
                                    (18,b'\xb7\x00'), (20,b'\x02'), (24,b'\x01'),
                                    (54,b'\x38'), (58,b'\x20'), (60,b'\xff\xff')]:
            changed = bytearray(self.object_bytes)
            changed[offset:offset+len(replacement)] = replacement
            cases.append(bytes(changed))
        for n, data in enumerate(cases):
            with self.subTest(n=n):
                path = self.file('bad'+str(n)+'.o', data)
                with self.assertRaises(ValueError): request.x86_object_header(path)

    def test_bad_supplied_object_is_refused_before_output_creation(self):
        raw = self.file('bad.o', b'.text\n')
        with self.assertRaisesRegex(ValueError, 'Expected ELF64'):
            native.build(self.oargs(ir=raw, source=None, image_key=None, host=None, stage=None))
        self.assertFalse(self.oargs().out.exists())

    def test_bad_emitted_object_prevents_link_and_keeps_evidence(self):
        self.assembly = b'.text\n'
        with patch('native.run', side_effect=self.fake_run):
            result = native.build(self.oargs())
        self.assertFalse(result['complete'])
        self.assertEqual([row['label'] for row in result['jobs']], ['compiler'])
        self.assertEqual(Path(result['object']['file']).read_bytes(), self.assembly)
        self.assertIn('Expected ELF64', result['error'])

    def test_old_image_refusal_never_links(self):
        def refused(command, **kwargs):
            result = self.fake_run(command, **kwargs)
            Path(kwargs['stderr']).write_bytes(b'expected x86, absolute input/Base paths\n')
            result.update(complete=False, exitCode=2, stderr=pin(kwargs['stderr']))
            return result
        with patch('native.run', side_effect=refused):
            result = native.build(self.oargs())
        self.assertFalse(result['complete'])
        self.assertEqual(len(self.calls), 1)
        self.assertFalse((self.oargs().out/'program').exists())

    def test_object_reference_mismatch_prevents_link(self):
        expected = self.file('expected.o', self.object_bytes + b'other')
        with patch('native.run', side_effect=self.fake_run):
            result = native.build(self.oargs(expected=expected))
        self.assertFalse(result['complete'])
        self.assertIn('object digest differs', result['error'])
        self.assertEqual(len(self.calls), 1)

    def test_object_diagnostics_fail_even_with_valid_binary_stdout(self):
        def diagnostic(command, **kwargs):
            result = self.fake_run(command, **kwargs)
            Path(kwargs['stderr']).write_bytes(b'unexpected diagnostic\n')
            result['stderr'] = pin(kwargs['stderr'])
            return result
        with patch('request.run', side_effect=diagnostic):
            result = request.execute(self.oargs())
        self.assertFalse(result['complete'])
        self.assertIn('Unexpected compiler stderr', result['error'])
        self.assertEqual(Path(result['product']['file']).read_bytes(), self.object_bytes)

    def test_textual_qualification_and_bootstrap_decline_object_mode(self):
        with self.assertRaisesRegex(ValueError, 'Object bootstrap'):
            bootstrap.chain(self.oargs())
        with self.assertRaisesRegex(ValueError, 'Object emission requires separate qualification'):
            qualification.qualify(self.oargs())
        self.assertFalse(self.oargs().out.exists())


if __name__ == '__main__': unittest.main()
