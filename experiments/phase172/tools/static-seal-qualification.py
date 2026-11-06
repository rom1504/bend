#!/usr/bin/env python3
"""Relink qualified Phase170 objects and check literal positive-case outputs.

Host orchestration only: no Bend source compilation or QBE build. Run under one
outer disk/resource guard. --plan-only authenticates inputs without running any
linker or generated program. The three frontend-refusal cases are never run.
"""
import argparse
import json
import os
from pathlib import Path
import statistics
import sys
import time

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
from common import (clean_environment, fresh_output, pin, require, run,
                    verify, write_json, changed_inputs)

DEFAULT_CASES = ['focused/pure-string', 'focused/pure-aggregate',
                 'focused/arrays-io', 'focused/higher-order-capture',
                 'focused/non-tail-list', 'broad/coverage-closures-64']
QUALIFICATION = ROOT / 'selfhost/build/phase170/qbe64-final/report.json'
CATALOG = ROOT / 'selfhost/tools/conformance/qualification-catalog.json'
BUILD = ROOT / 'selfhost/build/phase172/static-seal-runtime-build01/report.json'


def same_identity(left, right):
    return all(left[key] == right[key] for key in ('bytes', 'sha256'))


def load(path):
    return json.loads(Path(path).read_text())


def prepare(args):
    inputs = {}

    def authentic(row):
        path = str(Path(row['file']).resolve())
        canonical = dict(row, file=path)
        if path in inputs:
            require(same_identity(inputs[path], canonical), 'Conflicting input identity: ' + path)
        else:
            verify(canonical)
            inputs[path] = canonical
        return canonical

    def current(path):
        return authentic(pin(path))

    current(__file__)
    current(ROOT / 'selfhost/tools/build/common.py')
    qualification_pin = current(QUALIFICATION)
    qualification = load(QUALIFICATION)
    require(qualification.get('complete') is True and qualification.get('passed') is True
            and qualification['kind'] == 'bend-finite-qualification'
            and qualification['host'] == 'native' and qualification['target'] == 'qbe'
            and qualification['stage'] == 'N2', 'Expected passed Phase170 N2 QBE qualification')
    catalog_pin = next(row for row in qualification['inputs']
                       if Path(row['file']).resolve() == CATALOG.resolve())
    authentic(catalog_pin)
    catalog = load(CATALOG)
    require(catalog['upstream'] == qualification['upstream'], 'Catalog upstream mismatch')
    definitions = {row['id']: row for row in catalog['cases']}
    require(len(definitions) == len(catalog['cases']), 'Duplicate catalog case')
    qualified = {row['id']: row for row in qualification['rows']}
    require(len(qualified) == 64 and len(qualified) == len(qualification['rows']),
            'Unexpected qualified case inventory')
    positive = [row['id'] for row in qualification['rows']
                if row['expected']['stage'] == 'execute' and row['expected']['exitCode'] == 0]
    require(len(positive) == 61, 'Expected exactly 61 positive execution cases')
    selected = positive if args.all_positive else (args.case or DEFAULT_CASES)
    require(len(selected) == len(set(selected)), 'Repeated case identity')
    require(all(name in positive for name in selected), 'Only qualified successful cases are allowed')
    runtime_receipt = current(BUILD)
    runtime_build = load(BUILD)
    require(runtime_build['kind'] == 'phase172-static-seal-runtime-build'
            and runtime_build.get('complete') is True, 'Incomplete private runtime build')
    require([r['label'] for r in runtime_build['variants']] == ['baseline', 'static-seal'],
            'Unexpected runtime pair')
    require(any(row['name'] == 'disabled-equals-installed-runtime' and row['passed']
                for row in runtime_build['checks']), 'Missing installed-runtime identity gate')
    for row in runtime_build['inputs']:
        authentic(row)
    compiler = authentic(runtime_build['compiler'])
    variants = [dict(label=row['label'], runtime=authentic(row['object']))
                for row in runtime_build['variants']]
    cases = []
    for name in selected:
        row = qualified[name]
        item = definitions[name]
        require(row['status'] == 'pass' and row['expected'] == item['expect'],
                'Qualified/catalog expectation differs: ' + name)
        source = authentic(row['source'])
        catalog_source = dict(item['source'], file=str((ROOT / item['source']['file']).resolve()))
        require(source == catalog_source, 'Catalog source identity differs: ' + name)
        emission_pin = authentic(row['emission'])
        build_pin = authentic(row['build'])
        emission = load(emission_pin['file'])
        build = load(build_pin['file'])
        require(emission['kind'] == 'bend-build-request' and emission.get('complete') is True
                and emission['target'] == 'qbe' and emission['source'] == source
                and not emission.get('changedInputs'), 'Unqualified emission: ' + name)
        require(build['kind'] == 'bend-native-build' and build.get('complete') is True
                and build['target'] == 'qbe' and build.get('outputExact') is True
                and not build.get('changedInputs'), 'Unqualified machine product: ' + name)
        ir = authentic(build['sourceIR'])
        require(same_identity(ir, emission['product']) and
                same_identity(ir, build['irDigest']), 'Emission/build IR mismatch: ' + name)
        obj = authentic(build['object'])
        require(same_identity(build['runtime'], variants[0]['runtime']),
                'Original build used a different runtime: ' + name)
        require(build['toolchain'] == {
            'target': 'amd64_sysv', 'assemblerFlags': ['-mbranches-within-32B-boundaries'],
            'linkerFlags': ['-no-pie'], 'libraries': ['-pthread', '-lm']},
            'Unexpected original machine flags: ' + name)
        require(any(Path(p['file']).resolve() == Path(compiler['file']).resolve()
                    and same_identity(p, compiler) for p in build['inputs']),
                'Original linker identity differs: ' + name)
        literal = dict(item['expect'])
        require(isinstance(literal['stdout'], str) and isinstance(literal['stderr'], str),
                'Exact literal outputs required: ' + name)
        cases.append(dict(id=name, source=source, expected=literal,
                          emissionReceipt=emission_pin, buildReceipt=build_pin,
                          programIR=ir, programObject=obj))
    return dict(kind='phase172-static-seal-qualified-relinks', version=1,
                complete=False, passed=False, targetsRun=False, planOnly=args.plan_only,
                inputs=list(inputs.values()), qualification=qualification_pin,
                catalog=authentic(catalog_pin), runtimeBuild=runtime_receipt,
                compiler=compiler, variants=variants, cases=cases,
                selected=selected, availablePositiveCases=61, omittedFrontendRefusals=3,
                rounds=args.rounds, secondsPerProcess=args.seconds, rows=[],
                cpuAffinity=sorted(os.sched_getaffinity(0)),
                historicalInputs='Retained qualification/emission/build receipts authenticate original provenance. Historical mutable manifests are not rebound or re-executed.',
                scope='Successful ordinary Bend programs only; same retained program IR/object, private runtime relink pair, exact catalog stdout/stderr/exit. No QBE build, malformed runtime probes or production changes.',
                timingScope='Finite correctness gate; short-process timings include startup and are not representative program-performance claims.')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    selection = parser.add_mutually_exclusive_group()
    selection.add_argument('--case', action='append', help='Repeat for explicit catalog IDs')
    selection.add_argument('--all-positive', action='store_true')
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--rounds', type=int, default=1)
    parser.add_argument('--seconds', type=float, default=60)
    parser.add_argument('--plan-only', action='store_true')
    args = parser.parse_args()
    require(1 <= args.rounds <= 9 and 0 < args.seconds <= 120, 'Bounded rounds/time required')
    clean_environment()
    started = time.monotonic()
    report = prepare(args)
    if not args.plan_only:
        require(report['cpuAffinity'] == [3], 'Run in the sole outer CPU3 lane')
    out = fresh_output(args.out, ROOT)
    try:
        if args.plan_only:
            report.update(complete=True, passed=None)
        else:
            for index, case in enumerate(report['cases']):
                case_out = out / ('%02d-%s' % (index, case['id'].replace('/', '-')))
                case_out.mkdir()
                row = dict(id=case['id'], expected=case['expected'], complete=False,
                           passed=False, links=[], executions=[])
                report['rows'].append(row)
                for variant in report['variants']:
                    label = variant['label']
                    binary = case_out / label
                    command = [report['compiler']['file'], '-no-pie', case['programObject']['file'],
                               variant['runtime']['file'], '-pthread', '-lm', '-o', str(binary)]
                    job = run(command, cwd=ROOT, stdout=case_out / (label + '.link.stdout'),
                              stderr=case_out / (label + '.link.stderr'), seconds=args.seconds)
                    report['targetsRun'] = True
                    link = dict(label=label, runtime=variant['runtime'], job=job)
                    row['links'].append(link)
                    write_json(case_out / 'report.json', row)
                    write_json(out / 'report.json', report)
                    require(job['complete'], 'Link failed: ' + case['id'] + '/' + label)
                    link['binary'] = pin(binary)
                for round_index in range(args.rounds):
                    order = row['links'] if (index + round_index) % 2 == 0 else row['links'][::-1]
                    for link in order:
                        label = link['label']
                        prefix = '%02d-%s' % (round_index, label)
                        job = run([link['binary']['file'], '--threads', '1', '--gpu', 'off'],
                                  cwd=ROOT, stdout=case_out / (prefix + '.stdout'),
                                  stderr=case_out / (prefix + '.stderr'), seconds=args.seconds)
                        expected = case['expected']
                        exact = (job['complete'] and job['exitCode'] == expected['exitCode']
                                 and Path(job['stdout']['file']).read_bytes() == expected['stdout'].encode()
                                 and Path(job['stderr']['file']).read_bytes() == expected['stderr'].encode())
                        row['executions'].append(dict(label=label, round=round_index,
                                                      job=job, exact=exact))
                        write_json(case_out / 'report.json', row)
                        write_json(out / 'report.json', report)
                        require(exact, 'Literal output mismatch: ' + case['id'] + '/' + label)
                row.update(complete=True, passed=True,
                           medianSeconds={label: statistics.median(
                               runrow['job']['seconds'] for runrow in row['executions']
                               if runrow['label'] == label) for label in ['baseline', 'static-seal']})
                write_json(case_out / 'report.json', row)
                write_json(out / 'report.json', report)
            report.update(complete=True, passed=True)
        report['changedInputs'] = changed_inputs(report['inputs'])
        require(not report['changedInputs'], 'Pinned input changed during campaign')
    except BaseException as error:
        report.update(complete=False, passed=False, error=repr(error))
        raise
    finally:
        report['wallSeconds'] = time.monotonic() - started
        report['counts'] = dict(selected=len(report['selected']),
                               passed=sum(row['passed'] for row in report['rows']))
        report['totalLinkSeconds'] = sum(link['job']['seconds'] for row in report['rows']
                                         for link in row['links'])
        report['totalExecutionSeconds'] = sum(execution['job']['seconds'] for row in report['rows']
                                              for execution in row['executions'])
        write_json(out / 'report.json', report)
        print(json.dumps(dict(report=str(out / 'report.json'), complete=report['complete'],
                              passed=report['passed'], counts=report['counts'],
                              targetsRun=report['targetsRun'])))


if __name__ == '__main__':
    main()
