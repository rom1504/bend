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
