#!/usr/bin/env python3
"""Data-only leaf census under the actual selected constructor_exists stack."""
import collections
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
EVIDENCE = ROOT / 'implementation/phase65/evidence/baseline-state09-allocation.json'
OUT = ROOT / 'implementation/phase65/evidence/constructor-misses.json'


def pin(file):
    file = Path(file).resolve(strict=True)
    return dict(file=str(file), sha256=hashlib.sha256(file.read_bytes()).hexdigest())


def verify(record):
    assert pin(record['file'])['sha256'] == record['sha256']


assert not OUT.exists()
prior = json.loads(EVIDENCE.read_text())
assert prior['pass'] and prior['complete']
rows = []
for row in prior['rows']:
    if row['role'] != 'baseline':
        continue
    verify(row['raw'])
    verify(row['worker'])
    worker = json.loads(Path(row['worker']['file']).read_text())
    api = worker['image']['api']
    verify(api)
    api_url = Path(api['file']).as_uri()
    profile = json.loads(Path(row['raw']['file']).read_text())
    nodes, parents = {}, {}
    todo = [(profile['head'], None)]
    while todo:
        node, parent = todo.pop()
        assert node['id'] not in nodes
        nodes[node['id']] = node
        parents[node['id']] = parent
        todo.extend((child, node['id']) for child in node.get('children', []))
    leaves = collections.Counter()
    leaf_samples = collections.Counter()
    total = count = 0
    for sample in profile['samples']:
        node_id, size = sample['nodeId'], sample['size']
        cursor = node_id
        found = False
        while cursor is not None:
            frame = nodes[cursor]['callFrame']
            if frame.get('url') == api_url and frame['functionName'] == '$jd$constructor_95_exists':
                found = True
                break
            cursor = parents[cursor]
        if not found:
            continue
        frame = nodes[node_id]['callFrame']
        key = (frame['functionName'], frame.get('url', ''), frame.get('lineNumber'), frame.get('columnNumber'))
        leaves[key] += size
        leaf_samples[key] += 1
        total += size
        count += 1
    rows.append(dict(case=row['case'], raw=row['raw'], worker=row['worker'], api=api,
                     sampleBytes=total, samples=count,
                     leaves=[dict(functionName=k[0], url=k[1], lineNumber=k[2], columnNumber=k[3],
                                  sampledBytes=v, samples=leaf_samples[k], percent=100*v/total)
                             for k, v in leaves.most_common()]))
result = dict(kind='phase65-constructor-miss-leaf-census', complete=True, dataOnly=True,
              targetExecuted=False, producer=pin(__file__), inputs=[pin(EVIDENCE)], rows=rows,
              scope='Samples[].size under exact selected API constructor_exists ancestry only. '
                    'Leaf attribution includes V8 inlining effects and is not an allocation count '
                    'or proof of removable cost. Generated source must establish actual construction; '
                    'clean request timing must establish gain. No target or old raw mutation.')
OUT.write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps(dict(output=pin(OUT), rows=[dict(case=r['case'], sampleBytes=r['sampleBytes'], leaves=r['leaves'][:5]) for r in rows])))
