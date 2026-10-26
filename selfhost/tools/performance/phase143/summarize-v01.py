"""Join exact cold-build/qualification receipts; no compiler targets run."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
OUT = ROOT/'implementation/phase143'


def pin(file):
    file = Path(file).resolve()
    b = file.read_bytes()
    return dict(file=str(file), bytes=len(b), sha256=hashlib.sha256(b).hexdigest())


inputs = {}


def load(file):
    file = ROOT/file
    p = pin(file)
    inputs[p['file']] = p
    return json.loads(file.read_text())


def verify(p):
    assert pin(p['file']) == p, p['file']
    return p


def save(name, value):
    file = OUT/name
    assert not file.exists(), file
    file.write_text(json.dumps(value, indent=2)+'\n')


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    before = load('selfhost/build/phase130/p143-current-native-cold01/report.json')
    after = load('selfhost/build/phase130/p143-candidate-current-cold01/report.json')
    bm = load('selfhost/build/phase111/p143-current-n2/report.json')
    am = load('selfhost/build/phase111/p143-candidate-current-built/report.json')
    for request in [before, after]:
        assert request['complete'] and request['byteExact'] and request['exitCode'] == 0
        for k in ['image', 'source', 'product', 'base', 'carrier', 'expectedQbe']:
            verify(request[k])
    for k in ['source', 'base', 'carrier', 'stamp', 'expectedQbe']:
        assert before[k] == after[k], k
    assert before['inheritedAffinity'] == after['inheritedAffinity'] == [3]
    assert before['product']['sha256'] == after['product']['sha256']
    for build in [bm, am]:
        assert build['complete'] and all(j['exitCode'] == 0 for j in build['jobs'])
        verify(build['object']); verify(build['binary'])
    assert bm['object']['sha256'] == am['object']['sha256']
    clocks = {}
    for mode, request, build, guards in [
        ('baseline', before, bm, ['current-native-cold01-guard', 'current-native-machine01-guard']),
        ('candidate', after, am, ['candidate-current-cold01-guard', 'candidate-current-machine01-guard'])]:
        g = [load('selfhost/build/phase143/'+name+'/process.json') for name in guards]
        assert all(x['complete'] for x in g)
        clocks[mode] = dict(compilerSeconds=request['nativeSeconds'], machineSeconds=build['buildSeconds'],
                           targetBuildSeconds=request['nativeSeconds']+build['buildSeconds'],
                           supervisedBuildSeconds=sum(x['wallSeconds'] for x in g),
                           peakCompilerRssBytes=request['peakRssKiB']*1024)
    metrics = dict(kind='phase143-same-source-cold-build', complete=True, clocks=clocks,
        ratios={k: clocks['candidate'][k]/clocks['baseline'][k]
                for k in ['compilerSeconds', 'targetBuildSeconds', 'supervisedBuildSeconds']},
        source=before['source'], baselineImage=before['image'], candidateImage=after['image'],
        exactQbe=after['product'], exactMachineObject=am['object'],
        scope='One controlled fresh-process comparison on the same full Phase142 source, '
              'prepared Base/runtime, CPU3 and complete independent QBE. No source-specific reuse. '
              'Target sum includes source/file I/O and machine construction; supervised sum additionally '
              'includes launch, receipt/authentication and byte comparison. Not a confidence interval '
              'or a fresh upstream/JS/C comparison. OS page caches were not flushed.',
        inputs=list(inputs.values()), method=pin(__file__))
    save('metrics.json', metrics)

    emission = load('selfhost/build/phase130/p143-integrated-emit01/report.json')
    reproduction = load('selfhost/build/phase130/p143-reproduce01/report.json')
    n1 = load('selfhost/build/phase111/p143-integrated-n1/report.json')
    n2 = load('selfhost/build/phase111/p143-integrated-n2/report.json')
    api = load('selfhost/build/phase111/p143-integrated-api03/report.json')
    assembly = load('selfhost/build/phase143/integrated-source03/manifest.json')
    assert api['complete'] and api['checked'] and emission['complete']
    assert reproduction['complete'] and reproduction['byteExact']
    assert emission['source'] == reproduction['source'] == assembly['source']
    assert emission['product']['sha256'] == reproduction['product']['sha256']
    assert n1['complete'] and n2['complete'] and n1['object']['sha256'] == n2['object']['sha256']
    for p in [assembly['source'], n1['binary'], n2['binary'], n1['object'], n2['object']]: verify(p)
    suites = []
    for label, reference in [('n1-focused19', 'focused19'), ('n2-focused19', 'focused19'), ('n2-full45', 'full45')]:
        result = load(f'selfhost/build/phase111/p143-{label}/report.json')
        old = load(f'selfhost/build/phase111/p137-n3-{reference}/report.json')
        assert result['complete'] and result['passed'] and result['names'] == old['names']
        old_rows = {r['name']: r for r in old['rows']}
        exact = []
        for row in result['rows']:
            if row['compiled']:
                verify(row['product'])
                assert row['product']['sha256'] == old_rows[row['name']]['product']['sha256'], row['name']
                exact.append(row['name'])
        suites.append(dict(name=label, summary=result['summary'], exactProducts=exact))
    qualification = dict(kind='phase143-ordinary-native-qualification', complete=True, nativeQualified=True,
        source=assembly['source'], n1=n1['binary'], n2=n2['binary'], qbe=emission['product'],
        qbeReproductionExact=True, machineObjectsExact=True, suites=suites,
        inputs=list(inputs.values()), method=pin(__file__),
        scope='Independent upstream source check; qualified Phase137 producer to N1 to N2; '
              'complete QBE reproduction, both focused19 gates and N2 ordinary45, all positive products '
              'byte-identical to frozen references. Not a compiler theorem, complete language conformance, '
              'ELF fixed point, new JS/C qualification or installed/default promotion.')
    save('qualification.json', qualification)
    load('implementation/phase142/candidate.json')
    fallback = load('implementation/phase137/candidate.json')
    assert emission['image'] == fallback['n3']
    candidate = dict(kind='phase143-cold-native-candidate', complete=True, sourceChecked=True,
        nativeQualified=True, incrementalQualified=False, selected=False, installed=False,
        defaultSelectionChanged=False,
        source=assembly['source'], sourceManifest=pin(ROOT/'selfhost/build/phase143/integrated-source03/manifest.json'),
        checkedApi=pin(ROOT/'selfhost/build/phase111/p143-integrated-api03/report.json'),
        native=n2['binary'], n1=n1['binary'], n2=n2['binary'],
        nativeBuild=pin(ROOT/'selfhost/build/phase111/p143-integrated-n2/report.json'),
        qualification=pin(OUT/'qualification.json'), metrics=pin(OUT/'metrics.json'),
        preferredCarrierReceipt=pin(ROOT/'selfhost/build/phase130/base-carrier01/receipt.json'),
        preferredCarrier=emission['carrier'], preferredStamp=emission['stamp'],
        qualifiedFallback=pin(ROOT/'implementation/phase137/candidate.json'),
        parent=pin(ROOT/'implementation/phase142/candidate.json'),
        runtime=emission['runtime'], overrides=assembly['overrides'],
        sourceLines=dict(before=assembly['parentLines'], after=assembly['physicalLines'],
                         addedDefinitions=len(assembly['added'])),
        proofScope=dict(newProof=False, unchangedDeclarations=assembly['unchangedProofDeclarations'],
                        note='Existing proof and verifier declarations preserved; new transformations have '
                             'source review, finite/complete-product tests, not new BendTT theorems.'),
        qualificationScope=qualification['scope'])
    save('candidate.json', candidate)
    print(json.dumps(dict(clocks=clocks, ratios=metrics['ratios'], nativeQualified=True,
                          sourceLines=candidate['sourceLines'])))


if __name__ == '__main__':
    main()
