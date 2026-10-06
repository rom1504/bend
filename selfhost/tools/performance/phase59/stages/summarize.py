#!/usr/bin/env python3
"""Data-only, exclusive-wall-clock readback of the Phase59 first-request stages."""
import argparse
import hashlib
import json
import math
import statistics
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT / 'selfhost/build/phase59'
GROUPS = ['Import / API load', 'Cache / identity', 'Source loading',
          'Check + completion', 'Reach + code generation', 'Request residual']
CACHE = {'driver.base-identity', 'driver.base-cache', 'driver.prepare-base'}
SOURCE = {'driver.source-graph', 'ts.book-load'}
CHECK = {'compiler.check-and-complete', 'ts.book-valid'}
EMIT = {'compiler.owned-layout', 'compiler.context', 'compiler.roots-and-stops',
        'compiler.source-reach', 'compiler.annotation', 'compiler.emitted-reach',
        'compiler.foreign-check', 'compiler.layout-proof', 'compiler.foreign-paths',
        'compiler.foreign-modules', 'compiler.library', 'driver.foreign-resolver',
        'driver.output-assembly', 'ts.js-lib'}
B2 = 'a73daccf86a807092a334d5f3121745e0b91c3054164c25462f1658644b7b081'


def sha(path):
    h = hashlib.sha256()
    with Path(path).open('rb') as f:
        for block in iter(lambda: f.read(1048576), b''):
            h.update(block)
    return h.hexdigest()


def close(a, b):
    assert math.isfinite(a) and math.isfinite(b)
    assert abs(a-b) <= 0.00001, (a, b)


def stats(xs):
    return dict(mean=statistics.mean(xs), median=statistics.median(xs),
                minimum=min(xs), maximum=max(xs), samples=len(xs))


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('report', type=Path)
    ap.add_argument('output', type=Path)
    args = ap.parse_args()
    source, out = args.report.resolve(), args.output.resolve()
    assert RAW in source.parents and RAW in out.parents and not out.exists()
    pinned = {}

    def verify(identity):
        p = Path(identity['file']).resolve()
        if p in pinned:
            assert pinned[p] == identity['sha256']
        else:
            assert sha(p) == identity['sha256'], str(p)
            pinned[p] = identity['sha256']
        if 'bytes' in identity:
            assert p.stat().st_size == identity['bytes']
        return p

    def read(identity):
        return json.loads(verify(identity).read_text())

    origin = dict(file=str(source), sha256=sha(source))
    run = read(origin)
    assert run['complete'] and run['pass'] and run['mode'] == 'stages'
    plan = read(run['config'])
    assert plan['rounds'] == 3 and plan['warmRequests'] == 0
    assert plan['roles'] == ['direct', 'typescript']
    assert plan['upstreamCommit'] == '018751270e800bc222a93dad7f257083ee53a5f7'
    for identity in run['inputs'] + plan['inputs']:
        verify(identity)
    read(run['methodDerivation'])
    derivation = read(plan['stageDriver'])
    assert derivation['pass'] and derivation['exactInverse']
    for name in ['source', 'output', 'producer', 'clock']:
        verify(derivation[name])
    cases = {c['id']: c for c in plan['cases']}
    assert list(cases) == ['test-evening-program', 'lexer']
    assert len(cases) == 2 and len(run['rows']) == 12
    samples, seen = [], set()
    for row in run['rows']:
        key = (row['case'], row['role'], row['sample'])
        assert key not in seen and key[0] in cases and key[1] in plan['roles'] and 0 <= key[2] < 3
        seen.add(key)
        assert row['execution']['complete'] and row['execution']['returncode'] == 0
        o = read(row['result'])
        assert o == row['observation'] and o['complete'] and o['pass']
        assert (o['role'], o['sample']) == key[1:] and o['mode'] == 'stages'
        assert o['warmRequests'] == [] and o['cleanTiming'] is False
        assert o['observation']['checked']
        if key[1] == 'direct':
            assert o['observation']['status'] == 'ok'
        else:
            assert o['observation']['holes'] == 0 and o['observation']['backend'] == 'upstream'
        assert o['source'] == cases[key[0]]['source']
        for field in ['request', 'config', 'preparation', 'source', 'expected', 'output', 'stageClock']:
            verify(o[field])
        assert o['expected']['sha256'] == o['output']['sha256']
        assert o['expected']['bytes'] == o['output']['bytes']
        assert o['stageClock'] == {k: derivation['clock'][k] for k in ['file', 'sha256']}
        if key[1] == 'direct':
            assert o['image']['api']['sha256'] == B2
            verify(o['image']['api'])
            assert o['diagnosticDriver'] == plan['stageDriver']
            assert o['originalDriver'] == {k: derivation['source'][k] for k in ['file', 'sha256']}
        clock = o['stages']
        assert clock['kind'] == 'phase59-exclusive-stage-clock' and clock['version'] == 1
        assert clock['incomplete'] == 0
        events = {e['id']: e for e in clock['events']}
        assert len(events) == len(clock['events'])
        roots = sorted((e for e in events.values() if e['parent'] is None), key=lambda e:e['startMs'])
        assert [e['name'] for e in roots] == ['host-import', 'api-load', 'first-request']
        groups = dict.fromkeys(GROUPS, 0.0)
        aggregate = defaultdict(lambda: dict(calls=0, inclusiveMs=0.0, exclusiveMs=0.0, incomplete=0))
        for e in events.values():
            assert not e['incomplete'] and e['exclusiveMs'] >= -0.00001
            close(e['endMs']-e['startMs'], e['inclusiveMs'])
            children = sorted((x for x in events.values() if x['parent'] == e['id']), key=lambda x:x['startMs'])
            previous = e['startMs']
            for child in children:
                assert previous <= child['startMs'] <= child['endMs'] <= e['endMs']
                previous = child['endMs']
            close(sum(c['inclusiveMs'] for c in children), e['childMs'])
            close(e['inclusiveMs']-e['childMs'], e['exclusiveMs'])
            chain, cursor = [], e
            while True:
                assert cursor['id'] not in [c['id'] for c in chain]
                chain.append(cursor)
                if cursor['parent'] is None:
                    break
                cursor = events[cursor['parent']]
            names = {c['name'] for c in chain}
            if chain[-1]['name'] in {'host-import', 'api-load'}:
                group = GROUPS[0]
            elif names & CACHE:
                group = GROUPS[1]
            elif names & SOURCE:
                group = GROUPS[2]
            elif names & CHECK:
                group = GROUPS[3]
            elif names & EMIT:
                group = GROUPS[4]
            else:
                group = GROUPS[5]
            groups[group] += e['exclusiveMs']
            a = aggregate[e['name']]
            a['calls'] += 1
            for field in ['inclusiveMs', 'exclusiveMs']:
                a[field] += e[field]
        for a in clock['aggregate']:
            actual = aggregate[a['name']]
            assert a['calls'] == actual['calls'] and a['incomplete'] == 0
            close(a['inclusiveMs'], actual['inclusiveMs'])
            close(a['exclusiveMs'], actual['exclusiveMs'])
        assert len(aggregate) == len(clock['aggregate'])
        for previous, following in zip(roots, roots[1:]):
            assert previous['endMs'] <= following['startMs']
        total = sum(e['inclusiveMs'] for e in roots)
        close(total, sum(groups.values()))
        close(total, clock['rootMs'])
        close(total, clock['exclusiveMs'])
        samples.append(dict(case=key[0], role=key[1], sample=key[2], totalMs=total,
                            rootMs={e['name']:e['inclusiveMs'] for e in roots}, groupsMs=groups,
                            stages=dict(aggregate), result=row['result']))
    summaries = []
    for case in cases:
        for role in plan['roles']:
            rows = [r for r in samples if r['case'] == case and r['role'] == role]
            assert len(rows) == 3
            names = sorted(set().union(*(r['stages'] for r in rows)))
            summaries.append(dict(case=case, role=role, totalMs=stats([r['totalMs'] for r in rows]),
                groupsMs={g:stats([r['groupsMs'][g] for r in rows]) for g in GROUPS},
                stagesExclusiveMs={n:stats([r['stages'].get(n, {}).get('exclusiveMs',0) for r in rows]) for n in names},
                stagesInclusiveMs={n:stats([r['stages'].get(n, {}).get('inclusiveMs',0) for r in rows]) for n in names}))
    result = dict(kind='phase59-stage-readback', complete=True, pass=True, dataOnly=True,
                  source=origin, producer=dict(file=str(Path(__file__).resolve()), sha256=sha(__file__)),
                  unit='milliseconds', averaging='Arithmetic means of exclusive partitions; medians are not additive.',
                  scope='Diagnostic wall clocks including hooks; unequal TS/B2 stage granularity, not removable CPU costs.',
                  groups=GROUPS, samples=samples, summaries=summaries,
                  inputs=[dict(file=str(p), sha256=h) for p,h in pinned.items()])
    for p,h in pinned.items():
        assert sha(p) == h, str(p)
    out.mkdir()
    (out/'report.json').write_text(json.dumps(result, indent=2)+'\n')
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    colors = ['#8a8a8a','#b28cbe','#6aa6b8','#df9860','#4e718e','#cacaca']
    fig, ax = plt.subplots(figsize=(10, 4.8))
    for i,s in enumerate(summaries):
        left = 0
        for g,color in zip(GROUPS,colors):
            value = s['groupsMs'][g]['mean']
            ax.barh(i,value,left=left,color=color,label=g if i==0 else None,height=0.64)
            if value >= 135:
                ax.text(left+value/2,i,f'{value:.0f}',ha='center',va='center',fontsize=9)
            left += value
        ax.text(left+15,i,f'{left:,.0f} ms',va='center',fontsize=10)
    ax.set_yticks(range(4), ['Evening · B2','Evening · TS','Lexer · B2','Lexer · TS'])
    ax.invert_yaxis()
    ax.set_xlim(0,max(s['totalMs']['mean'] for s in summaries)*1.12)
    ax.set_xlabel('Mean exclusive wall time across three fresh processes (ms)')
    ax.set_title('First import + API load + compilation: diagnostic stage clocks',loc='left',pad=16)
    ax.spines[['top','right','left']].set_visible(False)
    ax.legend(loc='upper center',bbox_to_anchor=(0.5,-0.19),ncol=3,frameon=False,fontsize=9)
    fig.text(0.01,0.01,'All 12 outputs matched. Check includes completion; TS js_lib is one coarse reach/code-generation interval.',fontsize=8)
    fig.tight_layout(rect=(0,0.10,1,1))
    fig.savefig(out/'stages.svg',metadata={'Date':None})
    plt.close(fig)
    print(json.dumps(dict(pass_=True,output=str(out),rows=len(samples),reportSha256=sha(out/'report.json'))))


if __name__ == '__main__':
    main()
