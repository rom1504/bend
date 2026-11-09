#!/usr/bin/env python3
"""Compose an explicit analytical view of immutable complete runtime case blocks.

Never executes targets and never rewrites a source report or reuses partial cases.
"""
import argparse
import copy
import importlib.util
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('p186_block_runtime', HERE.parent / 'phase185/runtime-loop.py')
L = importlib.util.module_from_spec(spec)
spec.loader.exec_module(L)
B = L.B


def compose(parts, out):
    B.require(2 <= len(parts) <= 4 and not out.exists(), 'Two to four parts and fresh output required')
    documents = [B.read(p) for p in parts]
    base = documents[0]
    fields = ['kind', 'version', 'roles', 'reference', 'rounds', 'targetMs',
              'initialPilotMaximumRepetitions', 'minimumAcceptedMs', 'cpu', 'positionBalanced', 'ordering', 'inputs']
    B.require(base['kind'] == 'phase185-adaptive-native-runtime' and base['cpu'] == 3
              and base['rounds'] == 5 and base['positionBalanced']
              and list(base['roles']) == ['c', 'oldqbe', 'newqbe', 'oldx86', 'newx86']
              and base['reference'] == 'c', 'Exact five-role CPU3 method required')
    manifest = L.load(base['inputs'][0]['file'])
    B.require(manifest['roles'] == base['roles'] and manifest['reference'] == base['reference'],
              'Runtime roles differ from authenticated product manifest')
    catalog = B.catalog(L.CATALOG)
    known = {c['id']: c for c in catalog['cases']}
    products = {c['id']: c for c in manifest['cases']}
    included, provenance, new_inputs = {}, [], []
    saw_deadline = False
    for filename, report in zip(parts, documents):
        B.require(all(report[k] == base[k] for k in fields) and not report.get('changedInputs'),
                  'Block method/input closure differs or changed')
        for item in report['inputs']:
            B.verify(item)
        report_pin = B.pin(filename)
        guard = Path(filename).parent.with_name(Path(filename).parent.name + '-guard')
        gp, rp = guard / 'process.json', guard / 'retention.json'
        g, retention = B.read(gp), B.read(rp)
        B.require(retention.get('closed'), 'Source guard must be closed')
        if report.get('complete'):
            B.require(not report.get('error') and not report.get('deadlineReached') and g['returncode'] == 0,
                      'Completed block has failure/deadline status')
        else:
            B.require(report.get('deadlineReached') and report.get('error') and g['returncode'] != 0,
                      'Only an explicitly stopped deadline failure may supply partial-report blocks')
            saw_deadline = True
        B.require(report['selectedCaseIds'] == [c['id'] for c in report['cases']]
                  and len(set(report['selectedCaseIds'])) == len(report['cases']), 'Invalid block case selection')
        accepted, discarded = [], []
        for ci, case in enumerate(report['cases']):
            name = case['id']
            B.require(name in known and name in products and all(case[k] == known[name][k]
                      for k in ('point', 'family', 'sourceGroup')), 'Frozen catalog point differs')
            summary = B.summary(case['samples'], list(report['roles']), report['reference'], 5,
                                case['point']['ratioEligible'])
            complete = summary['complete'] and len(case['samples']) == 25 and (
                not summary['ratioEligible'] or summary['ratios'] is not None)
            if not complete:
                B.require(not report.get('complete'), 'Complete report contains incomplete case')
                discarded.append(dict(id=name, pilots=len(case['pilots']), samples=len(case['samples']),
                                      reason='Whole incomplete case discarded; no partial observations reused'))
                continue
            B.require(name not in included, 'Overlapping complete cases are forbidden: ' + name)
            B.require(summary == {k: v for k, v in case['summary'].items() if k != 'admitted'}
                      and case['summary']['admitted'], 'Recorded complete-case summary differs')
            for stage in ('pilots', 'samples'):
                for row in case[stage]:
                    proc = row['process']
                    B.require(row['correct'] and proc['exitCode'] == 0 and not proc['timedOut']
                              and row['warmups'] == case['point']['warmups'], 'Failed retained observation')
                    product = products[name]['products'][row['role']]
                    command = [product['artifact']['file'], *B.native_runtime_arguments(product),
                               str(row['repetitions']), str(row['warmups']), *map(str, case['point']['runtimeArgs'])]
                    B.require(proc['command'] == command, 'Observation executable/arguments differ')
                    B.verify(product['artifact'])
                    B.verify(proc['stdout']); B.verify(proc['stderr'])
                    point = dict(case['point'], repetitions=row['repetitions'])
                    elapsed = B.observation(Path(proc['stdout']['file']).read_bytes(),
                        Path(proc['stderr']['file']).read_bytes(), proc['exitCode'], point, proc['seconds'])
                    B.require(elapsed == row['elapsedMs'] and elapsed / row['repetitions'] == row['metricMs'],
                              'Recorded observation metric differs')
                    if stage == 'samples':
                        B.require(row['repetitions'] == case['calibration'][row['role']], 'Calibration count differs')
            roles = list(report['roles'])
            for ri in range(5):
                offset = (ci + ri) % len(roles)
                B.require([s['role'] for s in case['samples'] if s['round'] == ri] == roles[offset:] + roles[:offset],
                          'Recorded serial rotation differs')
            included[name] = copy.deepcopy(case)
            accepted.append(name)
        B.require(B.pin(filename) == report_pin, 'Source report changed during composition')
        pins = [report_pin, B.pin(gp), B.pin(rp)]
        new_inputs += pins
        provenance.append(dict(report=report_pin, guard=pins[1], retention=pins[2],
            originalComplete=report.get('complete'), originalError=report.get('error'),
            originalDeadlineReached=report.get('deadlineReached'), guardReturncode=g['returncode'],
            guardStarted=g.get('started'), guardFinished=g.get('finished'),
            includedCases=accepted, discardedWholeCases=discarded))
    B.require(saw_deadline and set(included) == set(known) and len(included) == 45,
              'Exact disjoint complete45-case union and retained deadline failure required')
    view = copy.deepcopy(base)
    view.pop('error', None)
    view.update(complete=True, derivedComposite=True, fullCatalog=True,
        completeMeaning='The analytical view has all45 complete case blocks. No source report is relabeled complete.',
        selectedCaseIds=[c['id'] for c in catalog['cases']],
        cases=[included[c['id']] for c in catalog['cases']],
        inputs=B.unique_inputs([*base['inputs'], B.pin(__file__), *new_inputs]), changedInputs=[],
        deadlineReached=False, deadlineReachedMeaning='This metadata-only analytical view executes no timed jobs; original deadline failures are preserved below.',
        wallSeconds=sum(r['wallSeconds'] for r in documents), secondsLimit=sum(r['secondsLimit'] for r in documents),
        scope='DERIVED MULTI-BLOCK ANALYTICAL VIEW. All complete cases retained from immutable reports; whole partial cases discarded and rerun. Original deadline failure is not repaired or relabeled.',
        composition=dict(kind='phase186-complete-runtime-case-blocks', method=B.pin(__file__),
            programsExecuted=False, parts=provenance, caseToPart={name: i for i, p in enumerate(provenance)
                for name in p['includedCases']}, originalReportsUnmodified=True,
            policy='No selective omission or replacement of complete cases; disjoint complete-case union only. Per-case old/new roles measured together; blocks occurred at separate recorded times.'))
    view['aggregate'] = B.aggregate(view['cases'], list(view['roles']), view['reference'])
    B.require(view['aggregate']['complete'] and view['aggregate']['timedCases'] == 44,
              'Derived full45 aggregate incomplete')
    out.parent.mkdir(parents=True, exist_ok=True)
    B.save(out, view, fresh=True)
    return dict(analyticalView=str(out), derivedComposite=True,
                completeCaseCount=45, sourceReports=[p['report']['file'] for p in provenance])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--part', type=Path, action='append', required=True)
    parser.add_argument('--out', type=Path, required=True)
    a = parser.parse_args()
    print(json.dumps(compose(a.part, a.out)))


if __name__ == '__main__':
    main()
