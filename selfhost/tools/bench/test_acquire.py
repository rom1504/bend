"""Acquisition protocol controls; no compiler/build/program processes run."""
import sys
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
sys.path.insert(0, str(Path(__file__).resolve().parent))
import acquire as A

class AcquisitionContracts(unittest.TestCase):
    def test_x86_role_has_no_upstream_emitter(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory); manifest=root/'assets.json';manifest.write_text('{}')
            role=dict(provider='build',target='x86',host='native',stage='N1',
                      policy='ordinary',status='fixture',assets=str(manifest))
            with patch.object(A.assets,'load_assets',return_value={'_manifest':A.common.pin(manifest)}):
                prepared,_,_=A.prepare_role(role,root,root)
                self.assertEqual(prepared['target'],'x86')
                role['provider']='upstream';role['stage']='upstream'
                with self.assertRaisesRegex(ValueError,'Upstream emits JS/C only'):
                    A.prepare_role(role,root,root)

    def test_x86_acquisition_builds_assembly_and_preserves_native_contract(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory); source=root/'source.bend';source.write_text('source fixture')
            role=dict(provider='build',target='x86',host='native',stage='N1',assets=str(root/'assets.json'))
            command=['/image','+RTS','--threads','1','--gpu','off','-RTS','--RTS','x86',str(source)]
            plan=dict(outputContract='stdout',host='native',command=command)
            def emit(args,selected):
                args.out.mkdir();(args.out/'program.s').write_text('.text\nentry: ret\n')
                (args.out/'report.json').write_text('{}')
                return dict(complete=True,product=A.common.pin(args.out/'program.s'),inputs=[])
            def build(args):
                self.assertEqual(args.target,'x86')
                self.assertEqual(args.ir.name,'program.s')
                self.assertIsNone(args.source)
                self.assertIsNone(args.image)
                self.assertEqual(args.output_protocol,'native-x86-source-v1')
                args.out.mkdir();(args.out/'program').write_text('unexecuted binary fixture')
                (args.out/'report.json').write_text('{}')
                return dict(complete=True,binary=A.common.pin(args.out/'program'),inputs=[],
                            runtimeArgumentConvention='bend-rts-v1')
            with patch.object(A.request,'plan',return_value=plan), \
                    patch.object(A.request,'execute',side_effect=emit), \
                    patch.object(A.native,'build',side_effect=build) as machine:
                product,replay=A.acquire_case(role,{},A.common.pin(source),root/'case',root,30)
            self.assertEqual(machine.call_count,1)
            self.assertEqual(product['runtimeArgumentConvention'],'bend-rts-v1')
            self.assertTrue(product['generatedSource']['file'].endswith('/program.s'))
            self.assertEqual(replay['command'],command)

    def test_native_product_cli_is_explicit_and_old_defaults_survive(self):
        self.assertEqual(A.bench.native_runtime_arguments({}),['--threads','1','--gpu','off','--'])
        with patch.dict(A.os.environ, {}, clear=True):
            self.assertEqual(A.bench.native_runtime_arguments(dict(runtimeArgumentConvention='bend-rts-v1')),
                             ['+RTS','--threads','1','--gpu','off','-RTS','--RTS'])

    def test_stdout_replay_retains_native_command(self):
        command=['/image', '--threads', '1', '--gpu', 'off', '--', 'phase111', '/source', '/base', 'cache', '/carrier', 'stamp']
        plan=dict(outputContract='stdout',host='native',command=command)
        replay=A.replay_request(plan, [], None)
        self.assertEqual(replay['command'],command)
        self.assertIsNot(replay['command'],command)

    def test_hosted_replay_fresh_report_and_authenticated_request(self):
        with tempfile.TemporaryDirectory() as directory:
            spec=Path(directory)/'request.json';spec.write_text('{}')
            plan=dict(outputContract='stdout',host='js',command=['/engine','/worker','--request',str(spec),'--report','/old-report'])
            replay=A.replay_request(plan,[],spec)
            self.assertEqual(replay['command'][-2:],['--report','{output}'])
            self.assertEqual(replay['inputs'],[A.common.pin(spec)])
            plan['command'][-2]='--unknown'
            with self.assertRaises(ValueError):A.replay_request(plan,[],spec)

    def test_file_telemetry_replays_native_prefix_without_wrapper(self):
        plan=dict(outputContract='file',host='native',command=['/image','/work/program'],
                  imageMetadata=dict(protocol='native-c-source-v1'),emittedFile='/work/program.1.c',
                  runtimePreparation=dict(parts=[]))
        replay=A.replay_request(plan,[],None)
        self.assertEqual(replay['command'],['/image','{output}'])
        self.assertEqual(replay['productSuffix'],'.1.c')
        self.assertEqual(replay['stderrProtocol'],'native-c-source-v1')
        plan['command']=['/image','/wrong-prefix']
        with self.assertRaises(ValueError):A.replay_request(plan,[],None)

    def test_public_c_replay_preserves_exact_banner_and_fresh_file_contract(self):
        import json
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory)
            for name,value in [('image','image fixture'),('source','source fixture'),('oracle','C product'),('empty','')]:
                (root/name).write_text(value)
            stderr=root/'emit.stderr'
            banner=b'SOME PROOFS FAIL\nError: 1 def relies on unsafe or foreign code:\n- IO.print\n\n'
            stderr.write_bytes(banner)
            command=[str(root/'image'),str(root/'source'),'-o',str(root/'program.c'),'--live']
            plan=dict(outputContract='file',host='native',command=command,emittedFile=str(root/'program.c'),
                      imageMetadata=dict(protocol='native-public-cli-v1'))
            replay=A.replay_request(plan,[],None,A.common.pin(stderr))
            self.assertEqual(replay['command'],[str(root/'image'),str(root/'source'),'-o','{output}','--live'])
            self.assertEqual(replay['outputContract'],'file')
            self.assertNotIn('stderrProtocol',replay)
            self.assertEqual(A.common.verify(replay['stderr']).read_bytes(),banner)
            role=dict(host='native',stage='N1',target='c',preparation='live',policy='ordinary',status='fixture')
            contract=dict(replay,scope='request',product=str(root/'oracle'),stdout=str(root/'empty'))
            recipe=dict(kind='compiler',reference='native-c',roles={'native-c':role},
                        cases=[dict(id='fixture',source=str(root/'source'),requests={'native-c':contract})])
            source=root/'recipe.json';source.write_text(json.dumps(recipe))
            manifest=A.bench.freeze(source,root/'manifest.json')
            frozen=manifest['cases'][0]['requests']['native-c']
            self.assertEqual(frozen['stderr'],A.common.pin(stderr))
            self.assertEqual(frozen['product'],A.common.pin(root/'oracle'))
            self.assertEqual(frozen['stdout']['bytes'],0)
            with self.assertRaisesRegex(ValueError,'stderr required'):
                A.replay_request(plan,[],None)
            stderr.write_bytes(banner+b'extra diagnostic\n')
            with self.assertRaises(ValueError): A.replay_request(plan,[],None,A.common.pin(stderr))
            stderr.write_bytes(banner)
            for bad in [command+[str(root/'program.c')],command[:2]+['--unknown',str(root/'program.c')]]:
                with self.assertRaisesRegex(ValueError,'output contract'):
                    A.replay_request(dict(plan,command=bad),[],None,A.common.pin(stderr))

    def test_public_c_acquisition_uses_selected_package_runtime_convention(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory);source=root/'source.bend';source.write_text('source fixture')
            role=dict(provider='build',target='c',host='native',stage='N1',assets=str(root/'assets.json'))
            out=root/'case/emission'
            plan=dict(outputContract='file',host='native',command=['/image',str(source),'-o',str(out/'program.c')],
                      emittedFile=str(out/'program.c'),publicPackage={'authenticated':'fixture'},
                      imageMetadata=dict(protocol='native-public-cli-v1',targetRuntimeArgumentConvention='bend-rts-v1'))
            def emit(args,selected):
                args.out.mkdir();(args.out/'program.c').write_text('C fixture')
                (args.out/'report.json').write_text('{}')
                (args.out/'emit.stderr').write_bytes(b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n\n')
                return dict(complete=True,product=A.common.pin(args.out/'program.c'),inputs=[],request=selected,
                            process=dict(stderr=A.common.pin(args.out/'emit.stderr')))
            def machine(document,product,directory,root,seconds):
                self.assertTrue(product['file'].endswith('/program.c'))
                file=directory/'program';file.write_text('unexecuted binary fixture')
                return A.common.pin(file),[]
            with patch.object(A.request,'plan',return_value=plan), patch.object(A.request,'execute',side_effect=emit), \
                    patch.object(A,'c_build',side_effect=machine) as build:
                product,replay=A.acquire_case(role,{},A.common.pin(source),root/'case',root,30)
            self.assertEqual(build.call_count,1)
            self.assertEqual(product['runtimeArgumentConvention'],'bend-rts-v1')
            self.assertEqual(replay['command'],['/image',str(source),'-o','{output}'])
            self.assertEqual(replay['stderr'],A.common.pin(out/'emit.stderr'))


    def test_native_c_manifest_freezes_exact_parser_and_refuses_suffix_escape(self):
        import json
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory)
            for name,value in [('image','executable fixture'),('source','source'),('oracle','C output'),('empty','')]:
                (root/name).write_text(value)
            role=dict(host='native',stage='N1',target='c',preparation='cache',policy='ordinary',status='fixture')
            contract=dict(scope='request',command=[str(root/'image'),'{output}'],
                          product=str(root/'oracle'),stdout=str(root/'empty'),
                          stderrProtocol='native-c-source-v1',productSuffix='.1.c')
            recipe=dict(kind='compiler',reference='candidate',roles=dict(candidate=role),
                        cases=[dict(id='fixture',source=str(root/'source'),requests=dict(candidate=contract))])
            recipe_file=root/'recipe.json';recipe_file.write_text(json.dumps(recipe))
            manifest=A.bench.freeze(recipe_file,root/'manifest.json')
            self.assertIn(str(A.HERE.parent/'build/request.py'),[row['file'] for row in manifest['inputs']])
            contract['productSuffix']='/../../escape'
            recipe_file.write_text(json.dumps(recipe))
            with self.assertRaises(ValueError):A.bench.freeze(recipe_file,root/'bad.json')

if __name__=='__main__':unittest.main()
