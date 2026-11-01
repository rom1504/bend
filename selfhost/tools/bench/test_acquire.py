"""Acquisition protocol controls; no compiler/build/program processes run."""
import sys
from pathlib import Path
import tempfile
import unittest
sys.path.insert(0, str(Path(__file__).resolve().parent))
import acquire as A

class AcquisitionContracts(unittest.TestCase):
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
