#!/usr/bin/env python3
"""Offline dependency obstruction census from existing candidate observations."""
import argparse
import collections
import hashlib
import json
from pathlib import Path


def pin(path):
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def components(graph):
    indices, low, stack, active, result = {}, {}, [], set(), []

    def visit(node):
        indices[node] = low[node] = len(indices)
        stack.append(node)
        active.add(node)
        for child in sorted(graph[node]):
            if child not in indices:
                visit(child)
                low[node] = min(low[node], low[child])
            elif child in active:
                low[node] = min(low[node], indices[child])
        if low[node] == indices[node]:
            group = []
            while True:
                child = stack.pop()
                active.remove(child)
                group.append(child)
                if child == node:
                    break
            result.append(sorted(group))

    for node in sorted(graph):
        if node not in indices:
            visit(node)
    return sorted(result)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--receipt', required=True, type=Path)
    parser.add_argument('--out', required=True, type=Path)
    args = parser.parse_args()
    report = json.loads(args.receipt.read_text())
    assert report['complete']
    rows = [r for r in report['rows'] if r['kind'] == 'candidate']
    candidates = {r['owner']: r for r in rows}
    assert len(candidates) == len(rows)
    admitted = {r['owner'] for r in report['rows'] if r['kind'] == 'admitted'}
    errors = {k for k, v in candidates.items() if v['error']}
    blocked = {k for k, v in candidates.items() if not v['error'] and not v['admitted']}
    for name, row in candidates.items():
        assert row['admitted'] == (name in admitted)
        assert set(row['missing']) == set(row['calls']) - admitted
    graph = {k: set(candidates[k]['calls']) & blocked for k in blocked}
    groups = [g for g in components(graph) if len(g) > 1 or g[0] in graph[g[0]]]
    cycle_sets = [set(g) for g in groups]

    def reach(start):
        seen, todo = set(), [start]
        while todo:
            node = todo.pop()
            if node in seen:
                continue
            seen.add(node)
            # Error rows may contain only the prefix lowered before failure.
            # Treat them as terminal barriers, never complete call graphs.
            if node in blocked:
                todo.extend(set(candidates[node]['calls']) - admitted)
        return seen

    reaches = {k: reach(k) for k in blocked}
    cycle_rows = []
    for i, group in enumerate(cycle_sets):
        external = set().union(*(set(candidates[k]['calls']) for k in group)) - admitted - group
        cycle_rows.append(dict(id=f'cycle-{i}', members=sorted(group),
                               externalUnadmittedDependencies=sorted(external),
                               closedAgainstAdmitted=not external,
                               blockedRowsReaching=sorted(k for k, seen in reaches.items() if seen & group)))

    def discharged_ready(allowed):
        ready = set(admitted)
        while True:
            old = set(ready)
            for node in sorted(blocked):
                if set(candidates[node]['calls']) <= ready:
                    ready.add(node)
            for group in allowed:
                if all(set(candidates[k]['calls']) <= ready | group for k in group):
                    ready |= group
            if ready == old:
                return sorted((ready - admitted) & blocked)

    classes = collections.Counter()
    observations = []
    for node in sorted(blocked):
        seen = reaches[node]
        es = sorted(seen & errors)
        cs = [f'cycle-{i}' for i, g in enumerate(cycle_sets) if seen & g]
        classes[f'{"errors" if es else "no-errors"}+{"cycles" if cs else "no-cycles"}'] += 1
        observations.append(dict(owner=node, missing=sorted(set(candidates[node]['calls']) - admitted),
                                 reachesErrors=es, reachesCycles=cs))
    unknown = set().union(*(set(candidates[k]['calls']) for k in blocked)) - candidates.keys() - admitted
    result = dict(kind='phase167-admission-obstruction-census', method=pin(Path(__file__)),
                  receipt=pin(args.receipt), inputs=report['inputs'],
                  counts=dict(raw=len(rows), errorRows=len(errors),
                              errorFree=len(rows)-len(errors),
                              rawAdmitted=sum(r['admitted'] for r in rows), finalFunctions=len(admitted),
                              blockedErrorFree=len(blocked), independentErrorFreeSccs=len(groups)),
                  generatedAdmittedIdentities=sorted(admitted-candidates.keys()),
                  unknownMissingCallees=sorted(unknown), classes=classes,
                  explicitErrors=[dict(owner=k,error=candidates[k]['error'],
                                       blockedRowsReaching=sorted(n for n,s in reaches.items() if k in s))
                                  for k in sorted(errors)],
                  cycles=cycle_rows, blocked=observations,
                  dependencyOnlyCounterfactuals={
                      **{f'cycle-{i}':discharged_ready([g]) for i,g in enumerate(cycle_sets)},
                      'closed-cycles':discharged_ready([g for g,c in zip(cycle_sets,cycle_rows) if c['closedAgainstAdmitted']]),
                      'all-cycles':discharged_ready(cycle_sets)},
                  limits=[
                      'Static candidate dependency observations; no runtime or wall-time attribution.',
                      'A cycle is an additional legality obligation, not permission for unbounded native recursion.',
                      'Counterfactuals assume a correct stack-safe cycle transformation; they only count dependency readiness.',
                      'Failed candidate call lists may be partial; traversal stops at error rows.',
                      'Reach sets overlap; counts cannot be summed into independent gains.',
                      'More complete lowering can change bodies and dependencies; no fixed speed gain follows.'
                  ])
    assert not args.out.exists()
    args.out.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(counts=result['counts'],classes=classes,
                         counterfactuals={k:len(v) for k,v in result['dependencyOnlyCounterfactuals'].items()})))


if __name__ == '__main__':
    main()
