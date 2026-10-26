"""Publish compact final03 identities from the already sealed qualification."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT/'selfhost/build/phase144/final03-qualification.json'
RAW_SHA = '6b9d48b9b2c9a560b9d878f21646d9f3d9c5246f9c20c8bcab720c65fbbb85d5'
INPUTS = {}


def pin(path):
    path = Path(path).resolve(); h = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024*1024), b''): h.update(block)
    return dict(file=str(path),bytes=path.stat().st_size,sha256=h.hexdigest())


def verify(row):
    assert pin(row['file']) == row, row['file']
    INPUTS[row['file']] = row
    return Path(row['file'])


def read(row):
    return json.loads(verify(row).read_text())


def main():
    raw_pin = pin(RAW); assert raw_pin['sha256']==RAW_SHA
    q = read(raw_pin)
    assert q['kind']=='phase144-native-qualification' and q['complete'] and q['nativeQualified']
    assert q['q2EqualsQ3'] and not q['q1EqualsQ2'] and not q['installed'] and not q['defaultChanged']
    a = q['sourceAdmission']; plan = read(q['plan'])
    assert a['completeSourceReplay'] and a['controls']==127 and len(a['unchangedProofDeclarations'])==11
    for row in [q['source'],q['api'],q['runtime'],q['producer'],q['n1'],q['n2'],
                a['sourceManifest'],a['checkedApi'],a['finiteControls'],*q['actualRuntimeAuthority']]: verify(row)
    for row in q['qbe'].values(): verify(row)
    assert q['qbe']['q2']['sha256']==q['qbe']['q3']['sha256'] and q['qbe']['q2']['bytes']==q['qbe']['q3']['bytes']
    suites = []
    assert len(q['suites'])==3
    for name, item, passes, refusals in zip(['n1-focused19','n2-focused19','n2-full45'],q['suites'],[16,16,45],[3,3,0]):
        report = read(item['report'])
        assert report['complete'] and report['passed'] and item['semanticPasses']==passes and item['expectedRefusals']==refusals
        assert report['summary']['semanticPasses']==passes and report['summary']['expectedRefusals']==refusals and report['summary']['pending']==0
        suites.append(dict(name=name,**item))
    smoke = read(q['hostSmokes'])
    assert smoke['complete'] and smoke['passed'] and smoke['image']==q['n2'] and smoke['runtime']==q['runtime']
    assert smoke['gates']==dict(path=True,publish=True,batch=True,session=True)
    batch, session = read(smoke['batch']), read(smoke['session'])
    assert batch['complete'] and batch['independentProductsExact'] and len(batch['jobs'])==4
    assert session['complete'] and session['independentProductsExact'] and len(session['frames'])==2
    method = pin(__file__);verify(method)
    sealer = pin(Path(__file__).with_name('seal-v02.py'));verify(sealer)
    assert sealer in q['inputs']
    policy = dict(threads=1,gpu='off',bendHeapMutators=1,hostIoWorkersAllowed=True,
        providerScope='Pinned direct-QBE foreign provider table; no arbitrary C embedding or foreign callbacks.')
    scope = ('Independent source check, exact source replay, qualified Phase143 N2 -> N1 -> N2, complete Q2=Q3, '
        'focused19 on both images and independent complete stdout on N2 ordinary45. Exact serial runtime under '
        'one Bend heap mutator. Path/publish and one frozen A/B batch/session are finite supplemental smokes, '
        'not broad incremental qualification. No compiler theorem, universal language conformance, machine/ELF '
        'fixed point, new JS/C qualification, performance result, installed selection or default change.')
    out = ROOT/'implementation/phase144'
    qp, cp = out/'qualification.json', out/'candidate.json'
    assert not qp.exists() and not cp.exists()
    compact = dict(kind='phase144-ordinary-native-qualification',complete=True,nativeQualified=True,
        rawQualification=raw_pin,method=method,sealer=sealer,source=q['source'],api=q['api'],checkedApi=a['checkedApi'],
        sourceManifest=a['sourceManifest'],finiteControls=a['finiteControls'],finiteControlCount=127,
        completeSourceReplay=True,protectedDeclarationCount=len(a['protectedDeclarations']),
        unchangedProofDeclarations=a['unchangedProofDeclarations'],producer=q['producer'],producerQualification=q['producerQualification'],
        n1=q['n1'],n2=q['n2'],runtime=q['runtime'],actualRuntimeAuthority=q['actualRuntimeAuthority'],runtimePolicy=policy,
        qbe=q['qbe'],q2EqualsQ3=True,q1EqualsQ2=False,machineIdentityClaimed=False,suites=suites,
        hostSmokes=q['hostSmokes'],incrementalQualified=False,
        incrementalSmoke=dict(batch=smoke['batch'],batchJobs=4,session=smoke['session'],sessionFrames=2,completeProductsExact=True),
        installed=False,defaultSelectionChanged=False,inputs=list(INPUTS.values()),
        verificationScope='Compact projection of the exact sealed raw receipt; principal and displayed evidence rehashed. The raw sealer authenticates its full input closure.',scope=scope)
    n2_build = read(q['actualRuntimeAuthority'][2])
    assert n2_build['binary']==q['n2'] and n2_build['source']==q['source'] and n2_build['runtime']==q['runtime']
    verify(n2_build['object'])
    encoded = (json.dumps(compact,indent=2)+'\n').encode()
    compact_pin = dict(file=str(qp),bytes=len(encoded),sha256=hashlib.sha256(encoded).hexdigest())
    candidate = dict(kind='phase144-cold-native-candidate',complete=True,sourceChecked=True,nativeQualified=True,
        incrementalQualified=False,selected=False,installed=False,defaultSelectionChanged=False,
        source=q['source'],sourceManifest=a['sourceManifest'],checkedApi=a['checkedApi'],api=q['api'],
        native=q['n2'],n1=q['n1'],n2=q['n2'],nativeBuild=q['actualRuntimeAuthority'][2],
        nativeObject=n2_build['object'],qualification=compact_pin,rawQualification=raw_pin,runtime=q['runtime'],runtimePolicy=policy,
        preferredCarrierReceipt=plan['carrierReceipt'],preferredCarrier=plan['carrier'],preferredStamp=plan['stamp'],base=plan['base'],
        qualifiedFallback=pin(ROOT/'implementation/phase143/candidate.json'),
        sourceLines=len(Path(q['source']['file']).read_text().splitlines()),
        sourceProofScope='11 inherited proof declarations retain exact bodies; this source/finite-test/native qualification is not a proof of the compiler or all callers.',
        incrementalScope='Only the separately pinned frozen A/B session and four-job batch smoke passed; broad incremental qualification is not claimed.',qualificationScope=scope)
    for row in INPUTS.values(): assert pin(row['file'])==row
    with qp.open('xb') as f: f.write(encoded)
    with cp.open('x') as f: f.write(json.dumps(candidate,indent=2)+'\n')
    print(json.dumps(dict(complete=True,qualification=pin(qp),candidate=pin(cp))))


if __name__=='__main__': main()
