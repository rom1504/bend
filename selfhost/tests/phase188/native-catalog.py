#!/usr/bin/env python3
"""Root-only finite native45 checks for an explicitly bound direct-object image.

The checked native Bend compiler owns source handling and object production.
This adapter only calls the maintained builder and independent catalog observer.
"""
import argparse
import copy
import json
import os
from pathlib import Path
import sys
import time

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path[:0] = [str(ROOT / 'selfhost/tools/bench'), str(ROOT / 'selfhost/tools/build')]
import assets
import bench
import common
import native
import request
import product_compare

CATALOG = ROOT / 'selfhost/tools/bench/catalogs/native45/catalog.json'
DEFAULT_CASES = ('local-pair', 'local-fold', 'tree-bitonic', 'coverage-map-churn-32',
                 'coverage-unicode-text-16', 'coverage-record-aggregation-64',
                 'variation-ray-active-64-2440', 'coverage-closures-64',
                 'coverage-expression-32', 'coverage-numeric-recurrence-256')


def build_args(args, case, role, out, seconds):
    value = copy.copy(args)
    value.workspace, value.source, value.out = ROOT, Path(case['source']['file']), out
    value.host, value.target, value.emit = 'native', 'x86', 'object' if role == 'object' else None
    value.seconds, value.plan, value.expected = seconds, False, None
    value.ir, value.runtime, value.runtime_key = None, None, 'qbe-runtime'
    value.runtime_argument_convention, value.runtime_abi = None, None
    value.expected_stdout, value.retain_ir = None, True
    value.output_stage, value.output_protocol = None, None
    if role == 'reference':
        value.stage = args.reference_stage
        value.image, value.image_receipt = args.reference_image, args.reference_receipt
        value.image_key = None if value.image else args.reference_image_key
    return value


def execute(args):
    common.clean_environment()
    common.require(args.guarded and os.sched_getaffinity(0) == {3}, 'One outer guarded CPU3 lane required')
    common.require(args.host == 'native' and args.stage and args.image and args.image_receipt,
                   'Explicit candidate --host native --stage --image --image-receipt required')
    common.require(args.target == 'x86' and args.emit == 'object', 'Explicit --target x86 --emit object required')
    common.require(not args.source and not args.expected and not args.plan, 'Catalog owns sources and observations')
    common.require(not (args.all and args.cases), '--all and --cases are mutually exclusive')
    common.require(not args.only_object or not (args.build_reference or args.execute_reference), 'Reference options conflict with --only-object')
    common.require(not args.reference_image or args.build_reference, '--reference-image requires --build-reference')
    common.require((args.reference_image is None) == (args.reference_receipt is None),
                   'Reference image requires its receipt')
    common.require('BENDRTS' not in os.environ, 'Ambient BENDRTS must be unset')
    common.timeout(args.seconds)
    started = time.monotonic()
    catalog = bench.catalog(CATALOG)
    known = {case['id']: case for case in catalog['cases']}
    names = list(known) if args.all else args.cases.split(',') if args.cases else list(DEFAULT_CASES)
    common.require(names and len(names) == len(set(names)) and all(name in known for name in names),
                   'Unknown, duplicate or empty case list')
    cases = [known[name] for name in names]
    baseline = bench.read(args.baseline_report)
    common.require(baseline.get('complete') and not baseline.get('changedInputs'), 'Completed Phase187 catalog baseline required')
    prior_rows = {row['id']: row for row in baseline['rows']}
    common.require(all(name in prior_rows for name in names), 'Selected baseline rows required')
    roles = ['object'] if args.only_object else ['object', 'reference']
    retained = {}
    if 'reference' in roles and not args.build_reference:
        manifest = bench.read(args.reference_manifest)
        common.require(manifest.get('kind') == 'programs' and args.reference_role in manifest.get('roles', {}),
                       'Retained reference manifest/role required')
        prior = {row['id']: row for row in manifest['cases']}
        for case in cases:
            old = prior.get(case['id'])
            common.require(old and old['source'] == case['source'] and old['expectedFile'] == case['expectedFile']
                           and old['point']['expectedStdout'] == case['point']['expectedStdout']
                           and old['point']['runtimeArgs'] == case['point']['runtimeArgs'],
                           'Retained reference source/oracle differs: ' + case['id'])
            product = old['products'].get(args.reference_role)
            common.require(product and Path(product['generatedSource']['file']).suffix == '.s',
                           'Retained assembly reference required')
            common.verify(product['artifact']); common.verify(product['generatedSource'])
            retained[case['id']] = product
    preflights = {role: request.plan(build_args(args, cases[0], role, args.out / 'preflight', args.seconds))
                  for role in roles if role != 'reference' or args.build_reference}
    document = assets.load_assets(args.assets, ROOT)
    inputs = [common.pin(args.baseline_report), common.pin(product_compare.__file__), common.pin(__file__), common.pin(CATALOG), document['_manifest'],
              *[common.pin(module.__file__) for module in (assets, bench, common, native, request)],
              common.pin(sys.executable)]
    for case in cases:
        inputs.extend([case['source'], case['expectedFile']])
        for old in prior_rows[case['id']]['products'].values():
            receipt = old['buildReceipt']
            previous = json.loads(common.verify(receipt).read_text())
            inputs.extend([receipt,previous['object'],previous['binary']])
    if retained:
        inputs.append(common.pin(args.reference_manifest))
        for product in retained.values():
            inputs.extend([product['artifact'], product['generatedSource']])
    for preflight in preflights.values():
        inputs.extend(preflight['inputs'])
    inputs = bench.unique_inputs(inputs)
    for item in inputs:
        common.verify(item)
    out = common.fresh_output(args.out, ROOT)
    report = dict(kind='phase188-native-object-catalog', version=1, complete=False,
                  inputs=inputs, selected=names, fullCatalog=args.all, roles=roles,
                  preflights=preflights, rows=[], cpu=3, secondsLimit=args.seconds,
                  retainedReference=dict(manifest=common.pin(args.reference_manifest), role=args.reference_role,
                                         executed=args.execute_reference) if retained else None,
                  scope='Finite native45 independent complete-value/count checks. Candidate emits ELF directly; default reference authenticates retained Phase187 assembly and ELF without executing either. Fresh reference build/execution is explicit. Paired GNU-as objects and linked program sections must match retained Phase187. No runtime speed aggregate, native reproduction, installed promotion or complete backend proof.')

    def save():
        report['objectsPassed'] = sum(row['products'].get('object', {}).get('status') == 'executed-independent-oracle-pass' for row in report['rows'])
        report['referencesExecuted'] = sum(row['products'].get('reference', {}).get('status') == 'executed-independent-oracle-pass' for row in report['rows'])
        report['seconds'] = time.monotonic() - started
        common.write_json(out / 'report.json', report)

    def left():
        remaining = args.seconds - (time.monotonic() - started)
        common.require(remaining > 0, 'Whole native catalog deadline exhausted')
        return remaining

    save()
    try:
        for case in cases:
            row = dict(id=case['id'], source=case['source'], expectedFile=case['expectedFile'],
                       point=dict(case['point'], repetitions=1, warmups=0), complete=False, products={})
            report['rows'].append(row)
            for role in roles:
                for item in inputs:
                    common.verify(item)
                directory = out / case['id'] / role
                directory.mkdir(parents=True)
                if role == 'reference' and retained:
                    product = retained[case['id']]
                    result = dict(binary=product['artifact'], generatedSource=product['generatedSource'],
                                  status='retained-authenticated-not-executed', complete=True)
                    row['products'][role] = result
                    save()
                    if not args.execute_reference:
                        continue
                    built = dict(binary=product['artifact'], runtimeArgumentConvention=product['runtimeArgumentConvention'])
                    result.update(status='execution-pending', complete=False)
                else:
                    built = native.build(build_args(args, case, role, directory / 'machine', left()))
                    receipt = common.pin(directory / 'machine/report.json')
                    result = dict(buildReceipt=receipt, complete=False)
                    row['products'][role] = result
                    save()
                    common.require(built.get('complete') and not built.get('changedInputs'),
                                   'Native build failed for ' + case['id'] + '/' + role + ': ' + str(built.get('error')))
                if role == 'object':
                    common.require(built.get('emissionFormat') == request.X86_OBJECT_FORMAT,
                                   'Candidate did not use direct-object route')
                    common.require(not any(job.get('label') == 'assemble' for job in built['jobs']),
                                   'Direct-object build unexpectedly invoked assembler')
                command = [built['binary']['file'], *bench.native_runtime_arguments(built),
                           '1', '0', *map(str, case['point']['runtimeArgs'])]
                child = common.run(command, cwd=ROOT, stdout=directory / 'oracle.stdout',
                                   stderr=directory / 'oracle.stderr', seconds=min(30, left()))
                common.write_json(directory / 'oracle-process.json', child)
                result['oracleReceipt'] = common.pin(directory / 'oracle-process.json')
                result['binary'] = built['binary']
                save()
                common.require(child.get('complete'), 'Native oracle process failed: ' + case['id'] + '/' + role)
                bench.observation(common.verify(child['stdout']).read_bytes(), common.verify(child['stderr']).read_bytes(),
                                  child['exitCode'], row['point'], child['seconds'])
                result['complete'] = True
                result['status'] = 'executed-independent-oracle-pass'
                save()
            row['machineComparison'] = product_compare.compare(row, prior_rows[case['id']])
            row['complete'] = True
            save()
        common.require(not common.changed_inputs(inputs), 'Qualification inputs changed')
        report['complete'] = True
    except BaseException as error:
        report['error'] = repr(error)
    finally:
        report['changedInputs'] = common.changed_inputs(inputs)
        if report['changedInputs']:
            report['complete'] = False
        save()
    print(json.dumps({key: report.get(key) for key in ('complete', 'selected', 'roles', 'seconds', 'error')}))
    return 0 if report['complete'] else 1


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    request.arguments(parser, source_required=False)
    parser.add_argument('--guarded', action='store_true')
    parser.add_argument('--cases')
    parser.add_argument('--all', action='store_true')
    parser.add_argument('--only-object', action='store_true')
    parser.add_argument('--reference-manifest', type=Path,
                        default=ROOT / 'selfhost/build/phase187/runtime-paired05/manifest.json')
    parser.add_argument('--reference-role', default='assembly')
    parser.add_argument('--baseline-report', type=Path, default=ROOT / 'selfhost/build/phase187/native45-final05/report.json')
    parser.add_argument('--execute-reference', action='store_true')
    parser.add_argument('--build-reference', action='store_true', help='Fresh assembly reference instead of retained products')
    parser.add_argument('--reference-image-key', default='x86-n2')
    parser.add_argument('--reference-image', type=Path)
    parser.add_argument('--reference-receipt', type=Path)
    parser.add_argument('--reference-stage', default='N2')
    return execute(parser.parse_args())


if __name__ == '__main__':
    sys.exit(main())
