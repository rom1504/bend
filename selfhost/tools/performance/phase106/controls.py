#!/usr/bin/env python3
"""Finite differential controls, run as one serial resource-guarded job.

Batching the subprocess checks avoids restarting the resource supervisor for
each tiny case. No timings from this diagnostic batch are performance results.
"""
import argparse
import copy
import importlib.util
import json
import subprocess
import sys
import time
from pathlib import Path

sys.dont_write_bytecode = True
sys.setrecursionlimit(10000)
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
from campaign import ROOT, WORKLOADS, expected, pin, read, save, MASK
from reference import Interpreter


def classification(code):
    return int(65 <= code <= 90 or 97 <= code <= 122 or 48 <= code <= 57 or code in (95, 46))


def space(code):
    return int(code == 32 or 9 <= code <= 13)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--artifacts', type=Path, required=True)
    p.add_argument('--adapter', type=Path, required=True)
    p.add_argument('--producer', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args(); out = a.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase106') and not out.exists()
    out.mkdir(parents=True)
    artifacts = read(a.artifacts)
    assert artifacts['complete']
    def check_artifacts():
        for product in artifacts['products'].values():
            for policy in product.values():
                for mode in policy.values():
                    assert pin(mode['artifact']['file']) == mode['artifact']
    check_artifacts()
    report = dict(complete=False, passed=False, started=time.time(), jobs=[],
                  interpreter=[], source=pin(a.artifacts), adapter=pin(a.adapter),
                  producer=pin(a.producer), method=pin(__file__), reference=pin(HERE / 'reference.py'),
                  campaign=pin(HERE / 'campaign.py'),
                  cases=pin(HERE / 'laws/cases.json'), harness=pin(HERE / 'cranelift/runner.c'),
                  scope='Finite independent-result/model/differential controls. No performance or '
                  'whole-compiler/memory-safety proof claim.')
    def checkpoint(): save(out / 'report.json', report)
    def run(label, argv, code=0, output=None):
        command = list(map(str, argv))
        started = time.monotonic()
        r = subprocess.run(command, cwd=ROOT, capture_output=True, text=True, timeout=30)
        row = dict(label=label, command=command, returncode=r.returncode,
                   stdout=r.stdout, stderr=r.stderr, seconds=time.monotonic() - started)
        report['jobs'].append(row)
        if r.returncode != code or (output is not None and r.stdout != output):
            checkpoint()
            raise AssertionError(row)
        return r
    checkpoint()
    try:
        selected = read(ROOT / 'selfhost/build/phase105/self-prepared01/report.json')
        build = read(selected['stages']['b2']['build']['file'])
        clang = build['clang']['file']
        assert pin(clang) == build['clang']
        cc = [clang, '-isystem', Path(clang).parents[1] / 'include/clang',
              '-std=c11', '-march=native', '-fPIC']
        runner = out / 'runner.o'
        run('runner-build', [*cc, '-O2', '-c', HERE / 'cranelift/runner.c', '-o', runner])
        cases = {}
        for name in WORKLOADS:
            values = [(0, 0), (1, 1), (7, 17), (3, MASK), (11, 0x80000000)]
            cases[name] = [(list(args), expected(name, *args)) for args in values]
        bridge = read(HERE / 'laws/cases.json')['cases']
        cases['law_bridge'] = [([i + offset, 0], item['expected'])
                              for offset in [0, 30] for i, item in enumerate(bridge)]
        operations = {'add': lambda a, b: (a + b) & MASK,
                      'sub': lambda a, b: (a - b) & MASK,
                      'mul': lambda a, b: (a * b) & MASK,
                      'and': lambda a, b: a & b, 'or': lambda a, b: a | b,
                      'xor': lambda a, b: a ^ b,
                      'eq': lambda a, b: int(a == b), 'ult': lambda a, b: int(a < b)}
        for seed in [17, 0x80000000, MASK]:
            cases['law_bridge'].extend(([i + 30, seed], operations[item['op']](item['a'] ^ seed, item['b'] ^ seed))
                                      for i, item in enumerate(bridge))
        scalars = [*range(256), 256, 65535, 65536, 0x80000000, MASK]
        cases['classify'] = [([n, MASK], classification(n) + 2 * space(n)
                             + 4 * classification(MASK) + 8 * space(MASK)) for n in scalars]
        cases['classify'] += [([n, seed], classification(n & MASK) + 2 * space(n & MASK)
                              + 4 * classification(seed & MASK) + 8 * space(seed & MASK))
                             for n, seed in [(2**32 + 65, 0), (2**32 + 9, 2**32 + 95),
                                             (2**64 - 1, 2**64 - 1)]]
        cases['shift'] = [([n, seed], (((seed << (n & 31)) & MASK) ^ (seed >> (n & 31))))
                          for n in [0, 1, 5, 13, 17, 31, 32, 33, 63, 64, MASK]
                          for seed in [0, 1, 0x80000000, MASK]]
        report['controlInputs'] = cases
        checkpoint()
        for name, values in cases.items():
            for policy in ['raw', 'fold']:
                product = artifacts['products'][name][policy]
                program = read(product['json']['artifact']['file'])
                if name == 'law_bridge':
                    literal = program['functions'][0]['body'][0]['then']
                    for item in bridge:
                        branch = literal[0]
                        expression = branch['then'][0]['value']
                        if policy == 'fold':
                            assert expression == dict(kind='const', type='u32', value=item['expected'])
                        else:
                            assert expression['kind'] == 'bin' and expression['op'] == item['op']
                        literal = branch['else']
                for args, answer in values:
                    observed = Interpreter(program).run(args)
                    assert observed['value'] == answer, (name, policy, args, observed, answer)
                    report['interpreter'].append(dict(workload=name, policy=policy,
                                                      args=args, expected=answer, **observed))
                for backend in ['c', 'cl']:
                    label = f'{name}-{policy}-{backend}'
                    obj, binary = out / (label + '.o'), out / label
                    if backend == 'c':
                        run(label + '-compile', [*cc, '-O2', '-c', product['c']['artifact']['file'], '-o', obj])
                    else:
                        run(label + '-compile', [a.adapter.resolve(), product['json']['artifact']['file'], obj, 'speed'])
                    run(label + '-link', [*cc, '-no-pie', runner, obj, '-o', binary])
                    for index, (args, answer) in enumerate(values):
                        run(label + f'-case{index}', [binary, '--expect', answer, *args], output=str(answer) + '\n')
                    # Wrong expected values must fail despite any checksum coincidence.
                    args, answer = values[-1]
                    run(label + '-bad-expected', [binary, '--repeat', 2, '--expect', answer ^ 0x80000000, *args], code=1)
                checkpoint()
        rejected = ['bad_var', 'bad_call', 'bad_type', 'bad_effect', 'bad_return', 'bad_operator', 'bad_duplicate', 'bad_identifier']
        for name in rejected:
            r = run(name, [a.producer.resolve(), 'verify', name, 'raw'], code=3)
            assert 'IR verifier refused' in r.stderr + r.stdout
        # Consumer rejects malformed transport independently of the Bend producer.
        base = read(artifacts['products']['tail']['fold']['json']['artifact']['file'])
        mutants = {}
        changed = copy.deepcopy(base); changed['version'] = 999; mutants['version'] = changed
        changed = copy.deepcopy(base); changed['unexpected'] = True; mutants['unknown-field'] = changed
        changed = copy.deepcopy(base); changed['functions'][0]['params'][0]['type'] = 'f32'; mutants['unknown-type'] = changed
        changed = copy.deepcopy(base); changed['functions'][0]['body'][0] = {'kind': 'fork'}; mutants['unsupported-fork'] = changed
        changed = copy.deepcopy(base); changed['functions'][0]['locals'].append(changed['functions'][0]['params'][0]); mutants['duplicate-local'] = changed
        for name, program in mutants.items():
            file = out / (name + '.json'); save(file, program)
            r = run(name, [a.adapter.resolve(), file, out / (name + '.o'), 'speed'], code=2)
            assert r.stderr.startswith('phase106 Cranelift: ')
        # Model controls demonstrate its memory checks are operative.
        def const(n): return dict(kind='const', type='u32', value=n)
        def var(n): return dict(kind='var', name=n)
        memory = dict(version=1, entry='main', functions=[dict(name='main', params=[], result='u32',
            locals=[dict(name='p', type='ptr'), dict(name='x', type='u32')], body=[
                dict(kind='set', name='p', value=dict(kind='alloc', bytes=const(4))),
                dict(kind='free', ptr=var('p')), dict(kind='return', value=const(0))])])
        assert Interpreter(memory).run([])['value'] == 0
        memory_mutants = {}
        changed = copy.deepcopy(memory); changed['functions'][0]['body'].pop(1); memory_mutants['leak'] = changed
        changed = copy.deepcopy(memory); changed['functions'][0]['body'].insert(2, dict(kind='free', ptr=var('p'))); memory_mutants['double-free'] = changed
        changed = copy.deepcopy(memory); changed['functions'][0]['body'].insert(2, dict(kind='set', name='x', value=dict(kind='load', type='u32', ptr=var('p'), offset=0))); memory_mutants['use-after-free'] = changed
        changed = copy.deepcopy(memory); changed['functions'][0]['body'].insert(1, dict(kind='set', name='x', value=dict(kind='load', type='u32', ptr=var('p'), offset=4))); memory_mutants['bounds'] = changed
        report['memoryModelRejections'] = []
        for name, program in memory_mutants.items():
            try: Interpreter(program).run([])
            except AssertionError as error:
                report['memoryModelRejections'].append(dict(name=name, diagnostic=str(error)))
            else: raise AssertionError(('memory model accepted mutant', name))
        for key in ['source', 'adapter', 'producer', 'method', 'reference', 'campaign', 'cases', 'harness']:
            assert pin(report[key]['file']) == report[key]
        check_artifacts()
        report.update(complete=True, passed=True, inputsUnchanged=True)
    finally:
        report['finished'] = time.time()
        checkpoint()
    print(json.dumps(dict(complete=report['complete'], jobs=len(report['jobs']),
                         interpretedCases=len(report['interpreter']))))


if __name__ == '__main__':
    main()
