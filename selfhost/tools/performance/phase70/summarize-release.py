#!/usr/bin/env python3
"""Verify closed Phase70 receipts and write one fresh portable summary; no targets."""
import argparse
import datetime
import hashlib
import json
import math
from pathlib import Path
import statistics
import subprocess

ROOT = Path(__file__).resolve().parents[4]
RAW = ROOT / 'selfhost/build/phase70'
API = '386ae358ee8fe33c5af3f7fec16f956b59451ee6004da99a94146140d3e8a162'
SOURCE = 'd583e187290f087d48b95ffdbe402ed01af81a28d91e0e2cec5462ed8797b2cc'
B2 = 'd069204f38786de7142f10dbc7126371dfa6f7fa234347da98e7d46a23cced8b'
VERIFIED = {}


def require(condition, message):
    if not condition:
        raise ValueError(message)


def local(value):
    p = Path(value)
    if not p.is_absolute():
        return ROOT / p
    # Receipts retain original absolute locations; support relocation of this repo.
    if '/selfhost/' in str(p):
        return ROOT / ('selfhost/' + str(p).split('/selfhost/', 1)[1])
    return p


def relative(p):
    try:
        return str(p.relative_to(ROOT))
    except ValueError:
        return str(p)


def pin(value):
    expected = value if isinstance(value, dict) else {}
    p = local(expected.get('file', expected.get('path')) if expected else value)
    before = p.stat()
    state = (before.st_size, before.st_mtime_ns, before.st_ino)
    cached = VERIFIED.get(p)
    if cached and cached[0] == state:
        row = cached[1]
    else:
        h = hashlib.sha256()
        with p.open('rb') as stream:
            for block in iter(lambda: stream.read(1024 * 1024), b''):
                h.update(block)
        after = p.stat()
        require(state == (after.st_size, after.st_mtime_ns, after.st_ino),
                'Input changed during hash: ' + str(p))
        row = dict(path=relative(p), sha256=h.hexdigest(), bytes=before.st_size)
        VERIFIED[p] = (state, row)
    require(not expected or row['sha256'] == expected['sha256'], 'Hash mismatch: ' + str(p))
    require('bytes' not in expected or row['bytes'] == expected['bytes'], 'Size mismatch: ' + str(p))
    return row


def read(value):
    row = pin(value)
    return json.loads(local(row['path']).read_text())


def same(left, right, label):
    require(pin(left)['sha256'] == pin(right)['sha256'], label)


def passed(value):
    v = read(value)
    require(v.get('complete', True) and v['pass'], 'Gate incomplete or failed: ' + str(value))
    return v


def geomean(xs):
    xs = list(xs)
    return math.exp(sum(math.log(x) for x in xs) / len(xs))


def portable(value):
    if isinstance(value, dict):
        return {k: portable(v) for k, v in value.items() if k != 'canonicalPath'}
    if isinstance(value, list):
        return [portable(v) for v in value]
    if isinstance(value, str) and '/selfhost/' in value and value.startswith('/'):
        return relative(local(value))
    return value


def runtime_cohort(report_path, identities):
    report = read(report_path)
    require(report['complete'], 'Runtime report incomplete')
    plan = read(report['plan'])
    for item in plan['inputs']:
        pin(item)
    require(plan['rounds'] == 3 and set(plan['roles']) == {'baseline69', 'candidate', 'upstream'},
            'Unexpected runtime rotation')
    records = report['records']
    require(len(records) == 54 and len(report['rows']) == 6, 'Unexpected runtime denominator')
    require(all(r['correct'] and r['qualified'] and r['process']['complete']
                and r['process']['returncode'] == 0 and r['child']['returncode'] == 0
                for r in records), 'Unqualified runtime sample')
    rows = []
    for row in report['rows']:
        case = row['case']
        identity = identities[case]
        medians, samples, executables = {}, {}, {}
        for role in plan['roles']:
            group = [r for r in records if r['case'] == case and r['role'] == role]
            require(len(group) == 3 and {r['round'] for r in group} == {0, 1, 2}, 'Missing runtime round')
            require(all(r['repetitions'] == plan['counts'][case]['repetitions'] and
                        r['warmups'] == plan['counts'][case]['warmups'] for r in group), 'Unequal runtime work')
            paths = {r['child']['command'][0] for r in group}
            require(len(paths) == 1, 'Runtime executable changed between rounds')
            executable = pin(next(iter(paths)))
            require(any(pin(item) == executable for item in plan['inputs']), 'Unpinned executable')
            executables[role] = executable
            samples[role] = [r['elapsedMs'] for r in sorted(group, key=lambda r: r['round'])]
            medians[role] = statistics.median(samples[role])
        require(medians == row['mediansMs'], 'Stored runtime median differs')
        same(executables['candidate'], identity['validatedExecutable'], 'C identity maps to different timed binary')
        source = pin(identity['input'])
        require(any(pin(item) == source for item in plan['inputs']), 'C identity maps to different benchmark source')
        c = pin(identity['expected']['b1'])
        require(any(pin(item) == c for item in plan['inputs']), 'C identity maps to different measured C')
        rows.append(dict(case=case, mediansMs=medians, samplesMs=samples,
            candidateOverUpstream=medians['candidate'] / medians['upstream'],
            baseline69OverCandidate=medians['baseline69'] / medians['candidate'],
            source=source, candidateC=c, executables=executables, work=plan['counts'][case]))
    return dict(report=pin(report_path), plan=pin(report['plan']), families=rows,
        qualifiedObservations=len(records),
        geomeanCandidateOverUpstream=geomean(r['candidateOverUpstream'] for r in rows),
        geomeanBaseline69OverCandidate=geomean(r['baseline69OverCandidate'] for r in rows),
        scope=plan['scope'])


def compilation(summary_path, attempt, images):
    summary = read(summary_path)
    require(summary['complete'] and not summary['missingJobs'], 'Final clean campaign incomplete')
    plan = read(summary['plan'])
    same(plan['attempt'], attempt, 'Wrong compilation attempt')
    same(plan['imagePins'], images, 'Wrong compilation images')
    for item in plan['inputs']:
        pin(item)
    observations = summary['observations']
    require(len(observations) == 29 and len(plan['jobs']) == 29, 'Expected 2 preparations and 27 clean requests')
    require({x['job']['name'] for x in observations} == {x['name'] for x in plan['jobs']}, 'Wrong compilation job set')
    clean = []
    for item in observations:
        report = passed(item['report'])
        require(report['inputsUnchanged'] and not item['job']['profile'], 'Dirty or profiled clean sample')
        require(report['job'] == item['job'], 'Wrong compilation job')
        same(report['plan'], summary['plan'], 'Wrong compilation plan')
        require(item['timings'] == report['timings'], 'Compilation timings differ')
        report_path = local(pin(item['report'])['path'])
        guard = read(report_path.parent.with_name(report_path.parent.name + '-guard') / 'process.json')
        require(guard['complete'] and guard['returncode'] == 0, 'Compilation guard failed')
        if item['job']['action'] == 'request':
            require(report['exactC'] and report['observation']['checked'], 'Unchecked or mismatched emitted C')
            same(report['output'], report['oracle'], 'Complete C differs from oracle')
            clean.append(item)
    require(len(clean) == 27, 'Unexpected clean request count')
    families = []
    for case in ['numeric', 'array', 'lexer']:
        roles = {}
        for role in ['b1', 'b2', 'typescript']:
            group = [x for x in clean if x['job']['case'] == case and x['job']['role'] == role]
            require(len(group) == 3 and {x['job']['round'] for x in group} == {0, 1, 2}, 'Missing compile round')
            roles[role] = dict(samples=3,
                requestMedianMs=statistics.median(x['timings']['requestMs'] for x in group),
                importsMedianMs=statistics.median(x['timings']['importsMs'] for x in group))
        families.append(dict(case=case, roles=roles, requestRatios={
            role: roles[role]['requestMedianMs'] / roles['typescript']['requestMedianMs'] for role in ['b1', 'b2']}))
    return dict(analysis=pin(summary_path), plan=pin(summary['plan']), cleanRequests=27, preparations=2,
        families=families, geomeanRequestRatios={role: geomean(x['requestRatios'][role] for x in families)
                                               for role in ['b1', 'b2']},
        basePreparation=[dict(role=x['job']['role'], timingsMs=x['timings']) for x in observations
                         if x['job']['action'] == 'prepare'],
        scope='Checked C request time; imports and explicit Bend Base preparation separate. Excludes Clang and generated-program execution. Three samples per cell.')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--source-commit', default='d6d6049')
    parser.add_argument('--identity', type=Path, default=RAW / 'compiler03-C-identity12-v2-summary.json')
    parser.add_argument('--compilation', type=Path, default=RAW / 'compiler03-compilation01-summary.json')
    args = parser.parse_args()
    require(not args.out.exists(), 'Output already exists; choose a fresh path')
    attempt_path = RAW / 'compiler03/attempt.json'
    attempt, images_path = read(attempt_path), RAW / 'compiler03-b2/image-pins.json'
    images = read(images_path)
    require(attempt['checked'] and attempt['artifactKind'] == 'derived-b1', 'Candidate is not checked B1')
    require(pin(attempt['api'])['sha256'] == API and pin(images['b2'])['sha256'] == B2 and
            pin(images['source'])['sha256'] == SOURCE, 'Wrong compiler03 source/API/B2')
    same(images['attempt'], attempt_path, 'Wrong B2 source attempt')
    same(images['b1'], attempt['api'], 'Wrong B2 generator')
    emission, driver = passed(images['emission']), passed(images['comparison'])
    require(emission['checking']['sourceSha256'] == SOURCE and driver['observations'] == 8,
            'Wrong B2 generation or driver qualification')
    commit = subprocess.check_output(['git', 'rev-parse', args.source_commit + '^{commit}'], cwd=ROOT, text=True).strip()
    require(not subprocess.check_output(['git', 'diff', '--name-only', commit, '--', 'selfhost/src'], cwd=ROOT),
            'Current compiler sources differ from selected source commit')
    for item in attempt['snapshot']['sources']:
        pin(item['frozen'])
        if '/selfhost/src/' in item['original']['file']:
            same(item['original'], item['frozen'], 'Live source differs from checked snapshot')
    validation_path = RAW / 'compiler03/validation-001/report.json'
    validation = passed(validation_path)
    same(validation['api'], attempt['api'], 'Wrong checked validation image')
    native_path = RAW / 'compiler03-native100/execution/report.json'
    native = read(native_path)
    same(native['api'], attempt['api'], 'Wrong native control image')
    paired = read(native['selected']['file'])
    require(native['complete'] and len(paired['rows']) == 100 and paired['candidateSelectedComplete']
            and all(r['candidateVerdict'] == 'pass' for r in paired['rows']), 'Native candidate controls failed')
    native_summary = dict(report=pin(native_path), paired=pin(native['selected']['file']),
        candidatePass=100, cases=100, pairedPass=native['pass'],
        referenceStatuses=native['selected']['reference']['statuses'],
        discrepancies=[dict(id=r['id'], reference=r['referenceVerdict'], candidate=r['candidateVerdict'])
                       for r in paired['rows'] if not r['exactAgreement']],
        scope='Candidate golden outcomes and upstream paired agreement are separate; no full-language denominator.')
    raw_path = RAW / 'compiler03-raw31/execution/report.json'
    raw = passed(raw_path)
    require(len(raw['rows']) == 31 and all(r['pass'] for r in raw['rows']), 'Raw controls failed')
    for item in raw['inputs']:
        pin(item)
    js_path = RAW / 'compiler03-js-protection/report.json'
    js = read(js_path)
    require(js['complete'] and not js['changed'] and not js['additionalExcludedRoots'] and
            js['unchangedFunctions'] == 2992 and js['unchangedPublicExports'] == 100, 'JS protection failed')
    same(js['checkedAttempt'], attempt_path, 'Wrong JS protection attempt')
    for item in js['inputs']:
        pin(item)
    identity = read(args.identity)
    require(identity['complete'] and identity['exactCheckedEmissions'] == 24 and
            identity['preparations'] == 2 and len(identity['cases']) == 12, 'C transfer incomplete')
    same(identity['attempt'], attempt_path, 'Wrong C identity attempt')
    same(identity['imagePins'], images_path, 'Wrong C identity images')
    identity_plan = read(identity['plan'])
    require(identity_plan['cases'] == identity['cases'], 'C transfer case mapping differs from plan')
    require(len(identity['observations']) == 26 and
            {x['job']['name'] for x in identity['observations']} == {x['name'] for x in identity_plan['jobs']},
            'C identity job set differs from plan')
    for item in identity_plan['hostRuntimeEquality']:
        same(item['previous'], item['current'], 'Compiler support changed across C transfer')
    for case in identity['cases']:
        jobs = [x['job'] for x in identity['observations'] if x['job'].get('case') == case]
        require(len(jobs) == 2 and {x['role'] for x in jobs} == {'b1', 'b2'}, 'Missing B1/B2 transfer pair')
    for item in identity['observations']:
        emission = passed(item['report'])
        require(emission['job'] == item['job'] and emission['inputsUnchanged'], 'Wrong C identity job')
        same(emission['plan'], identity['plan'], 'Wrong C identity plan')
        guard = read(item['guard'])
        require(guard['complete'] and guard['returncode'] == 0, 'C identity guard failed')
        if item['job']['action'] == 'request':
            require(emission['exactC'] and emission['observation']['checked'], 'Unchecked C identity request')
            same(emission['output'], item['output'], 'Wrong transfer output')
            same(emission['oracle'], item['oracle'], 'Wrong transfer oracle')
            same(item['oracle'], identity['cases'][item['job']['case']]['expected'][item['job']['role']],
                 'Transfer oracle differs from case mapping')
            same(item['output'], item['oracle'], 'C transfer mismatch')
    runtime = dict(transfer=pin(args.identity),
        identicalHostRuntimeSupportFiles=len(identity_plan['hostRuntimeEquality']),
        stage='Runtime measured from compiler02 B1 C; compiler03 checked B1 and genuine B2 reproduce all 12 complete C files byte for byte.',
        originalSix=runtime_cohort(RAW / 'compiler02-native06-comparison/report.json', identity['cases']),
        expandedSix=runtime_cohort(RAW / 'compiler02-coverage-final-comparison01/report.json', identity['cases']))
    compile_result = compilation(args.compilation, attempt_path, images_path)
    qualification = RAW / 'compiler03-release-qualification'
    check_path, fixed_path = qualification / 'self-check/report.json', qualification / 'fixed-point/report.json'
    check, fixed = passed(check_path), passed(fixed_path)
    require(check['freshSelfCheck'] and check['freshTypeCheck'] and check['observation']['typeAccepted']
            and check['expectedProofTrustFailure'] and not check['mathematicalProof'], 'Unexpected source check')
    same(check['image'], images['b2'], 'Wrong own-source checker')
    same(check['source'], images['source'], 'Wrong own-source subject')
    require(fixed['byteEquality'] and fixed['verification']['inputsUnchanged'], 'Fixed point failed')
    same(fixed['b2'], images['b2'], 'Wrong fixed point B2')
    same(fixed['b3'], images['b2'], 'B3 differs from B2')
    same(fixed['image']['source'], images['source'], 'Wrong fixed point source')
    release_path, installed_path = ROOT / 'selfhost/dist/release.json', ROOT / 'selfhost/dist/typed-api.mjs'
    release = read(release_path)
    require(release['sourceSha256'] == SOURCE and not release['newBootstrap'], 'Wrong installed source')
    same(installed_path, attempt['api'], 'Wrong installed API')
    release_root = RAW / 'release-compiler03'
    controls = []
    for name, suffix, count, key in [('legacy42', 'legacy42/checks/report.json', 42, 'steps'),
                                   ('default24', 'default24/report.json', 24, 'steps'),
                                   ('helper5', 'helper5/report.json', 5, 'checks')]:
        path = release_root / suffix
        gate = passed(path)
        require(len(gate[key]) == count and all(x['pass'] for x in gate[key]), 'Release control count/failure')
        same(gate['release'], release_path, 'Release control bound to different installation')
        controls.append(dict(name=name, report=pin(path), observations=count, passed=True))
    guards = []
    for name in ['install', 'verify-before', 'legacy42', 'default24', 'helper5', 'verify-after']:
        path = release_root / ('job-' + name) / 'process.json'
        guard = read(path)
        require(guard['complete'] and guard['returncode'] == 0, 'Release job failed: ' + name)
        guards.append(dict(name=name, receipt=pin(path), wallSeconds=guard['wallSeconds']))
    result = dict(kind='phase70-selected-evidence-summary', version=1, complete=True,
        recorded=datetime.datetime.now(datetime.timezone.utc).isoformat(), targetsExecuted=False,
        producer=pin(__file__), sourceCommit=commit,
        candidate=dict(name='compiler03', attempt=pin(attempt_path), api=pin(attempt['api']),
                       source=pin(images['source']), genuineB2=pin(images['b2']), imagePins=pin(images_path),
                       b2Generation=pin(images['emission']), b2DriverQualification=pin(images['comparison']),
                       checkedValidation=pin(validation_path)),
        nativeControls=native_summary, rawControls=dict(report=pin(raw_path), passCount=31),
        jsProtection=dict(report=pin(js_path), unchangedFunctions=2992, unchangedPublicExports=100,
                          scope='Structural protection, not a new JS timing campaign.'),
        nativeProgramRuntime=runtime, nativeCompilation=compile_result,
        selfHostingQualification=dict(ownSourceCheck=pin(check_path), freshTypeAcceptance=True,
            proofTrust=check['observation']['proofTrust'], mathematicalProof=False,
            fixedPoint=pin(fixed_path), b3=pin(fixed['b3']), byteEquality=True),
        release=dict(manifest=pin(release_path), api=pin(installed_path), controls=controls, guardedJobs=guards),
        limitations=['Selected controls are not full-language conformance.',
                     'Runtime and compiler throughput have separate denominators and clocks.',
                     'Six new families are separate from the historical six; neither establishes universal parity.',
                     'Retained evidence pins do not imply a hermetic build environment.'])
    # Recheck every verified input before the only output write.
    previous = list(VERIFIED.items())
    VERIFIED.clear()
    for p, (_, row) in previous:
        pin(row)
    result['verifiedInputFiles'] = len(VERIFIED)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    with args.out.open('x') as stream:
        json.dump(portable(result), stream, indent=2)
        stream.write('\n')
    print(json.dumps(dict(output=pin(args.out), complete=True, targetsExecuted=False)))


if __name__ == '__main__':
    main()
