#!/usr/bin/env python3
"""Freeze link-only guard counter commands; do not execute any target."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]

def pin(path):
    path = path.resolve()
    data = path.read_bytes()
    return {'file': str(path), 'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--machine', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    report_path = a.machine.resolve() / 'report.json'
    report = json.loads(report_path.read_text())
    assert report['complete'] and report['outputExact']
    assert report['runtimePolicy']['bendHeapMutators'] == 1
    links = [r['command'] for r in report['jobs'] if r['label'] == 'link']
    assert len(links) == 1
    link = links[0]
    assert '-no-pie' in link and link[-2] == '-o'
    inputs = [pin(report_path), pin(Path(__file__).resolve())]
    for key in ('object', 'runtime', 'assembly', 'sourceIR', 'expectedStdout'):
        row = report[key]
        got = pin(Path(row['file']))
        assert got == row, (key, got, row)
        inputs.append(got)
    source = Path(__file__).with_name('descendant-guard-counts-v2.c')
    representation = ROOT / 'selfhost/src/runtime/qbe/runtime.c'
    assert '#define RFC_BIT  (1ull << 63)' in representation.read_text()
    assert '#define term_rfc(t) ((bool)(((Term)(t) & RFC_BIT) != 0))' in representation.read_text()
    inputs += [pin(source), pin(Path(link[0])), pin(representation)]
    out = a.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase171') and not out.exists()
    out.mkdir(parents=True)
    run = out / 'execution'
    obj = run / 'counts.o'
    binary = run / 'program'
    commands = [
        [link[0], '-std=c11', '-O2', '-fno-omit-frame-pointer', '-c', str(source), '-o', str(obj)],
        link[:-2] + [str(obj), '-Wl,--wrap=p118_rt_borrow_scalar_safe', '-o', str(binary)],
        [str(binary), '--threads', '1', '--gpu', 'off'],
    ]
    plan = {'kind': 'phase171-guard-counter-plan', 'complete': True, 'targetsRun': False,
        'inputs': inputs, 'commands': commands, 'freshExecutionDirectory': str(run),
        'executionEnvironment': {'P171_GUARD_REPORT': str(run / 'counts.json')},
        'expectedStdout': report['expectedStdout'], 'expectedStderr': '',
        'guard': {'cpu': '3', 'seconds': 30, 'rssMiB': 512, 'diskMiB': 32},
        'interpretation': 'Separate diagnostic only, never timing. Disassemble THIS binary and map each returnAddress to the instruction immediately after a call to __wrap_p118_rt_borrow_scalar_safe. The exact selected wrapper contains two calls: first root guard, then result guard. Require unrecorded=0, unexpected=0, exact stdout and clean stderr. Root declines=root.calls-root.passed; reader declines=root.passed-result.calls; result declines=result.calls-result.passed; promotions=result.passed. Other sites belong to existing helper guards. Unseen mapped sites have zero calls. Validate 0<=result.passed<=result.calls<=root.passed<=root.calls.',
        'representationDiagnostic': 'firstRfc counts RFC_BIT in first operand, failedFirstRfc counts it only on guard result0. No heap/header reads. On the one-root result-guard site, failing RFC distinguishes retained RFC from raw escape; under valid ordinary states count<=1 then means count1, not an observed header count.',
        'scope': 'Same program.o and runtime.o; only link interposition and bounded diagnostic counters. No QBE rewrite, guard change, ownership mutation, new runtime probe or compiler promotion.'}
    (out / 'plan.json').write_text(json.dumps(plan, indent=2) + '\n')
    print(json.dumps({'plan': str(out / 'plan.json'), 'commands': commands}))

if __name__ == '__main__': main()
