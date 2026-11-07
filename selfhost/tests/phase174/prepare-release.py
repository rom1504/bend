#!/usr/bin/env python3
"""Prepare explicit Phase174 inputs for the unchanged Phase170 release auditor.

Metadata only: no compiler, generated program, installation or selector mutation.
Missing/incomplete gates fail closed. Run promotion.py separately after this.
"""
import argparse
import hashlib
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
import release
import source
from common import changed_inputs, fresh_output, pin, require, verify, write_json

CANONICAL = dict(bytes=3161409, sha256='74cd7de3e5076490e20ba0218d4c9254853be72562946b9ef66fed6c10c7a53a')
CONTROL_COUNTS = dict(failFast=22, scc=6, planners=32, catalogue=12, history=5)


def prepare(args):
    campaign = args.campaign.resolve(strict=True)
    inputs = [pin(__file__), pin(release.__file__), pin(source.__file__),
              pin(ROOT / 'selfhost/tools/build/common.py'),
              pin(ROOT / 'selfhost/tests/phase170/promotion.py')]

    def read(file):
        p = pin(ROOT / file)
        inputs.append(p)
        r = json.loads(verify(p).read_text())
        require(r.get('complete') is True and not r.get('error') and not r.get('changedInputs'),
                'Incomplete, failed or changed receipt: ' + str(file))
        return r

    def artifact(row):
        actual = pin(ROOT / row['file'])
        require(release.same(actual, row), 'Changed artifact: ' + row['file'])
        inputs.append(actual)
        return actual

    def record(relative):
        return campaign / relative / 'report.json'

    previous = read(args.previous)
    frozen = read(campaign / 'reference-source01/receipt.json')
    old_selector = next(p for p in frozen['pins'] if p['file'] == 'selfhost/manifests/current.json')
    require(release.same(pin(args.previous), old_selector), 'Frozen Phase170 selector differs')
    require(previous['source']['identity'] == dict(bytes=3150535,
        sha256='434edd1d56128f9480800573abf8a0ae21d910a547837af089f25cd1d0e89b71'),
        'Expected Phase170 predecessor')
    canonical = artifact(pin(campaign / 'source01/compiler.bend'))
    require(release.same(canonical, CANONICAL), 'Only exact measured Phase171 source is admitted')
    assembled = source.maintained_assemble(ROOT / 'selfhost/src/compiler.json', ROOT / 'selfhost', 'qbe')
    require(release.same(canonical, dict(bytes=len(assembled), sha256=hashlib.sha256(assembled).hexdigest())),
            'Maintained canonical source differs')
    inputs.append(pin(ROOT / 'selfhost/src/compiler.json'))

    roles = dict(qbeBuild=record('native-n2'), qbeQualification=record('qbe64'),
        jsB2=args.js_b2_report or record('js-b2-retry'), jsB3=record('js-b3'), jsQualification=record('js45'),
        jsPublic=record('js-public'), cliProfile=record('public-profile'),
        cliPackage=campaign / 'public-package/BUILD.json', cliControls=record('public-controls'),
        cliQualification=record('c45'))
    docs = {k: read(p) for k, p in roles.items()}
    n2, b2 = artifact(docs['qbeBuild']['binary']), artifact(docs['jsB2']['image'])
    n1_report = read(ROOT / 'selfhost/build/phase171/native-candidate01/report.json')
    n1 = artifact(n1_report['binary'])
    require(n1_report['imageBinding']['stage'] == 'N1'
            and release.same(n1_report['imageBinding']['sourceIdentity'], canonical),
            'Reused genuine N1 must have the same complete source')
    n1_ir = artifact(n1_report['retainedIR'])
    require(docs['qbeBuild'].get('comparedToReference') is True
            and release.same(docs['qbeBuild']['request']['image'], n1)
            and release.same(docs['qbeBuild']['expectedQbe'], n1_ir)
            and release.same(docs['qbeBuild']['irDigest'], n1_ir),
            'Fresh N2 must execute actual N1 and match its whole QBE')
    n2_ir = artifact(docs['qbeBuild']['retainedIR'])
    b1_doc = read(record('b1')); b1 = artifact(b1_doc['api'])
    require(release.same(docs['jsB2']['generator'], b1), 'Actual B2 did not use the checked B1')
    qbe_doc = read(record('qbe-api')); qbe_api = artifact(qbe_doc['api'])
    controls_doc = read(record('controls-api')); controls_api = artifact(controls_doc['api'])
    session_doc = read(record('session-api')); session_api = artifact(session_doc['api'])
    providers = {name: artifact(row) for name, row in previous['providers'].items()}
    require(set(providers) == {'base', 'jsLegacyRuntime', 'jsDirectRuntime', 'cRuntime',
                               'cRuntimeTemplate', 'qbeRuntime'}, 'Unexpected provider inventory')

    extras = {}

    def gate(name, file, role, claims, bindings=None, components=None):
        r = read(file)
        for field, expected in claims.items():
            actual = release.at(r, field)
            require(type(actual) is type(expected) and actual == expected,
                    'Expected gate claim failed: ' + name + ':' + field)
        for field, expected in (bindings or {}).items():
            require(release.same(release.at(r, field), expected), 'Gate identity differs: ' + name + ':' + field)
        if role == 'qualification':
            statuses = [r[k] for k in ('passed', 'qualified', 'nativeQualified') if k in r]
            require(statuses and all(v is True for v in statuses), 'Nonpassing qualification: ' + name)
        extras[name] = dict(report=str(file), role=role, claims=claims,
                            bindings=bindings or {}, components=components or [])
        return r

    gate('integrated-source', ROOT / 'implementation/phase174/source-integration.json', 'derivation',
         dict(kind='phase174-exact-phase171-integration', byteIdenticalToMeasured=True,
              inverseRecoversParent=True, originalSignaturesPreserved=True,
              declarationCounts=dict(original=8414, final=8442, unchanged=8398, replacements=16, additions=28, removed=0),
              **{'protected.count':112, 'protected.mapUnchanged':True,
                 'protected.normalizedChecksPassed':True, 'mainUnchanged.operation':'keep'}),
         {'maintainedSource':canonical, 'measuredSource':canonical}, ['qbe'])
    gate('source-checked', record('b1'), 'lineage',
         dict(kind='bend-checked-hosted-api', checked=True, status=0, signal=None),
         {'source':canonical, 'api':b1}, ['qbe', 'js'])
    gate('controls-source-checked', record('controls-api'), 'lineage',
         dict(kind='bend-checked-hosted-api', checked=True, status=0, signal=None),
         {'api':controls_api}, ['qbe'])
    gate('integrated-controls', record('controls'), 'qualification',
         dict(kind='phase174-integrated-controls', passed=True, total=77, counts=CONTROL_COUNTS),
         {'canonicalSource':canonical, 'candidateApi':controls_api}, ['qbe'])
    gate('qbe-reproduction', record('q3'), 'lineage',
         {'kind':'bend-build-request', 'byteExact':True, 'host':'native', 'stage':'N2', 'target':'qbe',
          'process.complete':True, 'process.exitCode':0, 'process.timedOut':False, 'process.stderr.bytes':0},
         {'image':n2, 'source':canonical, 'product':n2_ir, 'request.expected':n2_ir}, ['qbe'])
    gate('qbe-elf-metadata', ROOT / 'experiments/phase174/elf-audit.json', 'lineage',
         dict(kind='phase174-elf-metadata-audit', loadedSegmentsEqual=False, wholeELFEqual=False,
              allocatedSectionsEqual=False, allocatedSectionsExceptGnuBuildIdEqual=True,
              loaderRelevantHeadersEqual=True, allNonloadedDifferencesExplained=True,
              runtimeImageEquivalent=True, targetsRun=False), {'old':n1, 'new':n2}, ['qbe'])
    gate('qbe-bootstrap-chain', record('reproduction-v2'), 'lineage',
         dict(kind='phase174-native-reproduction-v2', n1Reused=True, allSameSource=True, qbeFixedPoint=True,
              machineIdentity={'program.ssa':True, 'program.s':True, 'program.o':True},
              loadedSegmentsEqual=False, allocatedSectionsEqual=False, wholeELFEqual=False,
              compiledCodeDataEqual=True, loaderRelevantHeadersEqual=True, runtimeImageEquivalent=True),
         {'source':canonical, 'n1':n1, 'n2':n2}, ['qbe'])
    broad = gate('qbe-correctness-products', campaign / 'broad-products.json', 'lineage',
         dict(kind='bend-phase170-exact-products', matched=45, exact=45, targetsRun=False),
         {'qualification':pin(roles['qbeQualification'])}, ['qbe'])
    require(len(broad['rows']) == 45, 'Expected exactly 45 broad product comparisons')
    timed = gate('qbe-timed-products', record('timed-products'), 'lineage',
         dict(kind='bend-phase170-timed-product-reemission', expectedCount=45), {'image':n2}, ['qbe'])
    require(len(timed['rows']) == 45 and all(row.get('complete') is True for row in timed['rows']),
            'Expected exactly 45 complete timed wrappers')
    gate('qbe-session-bootstrap', record('native-session-bootstrap'), 'qualification',
         dict(kind='bend-native-session-bootstrap-qualification', passed=True, qualified=True,
              protocolUnderTest='P140/2', modeMatchedColdComparisons=6, noOpExercisesReuse=True,
              realEditChangesProduct=True, sourceUnchanged=True), {'image':n2, 'source':canonical}, ['qbe'])
    session_claims = {'kind':'bend-experimental-session', 'process.complete':True, 'process.exitCode':0}
    gate('qbe-session-normal', record('native-session-normal'), 'lineage',
         {**session_claims, 'request.host':'native', 'request.stage':'N2'}, {'request.image':n2}, ['qbe'])
    hosted = gate('hosted-session-control', record('session-hosted'), 'lineage',
         {**session_claims, 'request.host':'js', 'request.stage':'B1', 'request.checkCold':True, 'request.units':True},
         {'request.image':session_api})
    require(len(hosted['request']['jobs']) == 8, 'Expected eight hosted-session controls')
    for name, target, count in [('js-negative','js',2), ('js-c-focused','c',5)]:
        gate(name, record(name), 'qualification',
             {'kind':'bend-finite-qualification','passed':True,'host':'js','stage':'B2','target':target,
              'counts':{'pass':count,'fail':0,'unsupported':0}}, {'image':b2}, ['js'])

    # This is the unchanged assembler's schema, not a claim that the release is Phase170.
    recipe = dict(kind='phase170-release-inputs', version=1, canonical=canonical['file'],
        sourceRecipe='selfhost/src/compiler.json', sourceRoot='selfhost', sourceProfile='qbe',
        previous=str(args.previous.resolve()), providers=providers,
        reports={k:str(p) for k,p in roles.items()},
        hostedQbe=dict(acquisition=str(record('qbe-api')), qualification=str(record('qbe-hosted')),
                       exports=str(args.qbe_exports.resolve())), extraGates=extras,
        installedQbeGates=['qbe-hosted-acquisition','qbe-hosted-qualified','qbe-session-bootstrap',
                           'qbe-session-normal','qbe-qualified'],
        scope='Phase174 promotion of exact measured Phase171 source. Genuine N1 acquisition reused; '
              'fresh N2/Q3 and source-bound public images; unchanged maintained release gates.')
    # Also fail here, before writing a candidate recipe, if hosted qualification/exports are absent.
    read(record('qbe-hosted')); inputs.append(pin(args.qbe_exports))
    require(not changed_inputs(inputs), 'Inputs changed during recipe preparation')
    out = fresh_output(args.out, ROOT)
    write_json(out / 'recipe.json', recipe)
    write_json(out / 'report.json', dict(kind='phase174-release-input-preparation', version=1,
        complete=True, targetsRun=False, installed=False, releaseAudited=False, inputs=inputs,
        recipe=pin(out / 'recipe.json'), canonical=canonical, reusedN1=n1,
        actualN2=n2, hostedQbe=qbe_api,
        next='Run unchanged selfhost/tests/phase170/promotion.py, then release.py audit/install.'))
    return out / 'recipe.json'


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--campaign', type=Path, default=ROOT / 'selfhost/build/phase174')
    p.add_argument('--previous', type=Path,
                   default=ROOT / 'selfhost/build/phase174/reference-source01/selfhost__manifests__current.json')
    p.add_argument('--qbe-exports', type=Path, default=ROOT / 'selfhost/build/phase170/qbe-exports.json')
    p.add_argument('--js-b2-report', type=Path, help='Defaults to campaign/js-b2-retry/report.json; failed js-b2 is never reused')
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    print(prepare(a))
