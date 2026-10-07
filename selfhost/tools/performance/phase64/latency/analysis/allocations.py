#!/usr/bin/env python3
"""Read-only sampled-allocation analysis using the preserved Phase62 partition."""
import argparse
import collections
import hashlib
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[6]
PARENT = ROOT/'selfhost/tools/performance/phase62/analysis/profiles-v2.py'
PARENT_SHA = '4fb715bddc5262f6c7b53d869840f46d225cd3eed2b9ae3b53cdb0ee00bb3679'
B2 = 'e838cbab6e6543d1785da0474c50c1c33ab91e6806d2e6796cfcbeabf5b98003'
SOURCE = '0ebe491e727721857ce981ff5a2167a52d1e040f5674915a3349fea33bed8ed5'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--report', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    assert not args.out.exists()
    inputs = {}

    def pin(value):
        file = Path(value['file'] if isinstance(value, dict) else value).resolve(strict=True)
        row = dict(file=str(file), sha256=hashlib.sha256(file.read_bytes()).hexdigest())
        if isinstance(value, dict):
            assert row['sha256'] == value['sha256']
        assert str(file) not in inputs or inputs[str(file)] == row
        inputs[str(file)] = row
        return row

    def read(value):
        return json.loads(Path(pin(value)['file']).read_text())

    assert pin(PARENT)['sha256'] == PARENT_SHA
    spec = importlib.util.spec_from_file_location('phase62_profile_partition', PARENT)
    method = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(method)
    additions = {'jd_plan_selected': 'lowering-plan', 'jd_plan_library': 'plan-render',
                 'f_prefix_complete_ready_seed': 'source-completion'}
    method.GENERATED_BOUNDARIES.update(additions)
    report = read(args.report)
    config = read(report['config'])
    assert report['complete'] and report['pass'] and report['mode'] == 'allocation'
    assert config['mode'] == 'allocation' and config['rounds'] == 1 and config['warmRequests'] == 0
    expected = {(case, role) for case in ['numeric-recurrence', 'lexer', 'test-map-set-ops'] for role in ['baseline', 'typescript']}
    assert len(report['rows']) == 6 and {(r['case'], r['role']) for r in report['rows']} == expected
    rows = []
    for row in report['rows']:
        worker = read(row['result'])
        assert worker == row['observation'] and row['success'] and row['execution']['returncode'] == 0
        assert worker['complete'] and worker['pass'] and worker['cleanTiming'] is False and worker['warmRequests'] == []
        for key in ['source', 'expected', 'output']:
            pin(worker[key])
        assert Path(worker['output']['file']).read_bytes() == Path(worker['expected']['file']).read_bytes()
        inline = worker['profile']
        profile = read(inline['receipt'])
        assert profile == {key: value for key, value in inline.items() if key != 'receipt'}
        assert profile['complete'] and profile['pass'] and profile['diagnosticOnly'] and profile['calls'] == 1
        assert profile['sampling'] == dict(intervalBytes=131072, includeObjectsCollectedByMajorGC=True, includeObjectsCollectedByMinorGC=True)
        raw, summary = read(profile['raw']), read(profile['summary'])
        image = worker.get('image')
        if image:
            assert image['api']['sha256'] == B2 and image['source']['sha256'] == SOURCE
            for key in ['api', 'source', 'driver']:
                pin(image[key])
        api = Path(image['api']['file']).as_uri() if image else None
        driver = Path(image['driver']['file']).as_uri() if image else None
        view = method.partition(raw, 'allocation', None, api, driver, Path(config['upstream']))
        assert view['total'] == summary['totalWeight'] == profile['totals']['totalWeight']
        assert view['sampleEvents'] == summary['sampleCount']
        nodes, parents, todo = {}, {}, [(raw['head'], None)]
        while todo:
            node, parent = todo.pop()
            assert node['id'] not in nodes
            nodes[node['id']], parents[node['id']] = node, parent
            todo += [(child, node['id']) for child in node.get('children', [])]
        sampled = collections.Counter()
        for sample in raw['samples']:
            sampled[sample['nodeId']] += sample['size']
        diffs = [dict(nodeId=nid, sampleBytes=sampled[nid], treeSelfBytes=nodes.get(nid, {}).get('selfSize', 0),
                      deltaBytes=sampled[nid]-nodes.get(nid, {}).get('selfSize', 0))
                 for nid in set(nodes)|set(sampled) if sampled[nid] != nodes.get(nid, {}).get('selfSize', 0)]
        families = collections.Counter()
        for nid, weight in sampled.items():
            names, cursor = [], nid
            while cursor in nodes:
                frame = nodes[cursor]['callFrame']
                if api and frame.get('url') == api:
                    name = method.decoded(frame['functionName'])
                    if name:
                        names.append(name)
                cursor = parents[cursor]
            for family, match in {
                'constructorLookup': 'constructor_exists' in names,
                'todoScan': any(n.startswith('driver_holes') or n == 'driver_count_todos' for n in names),
                'nativeLayout': any(n.startswith('jd_native_layout') for n in names),
                'callAnalysis': any(n.startswith('jd_calls_') for n in names),
                'hostExport': any(n.startswith(('jd_host', 'jd_marshal')) for n in names),
            }.items():
                if match:
                    families[family] += weight
        rows.append(dict(case=row['case'], role=row['role'], worker=pin(row['result']),
            profile=pin(inline['receipt']), raw=pin(profile['raw']), sampling=profile['sampling'],
            sampleBytes=view['total'], treeSelfBytes=sum(n.get('selfSize', 0) for n in nodes.values()),
            accountingMismatchNodes=len(diffs), accountingLargestDifferences=sorted(diffs,key=lambda x:abs(x['deltaBytes']),reverse=True)[:10],
            exclusiveStages=view['exclusiveStages'], inclusiveAncestorUnions=view['inclusiveAncestorUnions'],
            supplementalInclusiveUnions=[dict(name=k, bytes=v, percent=100*v/view['total']) for k,v in families.most_common()],
            absentTreeNodes=view['absentTreeNodes'], topSelf=view['topSelf'][:15], unresolvedSelf=view['unresolvedSelf'][:5], warnings=profile['warnings']))
    ratios = []
    for case in sorted({row['case'] for row in rows}):
        selected = {row['role']: row for row in rows if row['case'] == case}
        ratios.append(dict(case=case, baselineBytes=selected['baseline']['sampleBytes'],
            typescriptBytes=selected['typescript']['sampleBytes'], ratio=selected['baseline']['sampleBytes']/selected['typescript']['sampleBytes']))
    for row in list(inputs.values()):
        pin(row)
    result = dict(kind='phase64-state09-allocation-analysis', complete=True, **{'pass': True},
        dataOnly=True, targetExecuted=False, producer=pin(__file__), parent=pin(PARENT),
        boundaryAdditions=additions, report=pin(args.report), rows=rows, ratios=ratios, inputs=list(inputs.values()),
        policy='Weights use samples[].size only. Tree selfSize disagreements remain explicit. '
        'Exclusive stages partition each sample by nearest actual named ancestor. Inclusive unions overlap; '
        'shared SCC names are worker labels, not individual operation attribution. Missing/deep anonymous '
        'boundaries remain unresolved. Allocation is estimated cumulative bytes, not retained memory, CPU '
        'or a predicted latency gain. The profile window includes imports, API load and first compilation.')
    args.out.parent.mkdir(parents=True, exist_ok=True)
    with args.out.open('x') as stream:
        stream.write(json.dumps(result, indent=2)+'\n')
    print(json.dumps(dict(output=pin(args.out), ratios=ratios, rows=len(rows))))


if __name__ == '__main__':
    main()
