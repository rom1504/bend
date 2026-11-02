#!/usr/bin/env python3
"""Derive all twenty outcomes without selecting away losses or refusals."""
import hashlib
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'implementation/phase155'
BUILD=ROOT/'selfhost/build/phase155'


def pin(p):
    b=p.read_bytes()
    return dict(file=str(p.relative_to(ROOT)),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())


def main():
    OUT.mkdir(exist_ok=True)
    spec=json.loads((BUILD/'prepare07/manifest.json').read_text())
    first=json.loads((BUILD/'screen01/report.json').read_text())
    second=json.loads((BUILD/'screen02/report.json').read_text())
    measured={r['id']:dict(r,receipt='screen01/report.json') for r in first['rows']}
    for r in second['rows']:
        assert measured[r['id']]['status']=='screen-refused'
        measured[r['id']]=dict(r,receipt='screen02/report.json',firstScreen='insufficient duration at count cap')
    items=[]
    for s in sorted(spec['cases']+spec['rejected'],key=lambda x:x['id']):
        row=dict(id=s['id'],title=s['title'],family=s['family'],specification=s)
        if s['id'] in measured:
            r=measured[s['id']]
            row.update(status=r['status'],ratio=r.get('ratio'),n=r.get('n'),receipt=r['receipt'])
            if r.get('ratio'):
                row.update(speedup=1/r['ratio'],timeReductionPercent=100*(1-r['ratio']),
                           medianSeconds=r['medianSeconds'],pairRatios=[p['ratio'] for p in r['pairs']])
        else: row['status']='rejected-static'
        row['promotion']='not production-qualified'
        items.append(row)
    assert len(items)==20 and len({i['id'] for i in items})==20
    counts={status:sum(r['status']==status for r in items) for status in sorted({r['status'] for r in items})}
    result=dict(kind='phase155-twenty-idea-screen',complete=True,baselineCommit='c9de3ee',counts=counts,
                inputs=[pin(BUILD/x) for x in ('prepare07/manifest.json','controls01/report.json','screen01/report.json','screen02/report.json')],
                rows=items,warning='Local paired screens. Percentages overlap and must not be summed or projected onto cold builds. '
                                  'ID16 is an ungated tuple-analysis ceiling; storage has no persistent snapshots. '
                                  'Independent exact controls complement, but do not turn timing checksums into proofs.')
    (OUT/'metrics.json').write_text(json.dumps(result,indent=2)+'\n')
    for row in items:
        s=row['specification'];lines=[f'# P155-{row["id"].zfill(3)} — {row["title"]}', '',
            f'Status: **{row["status"]}**. [Overall report](../../implementation/phase155/README.md).', '',
            f'Family: [{row["family"]}]({row["family"]}/README.md).', '']
        if row.get('ratio'):
            lines += [f'Native new/old ratio: **{row["ratio"]:.6f}×**; {row["timeReductionPercent"]:.2f}% less time.',
                      f'Common count: {row["n"]}; receipt `selfhost/build/phase155/{row["receipt"]}`.',
                      'Three alternating paired rounds in the same native image; whole child time retained.', '']
        for field in ('whatWorkDisappears','scope','reason','limitations','promotionGate'):
            if field in s: lines += [f'**{field}:** {s[field]}', '']
        lines += ['This screen is not production qualification or a whole-compiler speed claim. See the',
                  'frozen specification and independent audit before choosing a transfer experiment.', '']
        (ROOT/'experiments/phase155'/f'P155-{row["id"].zfill(3)}.md').write_text('\n'.join(lines))
    jobs=[]
    for p in sorted(BUILD.rglob('process.json')):
        j=json.loads(p.read_text())
        if j.get('kind')!='build-retention-disk-guard-v1':continue
        jobs.append(dict(receipt=pin(p),returncode=j['returncode'],wallSeconds=j['wallSeconds'],peakTreeRssBytes=j['peakTreeRssBytes']))
    cost=dict(kind='phase155-costs',jobs=jobs,guardedJobs=len(jobs),guardedWallSeconds=sum(r['wallSeconds'] for r in jobs),
              fullCompilerBuilds=0,scope='Guarded jobs only, including failures. Excludes agent/review/documentation/retention effort; no quota telemetry.')
    (OUT/'cost.json').write_text(json.dumps(cost,indent=2)+'\n')
    print(json.dumps(dict(counts=counts,guardedSeconds=cost['guardedWallSeconds'])))


if __name__=='__main__':main()
