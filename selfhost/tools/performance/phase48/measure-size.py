#!/usr/bin/env python3
"""Static Phase48 accounting using the frozen Phase47 counting definitions."""
import argparse
import hashlib
import importlib.util
import json
import math
from pathlib import Path
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
PARENT = HERE.parent / 'phase47/measure-size.py'
PARENT_SHA = '8e59af66ae57c32cb335bacd480404fa1c8e52105b45aab0f4028450cfcf8681'
assert hashlib.sha256(PARENT.read_bytes()).hexdigest() == PARENT_SHA
spec = importlib.util.spec_from_file_location('phase47_size', PARENT)
old = importlib.util.module_from_spec(spec)
spec.loader.exec_module(old)
sys.path.insert(0, str(HERE.parent / 'programs'))
from run import load_bundle


def gm(values):
    values = list(values)
    return math.exp(sum(map(math.log, values)) / len(values))


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for role in ['baseline', 'candidate']:
        p.add_argument('--' + role + '-attempt', type=Path, required=True)
        p.add_argument('--' + role + '-bundle', type=Path, required=True)
    p.add_argument('--catalog', type=Path, default=HERE.parent / 'phase37/catalog.json')
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    assert not a.out.exists()
    assert any(a.out.resolve().is_relative_to(old.REPO / prefix) for prefix in ['selfhost/build/phase48', 'implementation/phase48'])
    for f in [__file__, PARENT, sys.executable, sys.modules['run'].__file__, sys.modules['support'].__file__]:
        old.read(f)
    catalog = json.loads(old.read(a.catalog))
    assert len(catalog['cases']) == 45 and catalog['upstreamCommit'] == old.UPSTREAM
    sha = hashlib.sha256(a.catalog.read_bytes()).hexdigest()
    sources, attempts, bundles = {}, {}, {}
    for role in ['baseline', 'candidate']:
        attempt_path = getattr(a, role + '_attempt')
        if attempt_path.is_dir():
            attempt_path = attempt_path / 'attempt.json'
        sources[role], attempts[role], _ = old.snapshot(attempt_path)
        checks = []
        bundles[role] = load_bundle(getattr(a, role + '_bundle'), catalog, sha, catalog['cases'],
                                   ['baseline', 'typescript'] if role == 'baseline' else ['candidate'], checks)
        for item in checks:
            old.read_record(item)
        compiler = bundles[role]['roles'][role]['compiler']
        for key in ['api', 'runtime', 'base']:
            assert compiler[key]['sha256'] == attempts[role][key]['sha256']
            old.read_record(compiler[key])
    baseline = sources['baseline']['totals']
    assert {k: baseline[k] for k in ['physicalLines', 'codeLines', 'definitions', 'types', 'modules']} == {
        'physicalLines': 23254, 'codeLines': 19175, 'definitions': 2622, 'types': 87, 'modules': 86}
    changes = []
    left = {x['module']: x for x in sources['baseline']['files']}
    right = {x['module']: x for x in sources['candidate']['files']}
    for module in sorted(set(left) | set(right)):
        b, c = left.get(module), right.get(module)
        if b is None or c is None or b['sha256'] != c['sha256']:
            changes.append(dict(module=module, delta={k: (c[k] if c else 0) - (b[k] if b else 0) for k in old.counts(b'')}))
    rows = []
    for case in catalog['cases']:
        b = bundles['baseline']['points'][case['id']]['baseline']
        c = bundles['candidate']['points'][case['id']]['candidate']
        rows.append(dict(id=case['id'], sourceSha256=case['source']['sha256'], baseline=b, candidate=c,
                         deltaBytes=c['bytes'] - b['bytes'], candidateOverBaseline=c['bytes'] / b['bytes'],
                         byteIdentical=b['sha256'] == c['sha256']))
    groups = {sha: [r for r in rows if r['sourceSha256'] == sha] for sha in sorted({r['sourceSha256'] for r in rows})}
    assert len(groups) == 23
    outputs = {role: {(r['sourceSha256'], r[role]['sha256']): r[role]['bytes'] for r in rows} for role in ['baseline', 'candidate']}
    libraries = dict(points=45, sources=23, rows=rows, changedPoints=sum(not r['byteIdentical'] for r in rows),
        changedSources=sum(any(not r['byteIdentical'] for r in rs) for rs in groups.values()),
        distinctSourceOutputs={k: len(v) for k, v in outputs.items()}, distinctSourceOutputBytes={k: sum(v.values()) for k, v in outputs.items()},
        byteRatioGeometricMeans=dict(equalPoint=gm(r['candidateOverBaseline'] for r in rows),
            equalSource=gm(gm(r['candidateOverBaseline'] for r in rs) for rs in groups.values())))
    report = dict(kind='phase48-static-size-accounting', complete=True, **{'pass': True},
        producer=old.identity(__file__, old.read(__file__)), parent=old.identity(PARENT, old.read(PARENT, PARENT_SHA)),
        execution='None; no compiler or generated program imported. No archive extraction or historical writes.',
        scope='Manifest-listed Bend physical/code/declaration counts reuse Phase47 exactly. Generated sizes include runtime prefixes; distinct source/output pairs retain observation adapters. Runtime/core/API images are separate, not summed as maintained source.',
        roles=sources, sourceDelta=old.delta(baseline, sources['candidate']['totals']), changedSourceModules=changes,
        libraries=libraries)
    for file, item in old.INPUTS.items():
        assert old.identity(file, Path(file).read_bytes()) == item
    report['inputs'] = list(old.INPUTS.values())
    a.out.parent.mkdir(parents=True, exist_ok=True)
    with a.out.open('x') as f:
        json.dump(report, f, indent=2); f.write('\n')
    print(json.dumps(dict(complete=True, sourceDelta=report['sourceDelta'], changedPoints=libraries['changedPoints'], changedSources=libraries['changedSources'])))


if __name__ == '__main__':
    main()
