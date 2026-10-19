#!/usr/bin/env python3
"""Authenticate the unchanged Phase93 45-point corpus; no target execution."""
from datetime import datetime, timezone
import hashlib
import json
import math
from pathlib import Path
import statistics

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]


def pin(path):
    path = (ROOT / path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def verify(item):
    actual = pin(item['file'])
    assert all(actual[k] == item[k] for k in ['bytes', 'sha256']), item['file']
    return actual


def main():
    assert not (HERE / 'manifest01.json').exists(), 'Fresh freeze required'
    files = [ROOT / ('selfhost/build/phase93/' + x + '/report.json') for x in
             ['pilot02', 'broad01', 'measure-pilot01', 'measure-broad01']]
    pilot, broad, pilot_time, broad_time = [json.loads(p.read_text()) for p in files]
    assert all(x['complete'] for x in [pilot, broad, pilot_time, broad_time])
    six_file = HERE.parent / 'benchmark/manifest01.json'
    six = json.loads(six_file.read_text())
    old_six = [x['name'] for x in six['cases']]
    fixtures_file = ROOT / 'selfhost/build/phase93/fixtures01/manifest.json'
    fixtures = json.loads(fixtures_file.read_text())
    assert fixtures['complete'] and len(fixtures['cases']) == 45
    acquisition = {x['name']: (x, a) for a in [pilot, broad] for x in a['cases']}
    counts = {k: v for t in [pilot_time, broad_time] for k, v in t['plan'].items()}
    records = [x for t in [pilot_time, broad_time] for x in t['records']]
    oracle_file = ROOT / 'selfhost/tools/performance/phase111/coverage/full45/manifest.json'
    oracles = {x['name']: x for x in json.loads(oracle_file.read_text())['fixtures']}
    exclusion_file = ROOT / 'selfhost/build/phase93/calibration-continuation01/unmeasured.json'
    exclusions = json.loads(exclusion_file.read_text())
    assert exclusions['complete'] and [x['id'] for x in exclusions['cases']] == ['scalar-region-0']
    base, carrier = verify(six['base']), verify(six['carrier'])
    inputs = [pin(__file__), *map(pin, files), pin(six_file), pin(fixtures_file), pin(oracle_file),
              pin(exclusion_file), base, carrier,
              *[verify(x) for x in six['inputs'] if x['file'].endswith('/implementation/phase111/selection.json')],
              verify(six['phase111Compiler']), verify(six['phase111Runtime']),
              *[verify(x) for x in six['directToolchain'].values()]]
    rows, profile_counts, derivation = [], {}, {}
    for fixture in fixtures['cases']:
        name = fixture['name']
        row, acquired = acquisition[name]
        assert row['passed'] and row['source'] == fixture['source']
        assert base in [verify(x) for x in acquired['upstreamInputs'] if x['file'] == base['file']]
        source = verify(row['source'])
        assert verify(row['source88']) == verify(oracles[name]['source'])
        oracle = verify(oracles[name]['stdoutFile'])
        expected = row['expectedStdout']
        assert expected == oracles[name]['expect']['stdout'] == Path(oracle['file']).read_text()
        upstream = row['products']['upstream']
        binary, c = verify(upstream['binary']), verify(upstream['c'])
        clang = verify(acquired['authentication']['clang'])
        command = upstream['build']['command']
        assert command[-7:] == ['-std=c11', '-O3', c['file'], '-o', binary['file'], '-lpthread', '-lm']
        assert clang['file'] in command
        excluded = name == 'scalar-region-0'
        historical = {role: [x['elapsedMs'] for x in records if x['case'] == name and x['role'] == role]
                      for role in ['upstream', 'own']}
        if excluded:
            old = dict(repetitions=1, warmups=4)
            new_reps, predicted = 1, None
            derivation[name] = dict(ratioEligible=False, reason='Historical undefined-ratio zero-work control; one measured repetition, four warmups, full output checked each round.')
        else:
            old = counts[name]
            assert len(historical['upstream']) == 3 and all(x['qualified'] and x['correct'] for x in records if x['case'] == name)
            median = statistics.median(historical['upstream'])
            new_reps = max(1, math.ceil(old['repetitions'] * 50 / median))
            predicted = median * new_reps / old['repetitions']
            derivation[name] = dict(ratioEligible=True, originalRepetitions=old['repetitions'],
                upstreamSamplesMs=historical['upstream'], upstreamMedianMs=median,
                targetMs=50, estimatedUpstreamMs=predicted)
        profile_counts[name] = dict(repetitions=new_reps, warmups=4)
        rows.append(dict(name=name, family=row['family'], source=source, source88=verify(row['source88']),
            original=verify(row['original']), expectedStdout=expected, expectedStdoutEvidence=oracle,
            runtimeArgs=row['runtimeArgs'], repetitions=old['repetitions'], warmups=old['warmups'],
            ratioEligible=not excluded, phase112Heldout=name not in old_six,
            upstream=dict(binary=binary, source=source, generatedC=c, buildCommand=command, clang=clang),
            historicalSamplesMs=historical,
            oracleProvenance='Exact Phase93 complete expected output, authenticated against preserved independent Phase92/105 evidence in Phase111 full45; reused historical regression oracle.'))
        inputs += [source, c, binary, oracle, clang]
    unique_inputs = {x['file']: x for x in inputs}
    for x in unique_inputs.values():
        verify(x)
    names = [x['name'] for x in rows]
    heldout = [x for x in names if x not in old_six]
    assert len(names) == 45 and len(heldout) == 39
    manifest = dict(kind='phase112-frozen-matched-program-broad', version=1, preparedOnly=True, targetsRun=False,
        frozenUtc=datetime.now(timezone.utc).isoformat(), cases=rows, inputs=list(unique_inputs.values()),
        base=base, carrier=carrier, phase111Compiler=six['phase111Compiler'], phase111Runtime=six['phase111Runtime'],
        directToolchain=six['directToolchain'], rounds=3, minimumMs=100, sampleDeadlineSeconds=30,
        zeroWorkExclusions=[dict(name='scalar-region-0', ratio=None, reason=exclusions['cases'][0]['reason'], evidence=pin(exclusion_file))],
        partitions=dict(all45=names, previouslyScreened6=old_six, heldout39=heldout,
                        measurable44=[x for x in names if x != 'scalar-region-0'],
                        heldoutMeasurable38=[x for x in heldout if x != 'scalar-region-0']),
        clock=six['clock'], ordering=six['ordering'],
        aggregate='Equal fixed-input-point weighting over all 44 measurable points, or explicit 38-point Phase112 heldout. Zero-work control gets complete-output checks and no ratio. Not 44 independent source programs.',
        workload='Exact 45 existing Phase93 batch wrappers, workload arguments and oracles. Original counts retained; new separately frozen upstream-only count profile required for short screen.',
        heldoutScope='39 corpus points not selected by initial Phase112 six-case runtime screen; previously seen by earlier projects and conformance gates, not unseen programs or independent research holdout.',
        limits='Native or checked-API producer must be recorded; compiler request/build time excluded. Upstream pinned Clang -O3 versus direct pinned QBE/tool/link flags. No Phase111 Unicode denominator fabricated.')
    (HERE / 'manifest01.json').write_text(json.dumps(manifest, indent=2)+'\n')
    profile = dict(kind='phase112-frozen-runtime-profile', version=1, name='upstream-50ms-profile01',
        frozenUtc=manifest['frozenUtc'], targetsRun=False, manifest=pin(HERE / 'manifest01.json'),
        minimumMs=20, roundsMinimum=3, cases=profile_counts, derivation=derivation,
        rule='For each measurable point, max(1,ceil(original repetitions * 50 / median of three prior Phase93 upstream milliseconds)); four warmups. No Phase112 candidate or baseline timing enters the count choice.',
        scope='New broad short-batch profile, separate from original Phase93 and Phase112 initial six profiles. Exact same source/args/counts across current roles. 1ms resolution limits small percentage claims. Named scalar-region-0 is correctness-only and never contributes a runtime ratio.',
        estimatedUpstreamSecondsPerRound=sum(x.get('estimatedUpstreamMs', 0) for x in derivation.values())/1000)
    (HERE / 'upstream-50ms-profile01.json').write_text(json.dumps(profile, indent=2)+'\n')
    for key in ['all45', 'heldout39', 'measurable44', 'heldoutMeasurable38']:
        (HERE / (key+'.txt')).write_text('\n'.join(manifest['partitions'][key])+'\n')
    print(json.dumps(dict(targetsRun=False, corpus=45, measurable=44, heldout=39, manifest=pin(HERE/'manifest01.json'), profile=pin(HERE/'upstream-50ms-profile01.json'))))


if __name__ == '__main__':
    main()
