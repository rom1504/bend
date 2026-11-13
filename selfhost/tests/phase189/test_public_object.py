"""Public object routing with authenticated fixture assets; no compiler or target runs."""
import argparse
import copy
from pathlib import Path
import sys
import unittest
from unittest.mock import patch

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT/'selfhost/tools/build'))
import test_public_x86 as previous
from common import write_json

P, N = previous.P, previous.N


class PublicObject(previous.PublicX86):
    """Keep the existing ten authentication/publication controls and add route checks."""

    def setUp(self):
        super().setUp()
        self.current['components']['x86']['defaultEmission'] = 'object'
        self.doc['images']['x86-n2']['defaultEmission'] = 'object'
        write_json(self.selector, self.current)
        self.save()

    def checked_request(self, args, emission, mode):
        self.assertEqual((args.target, args.host, args.stage, args.image_key, args.emit, args.mode),
                         ('x86', 'native', 'N2', 'x86-n2', emission, mode))
        self.assertIsNone(args.image)
        self.assertIsNone(args.image_receipt)
        request = P.request.plan(args)
        marker = 'x86' if emission == 'assembly' else 'x86-object'
        self.assertEqual(request['command'][8], marker)
        self.assertEqual(request['command'][0], str(self.root/'selfhost/dist/x86/bend'))
        self.assertEqual(request['imageMetadata']['protocol'], 'native-x86-source-v1')
        self.assertEqual(request['outputContract'], 'stdout')
        self.assertEqual(request.get('emissionFormat'),
                         P.request.X86_ASSEMBLY_FORMAT if emission == 'assembly' else P.request.X86_OBJECT_FORMAT)

    def test_cache_and_live_select_explicit_format_from_destination(self):
        for mode in ('cache', 'live'):
            for emission, suffix in [('assembly', '.s'), ('object', '')]:
                with self.subTest(mode=mode, emission=emission):
                    output = self.root/('selected-'+mode+'-'+emission+suffix)
                    def selected(args):
                        self.checked_request(args, emission, mode)
                        return self.emitted(args) if emission == 'assembly' else self.built(args)
                    arguments = ['--target=x86', str(self.source), '--output', str(output)]
                    if mode == 'live': arguments += ['--live']
                    route = P.request if emission == 'assembly' else P.native
                    method = 'execute' if emission == 'assembly' else 'build'
                    with patch.object(route, method, side_effect=selected) as called:
                        self.assertEqual(P.main(arguments, self.root), 0)
                    called.assert_called_once()
                    self.assertEqual(output.stat().st_mode & 0o777, 0o644 if suffix else 0o755)

    def test_object_build_plan_needs_no_assembler_asset(self):
        self.doc['assets'].pop('assembler')
        self.save()
        native_build = P.native.build
        def planned(args):
            self.checked_request(args, 'object', 'cache')
            plan_args = copy.copy(args)
            plan_args.plan = True
            plan = native_build(plan_args)
            self.assertTrue(plan['assemblerSkipped'])
            self.assertEqual(plan['emissionFormat'], P.request.X86_OBJECT_FORMAT)
            self.assertEqual(plan['jobs'], [])
            self.assertNotIn(str(self.assembler), [row['file'] for row in plan['inputs']])
            self.assertEqual(plan['runtimeABI'], 11102)
            self.assertEqual(plan['runtimeArgumentConvention'], 'bend-rts-v1')
            return self.built(args)
        with patch.object(P.native, 'build', side_effect=planned), patch.object(P.request, 'execute') as emit:
            self.assertEqual(P.main([str(self.source), '-o', str(self.root/'direct')], self.root), 0)
        emit.assert_not_called()

    def test_older_qualified_release_keeps_assembly_for_build_and_run(self):
        del self.current['components']['x86']['defaultEmission']
        del self.doc['images']['x86-n2']['defaultEmission']
        write_json(self.selector, self.current)
        self.save()
        def selected(args):
            self.checked_request(args, 'assembly', 'cache')
            return self.built(args)
        for destination in (['-o', str(self.root/'legacy-program')], ['--run']):
            with (self.subTest(destination=destination), patch.object(P.native, 'build', side_effect=selected),
                  patch.object(P.request, 'execute') as emit,
                  patch.object(P.subprocess, 'run', return_value=argparse.Namespace(returncode=0))):
                self.assertEqual(P.main([str(self.source), *destination], self.root), 0)
            emit.assert_not_called()

    def test_emission_default_must_be_known_and_bound_in_operational_assets(self):
        self.current['components']['x86']['defaultEmission'] = 'future'
        write_json(self.selector, self.current)
        with self.assertRaisesRegex(ValueError, 'emission default'): P.selected(self.root)
        self.current['components']['x86']['defaultEmission'] = 'object'
        write_json(self.selector, self.current)
        del self.doc['images']['x86-n2']['defaultEmission']
        self.save()
        with self.assertRaisesRegex(ValueError, 'binding differs'): P.selected(self.root)

    def test_object_run_preserves_arguments_status_and_temporary_cleanup(self):
        arguments = ['', 'a b', 'λ', '+RTS', '--target=x86', '--output', 'application.s']
        for status, expected in [(0, 0), (23, 23), (-9, 137)]:
            with self.subTest(status=status):
                def selected(args):
                    self.checked_request(args, 'object', 'live')
                    return self.built(args)
                with (patch.object(P.native, 'build', side_effect=selected),
                      patch.object(P.request, 'execute') as emit,
                      patch.object(P.subprocess, 'run', return_value=argparse.Namespace(returncode=status)) as run):
                    self.assertEqual(P.main([str(self.source), '--run', '--live', '--', *arguments], self.root), expected)
                emit.assert_not_called()
                self.assertEqual(run.call_args.args[0][1:],
                                 ['+RTS', '--threads', '1', '--gpu', 'off', '-RTS', '--RTS', *arguments])
                self.assertEqual(run.call_args.kwargs, {'check': False})
                self.assertFalse(Path(run.call_args.args[0][0]).exists())

    def test_failed_object_build_never_falls_back_publishes_or_executes(self):
        output = self.root/'refused-object'
        for destination in (['-o', str(output)], ['--run']):
            with self.subTest(destination=destination):
                with (patch.object(P.native, 'build', return_value={'complete': False, 'error': 'object refused'}) as build,
                      patch.object(P.request, 'execute') as emit, patch.object(P.subprocess, 'run') as run,
                      patch.object(P, 'diagnostics')):
                    self.assertEqual(P.main([str(self.source), *destination], self.root), 1)
                self.assertEqual(build.call_args.args[0].emit, 'object')
                emit.assert_not_called()
                run.assert_not_called()
                self.assertFalse(output.exists())

    def test_changed_source_blocks_publication_and_execution(self):
        output = self.root/'changed-object'
        for destination in (['-o', str(output)], ['--run']):
            with self.subTest(destination=destination):
                def changed(args):
                    result = self.built(args)
                    self.source.write_bytes(self.source.read_bytes()+b'changed\n')
                    return result
                with (patch.object(P.native, 'build', side_effect=changed),
                      patch.object(P.subprocess, 'run') as run,
                      self.assertRaisesRegex(ValueError, 'inputs changed')):
                    P.main([str(self.source), *destination], self.root)
                run.assert_not_called()
                self.assertFalse(output.exists())
                self.assertEqual(list((self.root/'selfhost/build').iterdir()), [])

    def test_unqualified_or_changed_installed_image_cannot_build(self):
        self.current['gateStatus']['qualified'] = False
        write_json(self.selector, self.current)
        with patch.object(P.native, 'build') as build, self.assertRaisesRegex(ValueError, 'qualified current'):
            P.main([str(self.source), '--run'], self.root)
        build.assert_not_called()
        self.current['gateStatus']['qualified'] = True
        write_json(self.selector, self.current)
        image = self.root/'selfhost/dist/x86/bend'
        image.write_bytes(image.read_bytes()+b'changed')
        with patch.object(P.native, 'build') as build, self.assertRaisesRegex(ValueError, 'Changed input'):
            P.main([str(self.source), '--run'], self.root)
        build.assert_not_called()

    def test_native_wrapper_preserves_equals_target_and_long_output(self):
        helper = str(self.root/'selfhost/tools/build/public-native.py')
        for arguments in (['--target=x86', 'input.bend', '--run', '--', '', 'a b'],
                          ['input.bend', '--output', 'explicit.s'],
                          ['--target', 'x86', 'input.bend', '--output', 'program']):
            with (self.subTest(arguments=arguments),
                  patch.object(N, '__file__', str(self.root/'selfhost/native.py')),
                  patch.object(N.sys, 'argv', ['native.py', *arguments]),
                  patch.object(N.os, 'execv', side_effect=StopIteration) as execute):
                with self.assertRaises(StopIteration): N.main()
            self.assertEqual(execute.call_args.args,
                             (sys.executable, [sys.executable, '-B', helper, *arguments]))


if __name__ == '__main__': unittest.main()
