"""Bounded Python fixtures only: no Bend, Bun, QBE, C compiler or native target."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.dont_write_bytecode = True
import assets
import bootstrap
import native
import request
import runtime
from common import pin, run, verify, write_json


class BuildFixtures(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='bend-build-fixtures-')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / 'selfhost/build').mkdir(parents=True)
        self.base = self.file('base.bend', b'base\n')
        self.source = self.file('source.bend', b'source\n')
        self.runtime = self.file('runtime.o', b'opaque runtime fixture\n')
        self.carrier = self.file('carrier', b'opaque preparation fixture\n')
        self.producer = self.script('producer', 'import os\nos.write(1, b"x" * 196613 + b"\\n\\n")\n')
        self.qbe = self.script('qbe', 'import pathlib,sys\na=sys.argv[1:]; data=pathlib.Path(a[-1]).read_bytes() if a[-1]!="-" else sys.stdin.buffer.read()\npathlib.Path(a[a.index("-o")+1]).write_bytes(data)\n')
        self.assembler = self.script('assembler', 'import pathlib,sys\na=sys.argv[1:]; pathlib.Path(a[a.index("-o")+1]).write_bytes(pathlib.Path(a[-1]).read_bytes())\n')
        self.linker = self.script('linker', 'import pathlib,sys\na=sys.argv[1:]; pathlib.Path(a[a.index("-o")+1]).write_bytes(b"fixture executable")\n')
        identity = dict(format='p88-private-base-text-1', cache='c'*64, api='a'*64,
                        base=pin(self.base)['sha256'], path=str(self.base),
                        begin=1, end=7, termAbi=1, spanAbi=3, worldVersion=3)
        stamp = 'p130-word-pair-v1:p88-private-base-text-1:' + hashlib.sha256(
            json.dumps(identity, separators=(',', ':')).encode()).hexdigest()
        self.doc = dict(kind='bend-build-assets', version=1, complete=True,
            assets={k:pin(p) for k,p in dict(base=self.base, **{'prepared-base':self.carrier,
                'producer':self.producer,'qbe':self.qbe,'assembler':self.assembler,
                'linker':self.linker,'qbe-runtime':self.runtime}).items()},
            images={'producer':dict(host='native',stage='N2',targets=['qbe'],protocol='qbe-source-v1')},
            preparedBase=dict(format='p130-word-pair-v1',stamp=stamp,sourceIdentity=identity,
                              sourceBegin=1,sourceEnd=7,base='base',carrier='prepared-base'),
            toolchains={'qbe':dict(target='amd64_sysv',assemblerFlags=['-mbranches-within-32B-boundaries'],
                                  linkerFlags=['-no-pie'],libraries=['-pthread','-lm'])})
        self.manifest = self.root / 'assets.json'
        self.save()

    def file(self, name, data):
        path = self.root / name
        path.write_bytes(data)
        return path

    def script(self, name, body):
        path = self.file(name, ('#!' + sys.executable + '\n' + body).encode())
        path.chmod(0o755)
        return path

    def save(self):
        write_json(self.manifest, self.doc)

    def args(self, **changes):
        values = dict(workspace=self.root, assets=self.manifest, image_key='producer',
            image=None, image_receipt=None, source=self.source, host='native', target='qbe',
            stage='N2',mode='cache',base_key='base',carrier_key='prepared-base',engine_key='bun',
            out=self.root/'selfhost/build/result',seconds=3,expected=None,plan=False,
            ir=None,runtime_key='qbe-runtime',runtime=None,retain_ir=True,expected_stdout=None,
            output_stage=None,output_protocol='qbe-source-v1')
        values.update(changes)
        return argparse.Namespace(**values)

    def test_cache_rejects_path_relocation_but_live_accepts(self):
        relocated = self.file('base-copy.bend', self.base.read_bytes())
        self.doc['assets']['base'] = pin(relocated)
        self.save()
        doc = assets.load_assets(self.manifest, self.root)
        with self.assertRaisesRegex(ValueError, 'source identity/path'):
            assets.prepared_base(doc, 'cache')
        self.assertIsNone(assets.prepared_base(doc, 'live')[1])

    def test_pin_and_stamp_mutation_refused(self):
        self.doc['preparedBase']['stamp'] += 'x'
        self.save()
        with self.assertRaisesRegex(ValueError, 'stamp'):
            assets.prepared_base(assets.load_assets(self.manifest,self.root),'cache')
        original = pin(self.source)
        self.source.write_bytes(b'changed')
        with self.assertRaisesRegex(ValueError, 'Changed input'):
            verify(original)

    def test_acquire_is_exact_and_never_overwrites(self):
        self.doc['assets']['copy'] = {**pin(self.source), 'file':'selfhost/.assets/source'}
        self.save()
        doc = assets.load_assets(self.manifest,self.root)
        with patch('assets.shutil.disk_usage') as usage:
            usage.return_value.free=10*1024**3
            result=assets.acquire(doc,{'copy':str(self.source)},['copy'])
            self.assertEqual(result['copied'],['copy'])
            dest=self.root/'selfhost/.assets/source'
            dest.write_bytes(b'corrupt')
            with self.assertRaisesRegex(ValueError, 'mismatch'):
                assets.acquire(doc,{'copy':str(self.source)},['copy'])
            self.assertEqual(dest.read_bytes(),b'corrupt')

    def test_explicit_stage_target_and_native_arguments(self):
        plan=request.plan(self.args())
        self.assertEqual(plan['command'][1:7],['--threads','1','--gpu','off','--','phase111'])
        with self.assertRaisesRegex(ValueError,'Host/stage'):
            request.plan(self.args(stage='B2'))
        with self.assertRaisesRegex(ValueError,'target'):
            request.plan(self.args(target='js'))
        self.assertFalse(self.args().out.exists())

    def test_request_keeps_full_newlines(self):
        result=request.execute(self.args())
        self.assertTrue(result['complete'],result)
        self.assertEqual(Path(result['product']['file']).read_bytes(),b'x'*196613+b'\n\n')

    def test_pipe_is_bounded_and_source_bytes_exact(self):
        expected=self.file('expected',b'x'*196613+b'\n\n')
        result=native.build(self.args(expected=expected,output_stage='N1'))
        self.assertTrue(result['complete'],result)
        self.assertLessEqual(result['maximumRelayBytes'],65536)
        self.assertEqual(Path(result['retainedIR']['file']).read_bytes(),expected.read_bytes())
        self.assertTrue(result['comparedToReference'])
        self.assertEqual(result['imageBinding']['producerStage'],'N2')
        self.assertEqual(result['imageBinding']['stage'],'N1')

    def test_pipe_early_consumer_exit_reaps_producer(self):
        bad=self.script('bad-qbe','import sys\nsys.exit(7)\n')
        self.doc['assets']['qbe']=pin(bad)
        self.save()
        result=native.build(self.args())
        self.assertFalse(result['complete'])
        self.assertTrue(all(row['status'] is not None for row in result['processes']))
        self.assertFalse((self.args().out/'program').exists())

    def test_process_deadline_and_diagnostic_preservation(self):
        slow=self.script('slow','import sys,time\nprint("diagnostic",file=sys.stderr,flush=True)\ntime.sleep(10)\n')
        result=run([slow],cwd=self.root,stdout=self.root/'stdout',stderr=self.root/'stderr',seconds=.1)
        self.assertFalse(result['complete'])
        self.assertTrue(result['timedOut'])
        self.assertLess(result['seconds'],2)
        self.assertEqual((self.root/'stderr').read_bytes(),b'diagnostic\n')

    def test_pipe_deadline_reaps_both_sessions(self):
        slow=self.script('slow-producer','import time\ntime.sleep(10)\n')
        self.doc['assets']['producer']=pin(slow)
        self.save()
        result=native.build(self.args(seconds=.1))
        self.assertFalse(result['complete'])
        self.assertTrue(result['timedOut'])
        self.assertTrue(all(row['status'] is not None for row in result['processes']))

    def test_native_c_binding_records_explicit_sentinel(self):
        result=native.build(self.args(output_stage='N1',output_protocol='native-c-source-v1'))
        self.assertTrue(result['complete'],result)
        binding=result['imageBinding']
        self.assertEqual(binding['targets'],['c'])
        self.assertEqual(binding['argvSentinel'],'compiler')
        self.assertNotEqual(binding['qualification'],'qualified')

    def test_bootstrap_executes_actual_child_generations(self):
        # The linker fixture writes a Python executable which records its own
        # location. Thus this checks real generation routing without a compiler.
        log=self.root/'generations'
        image=('#!'+sys.executable+'\nimport os,pathlib\n'
               +'with pathlib.Path('+repr(str(log))+').open("a") as f: f.write(__file__+"\\n")\n'
               +'os.write(1,b"x"*196613+b"\\n\\n")\n').encode()
        self.linker.write_text('#!'+sys.executable+'\nimport pathlib,sys\na=sys.argv[1:]\n'
             +'p=pathlib.Path(a[a.index("-o")+1]);p.write_bytes('+repr(image)+');p.chmod(0o755)\n')
        self.doc['assets']['linker']=pin(self.linker)
        self.save()
        result=bootstrap.chain(self.args(seconds=10))
        self.assertTrue(result['complete'],result)
        self.assertTrue(result['qbeFixedPoint'])
        self.assertFalse(result['semanticsQualified'])
        self.assertEqual(log.read_text().splitlines(),[
            str(self.args().out/'n1/program'),str(self.args().out/'n2/program')])
        self.assertEqual([row['stage'] for row in result['generations']],['N1','N2','Q3'])

    def runtime_args(self):
        source=self.file('runtime.c',b'#include "runtime.h"\n/* Python fixture input only */\n')
        header=self.file('runtime.h',b'/* fixture header */\n')
        compiler=self.script('runtime-compiler','import pathlib,sys\na=sys.argv[1:]\n'
            +'pathlib.Path(a[a.index("-o")+1]).write_bytes(b"opaque runtime fixture\\n")\n')
        self.doc['assets'].update({'runtime-source':pin(source),'runtime-header':pin(header),
                                   'runtime-compiler':pin(compiler)})
        self.doc['runtimeRecipes']={'serial-rfc':dict(compiler='runtime-compiler',source='runtime-source',
            headers=['runtime-header'],flags=[],expectedObject='qbe-runtime',policy={'threads':1})}
        self.save()
        return self.args(recipe='serial-rfc')

    def test_runtime_object_is_compared_completely(self):
        result=runtime.build(self.runtime_args())
        self.assertTrue(result['complete'],result)
        self.assertTrue(result['objectExact'])

    def test_runtime_unbound_local_include_refused(self):
        args=self.runtime_args()
        source=self.file('runtime.c',b'#include "not-declared.h"\n')
        self.doc['assets']['runtime-source']=pin(source)
        self.save()
        with self.assertRaisesRegex(ValueError,'Unbound local runtime include'):
            runtime.build(args)
        self.assertFalse(args.out.exists())

    def c_args(self):
        parts=['// λ🙂\n','first\n','second\n','third\n','last\n']
        raw=self.file('runtime-source.c',''.join(parts).encode())
        template=self.root/'runtime-template.json'
        write_json(template,dict(version=1,runtimeSha256=pin(raw)['sha256'],parts=parts))
        effect=self.file('print.c',b'/* fixture effect */\n')
        producer=self.script('c-producer','''import pathlib,sys
a=sys.argv[sys.argv.index('--')+1:]
sentinel,source,base,runtime,effects,output,count,*prepared=a
assert sentinel=='compiler' and count=='1'
p=pathlib.Path(runtime)
parts=[pathlib.Path(runtime+'.part'+str(i)).read_bytes() for i in range(5)]
assert b''.join(parts)==p.read_bytes()
assert parts[0]=='// λ🙂\\n'.encode()
code='int x; // λ🙂\\n'
verdict='ALL PROOFS CHECK\\nUse --verdict for mathematical validity.\\n'
pathlib.Path(output+'.1.c').write_text(code)
sys.stderr.write('base_prepare_ms=1\\nruntime_prepare_ms=0\\nrequest=1 request_ms=2 consumed_chars='+str(len(code)+len(verdict))+'\\n'+verdict+'\\n')
''')
        self.doc['assets'].update({'producer':pin(producer),'c-runtime':pin(raw),
                                  'c-template':pin(template),'effect':pin(effect)})
        self.doc['images']['producer']=dict(host='native',stage='N1',targets=['c'],
            protocol='native-c-source-v1',argvSentinel='compiler')
        self.doc['providers']={'c':{'runtime':'c-runtime','runtimeTemplate':'c-template','effects':['effect']}}
        self.save()
        return self.args(stage='N1',target='c')

    def test_native_c_exact_parts_arguments_and_telemetry(self):
        args=self.c_args()
        result=request.execute(args)
        self.assertTrue(result['complete'],result)
        self.assertEqual(len(result['runtimePreparation']['produced']),6)
        self.assertEqual(result['telemetry']['proofVerdict']['status'],'all-check')
        self.assertFalse(result['telemetry']['mathematicalValidityClaim'])
        self.assertEqual(Path(result['product']['file']).read_text(),'int x; // λ🙂\n')

    def test_native_c_timing_parser_rejects_extra_or_missing_data(self):
        product=b'int x;\n'
        verdict='ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n'
        text='base_prepare_ms=1\nruntime_prepare_ms=2\nrequest=1 request_ms=3 consumed_chars='+str(len(product)+len(verdict))+'\n'+verdict+'\n'
        for malformed in [text+'unexpected\n',text.replace('request=1','request=2'),
                          text.replace('runtime_prepare_ms=2\n',''),text.replace('consumed_chars=','consumed_chars=9')]:
            with self.assertRaises(ValueError):
                request.c_telemetry(malformed.encode(),product)
        unsafe='SOME PROOFS FAIL\nError: 1 def relies on unsafe or foreign code:\n- main\n'
        prefix='base_prepare_ms=0\nruntime_prepare_ms=0\nrequest=1 request_ms=1 consumed_chars='+str(len(product)+len(unsafe))+'\n'
        observation=request.c_telemetry((prefix+unsafe+'\n').encode(),product)
        self.assertEqual(observation['proofVerdict']['status'],'unsafe-or-foreign')
        self.assertEqual(observation['proofVerdict']['names'],['main'])
        self.assertFalse(observation['mathematicalValidityClaim'])

    def test_native_c_template_boundary_mutation_refused(self):
        args=self.c_args()
        plan=request.plan(args)
        template=self.root/'runtime-template.json'
        artifact=json.loads(template.read_text())
        artifact['parts'][0]+=artifact['parts'][1]
        artifact['parts'][1]=''
        write_json(template,artifact)  # Same concatenation, changed insertion boundaries.
        result=request.execute(args,plan)
        self.assertFalse(result['complete'])
        self.assertFalse((args.out/'compiler.stdout').exists())
        self.assertIn(str(template),result['changedInputs'])


if __name__=='__main__':
    unittest.main()
