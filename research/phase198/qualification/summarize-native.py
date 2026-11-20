#!/usr/bin/env python3
"""Authenticate completed Phase198 native gates without executing targets."""
import hashlib
import json
from pathlib import Path
ROOT = Path(__file__).resolve().parents[3]
BUILD = ROOT / 'selfhost/build/phase198'
def pin(path):
    p=Path(path).resolve(); data=p.read_bytes()
    return dict(file=str(p),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())
def read(path):return json.loads(Path(path).read_text())
def verify(item):
    got=pin(item['file'])
    assert all(got[k]==item[k] for k in ['bytes','sha256']),item['file']
    return got
source=pin(BUILD/'selected-source01/compiler.bend')
audit_path=ROOT/'research/phase198/qualification/source-audit.json'
audit=read(audit_path)
assert audit['complete'] and audit['exactExecutableBodiesIdentical'] and source==audit['selectedSource']
for key in ['checkedApiSource','checkedApiReceipt','method']:verify(audit[key])
sourcecheck=ROOT/'selfhost/build/phase197/full-source-check01/report.json'
assert read(sourcecheck)['complete']
assert source['sha256']==pin(ROOT/'selfhost/build/phase197/full-source01/compiler.bend')['sha256']
names=['native-image01','native-self01','native-reproduction01','native45-01','native45-02','native-generations-compare01','native64-01','runtime10-01','compare-hosted01']
gates=[]; docs={}
for name in names:
    path=BUILD/name/'report.json'; doc=read(path); docs[name]=doc
    assert doc['complete'] and not doc.get('error') and not doc.get('changedInputs'),name
    assert doc.get('passed',True),name
    for item in doc.get('inputs',[]):verify(item)
    guard=BUILD/(name+'-guard')/'process.json'; g=read(guard)
    assert g['complete'] and g['returncode']==0 and g['minimumDiskFreeBytes']>=g['diskReserveBytes'],name
    gates.append(dict(name=name,report=pin(path),guard=pin(guard),complete=True,seconds=doc.get('wallSeconds',doc.get('seconds'))))
obj2=pin(BUILD/'native-self01/program.o'); obj3=pin(BUILD/'native-reproduction01/program.o')
assert obj2['bytes']==obj3['bytes'] and obj2['sha256']==obj3['sha256']
assert docs['native-reproduction01']['expectedObject']==obj2
assert docs['native64-01']['counts']=={'pass':64,'fail':0,'unsupported':0}
assert len(docs['runtime10-01']['rows'])==10 and all(x['complete'] for x in docs['runtime10-01']['rows'])
compare=docs['native-generations-compare01']
assert compare['objectsIdentical']==45 and compare['linkedSectionsIdentical']==135
for name in ['native45-01','native45-02']:
    assert len(docs[name]['rows'])==45 and all(x['complete'] for x in docs[name]['rows'])
result=dict(kind='phase198-native-qualification-summary',complete=True,method=pin(__file__),selectedSource=source,sourceAudit=pin(audit_path),inheritedExactSourceCheck=pin(sourcecheck),gates=gates,candidateN1=pin(BUILD/'native-image01/program'),candidateN2=pin(BUILD/'native-self01/program'),candidateN2Receipt=pin(BUILD/'native-self01/report.json'),candidateN3=pin(BUILD/'native-reproduction01/program'),compilerObjectN2EqualsN3=True,compilerObject=obj2,native45GenerationCounts=[45,45],native45ExactObjects=45,native45ExactLinkedSections=135,native64Counts=docs['native64-01']['counts'],runtimeControlsPassed=10,broadRuntime=pin(ROOT/'research/phase198/qualification/broad-runtime-summary01.json'),regressionFollowup=pin(ROOT/'research/phase198/qualification/regression-summary01.json'),liveSourceApplied=False,installedSelectionChanged=False,scope='Finite sequential AMD64 SysV qualification, exact compiler reproduction and cross-generation program objects/sections. Broad runtime and rule ablations are separate evidence. No proof of whole-compiler correctness, parallel/GPU behavior or installed promotion.')
out=ROOT/'research/phase198/qualification/native-summary01.json'
assert not out.exists()
out.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({'complete':True,'summary':pin(out),'compilerObject':obj2}))
