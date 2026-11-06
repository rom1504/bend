#!/usr/bin/env python3
"""Reemit the exact timed wrappers serially; root must supply an outer guard.

Uses maintained request.execute with every original whole QBE as --expected.
No machine construction, benchmark execution, timing campaign or nested guard.
"""
import argparse
import copy
import importlib.util
import json
from pathlib import Path
import sys
import time

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
import assets
import request
from common import changed_inputs, fresh_output, pin, require, workspace, write_json

spec = importlib.util.spec_from_file_location('compare_products', HERE / 'compare-products.py')
compare = importlib.util.module_from_spec(spec)
spec.loader.exec_module(compare)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    request.arguments(parser, source_required=False)
    parser.add_argument('--reference', type=Path, action='append', required=True)
    parser.add_argument('--reference-role', default='candidate')
    parser.add_argument('--expected-count', type=int, default=45)
    parser.add_argument('--runtime-key', default='qbe-runtime')
    args = parser.parse_args()
    require(args.host == 'native' and args.target == 'qbe' and args.stage
            and args.image and args.image_receipt and not args.image_key,
            'Explicit final native image, binding and stage required')
    require(not args.source and not args.expected, 'Frozen references own sources and expected QBE')
    evidence = compare.Evidence()
    for path in (__file__, HERE / 'compare-products.py', request.__file__, assets.__file__):
        evidence.keep(pin(path))
    refs, reference_reports = compare.references(args.reference, evidence, args.reference_role, args.expected_count)
    root = workspace(args.workspace)
    document = assets.load_assets(args.assets, root)
    evidence.keep(document['_manifest'])
    tools = {name: assets.asset(document, name) for name in ('qbe', 'assembler', 'linker')}
    runtime = assets.asset(document, args.runtime_key)
    for row in [runtime, *tools.values()]:
        evidence.keep(row)
    machine = dict(runtime=compare.identity(runtime),
        runtimePolicy=document['runtimePolicies'][args.runtime_key], toolchain=document['toolchains']['qbe'],
        tools={label: compare.identity(tools[name]) for label, name in
               [('qbe', 'qbe'), ('assemble', 'assembler'), ('link', 'linker')]})
    jobs = []
    for index, old in enumerate(refs.values()):
        require(old['machine'] == machine, 'Runtime/toolchain differ from timed product: ' + old['id'])
        child = copy.copy(args)
        child.source, child.expected = Path(old['source']['file']), Path(old['product']['file'])
        child.out = args.out / ('%02d' % index)
        require(args.mode == old['mode'], 'Preparation mode differs')
        plan = request.plan(child)
        require(compare.key(plan['source']) == compare.key(old['source'])
                and compare.key(plan['expected']) == compare.key(old['product']), 'Source/reference drift')
        require(compare.identity(plan['base']) == old['base']
                and (compare.identity(plan['carrier']) if plan['carrier'] else None) == old['preparedBase']
                and plan['stamp'] == old['stamp'], 'Prepared Base differs')
        for row in plan['inputs']:
            evidence.keep(row)
        jobs.append((child, plan, old))
    result = dict(kind='bend-phase170-timed-product-reemission', version=1, complete=False,
        references=reference_reports, image=jobs[0][1]['image'], machinePolicy=machine, rows=[],
        expectedCount=args.expected_count, inputs=list(evidence.inputs.values()),
        scope='Whole QBE identity on exact timed wrapper sources with unchanged target runtime/toolchain. '
              'Prior runtime evidence applies to those products; no new timing, unrestricted conformance or compiler-speed claim.')
    if args.plan:
        result['planOnly'] = True
        result['jobs'] = [dict(id=old['id'], source=old['source'], expected=old['product'], request=plan)
                          for _, plan, old in jobs]
        print(json.dumps(result, indent=2))
        return 0
    out = fresh_output(args.out, root)
    started = time.monotonic()
    write_json(out / 'report.json', result)
    try:
        for child, plan, old in jobs:
            emitted = request.execute(child, plan)
            row = dict(id=old['id'], source=old['source'], expected=old['product'],
                       emission=pin(child.out / 'report.json'), product=emitted.get('product'),
                       complete=emitted.get('complete') is True and emitted.get('byteExact') is True)
            result['rows'].append(row)
            write_json(out / 'report.json', result)
            require(row['complete'], 'Exact reemission failed: ' + old['id'])
        result['complete'] = len(result['rows']) == args.expected_count
    except Exception as error:
        result['error'] = repr(error)
    finally:
        result['changedInputs'] = changed_inputs(result['inputs'])
        result['complete'] = result['complete'] and not result['changedInputs']
        result['seconds'] = time.monotonic() - started
        write_json(out / 'report.json', result)
    print(json.dumps({key: result.get(key) for key in ('complete', 'seconds', 'error')}))
    return 0 if result['complete'] else 1


if __name__ == '__main__':
    sys.exit(main())
