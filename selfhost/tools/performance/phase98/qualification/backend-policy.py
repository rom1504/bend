#!/usr/bin/env python3
"""Offline freeze explicit changed-C intent, its exact source and existing oracles."""
import argparse
import json
from pathlib import Path
from support import Bindings, ROOT, baseline, entry_definitions, freeze_methods, pin, read


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--source', type=Path, required=True)
    p.add_argument('--recipe', type=Path, required=True)
    p.add_argument('--reason', required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args(); out = a.out.resolve(); assert not out.exists(); out.mkdir(parents=True)
    assert len(a.reason.strip()) >= 20, 'Describe the actual backend mechanism'
    b = Bindings(); ctx = baseline(b); freeze_methods(out, b)
    source = b.bind(a.source); recipe_pin = b.bind(a.recipe); recipe = read(recipe_pin['file'])
    assert recipe['complete'] and b.bind(recipe['candidate']) == source
    assert recipe.get('forwardReplayExact', recipe.get('patchReplayedFromBaseline', False))
    assert recipe.get('inverseRecoversSource', recipe.get('reverseReplayExact', False))
    b.tree(recipe)
    original = Path(b.bind(recipe['source'])['file']).read_text()
    replay = original
    for change in recipe['changes']:
        start = change['offset']; old, new = change['old'], change['new']
        assert replay[start:start + len(old)] == old
        replay = replay[:start] + new + replay[start + len(old):]
    assert replay == Path(source['file']).read_text(), 'Exact recipe replay required'
    assert entry_definitions(Path(source['file']).read_text()) == entry_definitions(Path(ctx['source']['file']).read_text())
    origins = {}
    for name, file in [
        ('controls', 'selfhost/build/phase90/native07-qualification01/report.json'),
        ('broad45', 'selfhost/build/phase92/broad02/report.json'),
        ('native69', 'selfhost/build/phase92/conformance01/plan.json'),
        ('negatives', 'selfhost/build/phase92/conformance01/diagnostics/report.json')]:
        origins[name] = b.bind(ROOT / file)
    broad = read(origins['broad45']['file']); assert broad['complete'] and broad['passed'] and broad['inputsUnchanged']
    executions = {r['case']: r for r in broad['programExecutions']}
    cases = []
    for case in broad['cases']:
        actual = executions[case['name']]; assert actual['passed'] and actual['expected'] == case['expectedStdout']
        expected = (case['expectedStdout'] + '\n').encode()
        import hashlib
        assert actual['stdout']['bytes'] == len(expected) and actual['stdout']['sha256'] == hashlib.sha256(expected).hexdigest()
        assert actual['stderr']['bytes'] == 0
        cases.append(dict(name=case['name'], source=b.bind(case['source']), historicalC=case['oracle'],
                          expectedStdout=expected.decode(), expectedStderr='', runtimeArgs=['--threads', '1', '--gpu', 'off'],
                          original=case['original'], historicalExecution=case['historicalExecution'],
                          expectedStdoutEvidence=actual['stdout']))
    assert len(cases) == 45
    b.unchanged()
    report = dict(kind='phase98-changed-backend-intent', complete=True, targetsRun=False,
                  source=source, recipe=recipe_pin, recipeReplayedExactly=True, reason=a.reason.strip(), method=pin(__file__),
                  diagnosticsMustRemainExact=True, requireCandidateFixedPoint=True,
                  requireGeneratedProgramExecution=True, publicAdmission=False, imageQualified=False,
                  independentOrigins=origins, cases=cases, inputs=list(b.rows.values()),
                  requiredGates=['independent baseline self diagnostic', 'candidate B1/B2 exact self-C fixed point',
                                 'four live/cached sources and three exact rejections on both images',
                                 'native69 golden executions on each image plus three rejections',
                                 '45 original sources: B1/B2 exact C, matched Clang and full stdout/stderr'],
                  scope='Explicit permission to compare changed C by semantics, not qualification. Historical C differences are recorded; diagnostics, original inputs and expected program output remain exact. Runtime performance needs separate matched timing.')
    with (out / 'policy.json').open('x') as f: json.dump(report, f, indent=2); f.write('\n')
    print(json.dumps(dict(complete=True, targetsRun=False, cases=len(cases), policy=str(out / 'policy.json'))))


if __name__ == '__main__': main()
