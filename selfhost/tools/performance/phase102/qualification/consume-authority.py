#!/usr/bin/env python3
"""Offline authenticate fresh Phase102 authority emissions and exact raw-product reuse."""
import argparse
import importlib.util
from pathlib import Path
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
spec = importlib.util.spec_from_file_location('p102_authority_native', HERE.parent / 'native-inherit.py')
N = importlib.util.module_from_spec(spec); spec.loader.exec_module(N)
S = N.S


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for key in ['prepared', 'job', 'out']: p.add_argument('--' + key, type=Path, required=True)
    a = p.parse_args(); assert not a.out.exists(); a.out.parent.mkdir(parents=True, exist_ok=True)
    b = S.Bindings(); b.bind(__file__); b.bind(N.__file__)
    def load(path, complete=True):
        rp = b.bind(path); value = S.read(rp['file']); b.tree(value)
        assert not value.get('error')
        if complete: assert value['complete']
        return rp, value
    pp, prepared = load(a.prepared); plan_pin, plan = load(prepared['plan'], False)
    assert plan['kind'] == 'phase102-authority-inputs' and not plan['cases']
    assert plan['apiPins']['candidate'] == prepared['api']
    assert plan['sourceInputs']['candidate'] == prepared['source']
    api_pin, api = load(plan['apiAcquisition'])
    assert api['api'] == plan['apiPins']['candidate'] and api['source'] == prepared['source']
    assert api['recipe'] == plan['recipe']
    old_pin, old = load(plan['historicalQualification'])
    old_plan_pin, old_plan = load(old['plan'], False)
    assert old_plan_pin == plan['historicalPlan']
    assert plan['apiPins']['baseline']['file'] == old_plan['apis']['candidate']
    assert plan['sourceInputs']['baseline'] == old_plan['sourceInputs']['candidate']
    for key in ['controls', 'unknownProvider', 'unknownProviderDerivation', 'rawCases', 'audit']:
        assert plan[key] == old_plan[key], key
    for role in ['baseline', 'candidate']:
        assert plan['apis'][role] == plan['apiPins'][role]['file']
    job_pin = b.bind(a.job); job = S.read(job_pin['file'])
    job_evidence, child = N.job_evidence(b, job, prepared['command'])
    emitted_pin, emitted = load(Path(prepared['command'][-1]) / 'report.json')
    assert emitted['kind'] == 'phase98-observer-permission-small-emission'
    assert emitted['inputsUnchanged'] and emitted['executionPerformed']
    for identity in [plan_pin, plan['executionMethod'], *plan['apiPins'].values()]:
        assert identity in emitted['inputs']
    expected_ids = [x['id'] for x in old_plan['controls']] + ['unknown-provider',
        'raw-forged-observer-context-is-inert', 'raw-observer-return-node-is-not-source', 'raw-observer-loop-node-is-not-source']
    assert [x['id'] for x in emitted['cases']] == expected_ids
    observed = {x['id']: x for x in emitted['cases']}; assert all(x['passed'] for x in observed.values())
    for case in old_plan['controls']:
        row = observed[case['id']]
        assert row['kind'] == 'actual-emission'
        assert row['normalJsDriverPermission'] is (case['id'] != 'real-io')
        assert row['authority']['safe'] and all(x['accepted'] for x in row['authority']['checks'])
        assert all(row[k] for k in ['checkedEntriesExact', 'falseEntriesExact', 'rawPermissionOff'])
        if row['authority']['checks']:
            assert row['changedProviderRejected'] is True
        else:
            assert row['changedProviderRejected'] is None
        for role in ['baseline', 'candidate']:
            flags = row['policies'][role]
            assert flags['READONLY_OBSERVERS'] == 1 and flags['UNSHARED_ARRAYS'] == 0
            assert flags['TYPED_SCALARS'] == flags['SCALAR_ARRAYS'] == case['scalar']
    unknown = observed['unknown-provider']
    assert unknown['kind'] == 'authority-refusal' and not unknown['permission']['safe']
    assert not unknown['driverPermission'] and not any(unknown['flags'].values())
    for name in expected_ids[-3:]:
        row = observed[name]; assert row['kind'] == 'raw-boundary' and row['exactBaseline']
        assert bool(row['diagnostic']) is (name != expected_ids[-3])
    # Fresh exact raw C may inherit its original actual full native execution.
    # The three positive user programs instead run in the unchanged five-source
    # final-native gate; their changed generated C is not inherited here.
    old_emission_pin, old_emission = load(old['emission'])
    assert plan['apiPins']['baseline'] in old_emission['inputs']
    raw_id = expected_ids[-3]
    raw = next(x for x in emitted['programs'] if x['id'] == raw_id)
    old_raw = next(x for x in old_emission['programs'] if x['id'] == raw_id)
    assert N.same(raw['c'], old_raw['c'])
    assert (raw['stdout'], raw['stderr']) == (old_raw['stdout'], old_raw['stderr']) == ('7n\n', '')
    old_rows = {x['name']: x for x in old['rows']}
    run, build = old_rows[raw_id + '-run'], old_rows[raw_id + '-clang']
    for value in [run, build]:
        process = S.read(b.bind(value['guard'])['file'])
        assert process == value['process'] and S.bounded_exit(process, 0) and value['launcherExit'] == 0
    assert run['fullOutputExact']
    build_argv = build['process']['command']; binary = b.bind(build_argv[build_argv.index('-o') + 1])
    assert old_raw['c']['file'] in build_argv and '-O2' in build_argv
    assert run['process']['command'][-5:] == [binary['file'], '--threads', '1', '--gpu', 'off']
    captures = {s: b.bind(Path(run['guard']['file']).parent / (s + '.log')) for s in ['stdout', 'stderr']}
    assert Path(captures['stdout']['file']).read_bytes() == b'7n\n'
    assert not Path(captures['stderr']['file']).read_bytes()
    b.unchanged()
    report = dict(kind='phase102-authority-boundary-results', complete=True, passed=True,
        inputsUnchanged=True, targetsRun=False, imageQualified=False, source=prepared['source'],
        api=prepared['api'], apiAcquisition=api_pin, prepared=pp, plan=plan_pin,
        emission=emitted_pin, job=job_pin, jobEvidence=job_evidence,
        originalQualification=old_pin, originalEmission=old_emission_pin,
        rows=[dict(id=x['id'], passed=True, evidence=[emitted_pin, job_pin]) for x in emitted['cases']],
        rawExecutionReuse=dict(currentC=raw['c'], historicalC=old_raw['c'], exactWholeC=True,
            binary=binary, build=b.bind(build['guard']), run=b.bind(run['guard']), captures=captures),
        method=b.bind(__file__), inputs=list(b.rows.values()),
        scope='Fresh final-source API authority and raw-boundary observations. Only exact raw forged-context C reuses its original full 7n execution. Three positive source programs still require final native five-source controls; no whole-image qualification.')
    S.S.save(a.out, report)
    print(S.json.dumps(dict(complete=True, passed=True, source=report['source'], rows=len(report['rows']), report=str(a.out))))


if __name__ == '__main__': main()
