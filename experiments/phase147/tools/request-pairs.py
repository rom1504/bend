#!/usr/bin/env python3
"""Pair complete native QBE requests through the maintained explicit build API."""
import argparse
import json
from pathlib import Path
import statistics
import sys
import time

ROOT = Path(__file__).resolve().parents[3]
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT/'selfhost/tools/build'))
import request
import assets
from common import fresh_output, pin, require, verify, write_json


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for name in ('candidate', 'cases', 'assets', 'out'):
        p.add_argument('--'+name, type=Path, required=True)
    p.add_argument('--baseline-key', default='qbe-n2')
    p.add_argument('--pairs', type=int, default=3)
    p.add_argument('--seconds', type=float, default=60)
    p.add_argument('--budget-seconds', type=float, default=180)
    a = p.parse_args()
    require(2 <= a.pairs <= 8 and 0 < a.seconds <= 600 and 0 < a.budget_seconds <= 1800,
            'Bounded pair and process budgets required')
    document = assets.load_assets(a.assets, ROOT)
    old, metadata = assets.image(document, a.baseline_key, 'native', 'N2', 'qbe')
    images = dict(old=dict(assetKey=a.baseline_key, binding=dict(metadata, image=old)))
    inputs = [pin(__file__), pin(request.__file__), pin(a.cases), pin(a.assets), old]
    for mode, file in [('new', a.candidate)]:
        build = json.loads(file.read_text()); binding = build.get('imageBinding', {})
        require(build.get('complete') and not build.get('changedInputs') and not build.get('error')
                and binding.get('complete') and binding.get('host') == 'native'
                and binding.get('protocol') == 'qbe-source-v1', 'Completed native compiler binding required')
        require(build['binary'] == binding['image'] and build['request']['source'] == binding['sourceIdentity'],
                'Compiler image/source lineage mismatch')
        verify(binding['image']); verify(binding['sourceIdentity'])
        images[mode] = dict(receipt=pin(file), binding=binding)
        inputs += [pin(file), binding['image'], binding['sourceIdentity']]
    require(all(images['old']['binding']['linkedRuntime'][k] == images['new']['binding']['linkedRuntime'][k]
                for k in ('bytes', 'sha256')),
            'Matched compiler runtime required')
    cases = json.loads(a.cases.read_text())
    require(cases.get('complete') and cases.get('kind') == 'phase147-verifier-capture-inputs',
            'Pinned current source cases required')
    for case in cases['cases']: verify(case['source']); inputs.append(case['source'])
    out = fresh_output(a.out, ROOT); started = time.monotonic()
    report = dict(kind='phase147-native-request-pairs', version=1, complete=False, passed=False,
                  inputs=inputs, images=images, cases=[], timingScope='Whole native child request including reads and complete output; maintained preflight/hash checks excluded.',
                  scope='Exact old/new full QBE comparison on frozen source inputs. Independent program execution and negative qualification remain separate gates. No warm resident-session claim.')
    def save(): write_json(out/'report.json', report)
    save()
    try:
        for case_index, case in enumerate(cases['cases']):
            row = dict(name=case['name'], source=case['source'], scope=case['scope'], calls=[], pairs=[])
            report['cases'].append(row); reference = None
            for pair in range(a.pairs):
                order = ['old', 'new'] if pair % 2 == 0 else ['new', 'old']; measured = {}
                for mode in order:
                    require(time.monotonic()-started < a.budget_seconds, 'Whole pair campaign budget exceeded')
                    image = images[mode]; binding = image['binding']; folder = out/('%02d-%02d-%s' % (case_index, pair, mode))
                    args = argparse.Namespace(workspace=ROOT, assets=a.assets, image_key=image.get('assetKey'),
                        image=None if mode == 'old' else Path(binding['image']['file']),
                        image_receipt=None if mode == 'old' else Path(image['receipt']['file']),
                        source=Path(case['source']['file']), host='native', target='qbe', stage=binding['stage'],
                        mode='cache', base_key='base', carrier_key='prepared-base', engine_key='bun',
                        out=folder, seconds=min(a.seconds, a.budget_seconds-(time.monotonic()-started)),
                        expected=reference, plan=False)
                    receipt = request.execute(args)
                    call = dict(mode=mode, pair=pair, receipt=pin(folder/'report.json'), complete=receipt['complete'])
                    row['calls'].append(call); save()
                    require(receipt['complete'] and not receipt['changedInputs'], 'Complete exact QBE request failed')
                    if reference is None: reference = Path(receipt['product']['file']); row['reference'] = receipt['product']
                    measured[mode] = receipt['process']['seconds']; call['seconds'] = measured[mode]
                row['pairs'].append(dict(index=pair, order=order, seconds=measured, ratio=measured['new']/measured['old'])); save()
            row['medianSeconds'] = {mode: statistics.median(c['seconds'] for c in row['calls'] if c['mode'] == mode) for mode in images}
            row['ratio'] = row['medianSeconds']['new']/row['medianSeconds']['old']
            row['performanceQualified'] = min(c['seconds'] for c in row['calls']) >= .1
            row['passed'] = True; save()
        for item in inputs: verify(item)
        report['complete'] = report['passed'] = True
    except BaseException as error:
        report['error'] = repr(error)
        raise
    finally:
        report['totalSeconds'] = time.monotonic()-started; save()
    print(json.dumps(dict(complete=True, passed=True, seconds=report['totalSeconds'],
                         ratios={r['name']:r['ratio'] for r in report['cases']})))


if __name__ == '__main__': main()
