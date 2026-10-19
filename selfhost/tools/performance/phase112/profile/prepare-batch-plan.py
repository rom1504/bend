#!/usr/bin/env python3
"""Freeze a six-object diagnostic plan from an already qualified product binding."""
import argparse
import datetime
import json
from pathlib import Path
from prepare import ROOT, HERE
from parse import pin
from run import read, verify


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--binding', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    if a.out.exists():
        raise SystemExit('fresh plan path required')
    binding = read(a.binding)
    manifest_path = HERE.parent / 'benchmark/manifest01.json'
    manifest = read(manifest_path)
    if (binding.get('kind') != 'phase112-matched-product-binding' or not binding.get('complete') or
            not binding.get('fullFrozenQualified') or binding['manifest'] != pin(manifest_path) or
            len(manifest['cases']) != 6 or set(binding['products']) != {c['name'] for c in manifest['cases']}):
        raise SystemExit('complete exact six-program binding required')
    cases, inputs = [], [pin(Path(__file__)), pin(a.binding), pin(manifest_path), manifest['directToolchain']['linker']]
    for case in manifest['cases']:
        product = binding['products'][case['name']]
        build_path = verify(product['build'])
        built = read(build_path)
        if not built.get('complete') or built.get('perProgramC') or built.get('cproc'):
            raise SystemExit('completed direct-QBE object required')
        commands = [j['command'] for label in ['qbe', 'assemble', 'link'] for j in built['jobs'] if j['label'] == label]
        if commands != product['buildCommands'] or len(commands) != 3:
            raise SystemExit('binding/build command mismatch')
        if commands[1][2] != built['object']['file'] or commands[0][-1] != product['qbe']['file']:
            raise SystemExit('object/QBE provenance mismatch')
        row = dict(name=case['name'], object=built['object'], qbe=product['qbe'], build=product['build'],
                   emission=product['emission'], source=case['source'], oracle=case['expectedStdoutEvidence'],
                   runtimeArgs=case['runtimeArgs'], repetitions=1, warmups=0,
                   expected=dict(kind='phase112-diagnostic-batch-output', status=0,
                       stdoutPrefix=case['expectedStdout'] + '0\n1\n', stderr='',
                       suffixRule='unsigned-decimal-milliseconds-newline'))
        if verify(row['oracle']).read_bytes() != case['expectedStdout'].encode():
            raise SystemExit('independent full expected output differs from manifest')
        cases.append(row)
        inputs += [row[k] for k in ['object', 'qbe', 'build', 'emission', 'source', 'oracle']]
    for record in inputs:
        verify(record)
    plan = dict(kind='phase112-frozen-diagnostic-batch', version=1,
                createdUTC=datetime.datetime.now(datetime.timezone.utc).isoformat(), targetsRun=False,
                role=binding['label'], binding=pin(a.binding), benchmarkManifest=pin(manifest_path),
                compiler=manifest['directToolchain']['linker'], cases=cases, inputs=inputs,
                derivation='Exact independent benchmark outputs and input arguments; counts chosen1/0 before profiling. '
                           'Existing object pins come from the completed direct-QBE build receipts.',
                scope='Whole-process diagnostic counts only, including two workload evaluations plus wrapper/setup. '
                      'This new plan never replaces batch-plan01 or changes timing benchmark definitions.')
    a.out.parent.mkdir(parents=True, exist_ok=True)
    a.out.write_text(json.dumps(plan, indent=2) + '\n')
    print(json.dumps(dict(complete=True, targetsRun=False, role=binding['label'], plan=pin(a.out), inputs=len(inputs))))


if __name__ == '__main__':
    main()
