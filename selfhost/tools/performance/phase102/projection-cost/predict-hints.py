#!/usr/bin/env python3
"""Offline C-graph prediction; this does not execute the Bend compiler."""
import argparse
import importlib.util
import json
from pathlib import Path
import re
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
PROJECTION = HERE.parent / 'projection/prepare.py'
spec = importlib.util.spec_from_file_location('projection_patterns', PROJECTION)
P = importlib.util.module_from_spec(spec)
spec.loader.exec_module(P)
PATTERNS = json.loads((PROJECTION.parent / 'patterns.json').read_text())
CALL = re.compile(r'\bNF_FID_\w+(?=\()')


def graph(text):
    physical = P.functions(text)
    groups = {name: name for name in physical}
    for name in physical:
        if name.endswith('_trmc') and name[:-5] in physical:
            groups[name] = name[:-5]
    logical = {}
    for name, row in physical.items():
        owner = groups[name]
        if name != owner or owner not in logical:
            body = row['text'][row['text'].index('{') + 1:]
            logical[owner] = dict(calls={groups.get(c, c) for c in CALL.findall(body)},
                                 hint=row['text'].split()[0])
    return physical, groups, logical


def decoded(name):
    try:
        return ''.join(chr(int(x)) for x in name.removeprefix('NF_FID_').strip('_').split('_'))
    except ValueError:
        return name


def predict(before, after):
    fs0, groups0, old = graph(before)
    fs, groups, now = graph(after)
    callers = [name for name, row in fs0.items()
               if row['shape'] == PATTERNS['composition'] and name in fs
               and fs[name]['shape'] != row['shape']]
    eligible = {name for name, row in now.items() if row['hint'] == 'NF_INLINE'}
    def choose(edges):
        selected = set()
        for _ in range(3):
            selected = {name for name in eligible if edges[name]['calls'] <= selected}
        return selected
    existing = choose(now)
    cost = {name: dict(row, calls=set(row['calls'])) for name, row in now.items()}
    for name in callers:
        cost[groups[name]]['calls'] |= old[groups0[name]]['calls']
    predicted = choose(cost)
    prior = {name for name, row in old.items() if row['hint'] == 'NF_INLINE'}
    desired = eligible & prior
    return dict(currentGraphReproducesActual=existing == eligible,
        selectedCallers=[decoded(n) for n in callers],
        demoted=[decoded(n) for n in sorted(eligible - predicted)],
        priorHintRestorationExactly=predicted == desired,
        extraDemotions=[decoded(n) for n in sorted(desired - predicted)],
        missedDemotions=[decoded(n) for n in sorted(predicted - desired)])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    build = ROOT / 'selfhost/build/phase102'
    pairs = []
    for old in sorted((build / 'native-chain02/runtime-continuity').glob('*/output.1.c')):
        new = build / 'native-chain03/runtime-continuity' / old.parent.name / 'output.1.c'
        assert new.is_file()
        pairs.append(('runtime/' + old.parent.name, old, new))
    for new in sorted((build / 'projection-emission01').glob('*/emitted/program.c')):
        name = new.parent.parent.name
        old = build / 'depth-emission01' / name / 'emitted/program.c'
        assert old.is_file()
        pairs.append(('emission/' + name, old, new))
    assert len(pairs) == 62
    rows = [dict(id=name, before=P.pin(old), after=P.pin(new),
                 **predict(old.read_text(), new.read_text())) for name, old, new in pairs]
    report = dict(complete=True, targetsRun=False, method=P.pin(__file__),
        parser=P.pin(PROJECTION), patterns=P.pin(PROJECTION.parent / 'patterns.json'),
        candidateRecipe=P.pin(build / 'projection-cost-source01/changes.json'),
        programs=rows, products=len(rows),
        allCurrentGraphsReproduceActual=all(row['currentGraphReproducesActual'] for row in rows),
        allPriorHintsRestoredExactly=all(row['priorHintRestorationExactly'] for row in rows),
        scope='Prediction on retained generated C, not execution of the new Bend emitter. '
              'TRMC public/private workers share inner dependencies. Existing selected hints '
              'are enough eligibility because adding dependencies cannot promote any worker. '
              'Original composition syntax identifies cost edges, with no name whitelist. '
              'Actual emitter metadata may differ on other programs; require actual emission.')
    assert report['allCurrentGraphsReproduceActual'] and report['allPriorHintsRestoredExactly']
    out = args.out.resolve()
    assert out.is_relative_to(build)
    out.mkdir(parents=True, exist_ok=False)
    (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({key: report[key] for key in ('products', 'allCurrentGraphsReproduceActual', 'allPriorHintsRestoredExactly')}))


if __name__ == '__main__':
    main()
