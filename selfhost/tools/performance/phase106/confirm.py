#!/usr/bin/env python3
"""Fresh, bounded confirmation of the already selected training-only k=1 policy.

This does not search policies. Build once per workload/configuration/round and
reuse that executable for two new input sizes, with the original campaign ABI.
"""
import argparse
import json
import random
import statistics
import sys
import time
from pathlib import Path

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
from campaign import CASES as TRAINING_CASES, CONFIGS, MASK, ROOT, Jobs, expected, pin, read, save


CASES = {
    'text': dict(group='train', sizes=[100000, 400000], seed=7, repeat=100),
    'list': dict(group='train', sizes=[1024, 4096], seed=17, repeat=200),
    'tree': dict(group='heldout', sizes=[9, 12], seed=23, repeat=100),
    'closure': dict(group='heldout', sizes=[50000, 200000], seed=31, repeat=100),
}
ROUNDS = 3
SEED = 10620261019


def authenticate(value):
    assert pin(value['file']) == value, ('input changed', value['file'])
    return Path(value['file'])


def summarize(rows, configs, winner):
    table = {}
    for name, case in CASES.items():
        table[name] = {}
        for label, _, _ in configs:
            selected = [r for r in rows if r['workload'] == name and r['config'] == label]
            assert sorted(r['round'] for r in selected) == list(range(ROUNDS))
            metrics = {}
            for key in ['emissionSeconds', 'compileSeconds', 'linkSeconds']:
                values = [r[key] for r in selected]
                metrics[key] = dict(median=statistics.median(values), min=min(values), max=max(values))
            metrics['sizes'] = {}
            for n in case['sizes']:
                values = [r['executions'][str(n)]['executeSeconds'] for r in selected]
                timing = dict(median=statistics.median(values), min=min(values), max=max(values))
                values = [r['executions'][str(n)]['oneShotExecuteSeconds'] for r in selected]
                one_shot = dict(median=statistics.median(values), min=min(values), max=max(values))
                metrics['sizes'][str(n)] = dict(executeSeconds=timing,
                    oneShotExecuteSeconds=one_shot,
                    k1CostSeconds=sum(metrics[k]['median'] for k in
                                      ['emissionSeconds', 'compileSeconds', 'linkSeconds']) + timing['median'],
                    oneShotK1CostSeconds=sum(metrics[k]['median'] for k in
                                      ['emissionSeconds', 'compileSeconds', 'linkSeconds']) + one_shot['median'])
            metrics['reusedBuildCostSeconds'] = (
                sum(metrics[k]['median'] for k in ['emissionSeconds', 'compileSeconds', 'linkSeconds'])
                + sum(v['executeSeconds']['median'] for v in metrics['sizes'].values()))
            table[name][label] = metrics
    groups = {}
    for group in ['train', 'heldout']:
        names = [name for name, case in CASES.items() if case['group'] == group]
        values = {}
        for label in ['c-o2', winner]:
            values[label] = dict(
                k1CostSeconds=sum(s['k1CostSeconds'] for name in names
                                  for s in table[name][label]['sizes'].values()),
                reusedBuildCostSeconds=sum(table[name][label]['reusedBuildCostSeconds'] for name in names),
                executionSeconds=sum(s['executeSeconds']['median'] for name in names
                                     for s in table[name][label]['sizes'].values()),
                oneShotK1CostSeconds=sum(s['oneShotK1CostSeconds'] for name in names
                                        for s in table[name][label]['sizes'].values()),
                oneShotExecutionSeconds=sum(s['oneShotExecuteSeconds']['median'] for name in names
                                           for s in table[name][label]['sizes'].values()))
        baseline, selected = values['c-o2'], values[winner]
        groups[group] = dict(baseline=baseline, selected=selected,
            selectedOverBaseline={key: selected[key] / baseline[key] for key in baseline})
    return dict(table=table, groups=groups, executionBatchesPerBuild=1,
        accounting='k1CostSeconds sums per-size emission+compile+link+one execution batch, '
        'matching the original k=1 model. This charges a hypothetical independent build '
        'for each size. reusedBuildCostSeconds instead charges one build per workload '
        'and executes both repeated batches. oneShotK1CostSeconds uses a separate fresh '
        'process with repeat=1 for each size; it is not inferred by dividing batch time. '
        'One-shot observations do not select a policy and are not cold filesystem-cache '
        'measurements. Emission is the original single '
        'observation, not freshly measured. Common runner acquisition is reported separately; '
        'it and harness/reference/supervision costs are excluded from both cost models.')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--analysis', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase106') and not out.exists()
    analysis_pin = pin(args.analysis)
    analysis = read(authenticate(analysis_pin))
    assert analysis['complete']
    measurement = read(authenticate(analysis['source']))
    assert measurement['complete'] and measurement['passed'] and measurement['inputsUnchanged']
    assert measurement['cases'] == TRAINING_CASES
    assert measurement['configs'] == [list(c) for c in CONFIGS]
    searches = [s for s in analysis['searches'] if s['executionBatchesPerBuild'] == 1]
    assert len(searches) == 1
    selection = searches[0]
    winner = selection['selected']
    assert set(selection['trainingScores']) == {c[0] for c in CONFIGS}
    assert winner == min(selection['trainingScores'], key=selection['trainingScores'].get)
    assert winner in {c[0] for c in CONFIGS}
    configs = [c for c in CONFIGS if c[0] in {'c-o2', winner}]
    artifacts = read(authenticate(measurement['artifacts']))
    assert artifacts['complete'] and artifacts['cases'] == TRAINING_CASES
    inputs = dict(analysis=analysis_pin, measurement=analysis['source'],
        artifacts=measurement['artifacts'], adapter=measurement['adapter'],
        clang=measurement['clang'], harness=measurement['harness'],
        campaign=measurement['method'], method=pin(__file__))
    assert inputs['campaign'] == pin(HERE / 'campaign.py')
    assert inputs['harness'] == pin(HERE / 'cranelift/runner.c')

    def check_inputs():
        for value in inputs.values():
            authenticate(value)
        for product in artifacts['products'].values():
            for policy in product.values():
                for mode in policy.values():
                    authenticate(mode['artifact'])

    check_inputs()
    clang, adapter = inputs['clang']['file'], inputs['adapter']['file']
    cc = [clang, '-isystem', str(Path(clang).parents[1] / 'include/clang'),
          '-std=c11', '-march=native', '-fPIC']
    answers = {name: {str(n): expected(name, n, case['seed']) for n in case['sizes']}
               for name, case in CASES.items()}
    rng = random.Random(SEED)
    schedule = []
    for round_ in range(ROUNDS):
        batch = [(name, config) for name in CASES for config in configs]
        rng.shuffle(batch)
        for name, config in batch:
            sizes = list(CASES[name]['sizes'])
            rng.shuffle(sizes)
            schedule.append(dict(round=round_, workload=name, config=config, sizes=sizes))
    out.mkdir(parents=True)
    jobs = Jobs(out)
    report = dict(complete=False, passed=False, started=time.time(), inputs=inputs,
        selectedPolicy=dict(source=analysis_pin, executionBatchesPerBuild=1,
                            selected=winner, trainingScores=selection['trainingScores']),
        cases=CASES, casesFrozen=True, answers=answers, configs=configs,
        scenarios=dict(repeatedBatch='Per-case repeat count specified in cases',
                       oneShot='Fresh process with --repeat 1 on every same binary/input'),
        rounds=ROUNDS, seed=SEED, schedule=schedule, rows=[],
        scope='Fresh confirmation on two new sizes per workload, not another selection. '
        'The already frozen training k=1 winner is compared only with C-O2. The same '
        'Bend-emitted artifacts, adapter, Clang and runner source are authenticated. '
        'Each guarded runtime checks every invocation and the complete batch checksum. '
        'Held-out observations cannot change the selected policy.')
    try:
        save(out / 'report.json', report)
        runner = out / 'runner.o'
        child = jobs.run('runner-build', [*cc, '-O2', '-c', inputs['harness']['file'], '-o', runner])
        report['runnerAcquisitionSeconds'] = child['processSeconds']
        report['runnerObject'] = pin(runner)
        save(out / 'report.json', report)
        for item in schedule:
            round_, name = item['round'], item['workload']
            label, backend, option = item['config']
            prefix = f'r{round_}-{name}-{label}'
            obj, binary = out / (prefix + '.o'), out / prefix
            product = artifacts['products'][name]['fold']['c' if backend == 'c' else 'json']
            command = ([*cc, option, '-c', product['artifact']['file'], '-o', obj]
                       if backend == 'c' else [adapter, product['artifact']['file'], obj, option])
            compiled = jobs.run(prefix + '-compile', command)
            linked = jobs.run(prefix + '-link', [*cc, '-no-pie', runner, obj, '-o', binary])
            row = dict(round=round_, workload=name, config=label,
                emissionSeconds=product['emissionSeconds'], compileSeconds=compiled['processSeconds'],
                linkSeconds=linked['processSeconds'], peakCompileRssKiB=compiled['maxRssKiB'],
                object=pin(obj), binary=pin(binary), executions={})
            for n in item['sizes']:
                case, answer = CASES[name], answers[name][str(n)]
                child = jobs.run(prefix + f'-n{n}-execute',
                    [binary, '--repeat', case['repeat'], '--expect', answer, n, case['seed']])
                checksum = (answer * case['repeat']) & MASK
                assert child['stdout'] == str(checksum) + '\n' and not child['stderr'], (prefix, n, child)
                one_shot = jobs.run(prefix + f'-n{n}-one-shot',
                    [binary, '--repeat', 1, '--expect', answer, n, case['seed']])
                assert one_shot['stdout'] == str(answer) + '\n' and not one_shot['stderr'], (prefix, n, one_shot)
                row['executions'][str(n)] = dict(args=[n, case['seed']], repeat=case['repeat'],
                    expectedPerInvocation=answer, checksum=checksum,
                    executeSeconds=child['processSeconds'], peakExecuteRssKiB=child['maxRssKiB'],
                    oneShotExecuteSeconds=one_shot['processSeconds'],
                    oneShotPeakRssKiB=one_shot['maxRssKiB'], oneShotChecksum=answer)
            report['rows'].append(row)
            save(out / 'report.json', report)
            print(json.dumps(dict(round=round_, workload=name, config=label,
                                  compileSeconds=row['compileSeconds'], executions=row['executions'])), flush=True)
        check_inputs()
        authenticate(report['runnerObject'])
        report['summary'] = summarize(report['rows'], configs, winner)
        report.update(complete=True, passed=True, inputsUnchanged=True)
    finally:
        report.update(finished=time.time(), jobs=len(jobs.rows))
        save(out / 'report.json', report)


if __name__ == '__main__':
    main()
