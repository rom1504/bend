#!/usr/bin/env python3
"""Suite-bound provenance checks around unchanged native69 semantics and collection."""
import argparse
import json
from pathlib import Path
import subprocess
import sys
from support import Bindings, HERE, ROOT, PERF, S, bounded_exit, pin, read


HARNESS = ['run.mjs', 'worker.mjs', 'inventory.mjs', 'judge.mjs', 'selection.mjs',
           'run-probe.mjs', 'persistent-probe.mjs', 'replay.mjs']


def execution_inputs(plan, stage, bindings):
    producer = plan['roles'][stage]['producer']; assets = plan['executionAssets']
    values = [producer['binary'], producer['source'], assets['base'], assets['runtime'], assets['template'],
              *assets['parts'], *assets['effects'], assets['cache']['carrier'], plan['adapter'], plan['diagnosticsMethod'],
              plan['selection'], ROOT / 'selfhost/src/compiler.json']
    values.extend(ROOT / 'selfhost/tools/conformance' / name for name in HARNESS)
    values.extend(row['source'] for row in plan['eligible'] + plan['negatives'])
    pins = {bindings.bind(value)['file']:bindings.bind(value) for value in values}
    return [pins[file] for file in sorted(pins)]


def validate_partition(plan, bindings):
    assert plan['phase98'] and plan['provenancePolicy'] == 'full-before-after-suite-and-admission'
    assert len(plan['eligible']) == 69 and len(plan['excluded']) == 31 and len(plan['negatives']) == 3
    original_adapter = bindings.bind(plan['adapterParent']); original_diagnostics = bindings.bind(plan['diagnosticsParent'])
    assert original_adapter['file'] == str(PERF / 'phase92/conformance/adapter.mjs')
    assert original_diagnostics['file'] == str(PERF / 'phase92/conformance/diagnostics.mjs')
    text = Path(original_adapter['file']).read_text(); assert text.count('plan.inputs') == 3
    text = text.replace('const selected=plan.roles[role];',
        'const selected=plan.roles[role];\nconst executionInputs=plan.executionInputs[role];\nassert.ok(Array.isArray(executionInputs)&&executionInputs.length>0);', 1).replace('plan.inputs', 'executionInputs')
    assert Path(bindings.bind(plan['adapter'])['file']).read_text() == text
    text = Path(original_diagnostics['file']).read_text()
    assert text.count("'./adapter.mjs?diagnosticRole='") == 1
    assert Path(bindings.bind(plan['diagnosticsMethod'])['file']).read_text() == text.replace("'./adapter.mjs?diagnosticRole='", "'./conformance-adapter.mjs?diagnosticRole='")
    expected = {}
    for stage in ['b1', 'b2']:
        required = execution_inputs(plan, stage, bindings)
        assert plan['executionInputs'][stage] == required
        expected.update((row['file'], row) for row in required)
    assert plan['inputs'] == [expected[file] for file in sorted(expected)]
    provenance = {row['file']:row for row in plan['provenanceInputs']}
    assert all(provenance[row['file']] == row for row in plan['inputs'])
    for row in plan['provenanceInputs']: bindings.bind(row)
    return True


def validate_suite(plan_pin, plan, role, bindings):
    directory = Path(plan_pin['file']).parent
    receipt_pin = bindings.bind(directory / (role + '-integrity.json')); receipt = read(receipt_pin['file'])
    assert receipt['kind'] == 'phase98-conformance-suite-integrity' and receipt['complete'] and receipt['passed']
    assert receipt['plan'] == plan_pin and receipt['role'] == role
    assert receipt['beforeInputsExact'] and receipt['afterInputsExact'] and receipt['inputsUnchanged']
    assert receipt['provenanceInputs'] == plan['provenanceInputs']
    command = next(job['command'] for job in plan['suiteCommands'] if job['role'] == role)
    assert receipt['command'] == command and receipt['launcherExit'] == 0
    guard_pin = bindings.bind(receipt['guard']); process = read(guard_pin['file'])
    assert guard_pin['file'] == str(directory / (role + '-guard/process.json'))
    assert process == receipt['process'] and bounded_exit(process, 0)
    at = command.index('--'); target = command[at + 1:]
    assert process['command'][-len(target):] == target
    assert process['rssLimitBytes'] == 2048 * 1024**2 and process['availableFloorBytes'] == 4096 * 1024**2
    for row in receipt['captures']: bindings.bind(row)
    bindings.bind(receipt['method'])
    assert receipt['method'] == plan['integrityMethod']
    return receipt_pin


def run(a):
    b = Bindings(); plan_pin = b.bind(a.plan); plan = read(plan_pin['file'])
    assert plan['integrityMethod'] == b.bind(__file__)
    directory = Path(plan_pin['file']).parent; output = directory / (a.role + '-integrity.json')
    assert not output.exists() and not (directory / (a.role + '-guard')).exists()
    command = next(job['command'] for job in plan['suiteCommands'] if job['role'] == a.role)
    receipt = dict(kind='phase98-conformance-suite-integrity', complete=False, passed=False, plan=plan_pin,
        role=a.role, command=command, method=pin(__file__), provenanceInputs=plan['provenanceInputs'],
        beforeInputsExact=False, afterInputsExact=False, inputsUnchanged=False)
    S.save(output, receipt)
    try:
        validate_partition(plan, b); receipt['beforeInputsExact'] = True; S.save(output, receipt)
        job = subprocess.run(command, cwd=ROOT, capture_output=True, text=True)
        stdout, stderr = directory / (a.role + '-launcher.stdout'), directory / (a.role + '-launcher.stderr')
        stdout.write_text(job.stdout); stderr.write_text(job.stderr)
        receipt.update(launcherExit=job.returncode, captures=[b.bind(stdout), b.bind(stderr)])
        receipt['guard'] = b.bind(directory / (a.role + '-guard/process.json'))
        receipt['process'] = read(receipt['guard']['file'])
        b.unchanged(); receipt.update(afterInputsExact=True, inputsUnchanged=True)
        assert job.returncode == 0 and bounded_exit(receipt['process'], 0), 'Suite guard failed; retained without qualification'
        receipt.update(complete=True, passed=True)
    except BaseException as error:
        receipt['error'] = repr(error); raise
    finally: S.save(output, receipt)
    print(json.dumps(dict(complete=True, passed=True, role=a.role, receipt=str(output))))


def collect(a):
    assert not a.out.exists(); b = Bindings(); plan_pin = b.bind(a.plan); plan = read(plan_pin['file'])
    assert plan['integrityMethod'] == b.bind(__file__); validate_partition(plan, b)
    suites = {role:validate_suite(plan_pin, plan, role, b) for role in ['b1', 'b2', 'diagnostics']}
    old_collector = b.bind(plan['semanticCollector']); directory = Path(plan_pin['file']).parent
    semantic = directory / 'semantic-results.json'; assert not semantic.exists()
    command = [sys.executable, '-B', old_collector['file'], '--plan', plan_pin['file'], '--out', str(semantic)]
    result = subprocess.run(command, cwd=ROOT, capture_output=True, text=True)
    (directory / 'semantic-collect.stdout').write_text(result.stdout); (directory / 'semantic-collect.stderr').write_text(result.stderr)
    assert result.returncode == 0, result.stderr
    semantic_pin = b.bind(semantic); report = read(semantic)
    assert report['kind'] == 'phase92-native-conformance-results' and report['complete'] and report['passed'] and report['inputsUnchanged']
    assert report['plan'] == plan_pin
    b.unchanged(); report.update(method=pin(__file__), semanticReport=semantic_pin, provenanceSuites=suites,
        fullProvenanceRechecked=True, inputs=list(b.rows.values()),
        integrityScope='Full source/build/history/toolchain provenance checked before and after each suite and again by collector/admission; each isolated case verifies only selected runtime/source/method/fixture inputs. Same original69 golden judge and six exact rejections.')
    a.out.parent.mkdir(parents=True, exist_ok=True)
    with a.out.open('x') as stream: json.dump(report, stream, indent=2); stream.write('\n')
    print(json.dumps(dict(complete=True, passed=True, report=str(a.out), fullProvenanceRechecked=True)))


def main():
    p = argparse.ArgumentParser(description=__doc__); sub = p.add_subparsers(dest='mode', required=True)
    q = sub.add_parser('run'); q.add_argument('--plan', type=Path, required=True); q.add_argument('--role', choices=['b1', 'b2', 'diagnostics'], required=True)
    q = sub.add_parser('collect'); q.add_argument('--plan', type=Path, required=True); q.add_argument('--out', type=Path, required=True)
    a = p.parse_args(); (run if a.mode == 'run' else collect)(a)


if __name__ == '__main__': main()
