#!/usr/bin/env python3
"""Freeze unchanged historical source/output controls; never launches targets."""
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import re

HERE = Path(__file__).resolve().parent
COVERAGE = HERE.parent
ROOT = HERE.parents[5]


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def verified(row):
    actual = pin(ROOT / row['file'])
    if any(actual[key] != row[key] for key in ['bytes', 'sha256']):
        raise ValueError('Changed historical input: ' + row['file'])
    return actual


def main():
    if (HERE / 'manifest.json').exists() or (HERE / 'expected').exists():
        raise ValueError('Full45 freeze already exists')
    inventory_file = COVERAGE / 'broad-inventory.json'
    inventory = json.loads(inventory_file.read_text())
    corpus_pin = verified(inventory['priorCorpus'])
    corpus = json.loads(Path(corpus_pin['file']).read_text())
    plan_file = ROOT / 'selfhost/tools/performance/phase108/coverage/full-compiler-plan.json'
    plan = json.loads(plan_file.read_text())
    old_file = ROOT / 'selfhost/build/phase92/broad02/report.json'
    old = json.loads(old_file.read_text())
    focused_file = COVERAGE / 'manifest.json'
    focused = json.loads(focused_file.read_text())
    assets_file = COVERAGE.parent / 'native-assets01.json'
    assets = json.loads(assets_file.read_text())
    base, carrier = verified(assets['base']), verified(assets['cache']['carrier'])
    assert corpus['complete'] and corpus['passed'] and old['complete'] and old['passed']
    assert verified(corpus['upstream']['base']) == base == verified(plan['bindings']['base'])
    assert verified(plan['bindings']['preparedBase']) == carrier
    assert plan['bindings']['baseCacheStamp'] == assets['cache']['stamp']
    assert verified(corpus['selection']['admission']) == verified(assets['admission'])
    for asset in [base, carrier]:
        assert [verified(x) for x in old['inputs'] if x['file'] == asset['file']] == [asset]
    rows = corpus['cases']
    assert len(rows) == 45 and len({x['name'] for x in rows}) == 45
    previous = {x['name']: x for x in inventory['cases']}
    old_cases = {x['name']: x for x in old['cases']}
    executions = {x['case']: x for x in old['programExecutions']}
    representatives = {x['name']: x for x in focused['representatives']}
    assert len(previous) == len(old_cases) == len(executions) == 45 and len(representatives) == 6
    fixtures, extra_inputs, frozen_outputs = [], [], []
    for row in rows:
        name = row['name']
        source = verified(row['source'])
        assert source == verified(previous[name]['source']) == verified(old_cases[name]['source'])
        assert row['runtimeArgs'] == ['--threads', '1', '--gpu', 'off']
        imports = [line.strip() for line in Path(source['file']).read_text().splitlines()
                   if re.match(r'\s*import\s', line)]
        assert imports == ['import Base'], (name, imports)
        execution = executions[name]
        assert execution['passed'] and execution['run']['guardExit'] == 0
        assert execution['run']['process']['complete'] and execution['run']['process']['returncode'] == 0
        evidence = verified(row['expectedStdoutEvidence'])
        assert evidence == verified(execution['stdout']) == verified(previous[name]['expectedStdoutEvidence'])
        output = Path(evidence['file']).read_bytes()
        assert output == row['expectedStdout'].encode() == previous[name]['expectedStdout'].encode()
        stderr = verified(execution['stderr'])
        assert Path(stderr['file']).read_bytes() == row['expectedStderr'].encode() == b''
        guard = pin(Path(evidence['file']).with_name('process.json'))
        assert json.loads(Path(guard['file']).read_text()) == execution['run']['process']
        if name in representatives:
            rep = representatives[name]
            assert verified(rep['source']) == source and verified(rep['stdoutFile'])['sha256'] == evidence['sha256']
            assert rep['expect'] == dict(stage='execute', exitCode=0, stdout=row['expectedStdout'], stderr='')
        output_path = HERE / 'expected' / (name + '.stdout')
        frozen_outputs.append((output_path, output))
        fixtures.append(dict(name=name, source=source, origin=verified(row['original']),
            expect=dict(stage='execute', exitCode=0, stdout=row['expectedStdout'], stderr=''),
            stdoutFile=dict(file=str(output_path), bytes=len(output), sha256=evidence['sha256']),
            independentPriorEvidence=evidence, group='historical-broad-regression', imports=imports,
            family=old_cases[name].get('family'), historicalExecutionGuard=guard,
            historicalExecutionSeconds=execution['run']['process']['wallSeconds'],
            oracleProvenance='Unchanged Phase105 exact catalogue output, authenticated against successful Phase92 complete stdout/empty stderr. Independent of Phase111; reused observed regression, not a new handwritten oracle or held-out.',
            targetsRun=False))
        extra_inputs += [stderr, guard]
    all_names = [x['name'] for x in fixtures]
    six = [x['name'] for x in focused['representatives']]
    remaining = [name for name in all_names if name not in six]
    assert len(remaining) == 39 and set(six).isdisjoint(remaining) and set(six + remaining) == set(all_names)
    supervisor = pin(COVERAGE / 'native-run.py')
    inputs = [pin(__file__), pin(HERE / 'native-run.py'), supervisor, pin(inventory_file), corpus_pin,
              pin(plan_file), pin(old_file), pin(focused_file), pin(assets_file), base, carrier,
              verified(assets['selection']), verified(assets['admission']), *extra_inputs]
    manifest = dict(kind='phase111-frozen-full45-native-coverage', version=1, preparedOnly=True,
        targetsRun=False, preparedUtc=datetime.now(timezone.utc).isoformat(), inputs=inputs,
        supervisor=supervisor, fixtures=fixtures,
        representatives=[next(x for x in fixtures if x['name'] == name) for name in six], fastOrder=six,
        partitions=dict(all45=all_names, representatives6=six, remaining39=remaining),
        base=base, cache=assets['cache'],
        availability=dict(sourcePinsExact=45, stdoutEvidenceExact=45, priorSuccessfulExecutions=45,
                          sourcesImportOnlyPinnedBase=True, sixRepresentativeSourcesAndOutputsExact=True),
        runtimePolicy=dict(nativeRequestSeconds=120, perBuildCommandAndExecutionSeconds=10,
                           repetitionsPerCase=1, runtimeArgs=['--threads','1','--gpu','off'],
                           historicalMaximumGuardWallSeconds=max(x['historicalExecutionSeconds'] for x in fixtures),
                           historicalTimingScope='Phase92 native program plus ~20ms guard polling; not a Phase111 runtime prediction. Stop at first failed gate by default; root outer guard controls total campaign time.'),
        scope='45 unchanged finite source wrappers from the Phase105 catalogue, using original absolute paths and the same pinned Base. All positive complete-output regressions; no compiler benchmarks, per-case repetitions, generated-C input, new algorithm variants, or newly held-out claims.')
    (HERE / 'expected').mkdir()
    for path, output in frozen_outputs:
        path.write_bytes(output)
        verified(next(x['stdoutFile'] for x in fixtures if x['stdoutFile']['file'] == str(path)))
    for item in inputs:
        verified(item)
    (HERE / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print(json.dumps(dict(preparedOnly=True, targetsRun=False, cases=45, representatives=6,
                         remaining=39, manifest=pin(HERE / 'manifest.json'))))


if __name__ == '__main__':
    main()
