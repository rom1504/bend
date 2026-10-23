"""Plan native emission of frozen benchmark wrappers, then bind exact receipts.

No target is executed here: the existing run-jobs/native-emit tools own execution.
"""
import argparse
import json
from pathlib import Path
import sys

from qualify import ROOT, NATIVE, pin, pins, read, verify, require

CORPUS = ROOT / 'selfhost/tools/performance/phase112/benchmark45/manifest01.json'
EMITTER = NATIVE / 'native-emit.py'
EMITTER_SHA = '1eb3d76b674924c730a9bce96f600621f6f2687d06357f09f0f626f706f9cc58'


def emission(file, case, image, corpus):
    report = read(file)
    require(report['complete'] and report['kind'] == 'phase125-aligned-native-source-qbe-emission'
            and report['mode'] == 'cache' and report['image'] == image
            and report['gates']['emission'] == 'passed', 'Incomplete or wrong-image native receipt')
    require(pin(EMITTER) in report['inputs'] and all(r in report['inputs'] for r in
            [case['source'], corpus['base'], corpus['carrier']]), 'Native source/tool/Base/carrier identity differs')
    jobs = [j for j in report['jobs'] if j['label'] == 'native-request']
    require(len(jobs) == 1 and jobs[0]['exitCode'] == 0 and jobs[0]['status'] == 'complete'
            and jobs[0]['stdout'] == report['product'] and jobs[0]['stderr']['bytes'] == 0, 'Raw native output binding differs')
    for row in pins(report):
        verify(row)
    return dict(name=case['name'], source=case['source'], qbe=report['product'], emission=pin(file))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    modes = parser.add_subparsers(dest='mode', required=True)
    prep = modes.add_parser('prepare')
    for name in ['image', 'producer-receipt', 'runtime', 'out', 'prefix']:
        prep.add_argument('--' + name, type=Path, required=True)
    prep.add_argument('--reuse-map', type=Path, help='Optional exact-name map to already completed emission receipts')
    prep.add_argument('--names', nargs='+')
    finish = modes.add_parser('finish')
    finish.add_argument('--plan', type=Path, required=True)
    a = parser.parse_args()
    require(pin(EMITTER)['sha256'] == EMITTER_SHA, 'Frozen aligned native emitter changed')
    corpus = read(CORPUS)
    if a.mode == 'finish':
        plan = read(a.plan)
        require(plan['kind'] == 'phase128-native-wrapper-emission-plan' and not plan['targetsRun'], 'Wrong immutable plan')
        for row in plan['inputs']:
            verify(row)
        rows = [emission(row['receipt'], row['case'], plan['image'], corpus) for row in plan['cases']]
        inputs = [pin(a.plan), *plan['inputs'], *[r['emission'] for r in rows], *[r['qbe'] for r in rows]]
        result = dict(kind='phase128-native-wrapper-emission', complete=True, inputs=inputs,
            image=plan['image'], producerReceipt=plan['producerReceipt'], runtime=plan['runtime'], cases=rows,
            sourceKind='Exact historical Phase93 in-process benchmark wrappers, not ordinary full45 one-shot fixtures.',
            scope='Exact native producer/source/Base/cache/raw-QBE binding. Program output and runtime performance are not qualified here; the unchanged independent oracle must still validate every executed sample.')
        target = a.plan.parent / 'report.json'
        require(not read(target)['complete'], 'Completed aggregate is immutable')
        target.write_text(json.dumps(result, indent=2) + '\n')
        print(json.dumps(dict(complete=True, report=pin(target), cases=len(rows))))
        return
    out, prefix = a.out.resolve(), a.prefix.resolve()
    require(not out.exists() and out.is_relative_to(ROOT / 'selfhost/build/phase128'), 'Fresh Phase128 output required')
    require(prefix.is_relative_to(ROOT / 'selfhost/build/phase111'), 'Phase111 product prefix required')
    image, runtime, producer = pin(a.image), pin(a.runtime), read(a.producer_receipt)
    require(producer.get('complete') and image in list(pins(producer)) and runtime in list(pins(producer)), 'Complete exact-image/runtime producer receipt required')
    cases = corpus['cases']
    if a.names:
        require(len(a.names) == len(set(a.names)) and set(a.names) <= {r['name'] for r in cases}, 'Unknown/duplicate case')
        cases = [r for r in cases if r['name'] in a.names]
    reuse = read(a.reuse_map) if a.reuse_map else {}
    require(set(reuse) <= {r['name'] for r in cases}, 'Reuse map has unrequested cases')
    inputs = [pin(__file__), pin(Path(__file__).with_name('qualify.py')), pin(CORPUS), pin(EMITTER),
              image, runtime, pin(a.producer_receipt), corpus['base'], corpus['carrier'],
              *[r['source'] for r in cases]]
    if a.reuse_map:
        inputs.append(pin(a.reuse_map))
    rows, jobs = [], []
    for case in cases:
        if case['name'] in reuse:
            receipt = Path(reuse[case['name']]).resolve()
            emission(receipt, case, image, corpus)
            inputs.append(pin(receipt))
        else:
            dest = Path(str(prefix) + '-' + case['name'])
            require(not dest.exists(), 'Fresh native emission destination required')
            receipt = dest / 'report.json'
            jobs.append(dict(name='emit-' + case['name'], seconds=60, command=[sys.executable, '-B', str(EMITTER),
                '--image', image['file'], '--source', case['source']['file'], '--out', str(dest), '--mode', 'cache', '--seconds', '30']))
        rows.append(dict(case=case, receipt=str(receipt)))
    for row in inputs:
        verify(row)
    out.mkdir(parents=True)
    plan = dict(kind='phase128-native-wrapper-emission-plan', complete=True, targetsRun=False,
        inputs=inputs, image=image, runtime=runtime, producerReceipt=pin(a.producer_receipt), cases=rows,
        scope='Source-only job plan; target execution belongs to the unchanged native emitter and root serial guard.')
    (out / 'plan.json').write_text(json.dumps(plan, indent=2) + '\n')
    (out / 'report.json').write_text(json.dumps(dict(kind='phase128-native-wrapper-emission', complete=False,
        plan=pin(out / 'plan.json'), image=image, runtime=runtime, cases=[]), indent=2) + '\n')
    jobs.append(dict(name='bind-native-wrappers', seconds=60, command=[sys.executable, '-B', str(Path(__file__).resolve()),
                                                                  'finish', '--plan', str(out / 'plan.json')]))
    (out / 'jobs.json').write_text(json.dumps(dict(kind='phase128-native-wrapper-jobs', targetsRun=False,
        inputs=[pin(out / 'plan.json')], jobs=jobs), indent=2) + '\n')
    print(json.dumps(dict(complete=True, targetsRun=False, jobs=pin(out / 'jobs.json'), cases=len(cases))))


if __name__ == '__main__':
    main()
