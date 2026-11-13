"""Direct-object release admission controls; synthetic receipts, no target jobs."""
import copy
import json
from pathlib import Path
import unittest

import release
import test_release_x86 as legacy
from common import pin


class ObjectAdmission(unittest.TestCase):
    def setUp(self):
        self.old = legacy.X86ReleaseFixtures()
        self.old.setUp()
        self.addCleanup(self.old.doCleanups)
        self.root, self.file, self.json = self.old.root, self.old.file, self.old.json
        self.current = copy.deepcopy(self.old.proposal['bindings'])
        self.proposal = copy.deepcopy(self.old.proposal)
        self.source, self.runtime = self.old.source, self.old.runtime
        old = self.old.reports
        producer = copy.deepcopy(old['seed']['request']['imageMetadata'])
        producer.update(complete=True, linkedRuntimeABI=11102)
        qobject = pin(self.file('qbe.ssa', b'qbe'))
        self.reports = dict(producerSource=dict(kind='bend-independent-source-check', complete=True,
            checked=True, typeAccepted=True, unresolvedHoles=0, source=producer['sourceIdentity'], upstream=self.current['upstream']),
            producerBuild=dict(kind='bend-native-build', complete=True, target='qbe', imageBinding=producer,
                sourceIR=None,request=dict(source=producer['sourceIdentity']),
                binary=producer['image'], runtime=self.runtime, runtimeABI=11102, comparedToReference=True, irDigest=qobject),
            producerReproduction=dict(kind='bend-build-request', complete=True, byteExact=True, host='native', stage='N2', target='qbe',
                image=producer['image'], source=producer['sourceIdentity'], product=qobject,
                request=dict(image=producer['image'], source=producer['sourceIdentity'], expected=qobject, command=['qbe']),
                process=dict(complete=True, exitCode=0, stderr={'bytes':0}, stdout=qobject,command=['qbe'])),
            sourceCheck=copy.deepcopy(old['sourceCheck']), behavior=copy.deepcopy(old['behavior']),
            runtime=copy.deepcopy(old['runtime']))
        for key in ['producerSource','sourceCheck']:
            self.reports[key].update(version=1,phase='complete',emittedCode=False,executedCandidate=False)
        self.reports['producerBehavior'] = dict(copy.deepcopy(old['behavior']), target='qbe', image=producer['image'])
        obj = pin(self.file('compiler.o', b'object-fixture'))
        base = pin(self.file('base.bend', b'base')); carrier = pin(self.file('base.carrier', b'prepared'))
        for key, original, stage, target in [('n1','seed','N1','qbe'), ('n2','n1','N2','x86'), ('reproduction','n2','N3','x86')]:
            report = copy.deepcopy(old[original]); binding = report['imageBinding']; request = report['request']
            command = [producer['image']['file'], target, self.source['file']]
            report.update(stage=producer['stage'], target=target, compilerCommand=command,
                          compilerExitCode=0, compilerStderr={'bytes':0})
            binding.update(stage=stage, producer=producer['image'], producerStage=producer['stage'])
            request.update(stage=producer['stage'], target=target, image=producer['image'], imageMetadata=copy.deepcopy(producer),
                           mode='cache', base=base, carrier=carrier, stamp='stable', command=command)
            if target == 'x86':
                report.update(emissionFormat=release.X86_OBJECT, assemblerSkipped=True, object=obj, objectDigest=obj,
                    jobs=[dict(label='compiler', command=command, complete=True, started=1, exitCode=0, stderr={'bytes':0}, stdout=obj)])
                request['emissionFormat'] = release.X86_OBJECT
                binding['producerEmissionFormat'] = release.X86_OBJECT
            else:
                report.update(qbeExitCode=0,qbeStderr={'bytes':0},processes=[dict(command=command,status=0)])
            if stage == 'N3':
                report.update(expectedObject=obj, comparedToReference=True); request['expected'] = obj
            self.reports[key] = report
            producer = binding
        image = self.reports['n2']['binary']
        self.current['components']['x86'].update(image=image, qualificationVariant='direct-object-v1', defaultEmission='object')
        catalog = json.loads(Path(self.proposal['x86QualificationCatalog']['file']).read_text())
        for case in catalog['cases']:
            case.update(source=self.source, expect=dict(stdout='ok\n',stderr='',exitCode=0))
        self.proposal['x86QualificationCatalog'] = pin(self.json('catalog.json',catalog))
        for name in ['behavior','producerBehavior']:
            self.reports[name]['catalog'] = self.proposal['x86QualificationCatalog']
        behavior = self.reports['behavior']; behavior.update(image=image, emit='object', emissionFormat=release.X86_OBJECT)
        for i,row in enumerate(behavior['rows']):
            product = pin(self.file('case-'+str(i)+'.o', b'case object'))
            row.update(source=self.source, expected=catalog['cases'][i]['expect'])
            row['emission'] = pin(self.json('emit-'+str(i)+'.json',dict(image=image,source=self.source,product=product,
                request=dict(emissionFormat=release.X86_OBJECT))))
            row['build'] = pin(self.json('build-'+str(i)+'.json',dict(complete=True,emissionFormat=release.X86_OBJECT,
                assemblerSkipped=True,sourceObject=product,runtime=self.runtime)))
        controls = self.reports['runtime']; controls['image'] = image
        for i,row in enumerate(controls['rows']):
            row['source'] = self.source
            row['receipt'] = pin(self.json('runtime-'+str(i)+'.json',dict(complete=True,emissionFormat=release.X86_OBJECT,
                assemblerSkipped=True,host='native',stage='N2',target='x86',runtime=self.runtime,
                request=dict(image=image,source=self.source))))
        self.proposal['x86Qualification'] = {key:key for key in self.reports}
        self.current['components']['x86']['gates'] = list(self.reports)

    def audit(self):
        release.audit_x86_object(self.current,self.proposal,self.reports,self.root)

    def test_actual_object_chain(self):
        self.audit()

    def test_actual_n3_process_required(self):
        self.reports['reproduction']['jobs']=[]
        with self.assertRaises(ValueError): self.audit()

    def test_n3_process_timeout_rejected(self):
        self.reports['reproduction']['jobs'][0]['timedOut']=True
        with self.assertRaises(ValueError): self.audit()

    def test_relabelled_stage_rejected(self):
        self.reports['n1']['imageBinding']['stage']='N0'
        with self.assertRaises(ValueError): self.audit()

    def test_independent_qbe_producer_qualification_required(self):
        self.reports['producerBehavior']['counts']['pass']=63
        with self.assertRaises(ValueError): self.audit()

    def test_n3_must_be_executed_by_selected_n2(self):
        self.reports['reproduction']['request']['image']=self.reports['n1']['binary']
        with self.assertRaises(ValueError): self.audit()

    def test_n3_object_bytes_must_equal_n2(self):
        self.reports['reproduction']['objectDigest']=self.runtime
        with self.assertRaises(ValueError): self.audit()

    def test_base_preparation_must_match(self):
        self.reports['n2']['request']['carrier']=self.runtime
        with self.assertRaises(ValueError): self.audit()

    def test_assembly_behavior_cannot_qualify_object(self):
        self.reports['behavior']['emit']='assembly'
        with self.assertRaises(ValueError): self.audit()

    def test_nested_runtime_cannot_be_assembly(self):
        row=self.reports['runtime']['rows'][0]
        file=Path(row['receipt']['file']); value=json.loads(file.read_text())
        value['emissionFormat']='assembly'; file.write_text(json.dumps(value)); row['receipt']=pin(file)
        with self.assertRaises(ValueError): self.audit()

    def test_finite_oracles_cannot_change(self):
        self.reports['behavior']['rows'][0]['expected']={}
        with self.assertRaises(ValueError): self.audit()

    def test_snapshot_requires_exact_installed_artifact(self):
        proposal=copy.deepcopy(self.old.proposal); current=proposal['bindings']
        del current['components']['x86']
        origin=copy.deepcopy(current['source'])
        content=release.assembly.maintained_assemble(self.root/'selfhost/src/compiler.json',self.root/'selfhost','qbe')
        snap=pin(self.file('canonical.bend',content)); dest='selfhost/dist/canonical.bend'
        current['files'][dest]=dict(snap,file=dest); proposal['files'][dest]=snap
        current['source']=dict(origin,kind='bend-frozen-release-source-v1',origin=origin,snapshot=current['files'][dest])
        release.bindings(current,self.root,proposal['files'])
        current['source']['snapshot']=dict(snap,file='canonical.bend')
        with self.assertRaises(ValueError): release.bindings(current,self.root,proposal['files'])


if __name__ == '__main__': unittest.main()
