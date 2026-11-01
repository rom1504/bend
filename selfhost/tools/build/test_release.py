"""Release metadata/transaction fixtures; never install the actual compiler."""
import copy
import json
import os
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.dont_write_bytecode = True
import release
from common import pin, write_json


class ReleaseFixtures(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory(prefix='bend-release-fixtures-')
        self.addCleanup(self.temp.cleanup)
        self.root=Path(self.temp.name)
        (self.root/'selfhost/build').mkdir(parents=True)
        self.file('selfhost/src/preamble.bend',b'# fixture source\n')
        body=b'def main() -> U32:\n  1\n'
        self.file('selfhost/src/main.bend',body)
        recipe={'kind':'bend-maintained-source-v1','preamble':'src/preamble.bend',
            'modules':['src/preamble.bend','src/main.bend'],'order':[[1,'def','main']],
            'defaultProfile':'qbe','profiles':{'qbe':{}}}
        recipe_file=self.json('selfhost/src/compiler.json',recipe)
        canonical=self.file('canonical.bend',b'# fixture source\n'+body)
        cli=self.file('cli.bend',b'fixture CLI profile')
        self.identity=pin(canonical);self.cli_identity=pin(cli)
        images={key:self.file(key+'.image',('fixture '+key).encode()) for key in ['qbe','js','cli']}
        for file in images.values():file.chmod(0o755)
        destinations={'qbe':'selfhost/dist/qbe','js':'selfhost/dist/typed-api.mjs','cli':'selfhost/dist/native/bend'}
        self.copies={destinations[k]:pin(v) for k,v in images.items()}
        files={name:dict(row,file=name) for name,row in self.copies.items()}
        components={}
        gates={}
        for key,host,stage,protocol in [('qbe','native','N2','qbe-source-v1'),('js','js','B2','hosted-api-v1'),('cli','native','N1','native-public-cli-v1')]:
            name='nativeCli' if key=='cli' else key
            source=self.cli_identity if key=='cli' else self.identity
            image=files[destinations[key]]
            qualification=self.json(key+'-qualified.json',dict(complete=True,passed=True,image=pin(images[key]),source=source))
            gates[key]={'role':'qualification','report':pin(qualification),'claims':{'passed':True},'bindings':{'image':image,'source':source}}
            components[name]=dict(host=host,stage=stage,protocol=protocol,sourceIdentity=source,image=image,
                                 capabilities=['c' if key=='cli' else 'js' if key=='js' else 'qbe'],gates=[key])
        fixedpoint=self.json('fixedpoint.json',dict(kind='bend-js-self-emission',complete=True,stage='B3',freshSelfCheck=True,
            typeAccepted=True,byteEquality=True,generator=pin(images['js']),image=pin(images['js']),source=self.identity))
        gates['fixedpoint']={'role':'lineage','report':pin(fixedpoint),'claims':{'byteEquality':True},'bindings':{'generator':pin(images['js']),'source':self.identity}}
        derivation=self.json('derivation.json',dict(kind='bend-public-cli-source-profile',complete=True,qualified=False,
            allOtherBodiesIdentical=True,changedDeclarations=['main','p86_effect_read'],canonicalSource=self.identity,source=self.cli_identity))
        gates['derivation']={'role':'derivation','report':pin(derivation),'claims':{'allOtherBodiesIdentical':True},'bindings':{'source':self.cli_identity}}
        bindings=dict(kind='bend-current-bindings',version=1,complete=True,
            source={'recipe':dict(pin(recipe_file),file='selfhost/src/compiler.json'),'root':'selfhost','profile':'qbe','identity':self.identity},
            components=components,files=files,providers={})
        self.proposal=dict(kind='bend-release-promotion',version=1,complete=True,bindings=bindings,files=self.copies,
                           gates=gates,jsFixedPoint='fixedpoint',nativeCliDerivation='derivation')
        self.manifest=self.json('promotion.json',self.proposal)

    def file(self,name,data):
        path=self.root/name;path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(data);return path

    def json(self,name,value):
        path=self.root/name;path.parent.mkdir(parents=True,exist_ok=True);write_json(path,value);return path

    def test_audit_rejects_failed_gate_and_wrong_stage(self):
        release.audit(self.manifest,self.root)
        broken=copy.deepcopy(self.proposal);broken['bindings']['components']['js']['stage']='B1'
        with self.assertRaisesRegex(ValueError,'host/stage/protocol'):
            release.audit(self.json('wrong-stage.json',broken),self.root)
        gate=self.json('failed.json',dict(complete=True,passed=False))
        broken=copy.deepcopy(self.proposal);broken['gates']['qbe']['report']=pin(gate)
        with self.assertRaisesRegex(ValueError,'did not pass'):
            release.audit(self.json('failed-promotion.json',broken),self.root)

    def test_actual_b3_check_is_mandatory(self):
        broken=copy.deepcopy(self.proposal)
        report=json.loads(Path(broken['gates']['fixedpoint']['report']['file']).read_text())
        report['freshSelfCheck']=False
        broken['gates']['fixedpoint']['report']=pin(self.json('unchecked.json',report))
        with self.assertRaisesRegex(ValueError,'fixed point required'):
            release.audit(self.json('unchecked-promotion.json',broken),self.root)

    def test_install_selector_last_and_verify_without_gate_files(self):
        touched=[];replace=os.replace
        def observe(src,dst):
            if str(dst).startswith(str(self.root/'selfhost/dist')) or str(dst).endswith('/manifests/current.json'):
                touched.append(str(dst))
            return replace(src,dst)
        with patch('release.shutil.disk_usage') as disk,patch('release.os.replace',side_effect=observe):
            disk.return_value.free=20*1024**3
            result=release.install(self.manifest,self.root,self.root/'selfhost/build/install')
        self.assertTrue(result['complete'],result)
        self.assertEqual(touched[-1],str(self.root/'selfhost/manifests/current.json'))
        for gate in self.proposal['gates'].values():Path(gate['report']['file']).unlink()
        self.manifest.unlink()
        self.assertTrue(release.installed(self.root/'selfhost/manifests/current.json',self.root)['complete'])

    def test_partial_failure_restores_old_files_and_selector(self):
        old_image=self.file('selfhost/dist/qbe',b'old image')
        old_selector=self.file('selfhost/manifests/current.json',b'old selector')
        replace=os.replace;failed=False
        def fail_once(src,dst):
            nonlocal failed
            if str(dst).endswith('/dist/typed-api.mjs') and not failed:
                failed=True;raise OSError('injected installation failure')
            return replace(src,dst)
        with patch('release.shutil.disk_usage') as disk,patch('release.os.replace',side_effect=fail_once):
            disk.return_value.free=20*1024**3
            result=release.install(self.manifest,self.root,self.root/'selfhost/build/failed-install')
        self.assertFalse(result['complete']);self.assertTrue(result['rollback'])
        self.assertEqual(old_image.read_bytes(),b'old image')
        self.assertEqual(old_selector.read_bytes(),b'old selector')
        self.assertFalse((self.root/'selfhost/dist/typed-api.mjs').exists())

    def bridge_proposal(self):
        proposal=copy.deepcopy(self.proposal)
        component=proposal['bindings']['components']['qbe']
        old=pin(self.file('old-canonical.bend',b'actual original compiler source'))
        ir=pin(self.file('complete.ssa',b'whole qualified IR\n'))
        image=component['image']
        component['sourceIdentity']=old
        qualified=dict(kind='phase146-native-qualification',complete=True,sourceChecked=True,nativeQualified=True,
            q1q2CompleteStreamDigest=True,q3ObservedLiteralEqual=True,source=old,n2=image,qbe=ir)
        proposal['gates']['qbe']=dict(role='qualification',report=pin(self.json('old-qualified.json',qualified)),
            claims={'nativeQualified':True},bindings={'n2':image,'source':old})
        plan=dict(outputContract='stdout',image=image,source=self.identity,expected=ir,
            imageMetadata={'protocol':'qbe-source-v1','sourceIdentity':old})
        observation=dict(kind='bend-build-request',complete=True,byteExact=True,changedInputs=[],
            host='native',target='qbe',stage='N2',source=self.identity,image=image,product=ir,request=plan,
            process={'complete':True,'exitCode':0,'timedOut':False,'stderr':{'bytes':0},'stdout':ir})
        proposal['gates']['qbe-equivalence']=dict(role='lineage',report=pin(self.json('qbe-equivalence.json',observation)),
            claims={'byteExact':True},bindings={'source':self.identity,'image':image})
        component['gates'].append('qbe-equivalence')
        component['canonicalEquivalence']=dict(kind='whole-qbe-byte-identity',canonicalSourceIdentity=self.identity,
            requestGate='qbe-equivalence',qualificationGate='qbe',qualifiedQbeIdentity=ir)
        return proposal,observation

    def test_qbe_equivalence_preserves_actual_compiled_source(self):
        proposal,_=self.bridge_proposal()
        _,receipt=release.audit(self.json('bridge-proposal.json',proposal),self.root)
        self.assertTrue(receipt['complete'])
        self.assertNotEqual(receipt['components']['qbe']['sourceIdentity']['sha256'],self.identity['sha256'])
        self.assertEqual(receipt['components']['qbe']['canonicalEquivalence']['canonicalSourceIdentity'],self.identity)

    def test_qbe_equivalence_rejects_wrong_reference_and_incomplete_execution(self):
        proposal,observation=self.bridge_proposal()
        for broken in ['wrong-reference','failed-process','wrong-producer-source']:
            changed=copy.deepcopy(observation)
            if broken=='wrong-reference':changed['request']['expected']['sha256']='0'*64
            elif broken=='failed-process':changed['process']['exitCode']=1
            else:changed['request']['imageMetadata']['sourceIdentity']=self.identity
            candidate=copy.deepcopy(proposal)
            candidate['gates']['qbe-equivalence']['report']=pin(self.json(broken+'.json',changed))
            with self.assertRaises(ValueError):
                release.audit(self.json(broken+'-proposal.json',candidate),self.root)


if __name__=='__main__':
    unittest.main()
