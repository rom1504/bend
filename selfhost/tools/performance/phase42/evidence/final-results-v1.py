#!/usr/bin/env python3
"""Render exact closed full45 runtime evidence; never execute generated programs."""
import argparse
import hashlib
import json
import math
import statistics
from pathlib import Path

ROLES = ('baseline', 'candidate', 'typescript')
RATIOS = (('baseline', 'typescript'), ('candidate', 'typescript'), ('baseline', 'candidate'))

def load(path, expected=None):
    path = Path(path).resolve()
    raw = path.read_bytes()
    ident = dict(file=str(path), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())
    if expected is not None:
        assert ident['sha256'] == expected, 'Changed recorded input: ' + str(path)
    return json.loads(raw), ident

def recorded(row):
    return load(row.get('file', row.get('path')), row['sha256'])

def gm(values):
    assert values and all(math.isfinite(v) and v > 0 for v in values)
    return math.exp(statistics.mean(math.log(v) for v in values))

def close(a, b):
    assert math.isclose(a, b, rel_tol=1e-12, abs_tol=1e-15), (a, b)

def describe(values):
    return dict(median=statistics.median(values), minimum=min(values), maximum=max(values), samples=values)

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('closure', type=Path)
    parser.add_argument('--catalog', type=Path, required=True)
    parser.add_argument('--baseline-manifest', type=Path, required=True)
    parser.add_argument('--candidate-manifest', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    assert not args.out.exists(), 'Output must be new'
    closure, closure_id = load(args.closure)
    assert closure['kind'] == 'phase42-full45-serial-runtime-closure'
    assert closure['complete'] is True and closure['pass'] is True
    assert closure['selectedCases'] == 45 and closure['samples'] == 669
    plan, plan_id = recorded(closure['plan'])
    catalog, catalog_id = load(args.catalog, plan['catalog']['sha256'])
    baseline, baseline_id = load(args.baseline_manifest, plan['baseline']['sha256'])
    candidate, candidate_id = load(args.candidate_manifest, plan['candidate']['sha256'])
    assert baseline['complete'] is True and candidate['complete'] is True
    assert candidate['roles']['candidate']['compiler']['api']['sha256'] == closure['api']['sha256']
    selected = catalog['sets']['full']
    assert len(selected) == len(set(selected)) == 45
    specs = {r['id']: r for r in catalog['cases']}
    assert [r['id'] for r in closure['cases']] == selected
    sources = {specs[k]['source']['path'] for k in selected}
    assert len(sources) == 23
    batches = {}; batch_ids = []
    for receipt in closure['reports']:
        report, ident = recorded(receipt)
        assert report['complete'] is True and report['pass'] is True and report['status'] == 'measured'
        assert len(report['cases']) == 15
        batch_ids.append(ident)
        for row in report['cases']:
            assert row['id'] not in batches
            batches[row['id']] = row
    assert set(batches) == set(selected) and len(batch_ids) == 3
    rows = []; samples_count = 0
    for closed in closure['cases']:
        key = closed['id']; raw = batches[key]; spec = specs[key]
        assert raw['summary'] == closed['summary'] and raw['point'] == closed['point'] == spec['point']
        rounds = 3 if key == 'raytrace' else 5
        assert raw['rounds'] == rounds and raw['summary']['balancedRounds'] == list(range(rounds))
        assert raw['summary']['complete'] is True
        paired = {}
        for sample in raw['samples']:
            assert sample['complete'] is True and sample['process']['complete'] is True
            assert sample['process']['returncode'] == 0 and sample['result']['complete'] is True
            token = (sample['round'], sample['role']); assert token not in paired
            value = sample['result']['msPerCall']; assert math.isfinite(value) and value > 0
            paired[token] = value
        assert set(paired) == {(n, role) for n in range(rounds) for role in ROLES}
        samples_count += len(paired)
        stats = raw['summary']['stats']; role_values = {}
        for role in ROLES:
            values = [paired[n, role] for n in range(rounds)]
            close(stats[role]['medianMs'], statistics.median(values))
            close(stats[role]['minimumMs'], min(values)); close(stats[role]['maximumMs'], max(values))
            assert len(stats[role]['halfDriftPercent']) == rounds
            role_values[role] = dict(medianMs=stats[role]['medianMs'], minimumMs=min(values), maximumMs=max(values),
                samplesMs=values, halfDriftPercent=stats[role]['halfDriftPercent'],
                maximumAbsoluteHalfDriftPercent=max(abs(x) for x in stats[role]['halfDriftPercent']))
        ratios = {}; paired_ratios = {}
        for numerator, denominator in RATIOS:
            label = numerator + '/' + denominator
            ratios[label] = role_values[numerator]['medianMs'] / role_values[denominator]['medianMs']
            close(raw['summary']['ratios'][label], ratios[label])
            paired_ratios[label] = describe([paired[n, numerator] / paired[n, denominator] for n in range(rounds)])
        rows.append(dict(id=key, family=spec['family'], source=spec['source']['path'], point=spec['point'],
                         rounds=rounds, stats=role_values, ratios=ratios, pairedRoundRatios=paired_ratios))
    assert samples_count == 669
    aggregate = {}
    for numerator, denominator in RATIOS:
        label = numerator + '/' + denominator
        family_groups = {}; source_groups = {}
        for row in rows:
            family_groups.setdefault(row['family'], []).append(row['ratios'][label])
            source_groups.setdefault(row['source'], []).append(row['ratios'][label])
        aggregate[label] = dict(pointWeighted=gm([r['ratios'][label] for r in rows]),
            equalFamilyWeighted=gm([gm(v) for v in family_groups.values()]),
            equalSourceWeighted=gm([gm(v) for v in source_groups.values()]),
            families={k:gm(v) for k,v in family_groups.items()}, sources={k:gm(v) for k,v in source_groups.items()})
    manifests = {'baseline': {r['id']:r for r in baseline['cases']}, 'candidate': {r['id']:r for r in candidate['cases']}}
    changed = []; inventory = {}
    for role, manifest_rows in manifests.items():
        modules = {}
        for key in selected:
            entry = manifest_rows[key]
            assert entry['point'] == specs[key]['point'] and entry['sourceSha256'] == specs[key]['source']['sha256']
            module = entry['modules'][role]
            if module['sha256'] in modules:
                assert modules[module['sha256']]['bytes'] == module['bytes']
            modules[module['sha256']] = module
        inventory[role] = dict(uniqueModuleContents=len(modules), uniqueContentBytes=sum(r['bytes'] for r in modules.values()), modules=list(modules.values()))
    for row in rows:
        key = row['id']; old = manifests['baseline'][key]['modules']['baseline']; new = manifests['candidate'][key]['modules']['candidate']
        row['moduleBytes'] = dict(baseline=old['bytes'], candidate=new['bytes'], delta=new['bytes']-old['bytes'], changed=old['sha256']!=new['sha256'])
        if row['moduleBytes']['changed']: changed.append(key)
    winners = dict(candidateFasterThanBaseline=sum(r['ratios']['baseline/candidate']>1 for r in rows),
        candidateAtLeastTwiceAsFastAsBaseline=sum(r['ratios']['baseline/candidate']>=2 for r in rows),
        candidateFasterThanTypeScript=sum(r['ratios']['candidate/typescript']<1 for r in rows),
        candidateWithin10PercentOfTypeScript=sum(r['ratios']['candidate/typescript']<=1.1 for r in rows))
    definitions = dict(pointWeighted='Geometric mean of the45 per-point quotients of role medians; each catalog input point has equal weight.',
        equalFamilyWeighted='Within each family take the geometric mean of point quotients, then give each family equal weight.',
        equalSourceWeighted='Within each of23 exact catalog source paths take the geometric mean of point quotients, then give each source equal weight.',
        pairedRoundRatios='Same-number fresh role processes paired within each balanced round; median/min/max are descriptive ranges, not confidence intervals.',
        moduleBytes='Per-point module bytes include runtime/Base support. Unique-content inventory counts each SHA once; changed sources means any selected point from that source changed.',
        winnerCounts='Strict median comparisons; <=1.1 is a descriptive threshold, not statistically demonstrated parity.')
    inputs = [closure_id, plan_id, catalog_id, baseline_id, candidate_id] + batch_ids
    result = dict(kind='phase42-final-runtime-render', complete=True, performanceAdmitted=False,
        producer=dict(file=str(Path(__file__).resolve()),sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest()),
        inputs=inputs, selectedCases=45, sourceCoverage=23, familyCoverage=len({r['family'] for r in rows}), samples=669,
        definitions=definitions, winnerCounts=winners, geometricMeans=aggregate,
        moduleChanges=dict(changedPoints=len(changed),unchangedPoints=45-len(changed),changedIds=changed,
            changedSources=len({specs[k]['source']['path'] for k in changed}),inventory=inventory), cases=rows)
    lines = ['# Phase42 full45 runtime results', '', 'Exact complete serial batch closure; descriptive evidence, not installation or performance admission.', '',
             'Coverage:45 points,23 sources,669 fresh role samples.', '']
    lines += [f'- {name}: {value}/45.' for name,value in winners.items()]
    lines += ['', '| Point | Phase41 ms [min,max] | Candidate ms [min,max] | TS ms [min,max] | Phase41/candidate [paired min,max] | Candidate/TS [paired min,max] | Max absolute half drift B/C/TS % |',
              '| --- | ---: | ---: | ---: | ---: | ---: | ---: |']
    for row in rows:
        cells = [f"{row['stats'][role]['medianMs']:.6g} [{row['stats'][role]['minimumMs']:.6g},{row['stats'][role]['maximumMs']:.6g}]" for role in ROLES]
        drift = '/'.join(f"{row['stats'][role]['maximumAbsoluteHalfDriftPercent']:.3g}" for role in ROLES)
        gain = row['pairedRoundRatios']['baseline/candidate']; slowdown = row['pairedRoundRatios']['candidate/typescript']
        lines.append('| '+row['id']+' | '+' | '.join(cells)+f" | {row['ratios']['baseline/candidate']:.4g} [{gain['minimum']:.4g},{gain['maximum']:.4g}] | {row['ratios']['candidate/typescript']:.4g} [{slowdown['minimum']:.4g},{slowdown['maximum']:.4g}] | {drift} |")
    lines += ['', '| Ratio | Equal points | Equal families | Equal sources |','| --- | ---: | ---: | ---: |']
    for label, values in aggregate.items():
        lines.append(f"| {label} | {values['pointWeighted']:.6g} | {values['equalFamilyWeighted']:.6g} | {values['equalSourceWeighted']:.6g} |")
    lines += ['', *[f'- {name}: {text}' for name,text in definitions.items()], '',
        f"Changed modules:{len(changed)}/45 points across{result['moduleChanges']['changedSources']}/23 sources.",
        f"Unique-content generated bytes: Phase41{inventory['baseline']['uniqueContentBytes']}, candidate{inventory['candidate']['uniqueContentBytes']}.",
        '', 'Full paired-round ratio samples/ranges, signed drift, exact module identities and changed IDs remain in report.json.', '']
    for item in inputs:
        assert hashlib.sha256(Path(item['file']).read_bytes()).hexdigest() == item['sha256'], 'Input changed during rendering'
    args.out.mkdir(parents=True)
    (args.out/'report.json').write_text(json.dumps(result,indent=2)+'\n')
    (args.out/'report.md').write_text('\n'.join(lines))
    print(json.dumps(dict(complete=True,points=45,sources=23,samples=669,changedPoints=len(changed),out=str(args.out))))

if __name__ == '__main__':
    main()
