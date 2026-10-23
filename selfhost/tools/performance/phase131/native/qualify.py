"""Bind an actual qualified-native producer chain; data only, never execute targets."""
import argparse
import filecmp
import hashlib
import importlib.util
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[5]
sys.path.insert(0, str(ROOT / 'selfhost/tools/performance/phase128/native'))
import qualify as Q


def load_module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


C = load_module('phase131_composition', ROOT / 'selfhost/tools/performance/phase131/prepare.py')
R = load_module('phase130_request_contract', ROOT / 'selfhost/tools/performance/phase130/native-request.py')
SELECTION = ROOT / 'implementation/phase130/candidate.json'
FROZEN = {
    SELECTION: '28c819c35af862d996a1eef590a9b003a4854a5e1c92dc0a03c5b265b5d8a22c',
    Path(Q.__file__): '7e3bf643c2941874709cf11aa7890929ef119eeb4fa0a03d8427e8b119406726',
    Path(Q.__file__).with_name('prepare.py'): '861fce178949e15931224044de5ef970e0c6c00895157b097b6cc87edd795124',
    Path(R.__file__): 'e32e5e99502a9b6485e54ce6669200ee48eaba0c289d7bfb2809a1dc6ef0bf2f',
    Path(C.__file__): '33a4a40ab35ef705cbe99cff20b4b6a2c9792eee4ad8c9597a006d22ae22defa',
    Q.BASE: Q.BASE_SHA,
    Q.BUILDER: Q.BUILDER_SHA,
}
INPUTS = {}


def require(ok, message):
    if not ok:
        raise ValueError(message)


def retain(value):
    for row in Q.pins(value):
        if not Path(row['file']).is_absolute():
            row = dict(row, file=str((ROOT / row['file']).resolve()))
        previous = INPUTS.get(row['file'])
        require(previous is None or previous == row, 'Conflicting input identity: ' + row['file'])
        Q.verify(row)
        INPUTS[row['file']] = row


def read(path):
    retain(Q.pin(path))
    value = json.loads(Path(path).read_text())
    retain(value)
    return value


def bound(row):
    retain(row)
    return read(row['file'])


def exact(left, right):
    retain([left, right])
    return left['bytes'] == right['bytes'] and filecmp.cmp(left['file'], right['file'], shallow=False)


def source_contract(ad, selected):
    require(ad.get('kind') == 'phase131-native-acquisition-admission' and ad.get('complete')
            and ad.get('sourceChecked') and ad.get('originalVerifiersUnchanged')
            and ad.get('runtimeContractsUnchanged'), 'Complete checked source/runtime admission required')
    require(ad['parentAdmission'] == selected['admission'] and ad['runtime'] == selected['runtime'],
            'Qualified parent admission/runtime differs')
    sm, api = bound(ad['sourceBinding']), bound(ad['checkedApi'])
    require(sm['complete'] and sm['source'] == ad['source'] and sm['parent'] == selected['source'],
            'Composed source identity differs')
    require(api.get('kind') == 'phase111-checked-api' and api.get('complete') and api.get('checked')
            and api['status'] == 0 and api['api'] == ad['api'] and ad['source'] in api['inputs'],
            'Independent checked API does not consume exact source')
    require(api['command'][2:4] == [ad['source']['file'], ad['api']['file']]
            and api['command'][4:] == api['exports'], 'Checked source/API command differs')
    required = {'p88_cache_prepare', 'p86_prepare', 'p86_plan', 'p111_runtime_admission',
                'p111_emit_admitted', 'p111_compile_source'}
    require(required <= set(api['exports']), 'Missing checked request-bound exports')
    parent_api = bound(selected['checkedApi'])
    require(api['command'][:2] == parent_api['command'][:2], 'Upstream checking command changed')
    for old in parent_api['inputs']:
        if old == selected['source']:
            continue
        require(any(x['bytes'] == old['bytes'] and x['sha256'] == old['sha256'] for x in api['inputs']),
                'Upstream checker/method authority changed: ' + old['file'])
    parent = Path(selected['source']['file']).read_text()
    source = Path(ad['source']['file']).read_text()
    snapshots = sorted(Path(ad['source']['file']).parent.glob('module*.bend'),
                       key=lambda p: int(p.stem[len('module'):]))
    require(snapshots, 'Composition module snapshots missing')
    for path in snapshots:
        row = Q.pin(path)
        require(any(x['bytes'] == row['bytes'] and x['sha256'] == row['sha256'] for x in sm['inputs']),
                'Module snapshot lacks original input identity')
        retain(row)
    replay, added, protected = C.compose(parent, [p.read_text() for p in snapshots],
                                       set(sm['overrides']), set(sm.get('moduleOverrides', [])))
    require(replay.encode() == Path(ad['source']['file']).read_bytes(), 'Complete source replay differs')
    require(sm['added'] == added and sm['protectedDeclarations'] == protected,
            'Composed declaration/protected inventory differs')
    before, after = C.blocks(parent), C.blocks(source)
    changed = sorted(n for n in before if C.norm(before[n]) != C.norm(after[n]))
    require(sorted(ad['changedDeclarations']) == changed and sorted(ad['addedDeclarations']) == added,
            'Admission changed/added bodies differ')
    require(all(C.norm(before[n]) == C.norm(after[n]) for n in protected), 'Protected body changed')
    old_ad = bound(selected['admission'])
    inherited = bound(old_ad['parentAdmission'])['runtimeContract']
    require(inherited['complete'] and inherited['sourceChecked'] and inherited['runtime'] == ad['runtime'],
            'Inherited runtime contract differs')
    authority = C.blocks(Path(inherited['source']['file']).read_text())
    runtime_bodies = inherited['sourceDeclarations']
    for row in runtime_bodies:
        name, raw = row['name'], authority[row['name']].encode()
        require(len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256'],
                'Inherited runtime body identity differs: ' + name)
        require(C.norm(before[name]) == C.norm(authority[name]) == C.norm(after[name]),
                'Runtime authority changed; a new contract is required: ' + name)
    require(ad.get('semanticChecks'), 'No candidate semantic-check authorities declared')
    for row in ad['semanticChecks']:
        check = bound(row)
        require(check.get('complete') and (check.get('passed') is True or check.get('pass') is True),
                'Candidate semantic check is incomplete or failed')
    return dict(completeSourceReplay=True, changedDeclarations=changed, addedDeclarations=added,
                changedBodies=[dict(name=n, bytes=len(after[n].encode()),
                    sha256=hashlib.sha256(after[n].encode()).hexdigest()) for n in changed + added],
                protectedDeclarations=protected, unchangedRuntimeBodies=runtime_bodies,
                independentCheckedApi=ad['checkedApi'])


def command(image, source, base, carrier, stamp):
    return [image['file'], '--threads', '1', '--gpu', 'off', '--', 'phase111',
            source['file'], base['file'], 'cache', carrier['file'], stamp]


def emission(path, image, source, runtime, carrier_receipt):
    report = read(path)
    carrier, base, inputs = R.carrier_inputs(carrier_receipt)
    retain(inputs)
    require(report.get('kind') == 'phase130-native-source-qbe-request' and report.get('complete')
            and report['exitCode'] == 0 and report.get('changedInputs') == []
            and not report.get('timedOut', False), 'Incomplete native request')
    require(report['image'] == image and report['source'] == source and report['runtime'] == runtime
            and report['base'] == base and report['carrier'] == carrier['carrier']
            and report['stamp'] == carrier['stamp'] and report['mode'] == 'cache', 'Native request identity differs')
    require(report['command'] == command(image, source, base, carrier['carrier'], carrier['stamp']),
            'Native request argv differs')
    require(all(row in report['inputs'] for row in [image, source, runtime, Q.pin(R.__file__),
            Q.pin(carrier_receipt), *inputs]), 'Native request authority missing')
    require(report['product']['bytes'] > 0 and report['stderr']['bytes'] == 0,
            'Nonempty raw QBE and empty stderr required')
    if report.get('expectedQbe'):
        require(report.get('byteExact') and exact(report['expectedQbe'], report['product']),
                'Declared request equality failed')
    return report['product']


def coverage(path, image, image_build, runtime, tools, broad=False):
    report = read(path)
    corpus = ROOT / 'selfhost/tools/performance/phase111/coverage'
    corpus = corpus / ('full45/manifest.json' if broad else 'manifest.json')
    frozen = read(corpus)
    names = [r['name'] for r in frozen['fixtures']]
    positive, refused = (45, 0) if broad else (16, 3)
    require(report.get('complete') and report.get('passed') and report['mode'] == 'cache'
            and report['kind'] == 'phase125-aligned-native-source-semantic-coverage', 'Native coverage incomplete')
    require(report['names'] == names and [r['name'] for r in report['rows']] == names, 'Coverage corpus differs')
    require(all(p in report['inputs'] for p in [Q.pin(corpus), Q.pin(Q.NATIVE / 'coverage.py'), image, runtime]),
            'Coverage authority/image/runtime missing')
    require(report['summary']['semanticPasses'] == positive and report['summary']['expectedRefusals'] == refused
            and report['summary']['pending'] == 0, 'Coverage summary differs')
    legacy = read(R.OLD)
    refusals = {'negative-type': ('source-admission', 'check: main:'),
                'negative-affine': ('source-admission', 'check: twice:'),
                'negative-foreign': ('backend-admission', 'compile: foreign provider unavailable in fixed runtime: p108_missing')}
    for row, case in zip(report['rows'], frozen['fixtures']):
        require(row['expected'] == case['expect'], 'Independent output oracle changed')
        emitted = bound(row['emission'])
        source = dict(case['source'], file=str((ROOT / case['source']['file']).resolve()))
        retain(source)
        require(emitted['image'] == image and emitted['imageReceipt'] == Q.pin(image_build)
                and source in emitted['inputs'], 'Covered source/image/build differs')
        jobs = [j for j in emitted['jobs'] if j['label'] == 'native-request']
        require(len(jobs) == 1, 'Expected one raw covered request')
        job = jobs[0]
        require(job['command'] == command(image, source, legacy['inputPins']['base'], legacy['carrier'], legacy['stamp'])
                and job['stdout'] == emitted['product'] and job['stderr'] == emitted['stderr'],
                'Covered raw command/product differs')
        if case['expect']['stage'] == 'execute':
            require(row['semanticPass'] and row['status'] == 'passed' and emitted['complete']
                    and job['status'] == 'complete' and job['exitCode'] == 0 and job['stderr']['bytes'] == 0,
                    'Positive native request failed')
            built = bound(row['build'])
            require(emitted['buildReport'] == row['build']
                    and Q.build(built, emitted['product'], runtime, tools) == row['binary'], 'Covered binary differs')
            execution = [j for j in built['jobs'] if j['label'] == 'execute']
            require(len(execution) == 1 and built['outputExact']
                    and execution[0]['exitCode'] == case['expect']['exitCode']
                    and Q.verify(execution[0]['stdout']).read_bytes() == case['expect']['stdout'].encode()
                    and Q.verify(execution[0]['stderr']).read_bytes() == case['expect']['stderr'].encode(),
                    'Full independent program output differs')
        else:
            stage, prefix = refusals[case['name']]
            diagnostic = Q.verify(job['stderr']).read_text().strip()
            require(not emitted['complete'] and row['expectedRefusal'] and not row['semanticPass']
                    and row['status'] == 'source-refused' and row['refusalStage'] == stage
                    and row['diagnostic'] == diagnostic and diagnostic.startswith(prefix)
                    and job['status'] == 'failed' and job['exitCode'] == 1 and not job.get('timedOut', False)
                    and job['stdout']['bytes'] == 0, 'Refusal stage/output differs')
    return dict(report=Q.pin(path), image=image, semanticPasses=positive, expectedRefusals=refused)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for name in ['admission', 'producer', 'acquisition', 'n1-build', 'self-emission', 'n2-build',
                 'first-focused', 'final-focused', 'final-full45', 'out']:
        p.add_argument('--' + name, type=Path, required=True)
    p.add_argument('--reproduction', type=Path)
    p.add_argument('--n3-build', type=Path)
    p.add_argument('--carrier-receipt', type=Path)
    a = p.parse_args()
    require(not a.out.exists() and a.out.resolve().is_relative_to(ROOT / 'selfhost/build/phase131'),
            'Fresh Phase131 qualification output required')
    require(bool(a.reproduction) == bool(a.n3_build), 'Extra reproduction and N3 build must be supplied together')
    for path, sha in FROZEN.items():
        require(Q.pin(path)['sha256'] == sha, 'Frozen method/parent changed: ' + str(path))
        retain(Q.pin(path))
    selected = read(SELECTION)
    parent_qualification = bound(selected['qualification'])
    require(selected['complete'] and selected['nativeQualified'] and parent_qualification['complete']
            and parent_qualification['nativeQualified'], 'Qualified native parent required')
    for key in ['source', 'api', 'runtime', 'n1', 'n2']:
        require(selected[key] == parent_qualification[key], 'Parent qualification/selection mismatch: ' + key)
    producer = Q.pin(a.producer)
    require(producer in [selected['n1'], selected['n2']], 'Producer is not a selected qualified Phase130 image')
    ad = read(a.admission)
    bodies = source_contract(ad, selected)
    carrier = a.carrier_receipt or Path(selected['preferredCarrierReceipt']['file'])
    tools = read(Q.BASE)['tools']
    q1 = emission(a.acquisition, producer, ad['source'], ad['runtime'], carrier)
    n1 = Q.build(read(a.n1_build), q1, ad['runtime'], tools)
    q2 = emission(a.self_emission, n1, ad['source'], ad['runtime'], carrier)
    n2 = Q.build(read(a.n2_build), q2, ad['runtime'], tools)
    images, products = dict(n1=n1, n2=n2), dict(q1=q1, q2=q2)
    first_image, first_build, final_image, final_build = n1, a.n1_build, n2, a.n2_build
    left, right = q1, q2
    if a.reproduction:
        q3 = emission(a.reproduction, n2, ad['source'], ad['runtime'], carrier)
        n3 = Q.build(read(a.n3_build), q3, ad['runtime'], tools)
        images['n3'], products['q3'] = n3, q3
        first_image, first_build, final_image, final_build = n2, a.n2_build, n3, a.n3_build
        left, right = q2, q3
    require(exact(left, right), 'Required complete QBE reproduction differs')
    gates = [coverage(a.first_focused, first_image, first_build, ad['runtime'], tools),
             coverage(a.final_focused, final_image, final_build, ad['runtime'], tools),
             coverage(a.final_full45, final_image, final_build, ad['runtime'], tools, broad=True)]
    retain(Q.pin(__file__))
    result = dict(kind='phase131-native-producer-qualification', complete=True, nativeQualified=True,
        targetsRun=False, source=ad['source'], api=ad['api'], runtime=ad['runtime'],
        admission=Q.pin(a.admission), sourceBinding=ad['sourceBinding'], checkedApi=ad['checkedApi'],
        producer=producer, producerSelection=Q.pin(SELECTION), producerQualification=selected['qualification'],
        acquisitionRoute='qualified-native', hostedAcquisition=False, sourceBodyIdentity=bodies,
        **images, qbe=products, byteExact=True, reproducedQbe=dict(left=left, right=right),
        acquisitionQbeUnchanged=exact(q1, q2), finalImage=final_image, semanticGates=gates,
        reports={key: Q.pin(value) for key, value in vars(a).items()
                 if key not in ['out', 'producer', 'carrier_receipt'] and value is not None},
        inputs=list(INPUTS.values()), installed=False, selected=False,
        scope='Actual qualified Phase130 N0 compiles independently upstream-checked S to N1; N1(S) builds N2. '
              + ('N2(S) builds N3; Q2/Q3 raw bytes reproduce and focused19 covers N2/N3, ordinary45 N3. '
                 if a.reproduction else 'Q1/Q2 raw bytes reproduce; focused19 covers N1/N2, ordinary45 N2. ')
              + 'Finite regression qualification, not a mathematical compiler proof, ELF fixed point, performance or installed-selection claim.')
    for row in INPUTS.values():
        require(Q.pin(row['file']) == row, 'Input changed during qualification: ' + row['file'])
    with a.out.open('x') as f:
        f.write(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(complete=True, nativeQualified=True, finalImage=final_image, report=Q.pin(a.out))))


if __name__ == '__main__':
    main()
