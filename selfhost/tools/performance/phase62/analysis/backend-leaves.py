#!/usr/bin/env python3
"""Inspect saved backend-stage leaf costs; never execute a compiler."""
import argparse
import collections
import hashlib
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
STAGES = {'emitted-reach', 'final-library', 'host-wrapper', 'annotation', 'layout-proof',
          'ts-file-analysis', 'ts-library'}


def identity(file):
    file = Path(file).resolve()
    return dict(file=str(file), sha256=hashlib.sha256(file.read_bytes()).hexdigest(), bytes=file.stat().st_size)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--analysis', type=Path, required=True)
    p.add_argument('--cases', default='test-map-set-ops,test-evening-program,lexer,numeric-recurrence')
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    out = a.out.resolve()
    assert out.is_relative_to(ROOT/'selfhost/build/phase62') and not out.exists()
    reader = identity(Path(__file__).with_name('profiles-v2.py'))
    assert reader['sha256'] == '4fb715bddc5262f6c7b53d869840f46d225cd3eed2b9ae3b53cdb0ee00bb3679'
    spec = importlib.util.spec_from_file_location('phase62_profiles', reader['file'])
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    source = identity(a.analysis)
    analysis = json.loads(a.analysis.read_text())
    assert analysis['complete'] and analysis['pass']
    inputs, rows = [source, reader], []
    selected = set(a.cases.split(','))
    for row in analysis['rows']:
        if row['mode'] != 'cpu' or row['case'] not in selected:
            continue
        raw_id = identity(row['raw']['file'])
        assert raw_id == row['raw']
        inputs.append(raw_id)
        raw = json.loads(Path(raw_id['file']).read_text())
        nodes = {n['id']: n for n in raw['nodes']}
        parents = {c: n['id'] for n in raw['nodes'] for c in n.get('children', [])}
        image = row['image']
        api = Path(image['api']['file']).as_uri() if image else None
        driver = Path(image['driver']['file']).as_uri() if image else None
        counted, weighted = collections.defaultdict(collections.Counter), collections.defaultdict(collections.Counter)
        for nid, delta in zip(raw['samples'], raw['timeDeltas']):
            stack = []
            while nid is not None:
                stack.append(nodes[nid]['callFrame'])
                nid = parents.get(nid)
            stage = module.classify(stack, api, driver, ROOT/'selfhost/.bootstrap/upstream-phase23')
            if stage not in STAGES:
                continue
            f = stack[0]
            key = f['functionName'], f.get('url', ''), f['lineNumber'], f['columnNumber']
            counted[stage][key] += 1
            if row['weightedStatus'] == 'admitted': weighted[stage][key] += max(0, delta)
        views = {}
        for unit, groups in [('counts', counted), ('microseconds', weighted)]:
            if unit == 'microseconds' and row['weightedStatus'] != 'admitted': continue
            stages = []
            for stage, counter in groups.items():
                total = sum(counter.values())
                leaves = [dict(functionName=k[0], url=k[1], lineNumber=k[2], columnNumber=k[3], weight=v,
                    stagePercent=100*v/total, sharedSccName=k[0].endswith('$scc')) for k, v in counter.most_common(40)]
                stages.append(dict(stage=stage, total=total, leaves=leaves))
            views[unit] = stages
        rows.append(dict(case=row['case'], role=row['role'], raw=raw_id, weightedStatus=row['weightedStatus'], views=views))
    assert {r['case'] for r in rows} == selected
    for item in inputs: assert identity(item['file']) == item
    result = dict(kind='phase62-backend-leaf-census', complete=True, rows=rows, inputs=inputs,
        producer=identity(__file__), targetExecuted=False,
        scope='Exclusive leaves within exact real boundary ancestors. Percent denominators are individual stage sample mass, not clean request duration. Shared SCC labels retain ambiguity: representative names do not uniquely identify executed source members. No conversion into predicted wall-time gains.')
    result['pass'] = True
    out.mkdir(parents=True)
    (out/'report.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(dict(output=str(out), rows=len(rows))))


if __name__ == '__main__':
    main()
