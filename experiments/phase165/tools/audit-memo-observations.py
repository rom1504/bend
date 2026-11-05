#!/usr/bin/env python3
"""Offline semantic gates for retained Phase165 memo receipts. Runs no targets."""
import argparse
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
INPUTS = {}


def read(path):
    path = (ROOT / path).resolve()
    data = path.read_bytes()
    INPUTS[str(path)] = dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())
    return data


def load(path):
    return json.loads(read(path))


def verify(row):
    data = read(row['file'])
    assert len(data) == row['bytes'] and hashlib.sha256(data).hexdigest() == row['sha256'], row['file']
    return data


def tidy(data):
    # Exact upstream gates/test.ts tidy contract: trailing horizontal whitespace,
    # then leading/trailing whitespace around the complete diagnostic.
    return re.sub(rb'[ \t]+$', b'', data, flags=re.M).strip()


def unsafe_names(data):
    lines = data.decode().splitlines()
    assert lines[0] == 'SOME PROOFS FAIL'
    count = re.fullmatch(r'Error: ([0-9]+) defs rely on unsafe or foreign code:', lines[1])
    assert count and all(x.startswith('- ') and len(x) > 2 for x in lines[2:])
    names = [x[2:] for x in lines[2:]]
    assert len(names) == int(count[1]) == len(set(names))
    return names


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    assert not args.out.exists()
    read(Path(__file__).resolve())
    read('gates/test.ts')
    original = load('selfhost/build/phase165/original02/report.json')
    assert original['complete'] and original['original'] and original['exactOriginalC']
    assert verify(original['expectedC']) == verify(original['emission']['stdout'])
    seed = load(original['reusedExactMachineAcquisition']['file'])
    assert seed['complete'] and original['binary'] == seed['binary']
    verify(original['binary'])
    candidate = load('selfhost/build/phase165/memo01/report.json')
    assert candidate['complete'] and not candidate['original']
    verify(candidate['binary'])
    prior = load('selfhost/build/phase162/check-full01/report.json')
    assert prior['complete'] and prior['mode'] == 'check-only' and prior['expect'] == 'unsafe-verdict'
    prior_full = verify(prior['process']['stderr'])
    full_names = unsafe_names(prior_full)
    prior_bad = load('selfhost/build/phase162/bendc-diag-unsafe02/report.json')
    assert prior_bad['complete'] and prior_bad['outputExact']
    unsafe_error = verify(prior_bad['process']['stderr'])
    checks, summaries = [], []
    for suite, count in [('controls', 10), ('checker', 4), ('full', 4)]:
        receipt_path = f'selfhost/build/phase165/memo-{suite}01/report.json'
        receipt = load(receipt_path)
        assert receipt['complete'] and receipt['suite'] == suite and len(receipt['rows']) == count
        for item in receipt['inputs']:
            verify(item)
        role_outputs = {}
        for row in receipt['rows']:
            process = row['process']
            assert not process.get('timedOut') and 'error' not in process and row['exactOracle']
            stdout, stderr = verify(process['stdout']), verify(process['stderr'])
            command = process['command']
            assert command[1:7] == ['--threads', '1', '--gpu', 'off', '--', '--check-only']
            assert read(command[-2]) == verify(prior['base'])
            assert Path(command[-1]).resolve() == (ROOT / row['case']).resolve()
            source = read(row['case'])
            signature = (process['exitCode'], stdout, stderr)
            if row['case'] in role_outputs:
                assert signature == role_outputs[row['case']]
            role_outputs[row['case']] = signature
            gate = dict(suite=suite, case=row['case'], role=row['role'], round=row['round'],
                        exitCode=process['exitCode'], exactBetweenRoles=True)
            if suite == 'controls':
                lines = [x[2:] for x in source.splitlines() if x.startswith(b'#|') and not x.startswith(b'#|exit ')]
                success = row['case'].startswith('selfhost/tests/phase165/')
                expected = b'\n'.join(lines) + b'\n' if lines else unsafe_error
                assert process['exitCode'] == (0 if success else 1)
                actual = stdout if success else stderr
                assert (stderr if success else stdout) == b''
                assert tidy(actual) == tidy(expected)
                gate.update(independentOracle='source #| lines' if lines else 'Phase162 exact unsafe type-error receipt',
                            literalOracleMatch=actual == expected, upstreamTidyOracleMatch=True)
                if actual != expected:
                    assert row['case'] == 'tests/check/beta_ann_lambda.bend'
                    assert actual == expected.replace(b'9 |\n', b'9 | \n')
                    gate['difference'] = 'One trailing space in the blank source-gutter line 9 |; permitted by upstream tidy.'
            else:
                assert process['exitCode'] == 1 and stdout == b''
                names = unsafe_names(stderr)
                if suite == 'full':
                    assert source == verify(prior['source']) and stderr == prior_full
                    gate.update(independentOracle='Phase162 full exact verdict', literalOracleMatch=True, unsafeNames=len(names))
                else:
                    declared = set(re.findall(rb'^(?:def|law|type)\s+([^\s(:]+)', source, re.M))
                    selected = [x for x in full_names if x.encode() in declared]
                    assert set(names) == set(selected) and len(names) == 464
                    gate.update(independentOracle='Phase162 full unsafe-name set restricted to the exact closure source declarations',
                                unsafeNames=len(names), exactIndependentNameSet=True,
                                priorExactSliceByteOracleAvailable=False,
                                scope='Fresh original/variant bytes match exactly; independent name membership is exact, report order follows closure layout.')
            checks.append(gate)
        summaries.append(dict(suite=suite, rows=count, passed=True))
    result = dict(kind='phase165-independent-memo-observation-audit', complete=True, targetsRun=False,
                  inputs=list(INPUTS.values()), acquisitionOriginalCExact=True, summaries=summaries, checks=checks,
                  limitations=['Finite exact observations; not a general memo equivalence theorem.',
                               'No pre-existing exact checker-slice byte oracle was found; the independent full-report name restriction is recorded explicitly.',
                               'Runtime/compilation performance and causal cache-hit attribution are outside this offline audit.'])
    args.out.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(complete=True, checks=len(checks), output=str(args.out))))


if __name__ == '__main__':
    main()
