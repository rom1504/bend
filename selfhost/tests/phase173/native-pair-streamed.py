#!/usr/bin/env python3
"""Exact-output native timing from authenticated builds; retained QBE is optional.

Run under the existing disk guard. A --ir rebuild additionally needs its original
--ROLE-emission receipt; an interrupted original build remains interrupted.
"""
import argparse
import json
import os
from pathlib import Path
import re
import statistics
import subprocess
import sys
import time

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
from common import pin, verify, require, fresh_output, write_json


class Evidence:
    def __init__(self):
        self.pins = {}

    def add(self, row):
        require(isinstance(row, dict) and isinstance(row.get('file'), str)
                and Path(row['file']).is_absolute()
                and type(row.get('bytes')) is int and row['bytes'] >= 0
                and re.fullmatch('[0-9a-f]{64}', row.get('sha256', '')),
                'Complete absolute artifact pin required')
        row = {k: row[k] for k in ('file', 'bytes', 'sha256')}
        require(row['file'] not in self.pins or self.pins[row['file']] == row,
                'Conflicting artifact identities: ' + row['file'])
        self.pins[row['file']] = row
        return row

    def read(self, path):
        row = self.add(pin(path))
        return json.loads(verify(row).read_text())

    def verify(self):
        for row in self.pins.values():
            verify(row)


def identity(row):
    return {k: row[k] for k in ('bytes', 'sha256')}


def inputs_of(r, evidence):
    require(r.get('kind') == 'bend-native-build' and r.get('version') == 1
            and r.get('target') == 'qbe', 'Maintained QBE build receipt required')
    require(isinstance(r.get('inputs'), list) and r['inputs'], 'Build inputs missing')
    inputs = {p['file']: evidence.add(p) for p in r['inputs']}
    for name in ('native.py', 'request.py', 'assets.py', 'common.py'):
        require(str(ROOT / 'selfhost/tools/build' / name) in inputs,
                'Maintained builder identity missing: ' + name)
    return inputs


def bound(row, inputs, evidence):
    row = evidence.add(row)
    require(inputs.get(row['file']) == row, 'Artifact absent from build inputs: ' + row['file'])
    return row


def emission(r, inputs, evidence):
    require(r.get('sourceIR') is None and r.get('compilerExitCode') == 0
            and r.get('qbeExitCode') == 0, 'Successful complete source emission required')
    for key in ('compilerStderr', 'qbeStderr', 'qbeStdout'):
        require(evidence.add(r.get(key))['bytes'] == 0, 'Unexpected producer/QBE diagnostics')
    request = r.get('request')
    require(isinstance(request, dict) and request.get('kind') == 'bend-build-request-plan'
            and request.get('version') == 1 and request.get('target') == 'qbe'
            and request.get('outputContract') == 'stdout'
            and request.get('command') == r.get('compilerCommand')
            and request.get('host') == r.get('host')
            and request.get('stage') == r.get('stage'), 'Source request binding differs')
    for row in request['inputs']:
        bound(row, inputs, evidence)
    for key in ('source', 'image', 'base'):
        bound(request[key], inputs, evidence)
    if request.get('carrier') is not None:
        bound(request['carrier'], inputs, evidence)
    for provider in request.get('providers', {}).values():
        for row in provider if isinstance(provider, list) else [provider]:
            bound(row, inputs, evidence)
    if r.get('hostedReport'):
        hosted = evidence.read(evidence.add(r['hostedReport'])['file'])
        require(hosted.get('complete') is True, 'Hosted producer incomplete')
    require(r.get('host') != 'js' or r.get('hostedReport'), 'Hosted receipt missing')
    return request


def authenticate(r, origin, evidence):
    inputs = inputs_of(r, evidence)
    require(r.get('complete') is True and r.get('changedInputs') == []
            and not r.get('error') and not r.get('timedOut'), 'Completed unchanged build required')
    digest = r.get('irDigest', {})
    require(type(digest.get('bytes')) is int and digest['bytes'] > 0
            and re.fullmatch('[0-9a-f]{64}', digest.get('sha256', '')),
            'Nonempty complete stream digest required')
    runtime = bound(r['runtime'], inputs, evidence)
    binary = evidence.add(r['binary'])
    require(binary['bytes'] > 0, 'Empty executable')
    tc = r['toolchain']
    require(tc == dict(target='amd64_sysv', assemblerFlags=['-mbranches-within-32B-boundaries'],
                       linkerFlags=['-no-pie'], libraries=['-pthread', '-lm']),
            'Unexpected machine policy')
    jobs = r['jobs']
    labels = [j.get('label') for j in jobs]
    source_ir = r.get('sourceIR')
    prefix = ['qbe'] if source_ir else []
    require(labels in (prefix + ['assemble', 'link'], prefix + ['assemble', 'link', 'execute']),
            'Incomplete/reordered machine construction')
    for job in jobs:
        require(job.get('complete') is True and job.get('exitCode') == 0
                and job.get('timedOut') is False, 'Unsuccessful machine stage')
        evidence.add(job['stdout'])
        stderr = evidence.add(job['stderr'])
        require(job['label'] in ('assemble', 'link') or stderr['bytes'] == 0,
                'Unexpected machine/execution diagnostics')
    stages = {j['label']: j for j in jobs}
    tool_pins = {}
    for name, command in [('qbe', r['qbeCommand']), ('assembler', stages['assemble']['command']),
                          ('linker', stages['link']['command'])]:
        require(command[0] in inputs, 'Unpinned executable: ' + name)
        tool_pins[name] = inputs[command[0]]
    require(r['qbeCommand'] == [tool_pins['qbe']['file'], '-t', tc['target'], '-o',
            r['assembly']['file'], source_ir['file'] if source_ir else '-'], 'QBE command differs')
    require(stages['assemble']['command'] == [tool_pins['assembler']['file'], *tc['assemblerFlags'],
            '-o', r['object']['file'], r['assembly']['file']], 'Assembly binding differs')
    require(stages['link']['command'] == [tool_pins['linker']['file'], *tc['linkerFlags'],
            r['object']['file'], runtime['file'], *tc['libraries'], '-o', binary['file']],
            'Link/runtime binding differs')
    if source_ir:
        bound(source_ir, inputs, evidence)
        require(identity(source_ir) == digest and r.get('request') is None
                and r.get('compilerCommand') is None
                and stages['qbe']['command'] == r['qbeCommand'], 'Supplied IR binding differs')
        require(origin is not None, 'Supplied IR needs original --ROLE-emission receipt')
        require(not origin.get('changedInputs'), 'Original emission inputs changed')
        old_inputs = inputs_of(origin, evidence)
        request = emission(origin, old_inputs, evidence)
        old_ir = evidence.add(origin.get('retainedIR'))
        require(old_ir == source_ir and origin.get('irDigest') == digest,
                'Original emission differs from supplied IR')
        require(origin['runtime'] == runtime and origin['toolchain'] == tc
                and old_inputs.get(origin['qbeCommand'][0]) == tool_pins['qbe'],
                'Original emission runtime/toolchain differs')
    else:
        require(origin is None, 'Unexpected extra emission receipt for source build')
        request = emission(r, inputs, evidence)
    if r.get('retainedIR'):
        require(identity(evidence.add(r['retainedIR'])) == digest, 'Retained IR digest differs')
    if r.get('expectedQbe'):
        expected = bound(r['expectedQbe'], inputs, evidence)
        require(identity(expected) == digest and r.get('comparedToReference') is True,
                'Independent QBE comparison differs')
    return dict(binary=binary, runtime=runtime, toolchain=tc, tools=tool_pins,
                runtimePolicy=r['runtimePolicy'], irDigest=digest,
                retainedIR=source_ir or r.get('retainedIR'),
                source=request['source'], producer=request['image'],
                originalEmissionBuildComplete=origin.get('complete') if origin else r['complete'],
                provenance='Supplied IR rebuild plus original emission' if source_ir else 'Complete source build')


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for role in ('baseline', 'candidate'):
        p.add_argument('--' + role, type=Path, required=True)
        p.add_argument('--' + role + '-emission', type=Path)
    p.add_argument('--expected', type=Path, required=True)
    p.add_argument('--rounds', type=int, choices=[1, 4], default=4)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    evidence = Evidence()
    evidence.add(pin(__file__))
    products = {}
    for role in ('baseline', 'candidate'):
        origin_path = getattr(a, role + '_emission')
        origin = evidence.read(origin_path) if origin_path else None
        products[role] = authenticate(evidence.read(getattr(a, role)), origin, evidence)
    for key in ('runtime', 'runtimePolicy', 'toolchain', 'tools'):
        require(products['baseline'][key] == products['candidate'][key], key + ' differs')
    expected_pin = evidence.add(pin(a.expected))
    evidence.verify()
    expected = verify(expected_pin).read_bytes()
    out = fresh_output(a.out, ROOT)
    env = {k: v for k, v in os.environ.items()
           if not k.startswith('BEND_') and k not in ['BANGS', 'LD_PRELOAD', 'LD_AUDIT']}
    report = dict(kind='phase173-native-product-pair-streamed', version=1, complete=False,
                  inputs=list(evidence.pins.values()), products=products, expected=expected_pin,
                  runs=[], rounds=a.rounds, oracle='Fixed expected bytes; independent origin established separately.',
                  scope='Whole-process finite exact-output timing; not source checking, full conformance, or qualification.',
                  irScope='Stream digest authenticates build receipt; absent QBE text cannot support IR/machine analysis.',
                  intermediateRetention='Assembly/object pins retained in build receipts; hot copies not required here.')
    def save(): write_json(out / 'report.json', report)
    save()
    try:
        for cycle in range(a.rounds):
            for role in (['baseline', 'candidate'] if cycle % 2 == 0 else ['candidate', 'baseline']):
                binary = products[role]['binary']; verify(binary)
                command = [binary['file'], '--threads', '1', '--gpu', 'off']
                start = time.perf_counter()
                result = subprocess.run(command, cwd=ROOT, env=env, capture_output=True, timeout=15)
                seconds = time.perf_counter() - start
                so = out / f'{cycle}-{role}.stdout'; se = out / f'{cycle}-{role}.stderr'
                so.write_bytes(result.stdout); se.write_bytes(result.stderr)
                ok = result.returncode == 0 and not result.stderr and result.stdout == expected
                report['runs'].append(dict(role=role, cycle=cycle, command=command,
                    seconds=seconds, exitCode=result.returncode, stdout=pin(so), stderr=pin(se), outputExact=ok))
                save(); require(ok, 'Native output mismatch: ' + role)
        report['medians'] = {k: statistics.median(x['seconds'] for x in report['runs'] if x['role'] == k)
                             for k in products}
        report['resolved'] = a.rounds == 4 and min(x['seconds'] for x in report['runs']) >= .03
        if report['resolved']:
            report['ratio'] = report['medians']['candidate'] / report['medians']['baseline']
        evidence.verify()
        report['complete'] = True
    except Exception as error:
        report['error'] = repr(error)
    finally:
        save()
        print(json.dumps({k: v for k, v in report.items()
                          if k in ['complete', 'resolved', 'medians', 'ratio', 'error']}))
    return 0 if report['complete'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
