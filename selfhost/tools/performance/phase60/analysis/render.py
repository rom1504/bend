#!/usr/bin/env python3
"""Join completed diagnostic/clean summaries; render all-source tables and SVGs."""
import argparse
import collections
import hashlib
import html
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT/'selfhost/build/phase60'
FAMILIES = ['String-named frames', 'Emitted reference / use names', 'Index-named frames',
            'Substitution-named frames', 'Primitive table / lookup names', 'Term / definition constructors']
GROUPS = ['Import / API load', 'Cache / identity', 'Source loading', 'Check + completion',
          'Reach + code generation', 'Request residual']
COLORS = ['#999999', '#b18fbd', '#74a6b6', '#de996b', '#547d98', '#dddddd']


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--diagnostics', type=Path, required=True)
    p.add_argument('--clean', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    out = a.out.resolve()
    assert RAW in out.parents and not out.exists()
    inputs = []
    def read(path):
        path = path.resolve()
        b = path.read_bytes()
        inputs.append(dict(file=str(path), sha256=hashlib.sha256(b).hexdigest(), bytes=len(b)))
        return json.loads(b)
    d, c = read(a.diagnostics), read(a.clean)
    assert d['complete'] and d['pass'] and c['complete'] and c['pass']
    assert d['catalog'] == c['catalog'] and len(c['sources']) == 23 and len(d['rows']) == 138
    idx = {(r['case'],r['role'],r['mode']):r for r in d['rows']}
    assert len(idx) == 138
    by_clean = {s['id']:s for s in c['sources']}
    rows = []
    for case, clean in by_clean.items():
        expected = [(case,role,mode) for role in ['direct','typescript'] for mode in ['stages','cpu','allocation']]
        assert all(k in idx for k in expected)
        b, t = idx[(case,'direct','stages')], idx[(case,'typescript','stages')]
        assert b['source'] == t['source'] == clean['source']
        profiles = {mode:{role:idx[(case,role,mode)] for role in ['direct','typescript']} for mode in ['cpu','allocation']}
        excess = {g:b['groupsMs'][g]-t['groupsMs'][g] for g in GROUPS}
        shares = {mode:{x['name']:x['percent'] for x in profiles[mode]['direct']['classification']['selfNameFamilies']} for mode in profiles}
        row = dict(id=case, sourceBytes=b['sourceBytes'], pointIds=b['pointIds'],
            moduleBytes={role:idx[(case,role,'stages')]['emittedModuleBytes'] for role in ['direct','typescript']},
            cleanCombinedRatio=clean['b2OverTs']['importApiAndFirstMs'], cleanCombinedGapMs=clean['combinedGapMs'],
            cleanFourRequestWorkerPairMedianSeconds=sum(r['workerWallMs']['median'] for r in clean['roles'].values())/1000,
            stages={role:dict(totalMs=idx[(case,role,'stages')]['totalMs'],groupsMs=idx[(case,role,'stages')]['groupsMs']) for role in ['direct','typescript']},
            b2Stages=b['stages'], stageExcessMs=excess, largestStageExcess=max(excess,key=excess.get),
            b2LargestIndividualStage=max(b['stages'],key=lambda k:b['stages'][k]['exclusiveMs']),
            allocationBytes={role:profiles['allocation'][role]['classification']['total'] for role in ['direct','typescript']},
            cpuSampleCounts={role:profiles['cpu'][role]['classification']['total'] for role in ['direct','typescript']},
            b2SelfFamilyPercent={mode:{f:shares[mode].get(f,0.0) for f in FAMILIES} for mode in shares},
            b2AncestorPartitions={mode:profiles[mode]['direct']['classification']['ancestorStages'] for mode in shares})
        rows.append(row)
    # 5% is a descriptive screening flag only, never a confidence or absence test.
    recurrence = {mode:{f:dict(atLeast5Percent=sum(r['b2SelfFamilyPercent'][mode][f]>=5 for r in rows),
                              observedPositive=sum(r['b2SelfFamilyPercent'][mode][f]>0 for r in rows),
                              minimum=min(r['b2SelfFamilyPercent'][mode][f] for r in rows),
                              maximum=max(r['b2SelfFamilyPercent'][mode][f] for r in rows)) for f in FAMILIES} for mode in ['cpu','allocation']}
    result = dict(kind='phase60-bottleneck-view',complete=True,dataOnly=True,targetExecuted=False,
                  producer=dict(file=str(Path(__file__).resolve()),sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest()),
                  inputs=inputs,rows=rows,familyRecurrence=recurrence,
                  largestIndividualStageCounts=dict(collections.Counter(r['b2LargestIndividualStage'] for r in rows)),
                  largestCoarseExcessCounts=dict(collections.Counter(r['largestStageExcess'] for r in rows)),
                  scope='All 23 sources. Diagnostic one-observation clocks/profiles remain separate from clean medians. Family flags describe observed self frames, not causal operations, absence proofs or gains; shared SCC names remain shared. Full population/failed cases must be assessed before selecting a subset.')
    result['pass'] = True
    for i in inputs:
        assert hashlib.sha256(Path(i['file']).read_bytes()).hexdigest() == i['sha256']
    out.mkdir(parents=True)
    (out/'report.json').write_text(json.dumps(result,indent=2)+'\n')
    ordered = sorted(rows,key=lambda r:-r['stages']['direct']['totalMs'])
    md = ['# All-source diagnostic classification','',result['scope'],'',
          '| Source | Source B | B2 / TS module B | B2 / TS stage total ms | Largest coarse excess (ms) | B2 / TS sampled MB |',
          '| --- | ---: | ---: | ---: | --- | ---: |']
    for r in ordered:
        g=r['largestStageExcess'];b=r['stages']['direct']['totalMs'];t=r['stages']['typescript']['totalMs']
        md.append(f"| {r['id']} | {r['sourceBytes']} | {r['moduleBytes']['direct']} / {r['moduleBytes']['typescript']} | {b:.1f} / {t:.1f} | {g}: {r['stageExcessMs'][g]:.1f} | {r['allocationBytes']['direct']/1e6:.1f} / {r['allocationBytes']['typescript']/1e6:.1f} |")
    (out/'report.md').write_text('\n'.join(md)+'\n')
    def start(height,title,note):
        return [f'<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="{height}" viewBox="0 0 1200 {height}">',
            '<rect width="100%" height="100%" fill="white"/><g font-family="sans-serif" font-size="12">',
            f'<text x="20" y="28" font-size="20">{html.escape(title)}</text>',f'<text x="20" y="52">{html.escape(note)}</text>']
    height=160+len(ordered)*53
    svg=start(height,'First-window stages across all 23 compilation inputs','One fresh diagnostic observation per role; exclusive wall time (ms). TS reach/code generation remains one coarse js_lib interval.')
    scale=780/max(r['stages'][role]['totalMs'] for r in ordered for role in ['direct','typescript'])
    for n,r in enumerate(ordered):
        y=85+n*53
        svg.append(f'<text x="20" y="{y+12}">{html.escape(r["id"])}</text>')
        for j,role in enumerate(['direct','typescript']):
            left=240;yy=y+j*18
            svg.append(f'<text x="212" y="{yy+11}">{"B2" if j==0 else "TS"}</text>')
            for g,color in zip(GROUPS,COLORS):
                v=r['stages'][role]['groupsMs'][g];w=v*scale
                svg.append(f'<rect x="{left:.3f}" y="{yy}" width="{w:.3f}" height="14" fill="{color}"><title>{html.escape(g)}: {v:.6f} ms</title></rect>');left+=w
            svg.append(f'<text x="{left+6:.3f}" y="{yy+11}">{r["stages"][role]["totalMs"]:.0f}</text>')
    for i,(g,color) in enumerate(zip(GROUPS,COLORS)):
        x=20+i%3*380;y=height-49+i//3*23
        svg.extend([f'<rect x="{x}" y="{y-10}" width="12" height="12" fill="{color}"/>',f'<text x="{x+20}" y="{y}">{html.escape(g)}</text>'])
    svg.append('</g></svg>');(out/'stage-population.svg').write_text('\n'.join(svg)+'\n')
    labels=['String names','Emitted refs','Index names','Substitution','Primitive metadata','Term constructors']
    for mode in ['cpu','allocation']:
        height=135+len(ordered)*29
        svg=start(height,'B2 '+mode+' self-frame families: all 23 inputs','Cell = rounded observed share (%), one profile per input. Shared SCC labels are not individual source members; unshown families remain in the denominator.')
        for j,label in enumerate(labels):svg.append(f'<text x="{250+j*140}" y="81" text-anchor="middle">{label}</text>')
        for i,r in enumerate(ordered):
            y=96+i*29;svg.append(f'<text x="20" y="{y+15}">{html.escape(r["id"])}</text>')
            for j,f in enumerate(FAMILIES):
                v=r['b2SelfFamilyPercent'][mode][f];strength=min(v/40,1)
                rgb=tuple(round(245+(base-245)*strength) for base in [44,104,141])
                color='#%02x%02x%02x'%rgb;ink='white' if strength>.65 else '#222222';x=190+j*140
                svg.append(f'<rect x="{x}" y="{y}" width="125" height="24" fill="{color}"/><text x="{x+62.5}" y="{y+16}" text-anchor="middle" fill="{ink}">{v:.1f}</text>')
        svg.append('</g></svg>');(out/(mode+'-families.svg')).write_text('\n'.join(svg)+'\n')
    print(json.dumps(dict(out=str(out),sources=len(rows),familyRecurrence=recurrence)))


if __name__ == '__main__':
    main()
