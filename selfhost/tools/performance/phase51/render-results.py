#!/usr/bin/env python3
"""Render an already-validated Phase44 full-runtime summary; execute no targets."""
import argparse
import hashlib
import json
from pathlib import Path

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('summary', type=Path)
p.add_argument('out', type=Path, nargs='?', default=Path(__file__).resolve().parents[4] / 'implementation/phase51/results.md')
a = p.parse_args()
assert not a.out.exists(), 'Output must be fresh'
raw = a.summary.read_bytes()
d = json.loads(raw)
assert d['kind'] == 'bend-full-runtime-summary' and d['complete'] is True and d['pass'] is True
assert d['points'] == len(d['cases']) == 45 and d['samples'] == 669
sha = lambda b: hashlib.sha256(b).hexdigest()
producer = Path(__file__).read_bytes()
rows = sorted(d['cases'], key=lambda r: r['id'])
roles = ('typescript', 'baseline', 'candidate')
def drift(row, role):
    values = [v for v in row['rawSummary']['stats'][role]['halfDriftPercent'] if isinstance(v, (int, float))]
    return max(values, key=abs) if values else None
def show_drift(value):
    return f'{value:+.1f}%' if value is not None else 'n/a'
def line(row):
    s, q = row['rawSummary']['stats'], row['ratios']
    values = ' | '.join(f"{s[role]['medianMs']:.6g}" for role in roles)
    return f"| `{row['id']}` | {values} | {q['candidate/typescript']:.4f}× | {q['baseline/candidate']:.4f}× | {row['candidateChangePercent']:+.2f}% | {show_drift(drift(row, 'candidate'))} |"
text = ['# Phase51: complete generated-program timing results', '',
    f"The validated comparison covers **45 points, {d['sourceCount']} distinct sources, {d['familyCount']} families, and 669 samples**. All result checks passed. These timings do not independently establish compiler conformance or release qualification.", '',
    'Baseline is the comparison baseline recorded in the summary; candidate is the selected experimental compiler recorded there. Ratios above 1 in baseline/candidate mean faster candidate execution. Positive time changes mean regressions.', '',
    '| Weighting | Baseline / TypeScript | Candidate / TypeScript | Baseline / candidate |',
    '| --- | ---: | ---: | ---: |']
for key, label in [('pointWeighted', 'Equal points'), ('equalSourceWeighted', 'Equal sources'), ('equalFamilyWeighted', 'Equal families')]:
    if key in d['geometricMeans']['baseline/candidate']:
        v = [d['geometricMeans'][name][key] for name in ('baseline/typescript', 'candidate/typescript', 'baseline/candidate')]
        text.append(f'| {label} | {v[0]:.6f}× | {v[1]:.6f}× | {v[2]:.6f}× |')
c = d['medianChanges']
text += ['', f"Point medians: {c['wins']} faster, {c['regressions']} slower, {c['ties']} exactly tied. This sign count has no significance threshold. Geometric means give each listed unit equal weight, not each application or elapsed second.", '',
    '## Protocol and drift', '', f"Node: `{d['sampleEnvironment'][0]}`. Protocol: `{json.dumps(d['plan']['protocol'], sort_keys=True)}`. Raytrace uses the summarizer's explicit three-round/one-initial-warmup-call exception; other points use five rotated rounds.", '',
    'Warmup duration and repeated rounds do not prove stationarity. Half drift compares the second sample half with the first; negative values mean it got faster. A single-call sample has no half drift (n/a), not zero drift. Medians can include continued tiering, feedback evolution, GC and scheduling effects. Do not interpret a small ratio as a confirmed gain or attribute it to an optimization mechanism from this table alone.', '',
    '| Role | Largest absolute half drift | Point |', '| --- | ---: | --- |']
for role in roles:
    r = max((r for r in rows if drift(r, role) is not None), key=lambda x: abs(drift(x, role)))
    text.append(f"| {role} | {drift(r, role):+.3f}% | `{r['id']}` |")
text += ['', '## All points', '', 'Times are milliseconds per public call. The final column is the candidate sample with the largest absolute half drift, retaining its sign.', '',
    '| Point | TypeScript ms | Baseline ms | Candidate ms | Candidate / TS | Speed ratio | Time change | Candidate drift |',
    '| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |', *map(line, rows), '', '## Largest observed regressions', '']
worst = sorted((r for r in rows if r['candidateChangePercent'] > 0), key=lambda r: -r['candidateChangePercent'])[:5]
text += [f"- `{r['id']}`: {r['candidateChangePercent']:+.2f}% time; {r['ratios']['baseline/candidate']:.4f}× speed ratio; candidate maximum half drift {show_drift(drift(r, 'candidate'))}." for r in worst] or ['No point median regressed.']
text += ['', '## Evidence identity', '', f"Summary: `{a.summary.resolve()}`; SHA-256 `{sha(raw)}`.", '',
    f"Renderer: `selfhost/tools/performance/phase51/render-results.py`; SHA-256 `{sha(producer)}`. It formats the validated summary and does not rerun its underlying evidence checks or any target. The summary retains exact compiler, module, node, raw report and protocol identities.", '']
assert a.summary.read_bytes() == raw and Path(__file__).read_bytes() == producer, 'Input changed while rendering'
a.out.parent.mkdir(parents=True, exist_ok=True)
with a.out.open('x') as stream:
    stream.write('\n'.join(text))
print(json.dumps(dict(output=str(a.out.resolve()), summarySha256=sha(raw), producerSha256=sha(producer), points=len(rows))))
