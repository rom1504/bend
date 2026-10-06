#!/usr/bin/env python3
"""Present a verified Phase58 saved-data summary; never import a target compiler."""
import argparse, hashlib, json, math, statistics
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
READER_SHA = '200f9daae7217af9e1450b7ca01aacd006859c943f42d1d56a83868ec9d6d73d'
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('summary', type=Path)
p.add_argument('out', type=Path, help='Fresh directory below Phase58 build or implementation')
a = p.parse_args()
out = a.out.resolve()
assert not out.exists() and any(out.is_relative_to(ROOT / x) for x in
    ['selfhost/build/phase58', 'implementation/phase58'])
inputs = {}

def pin(value):
    file = Path(value['file'] if isinstance(value, dict) else value).resolve(strict=True)
    h = hashlib.sha256()
    with file.open('rb') as f:
        for block in iter(lambda: f.read(2**20), b''):
            h.update(block)
    row = dict(file=str(file), sha256=h.hexdigest(), bytes=file.stat().st_size)
    if isinstance(value, dict):
        assert row['sha256'] == value['sha256']
        assert 'bytes' not in value or row['bytes'] == value['bytes']
    inputs[str(file)] = row
    return row

def read(value):
    row = pin(value)
    assert row['bytes'] <= 64 * 2**20
    return row, json.loads(Path(row['file']).read_text())

def cell(value):
    return str(value).replace('|', '\\|').replace('\n', ' ')

def stat(values):
    assert values and all(math.isfinite(x) and x >= 0 for x in values)
    return dict(median=statistics.median(values), min=min(values), max=max(values), samples=values)

producer = pin(__file__)
summary_id, summary = read(a.summary)
assert summary['kind'] == 'phase58-latency-emission-analysis'
assert summary['complete'] and summary['pass'] and summary['dataOnly'] and not summary['targetExecuted']
assert pin(summary['producer'])['sha256'] == READER_SHA
lines = ['# Compiler profile comparison', '',
    'Presentation of the independently validated saved-data summary. No target was imported or executed.', '',
    'Allocation is sampled cumulative bytes, including objects collected by minor and major GC. '
    'Decimal MB means 1,000,000 bytes. It is neither retained heap nor peak RSS. '
    'Profiles include request correctness checks and are separate from clean latency. '
    'Observed differences are descriptive, with no significance or isolated-pass attribution claim.', '',
    f"Validated summary: `{summary_id['file']}` (`{summary_id['sha256']}`).", '']
campaigns = []
for campaign in summary['campaigns']:
    if campaign['mode'] not in ['cpu', 'allocation']:
        continue
    _, config = read(campaign['config'])
    name = Path(campaign['report']['file']).parent.name
    images = {}
    for role, binding in campaign['roles'].items():
        if binding['image'] is not None:
            images[role] = [binding['image']['api']]
        else:
            expected = {str((Path(config['upstream'])/'bend2'/name).resolve()) for name in ['bend.ts', 'comp.ts']}
            images[role] = [x for x in config['inputs'] if str(Path(x['file']).resolve()) in expected]
            assert role == 'typescript' and len(images[role]) == 2
            assert {str(Path(x['file']).resolve()) for x in images[role]} == expected
    lines += [f"## {name}: {campaign['mode']}", '',
        'Role identities below are the files already bound by the validated summary; this presentation '
        'does not repeat its full provenance audit.', '', '| Role | Compiler source/image | SHA-256 |', '| --- | --- | --- |']
    for role, identities in images.items():
        for identity in identities:
            lines.append(f"| {role} | `{cell(identity['file'])}` | `{identity['sha256']}` |")
    profiles = campaign['profiles']
    assert profiles
    cases = {}
    for case in dict.fromkeys(x['case'] for x in profiles):
        rows = [x for x in profiles if x['case'] == case]
        lines += ['', f'### {case}', '']
        if campaign['mode'] == 'allocation':
            values = {role: stat([x['estimatedAllocationBytesPerRequest'] for x in rows if x['role'] == role])
                for role in campaign['roles']}
            ratios = {}
            if {'baseline', 'candidate'} <= values.keys():
                b, c = values['baseline']['median'], values['candidate']['median']
                assert b > 0 and c > 0
                ratios.update(baselineOverCandidate=b/c, candidateChangePercent=100*(c/b-1))
            if 'typescript' in values:
                t = values['typescript']['median']; assert t > 0
                ratios['overTypeScript'] = {r: x['median']/t for r, x in values.items() if r != 'typescript'}
            cases[case] = dict(bytesPerRequest=values, ratios=ratios)
            lines += ['| Role / process | Requests | Samples | Sampled cumulative MB | MB/request |', '| --- | ---: | ---: | ---: | ---: |']
            for x in rows:
                lines.append(f"| {x['role']} / {x['sample']} | {x['calls']} | {x['sampleCount']} | {x['totalWeight']/1e6:.3f} | {x['estimatedAllocationBytesPerRequest']/1e6:.3f} |")
            if 'baselineOverCandidate' in ratios:
                lines += ['', f"Baseline/candidate allocation per request: **{ratios['baselineOverCandidate']:.3f}×**; "
                    f"candidate change **{ratios['candidateChangePercent']:+.2f}%**."]
            if 'overTypeScript' in ratios:
                lines += ['', 'Allocation per request / TypeScript: ' + ', '.join(
                    f'**{role} {ratio:.3f}×**' for role, ratio in ratios['overTypeScript'].items()) + '.']
        for x in rows:
            lines += ['', f"#### {x['role']} / process {x['sample']}", '',
                f"{x['calls']} profiled requests; {x['sampleCount']} samples; unit `{x['unit']}`. "
                f"Summary view `{x['summaryView']}`; weighted status `{x['weightedStatus']}`.", '',
                '| Exclusive self frame | Source location | Self % | ' + ('MB/request' if x['mode'] == 'allocation' else 'Self weight') + ' |',
                '| --- | --- | ---: | ---: |']
            for frame in x['topSelf'][:10]:
                pct = 100*frame['selfWeight']/x['totalWeight'] if x['totalWeight'] else 0
                weight = frame['selfWeight']/x['calls']/1e6 if x['mode'] == 'allocation' else frame['selfWeight']
                location = (f"{frame['url']}:{frame['line']}:{frame['column']}" if frame['line'] is not None and frame['column'] is not None
                    else f"{frame['url']} (position unknown)") if frame['url'] else '(no source URL)'
                lines.append(f"| `{cell(frame['functionName'] or '(anonymous)')}` | `{cell(location)}` | {pct:.2f} | {weight:.3f} |")
            lines += ['', 'Top frames use exclusive self weights, not summed inclusive stacks. '
                'Names are reported verbatim; anonymous frames are not assigned a compiler role. '
                'TypeScript work can span multiple modules, so one generated-module category is not total compiler work.', '']
            for warning in x['warnings']:
                lines.append(f'- {cell(warning)}')
    campaigns.append(dict(report=campaign['report'], mode=campaign['mode'], images=images,
        allocation=cases, profiles=profiles))
assert campaigns, 'Summary contains no completed CPU/allocation campaigns'
for identity in list(inputs.values()):
    assert pin(identity) == identity
result = dict(kind='phase58-profile-presentation', complete=True, dataOnly=True, targetExecuted=False,
    producer=producer, summary=summary_id, campaigns=campaigns, inputs=list(inputs.values()),
    scope='Presentation only; original saved-data reader validates reports and raw profiles. '
    'No retained-memory, significance, stationary-rate or single-pass causal claim.', pass_=True)
result['pass'] = result.pop('pass_')
out.mkdir(parents=True)
(out/'report.json').write_text(json.dumps(result, indent=2)+'\n')
(out/'report.md').write_text('\n'.join(lines)+'\n')
print(json.dumps(dict(json=pin(out/'report.json'), markdown=pin(out/'report.md'))))
