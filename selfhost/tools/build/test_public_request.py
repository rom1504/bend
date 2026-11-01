"""Offline public-CLI protocol fixtures; no Bend or native target execution."""
import hashlib
from pathlib import Path
import sys
import unittest
sys.dont_write_bytecode=True
sys.path.insert(0,str(Path(__file__).resolve().parent))
import test_build as fixtures
import request
from common import pin


class PublicRequestFixtures(unittest.TestCase):
    setUp=fixtures.BuildFixtures.setUp
    file=fixtures.BuildFixtures.file
    script=fixtures.BuildFixtures.script
    save=fixtures.BuildFixtures.save
    args=fixtures.BuildFixtures.args

    def public_args(self,extra='',exit_code=0):
        package=self.root/'package'
        (package/'assets/effs').mkdir(parents=True)
        (package/'assets/base.bend').write_bytes(b'package Base')
        (package/'assets/base.p88').write_bytes(b'package cache')
        parts=['// λ🙂\n','one\n','two\n','three\n','four\n']
        for index,text in enumerate(parts):(package/'assets'/('runtime.c.part'+str(index))).write_text(text)
        for name in ['args','print','print_err','now','file_open','file_read','file_size','file_write','file_close']:
            (package/'assets/effs'/(name+'.c')).write_text('fixture '+name)
        verdict='ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n\n'
        image=self.script('package/bend','import pathlib,sys\na=sys.argv[1:]\n'
            +'assert len(a) in (3,4) and a[1]=="-o"\n'
            +'assert len(a)==3 or a[3]=="--live"\n'
            +'pathlib.Path(a[2]).write_text("int x;\\n")\n'
            +'sys.stderr.write('+repr(verdict+extra)+')\n'
            +'sys.exit('+str(exit_code)+')\n')
        raw=''.join(parts).encode()
        package_assets={str(p.relative_to(package/'assets')):pin(p) for p in (package/'assets').rglob('*') if p.is_file()}
        self.doc['assets']['producer']=pin(image)
        self.doc['images']['producer']=dict(host='native',stage='N1',targets=['c'],protocol='native-public-cli-v1',
            packageAssets=package_assets,baseIdentity='/preserved/compiler/base.bend',cacheStamp='p88-private-base-text-1:'+'a'*64,
            targetRuntime=dict(file='/not-read/runtime.c',bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest()))
        self.doc['providers']={'c':{'runtime':'missing-external-runtime'}}
        self.save()
        self.base.unlink();self.carrier.unlink()  # Public image owns its package.
        return self.args(stage='N1',target='c')

    def test_public_argv_and_package_owned_inputs(self):
        args=self.public_args()
        plan=request.plan(args)
        self.assertEqual(plan['command'],[str(self.root/'package/bend'),str(self.source),'-o',str(args.out/'program.c')])
        self.assertEqual(plan['base']['file'],str(self.root/'package/assets/base.bend'))
        self.assertNotIn(str(self.base),[p['file'] for p in plan['inputs']])
        self.assertNotIn('runtimePreparation',plan)
        result=request.execute(args,plan)
        self.assertTrue(result['complete'],result)
        self.assertEqual(result['publicVerdict']['proofVerdict']['status'],'all-check')
        self.assertFalse(result['publicVerdict']['mathematicalValidityClaim'])
        self.assertNotIn('telemetry',result)
        self.assertEqual(Path(result['product']['file']).read_bytes(),b'int x;\n')

    def test_public_live_flag_and_wrong_target_refusal(self):
        args=self.public_args();args.mode='live'
        plan=request.plan(args)
        self.assertEqual(plan['command'][-1],'--live')
        self.assertIsNone(plan['carrier'])
        self.assertTrue(request.execute(args,plan)['complete'])
        args.target='qbe'
        with self.assertRaisesRegex(ValueError,'target'):
            request.plan(args)

    def test_public_unknown_stderr_is_failure(self):
        result=request.execute(self.public_args(extra='unexpected warning\n'))
        self.assertFalse(result['complete'])
        self.assertIn('verdict',result['error'])

    def test_public_nonzero_exit_cannot_be_success(self):
        result=request.execute(self.public_args(exit_code=1))
        self.assertFalse(result['complete'])
        self.assertEqual(result['process']['exitCode'],1)

    def test_public_asset_mutation_refused_before_execution(self):
        args=self.public_args()
        (self.root/'package/assets/effs/print.c').write_text('changed')
        with self.assertRaisesRegex(ValueError,'asset differs'):
            request.plan(args)
        self.assertFalse(args.out.exists())


if __name__=='__main__':unittest.main()
