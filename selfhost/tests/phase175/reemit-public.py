#!/usr/bin/env python3
"""Compare frozen Phase174 JS/C products via checked B1/live requests.

Root supplies the outer execution guard. No machine construction or execution.
--plan authenticates inputs and prints jobs without invoking the compiler.
Default: all 45 products. Repeat --case EXACT_ID for an explicit partial screen.
"""
import argparse
import hashlib
import json
from pathlib import Path
import sys
import time

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
import assets
import request
from common import changed_inputs, fresh_output, pin, require, verify, write_json


def identity(row):
    return {key: row[key] for key in ('bytes', 'sha256')}


class Evidence:
    def __init__(self):
        self.rows = {}

    def keep(self, row):
        old = self.rows.get(row['file'])
        require(old is None or identity(old) == identity(row), 'Conflicting artifact identity')
        if old is None:
            verify(row)
            self.rows[row['file']] = row
        return Path(row['file'])

    def document(self, row):
        return json.loads(self.keep(row).read_text())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--target', choices=['js', 'c'], required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--assets', type=Path, default=ROOT/'selfhost/manifests/assets-native.json')
    parser.add_argument('--api', type=Path, default=ROOT/'selfhost/build/phase175/public-api01/api.mjs')
    parser.add_argument('--api-receipt', type=Path, default=ROOT/'selfhost/build/phase175/public-api01/report.json')
    parser.add_argument('--seconds', type=float, default=60)
    parser.add_argument('--case', action='append', dest='cases',
                        help='Exact frozen case ID; repeat for a nonempty partial screen')
    parser.add_argument('--plan', action='store_true')
    args = parser.parse_args()
    evidence = Evidence()
    for path in (__file__, request.__file__, assets.__file__, ROOT/'selfhost/tools/build/common.py'):
        evidence.keep(pin(path))
    reference = pin(ROOT/('selfhost/build/phase174/'+args.target+'45/report.json'))
    prior = evidence.document(reference)
    require(prior.get('complete') and prior.get('passed') and not prior.get('changedInputs')
            and prior['target'] == args.target and prior['counts'] == {'pass': 45, 'fail': 0, 'unsupported': 0},
            'Complete unchanged Phase174 broad45 qualification required')
    require(len(prior['rows']) == 45 and prior['selected'] == [r['id'] for r in prior['rows']]
            and len(set(prior['selected'])) == 45, 'Exact ordered 45-case reference required')
    requested = prior['selected'] if args.cases is None else args.cases
    require(requested and len(set(requested)) == len(requested)
            and set(requested).issubset(prior['selected']),
            '--case requires distinct exact IDs from the frozen 45-case reference')
    selected = [row for row in prior['rows'] if row['id'] in set(requested)]
    full_suite = len(selected) == 45
    document = assets.load_assets(args.assets, ROOT)
    evidence.keep(document['_manifest'])
    jobs = []
    for index, row in enumerate(selected):
        require(row['status'] == 'pass' and row['expected']['stage'] == 'execute', 'Qualified executable case required')
        evidence.keep(row['source'])
        old = evidence.document(row['emission'])
        require(old.get('complete') and not old.get('changedInputs') and old['target'] == args.target
                and identity(old['source']) == identity(row['source']), 'Qualified emitted-product mismatch')
        evidence.keep(old['product'])
        execution = row['execution']
        require(execution.get('complete') and not execution.get('timedOut')
                and execution['exitCode'] == row['expected']['exitCode'] == 0, 'Prior execution failed')
        for stream in ('stdout', 'stderr'):
            observed = evidence.keep(execution[stream]).read_bytes()
            require(observed == row['expected'][stream].encode('utf8'), 'Prior whole-output oracle mismatch')
        child = argparse.Namespace(workspace=ROOT, assets=args.assets, image_key=None,
            image=args.api, image_receipt=args.api_receipt, source=Path(row['source']['file']),
            host='js', target=args.target, stage='B1', mode='live', base_key='base',
            carrier_key='prepared-base', engine_key='bun', out=args.out/('%02d' % index),
            seconds=args.seconds, expected=Path(old['product']['file']), plan=False)
        plan = request.plan(child)
        require(identity(plan['source']) == identity(row['source'])
                and identity(plan['expected']) == identity(old['product'])
                and identity(plan['base']) == identity(old['base']), 'Source/product/Base changed')
        for item in plan['inputs']:
            evidence.keep(item)
        providers = old['request']['providers']
        if args.target == 'js':
            evidence.keep(providers['runtime'])
            require(identity(plan['providers']['runtime']) == identity(providers['runtime']), 'JS runtime changed')
            evidence.keep(row['programEngine'])
            require(identity(plan['engine']) == identity(row['programEngine']), 'Program engine changed')
            machine = dict(programEngine=row['programEngine'], runtime=providers['runtime'])
        else:
            # Public native reference stores five runtime pieces; B1 receives their exact raw concatenation.
            raw = b''.join(evidence.keep(part).read_bytes() for part in providers['runtimeParts'])
            require(len(raw) == plan['providers']['runtime']['bytes']
                    and hashlib.sha256(raw).hexdigest() == plan['providers']['runtime']['sha256'],
                    'C runtime concatenation changed')
            effects = {Path(part['file']).name: identity(part) for part in plan['providers']['effects']}
            for part in providers['effects']:
                evidence.keep(part)
                require(effects.get(Path(part['file']).name) == identity(part), 'Qualified C provider changed')
            evidence.keep(row['compiler'])
            compiler = assets.asset(document, 'clang')
            evidence.keep(compiler)
            require(identity(compiler) == identity(row['compiler'])
                    and document['toolchains']['c'] == row['toolchain'], 'Qualified C toolchain changed')
            require(row['buildProcess']['complete'] and row['buildProcess']['exitCode'] == 0,
                    'Prior C construction failed')
            evidence.keep(row['binary'])
            machine = dict(compiler=row['compiler'], toolchain=row['toolchain'],
                runtime=plan['providers']['runtime'], qualifiedEffects=providers['effects'],
                providerScope='Every historical provider matches; additional current providers are authenticated by request.plan. Complete output identity remains mandatory.')
        jobs.append((child, plan, dict(id=row['id'], source=row['source'], expected=old['product'],
            priorEmission=row['emission'], priorExecutionOracle=row['expected'], priorMode=old['mode'], machine=machine)))
    result = dict(kind='phase175-public-product-reemission', version=1, complete=False,
        target=args.target, host='js', stage='B1', mode='live', reference=reference,
        candidate=jobs[0][1]['image'], inputs=list(evidence.rows.values()), rows=[],
        selected=[row['id'] for row in selected], requestedCases=args.cases,
        available=prior['selected'], availableCount=45, expectedCount=len(selected), fullSuite=full_suite,
        completionScope='All 45 frozen products' if full_suite else 'Selected subset only; the full 45-case suite was not re-emitted',
        scope='Exact complete JS/C product identity against qualified Phase174 sources and whole-output oracles. '
              'Historical C used native/cache; this gate uses checked B1/live. No machine rebuild, program execution, '
              'fresh conformance qualification, compiled-program speed or compiler-speed comparison claim.')
    if args.plan:
        result.update(planOnly=True, jobs=[dict(authority=old, request=plan) for _, plan, old in jobs])
        print(json.dumps(result, indent=2))
        return 0
    out = fresh_output(args.out, ROOT)
    started = time.monotonic()
    write_json(out/'plan.json', dict(kind='phase175-public-product-reemission-plan',
        inputs=result['inputs'], selected=result['selected'], available=result['available'],
        availableCount=45, expectedCount=len(selected), fullSuite=full_suite,
        completionScope=result['completionScope'],
        jobs=[dict(authority=old, request=plan) for _, plan, old in jobs]))
    write_json(out/'report.json', result)
    try:
        for child, plan, old in jobs:
            emitted = request.execute(child, plan)
            row = dict(old, emission=pin(child.out/'report.json'), product=emitted.get('product'),
                complete=emitted.get('complete') is True and emitted.get('byteExact') is True)
            result['rows'].append(row)
            write_json(out/'report.json', result)
            require(row['complete'], 'Complete product differs: '+old['id'])
        result['complete'] = len(result['rows']) == len(selected)
    except Exception as error:
        result['error'] = repr(error)
    finally:
        result['changedInputs'] = changed_inputs(result['inputs'])
        result['complete'] = result['complete'] and not result['changedInputs']
        result['seconds'] = time.monotonic()-started
        write_json(out/'report.json', result)
    print(json.dumps({key: result.get(key) for key in ('target','complete','seconds','error')}))
    return 0 if result['complete'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
