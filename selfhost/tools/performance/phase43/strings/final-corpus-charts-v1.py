#!/usr/bin/env python3
"""Final Phase43 corpus charts; read validated paired full45 data, never run targets."""
import argparse
import hashlib
import json
import math
import html
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
    assert closure['kind'] == 'phase43-full45-serial-runtime-closure'
    assert closure['complete'] is True and closure['pass'] is True
    assert closure['performanceAdmitted'] is False, 'Closure is measurement evidence, not semantic admission'
    assert closure['selectedCases'] == 45 and closure['samples'] == 669
    plan, plan_id = recorded(closure['plan'])
    catalog, catalog_id = load(args.catalog, plan['catalog']['sha256'])
    baseline, baseline_id = load(args.baseline_manifest, plan['baseline']['sha256'])
    candidate, candidate_id = load(args.candidate_manifest, plan['candidate']['sha256'])
    assert baseline['complete'] is True and candidate['complete'] is True
    assert candidate['roles']['candidate']['compiler']['api']['sha256'] == closure['api']['sha256']
    assert plan['kind'] == 'phase43-full45-serial-runtime-batches' and plan['complete'] and plan['bound']
    assert plan['api'] == closure['api'] and plan['attempt'] == closure['attempt']
    assert plan['selectedIds'] == catalog['sets']['full']
    assert baseline['roles']['baseline']['compiler']['api']['sha256'] == '63ddb2dd35554aafafc26dbdff4aba86b5d3774cd0d99a9509ccf237d210ba54'
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
        assert report['kind'] == 'bend-program-execution-report'
        assert report['plan']['protocol'] == plan['protocol'] and report['plan']['roles'] == plan['roles']
        assert report['plan']['variants']['candidate']['compiler'] == candidate['roles']['candidate']['compiler']
        assert report['plan']['variants']['baseline']['compiler'] == baseline['roles']['baseline']['compiler']
        assert report['plan']['variants']['typescript']['compiler'] == baseline['roles']['typescript']['compiler']
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
            assert sample['process']['returncode'] == 0 and not sample['process'].get('stoppedFor') and sample['result']['complete'] is True and sample['result']['pass'] is True
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
            drift_values = stats[role]['halfDriftPercent']
            assert all(x is None or (isinstance(x, (int, float)) and math.isfinite(x)) for x in drift_values)
            known_drift = [x for x in drift_values if x is not None]
            role_values[role] = dict(medianMs=stats[role]['medianMs'], minimumMs=min(values), maximumMs=max(values),
                samplesMs=values, halfDriftPercent=drift_values,
                halfDriftKnownCount=len(known_drift), halfDriftMissingCount=len(drift_values)-len(known_drift),
                maximumAbsoluteHalfDriftPercent=max((abs(x) for x in known_drift), default=None))
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
        halfDrift='Raw signed halfDriftPercent preserves unavailable measurements as null. Maximum uses only available finite values; all-missing maximum is null/NA. Known/missing counts do not infer stability from unavailable halves.',
        moduleBytes='Per-point module bytes include runtime/Base support. Unique-content inventory counts each SHA once; changed sources means any selected point from that source changed.',
        winnerCounts='Strict median comparisons; <=1.1 is a descriptive threshold, not statistically demonstrated parity.')
    inputs = [closure_id, plan_id, catalog_id, baseline_id, candidate_id] + batch_ids
    families = {}
    for row in rows:
        families.setdefault(row['family'], []).append(row)
    def counts(items):
        return dict(wins=sum(r['stats']['candidate']['medianMs'] < r['stats']['baseline']['medianMs'] for r in items),
                    regressions=sum(r['stats']['candidate']['medianMs'] > r['stats']['baseline']['medianMs'] for r in items),
                    unchanged=sum(r['stats']['candidate']['medianMs'] == r['stats']['baseline']['medianMs'] for r in items),
                    candidateFasterThanTypeScript=sum(r['ratios']['candidate/typescript'] < 1 for r in items),
                    candidateWithin10PercentOfTypeScript=sum(r['ratios']['candidate/typescript'] <= 1.1 for r in items))
    overall_counts = counts(rows)
    family_rows = [dict(family=name, points=len(items), counts=counts(items),
                       ratios={label:values['families'][name] for label,values in aggregate.items()})
                   for name, items in sorted(families.items())]
    result = dict(kind='phase43-final-corpus-charts', complete=True, performanceAdmitted=False,
        producer=dict(file=str(Path(__file__).resolve()),sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest()),
        inputs=inputs, selectedCases=45, sourceCoverage=23, familyCoverage=len(families), samples=669,
        protocol=plan['protocol'], definitions=definitions, winnerCounts=overall_counts,
        geometricMeans=aggregate, families=family_rows,
        moduleChanges=dict(changedPoints=len(changed),unchangedPoints=45-len(changed),changedIds=changed,
            changedSources=len({specs[k]['source']['path'] for k in changed}),inventory=inventory), cases=rows)
    corpus_plot = []
    for r in sorted(rows, key=lambda r:(r['family'],r['id'])):
        corpus_plot.append(dict(label=r['id'], group=r['family'],
            before=r['ratios']['baseline/typescript'], after=r['ratios']['candidate/typescript'],
            gain=r['ratios']['baseline/candidate'],
            beforeRange=r['pairedRoundRatios']['baseline/typescript'],
            afterRange=r['pairedRoundRatios']['candidate/typescript']))
    family_plot = []
    for weight,label in [('pointWeighted','Corpus: equal points'),('equalFamilyWeighted','Corpus: equal families'),('equalSourceWeighted','Corpus: equal sources')]:
        family_plot.append(dict(label=label,group='Descriptive corpus geometric means',
            before=aggregate['baseline/typescript'][weight],after=aggregate['candidate/typescript'][weight],
            gain=aggregate['baseline/candidate'][weight]))
    for r in family_rows:
        family_plot.append(dict(label=f"{r['family']} ({r['points']} points)", group='Within-family equal-point geometric means',
            before=r['ratios']['baseline/typescript'],after=r['ratios']['candidate/typescript'],gain=r['ratios']['baseline/candidate']))
    charts = {
        'corpus.svg':ratio_chart(corpus_plot,'Every measured point relative to TypeScript',
            f"45 points, 669 fresh samples. Medians: {overall_counts['wins']} faster, {overall_counts['regressions']} slower, {overall_counts['unchanged']} unchanged vs baseline.",closure_id['sha256'],True),
        'families.svg':ratio_chart(family_plot,'Corpus and family runtime ratios',
            'Geometric means of fixed-input median ratios. The three corpus weighting rules are separate.',closure_id['sha256'],False),
        'family-wins.svg':count_chart(family_rows,overall_counts,closure_id['sha256'])}
    lines = ['# Phase43 final corpus runtime evidence', '',
        '45 catalog points, 23 exact sources, 669 fresh role samples from the complete final serial batches. No exploratory screen is combined with these results.', '',
        'Ratios describe these inputs and protocol; they do not establish general TypeScript parity, statistical significance, semantic admission or installation.', '',
        f"Candidate medians: {overall_counts['wins']}/45 faster, {overall_counts['regressions']}/45 slower, {overall_counts['unchanged']}/45 unchanged against baseline.", '',
        '![Every measured point relative to TypeScript](corpus.svg)', '',
        '![Corpus and family runtime ratios](families.svg)', '',
        '![Family median wins and regressions](family-wins.svg)', '',
        '| Ratio | Equal points | Equal families | Equal sources |', '| --- | ---: | ---: | ---: |']
    for label,values in aggregate.items():
        lines.append(f"| {label} | {values['pointWeighted']:.6g}× | {values['equalFamilyWeighted']:.6g}× | {values['equalSourceWeighted']:.6g}× |")
    lines += ['', '| Family | Points | Faster | Slower | Unchanged | Baseline/candidate geometric mean | Candidate/TS geometric mean |',
        '| --- | ---: | ---: | ---: | ---: | ---: | ---: |']
    for r in family_rows:
        c=r['counts'];lines.append(f"| {r['family']} | {r['points']} | {c['wins']} | {c['regressions']} | {c['unchanged']} | {r['ratios']['baseline/candidate']:.6g}× | {r['ratios']['candidate/typescript']:.6g}× |")
    lines += ['', '| Point | Baseline ms | Candidate ms | TS ms | Baseline/candidate [paired min,max] | Candidate/TS [paired min,max] | Maximum available absolute half drift B/C/TS % | Missing halves B/C/TS |',
        '| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |']
    for row in sorted(rows,key=lambda r:(r['family'],r['id'])):
        cells=[f"{row['stats'][role]['medianMs']:.6g}" for role in ROLES]
        drift='/'.join('NA' if row['stats'][role]['maximumAbsoluteHalfDriftPercent'] is None else f"{row['stats'][role]['maximumAbsoluteHalfDriftPercent']:.3g}" for role in ROLES)
        missing='/'.join(str(row['stats'][role]['halfDriftMissingCount']) for role in ROLES)
        gain=row['pairedRoundRatios']['baseline/candidate'];ratio=row['pairedRoundRatios']['candidate/typescript']
        lines.append('| '+row['id']+' | '+' | '.join(cells)+f" | {row['ratios']['baseline/candidate']:.6g} [{gain['minimum']:.6g},{gain['maximum']:.6g}] | {row['ratios']['candidate/typescript']:.6g} [{ratio['minimum']:.6g},{ratio['maximum']:.6g}] | {drift} | {missing} |")
    lines += ['', *[f'- {name}: {text}' for name,text in definitions.items()], '',
        'SVG files are standalone: fixed white background, local system fonts, no scripts, external assets or linked styles. Keep these three images beside this Markdown file for GitHub rendering.', '',
        'Exact input/module identities, role medians, signed/missing drift and all paired-round ratio values remain in report.json. Earlier failed measurements are retained outside this complete closure and are not averaged here.', '']
    for item in inputs:
        assert hashlib.sha256(Path(item['file']).read_bytes()).hexdigest()==item['sha256'],'Input changed during rendering'
    args.out.mkdir(parents=True)
    for name,text in charts.items():
        (args.out/name).write_text(text)
    result['outputs']=[dict(file=name,sha256=hashlib.sha256((args.out/name).read_bytes()).hexdigest()) for name in charts]
    (args.out/'report.json').write_text(json.dumps(result,indent=2)+'\n')
    (args.out/'report.md').write_text('\n'.join(lines))
    print(json.dumps(dict(complete=True,points=45,sources=23,samples=669,winnerCounts=overall_counts,out=str(args.out))))


def escape(value):
    return html.escape(str(value),quote=True)


def svg_head(width,height):
    return [f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}" role="img">',
        '<rect width="100%" height="100%" fill="white"/>',
        '<style>text{font-family:Arial,sans-serif;fill:#172033}.small{font-size:12px}.label{font-size:13px}.family{font-size:14px;font-weight:bold}</style>']


def ratio_chart(rows,title,subtitle,source_hash,paired_ranges):
    positioned=[];groups=[];y=139;last=None
    for row in rows:
        if row['group']!=last:
            groups.append((y,row['group']));y+=25;last=row['group']
        positioned.append((y,row));y+=30
    values=[r[k] for r in rows for k in ['before','after']]
    if paired_ranges:
        values += [r[k][bound] for r in rows for k in ['beforeRange','afterRange'] for bound in ['minimum','maximum']]
    lower=2**math.floor(math.log2(min(min(values),.5)));upper=2**math.ceil(math.log2(max(max(values),2)))
    left,right,width,height=400,935,1240,y+99
    def xpos(v):return left+math.log(v/lower)/math.log(upper/lower)*(right-left)
    parts=svg_head(width,height)+[f'<title>{escape(title)}</title>',
        f'<text x="20" y="29" font-size="21" font-weight="bold">{escape(title)}</text>',
        f'<text x="20" y="53" class="label">{escape(subtitle)}</text>',
        '<circle cx="28" cy="77" r="5" fill="#2563eb"/><text x="40" y="82" class="label">Phase42 baseline</text>',
        '<circle cx="227" cy="77" r="5" fill="#ea580c"/><text x="239" y="82" class="label">Phase43 candidate</text>',
        '<text x="415" y="82" class="label">Lower is faster; log scale. TypeScript = 1×.</text>',
        '<text x="961" y="115" class="small">Baseline → candidate | gain</text>']
    start,end=math.floor(math.log2(lower)),math.ceil(math.log2(upper))
    spacing=max(1,math.ceil((end-start)/10))
    for power in range(start,end+1):
        if power % spacing:continue
        tick=2**power;xx=xpos(tick)
        parts += [f'<line x1="{xx:.2f}" y1="98" x2="{xx:.2f}" y2="{y}" stroke="{"#64748b" if tick==1 else "#e2e8f0"}" stroke-dasharray="{"4 3" if tick==1 else "0"}"/>',
            f'<text x="{xx:.2f}" y="116" text-anchor="middle" class="small">{tick:g}×</text>']
    for yy,label in groups:parts.append(f'<text x="20" y="{yy}" class="family">{escape(label)}</text>')
    for yy,row in positioned:
        parts += [f'<text x="28" y="{yy+4}" class="label">{escape(row["label"])}</text>',
            f'<line x1="{xpos(row["before"]):.2f}" y1="{yy}" x2="{xpos(row["after"]):.2f}" y2="{yy}" stroke="#94a3b8" stroke-width="2"/>']
        for key,color,offset in [('before','#2563eb',-3),('after','#ea580c',3)]:
            center=xpos(row[key]);at=yy+offset
            if paired_ranges:
                extent=row[key+'Range'];parts.append(f'<line x1="{xpos(extent["minimum"]):.2f}" y1="{at}" x2="{xpos(extent["maximum"]):.2f}" y2="{at}" stroke="{color}" stroke-width="1.5" opacity="0.65"/>')
            parts.append(f'<circle cx="{center:.2f}" cy="{at}" r="4.5" fill="{color}"><title>{escape(row["label"])} {key}: {row[key]:.9g}×</title></circle>')
        parts.append(f'<text x="958" y="{yy+4}" class="label">{row["before"]:.3g}× → {row["after"]:.3g}× | {row["gain"]:.3g}×</text>')
    note='Dots: ratio of role medians. Whiskers: paired-round min/max ratios; descriptive ranges, not confidence intervals.' if paired_ranges else 'Each family dot gives its catalog points equal weight. Corpus weighting rules are labeled; no time sums across workloads.'
    parts += [f'<text x="20" y="{y+25}" class="small">{escape(note)}</text>',
        f'<text x="20" y="{y+46}" class="small">{len(rows)} rows. All values shown without clipping; exact medians, ratios and weighting definitions remain in report.json.</text>',
        f'<text x="20" y="{y+67}" class="small">Final closure SHA256: {source_hash}</text>','</svg>']
    return '\n'.join(parts)+'\n'


def count_chart(families,counts,source_hash):
    width,height,left,span=1180,165+33*(len(families)+1),310,600
    rows=[dict(family='All 45 points',points=45,counts=counts)]+families
    maximum=max(r['points'] for r in rows);parts=svg_head(width,height)+[
        '<title>Family median wins and regressions against Phase42 baseline</title>',
        '<text x="20" y="29" font-size="21" font-weight="bold">Median wins and regressions against baseline</text>',
        '<text x="20" y="53" class="label">Strict measured median comparisons. These counts do not establish statistical significance.</text>']
    colors={'wins':'#15803d','regressions':'#dc2626','unchanged':'#64748b'}
    for n,(key,color) in enumerate(colors.items()):
        x=20+220*n;parts += [f'<rect x="{x}" y="73" width="13" height="13" fill="{color}"/>',f'<text x="{x+22}" y="84" class="label">{key.capitalize()}</text>']
    for index,row in enumerate(rows):
        y=117+33*index;x=left
        parts.append(f'<text x="20" y="{y+5}" class="label">{escape(row["family"])}</text>')
        for key,color in colors.items():
            n=row['counts'][key];w=n/maximum*span
            if n:parts.append(f'<rect x="{x:.2f}" y="{y-9}" width="{w:.2f}" height="18" fill="{color}"><title>{escape(row["family"])} {key}: {n}</title></rect>')
            x+=w
        c=row['counts'];parts.append(f'<text x="935" y="{y+5}" class="label">{c["wins"]} / {c["regressions"]} / {c["unchanged"]} ({row["points"]} points)</text>')
    parts += [f'<text x="20" y="{height-39}" class="small">Bar width counts fixed catalog points; family size differs. Exact comparisons and paired-round ranges remain in report.json.</text>',
        f'<text x="20" y="{height-18}" class="small">Final closure SHA256: {source_hash}</text>','</svg>']
    return '\n'.join(parts)+'\n'


if __name__ == '__main__':
    main()
