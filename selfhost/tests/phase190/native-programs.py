#!/usr/bin/env python3
"""Acquire native45 objects/programs from one explicitly bound native image.

The maintained native builder owns requests and linking. Independent native45
values/counts qualify each product; optimized products need not equal old bytes.
Run under one outer CPU3 disk guard. This adapter never builds compiler images.
"""
import argparse
import copy
import json
import os
from pathlib import Path
import re
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

CATALOG = ROOT / 'selfhost/tools/bench/catalogs/native45/catalog.json'
PARTITION = Path(__file__).with_name('cases.json')


def select_cases(selection, catalog):
    partition = bench.read(PARTITION)
    actual = common.pin(CATALOG)
    common.require(all(partition['catalog'][key] == actual[key] for key in ('bytes', 'sha256')),
                   'Frozen native45 catalog changed')
    known = {case['id']: case for case in catalog['cases']}
    divided = partition['development'] + partition['heldout']
    common.require(len(known) == len(divided) == 45 and len(set(divided)) == 45
                   and set(divided) == set(known), 'Frozen development/heldout partition differs')
    names = (list(known) if selection == 'all' else partition[selection]
             if selection in ('development', 'heldout') else selection.split(','))
    common.require(names and len(names) == len(set(names)) and all(name in known for name in names),
                   'Unknown, duplicate or empty native45 case selection')
    return [known[name] for name in names], partition


def build_args(args, case, out, seconds):
    value = copy.copy(args)
    value.workspace, value.source, value.out = ROOT, Path(case['source']['file']), out
    value.host, value.target, value.emit = 'native', 'x86', 'object'
    value.seconds, value.plan, value.expected = seconds, False, None
    value.ir, value.runtime, value.runtime_key = None, None, 'qbe-runtime'
    value.runtime_argument_convention, value.runtime_abi = None, None
    value.expected_stdout, value.retain_ir = None, True
    value.output_stage, value.output_protocol = None, None
    return value


def validate_build(built, case, preflight, runtime):
    common.require(built.get('complete') is True and not built.get('changedInputs'),
                   'Native construction failed: ' + str(built.get('error')))
    common.require(built.get('target') == 'x86' and built.get('host') == 'native'
                   and built.get('stage') == preflight['stage']
                   and built.get('emissionFormat') == request.X86_OBJECT_FORMAT
                   and built.get('assemblerSkipped') is True
                   and isinstance(built.get('jobs'), list)
                   and not any(job.get('label') == 'assemble' for job in built['jobs']),
                   'Direct-object construction must skip the assembler')
    producer = built.get('request', {})
    common.require(producer.get('source') == case['source'], 'Native source identity differs')
    common.require(producer.get('image') == preflight['image']
                   and producer.get('imageMetadata') == preflight['imageMetadata']
                   and producer.get('host') == 'native'
                   and producer.get('target') == 'x86' and producer.get('emit') == 'object'
                   and producer.get('stage') == preflight['stage'], 'Native producer binding differs')
    common.require(built.get('runtime') == runtime and built.get('runtimeABI') == 11102,
                   'Target runtime identity/ABI differs')
    product = built.get('object', {})
    common.require(0 < product.get('bytes', 0) <= 128 * 1024 * 1024
                   and Path(product.get('file', '')).suffix == '.o', 'Bounded direct object required')
    common.verify(product)
    common.verify(built['binary'])
    return product


def execute(args):
    common.clean_environment()
    common.timeout(args.seconds)
    common.require(args.guarded and os.sched_getaffinity(0) == {3}, 'One outer guarded CPU3 lane required')
    common.require('BENDRTS' not in os.environ, 'Ambient BENDRTS must be unset')
    common.require(args.host == 'native' and re.fullmatch(r'N[0-9]+', args.stage or '')
                   and args.image and args.image_receipt and not args.image_key,
                   'Explicit --host native --stage N# --image --image-receipt required')
    common.require(args.target == 'x86' and args.emit == 'object', 'Explicit --target x86 --emit object required')
    common.require(not args.source and not args.expected and not args.plan, 'Catalog owns sources and value/count oracles')
    common.require(bench.NAME.fullmatch(args.role) and args.role not in ('.', '..'), 'Invalid role alias')
    started = time.monotonic()
    cases, partition = select_cases(args.cases, bench.catalog(CATALOG))
    preflight = request.plan(build_args(args, cases[0], args.out / 'preflight', args.seconds))
    document = assets.load_assets(args.assets, ROOT)
    runtime = assets.asset(document, 'qbe-runtime')
    compiler_source = preflight['imageMetadata'].get('sourceIdentity')
    common.require(isinstance(compiler_source, dict) and 'file' in compiler_source,
                   'Native image must bind its exact compiler source')
    inputs = bench.unique_inputs([*preflight['inputs'], compiler_source, document['_manifest'], runtime,
        common.pin(CATALOG), common.pin(PARTITION), common.pin(__file__), common.pin(sys.executable),
        *[common.pin(module.__file__) for module in (assets, bench, common, native, request)],
        *[pin for case in cases for pin in (case['source'], case['expectedFile'])]])
    for item in inputs:
        common.verify(item)
    out = common.fresh_output(args.out, ROOT)
    role = dict(host='native', stage=args.stage, target='x86', emit='object', preparation=args.mode,
        policy='ordinary', status='experimental-explicit-native-output', emitter='selfhost',
        compiler=preflight['image'], compilerSource=compiler_source, runtime=runtime,
        imageBinding=common.pin(args.image_receipt), inputs=inputs)
    recipe = dict(kind='programs', cwd=str(ROOT), catalog=str(CATALOG), reference=args.role,
                  roles={args.role: role}, cases=[])
    report = dict(kind='bend-benchmark-acquisition', version=1, complete=False, inputs=inputs,
        roles=recipe['roles'], selected=[case['id'] for case in cases], selection=args.cases,
        development=partition['development'], heldout=partition['heldout'], rows=[], preflight=preflight,
        secondsLimit=args.seconds, cpu=3, guarded=True, emit='object',
        scope='Actual explicitly bound native image emits direct ELF; each program passes one independent native45 full-value/count observation. Optimized machine bytes may differ. No compiler timing, image reproduction, promotion or broader qualification claim.')

    def save():
        report['seconds'] = time.monotonic() - started
        common.write_json(out / 'report.json', report)

    def left():
        remaining = args.seconds - (time.monotonic() - started)
        common.require(remaining > 0, 'Whole native catalog deadline exceeded')
        return remaining

    save()
    try:
        for case in cases:
            directory = out / case['id']
            directory.mkdir()
            row = dict(id=case['id'], source=case['source'], expectedFile=case['expectedFile'],
                partition='development' if case['id'] in partition['development'] else 'heldout', complete=False)
            report['rows'].append(row)
            save()
            built = native.build(build_args(args, case, directory / 'machine', left()))
            row['buildReceipt'] = common.pin(directory / 'machine/report.json')
            save()
            generated = validate_build(built, case, preflight, runtime)
            product = dict(artifact=built['binary'], generatedSource=generated,
                runtimeArgumentConvention=built['runtimeArgumentConvention'],
                inputs=bench.unique_inputs([*inputs, *built['inputs'], row['buildReceipt']]))
            point = dict(case['point'], repetitions=1, warmups=0)
            command = [product['artifact']['file'], *bench.native_runtime_arguments(product),
                       '1', '0', *map(str, point['runtimeArgs'])]
            child = common.run(command, cwd=ROOT, stdout=directory / 'oracle.stdout',
                stderr=directory / 'oracle.stderr', seconds=min(30, left()))
            common.write_json(directory / 'oracle-process.json', child)
            row['oracleReceipt'] = common.pin(directory / 'oracle-process.json')
            save()
            common.require(child.get('complete') is True, 'Native independent oracle process failed')
            bench.observation(common.verify(child['stdout']).read_bytes(),
                common.verify(child['stderr']).read_bytes(), child['exitCode'], point, child['seconds'])
            product['inputs'] = bench.unique_inputs([*product['inputs'], row['oracleReceipt'],
                                                    child['stdout'], child['stderr']])
            recipe['cases'].append(dict(id=case['id'], products={args.role: product}))
            row.update(complete=True, artifact=product['artifact'], object=generated,
                       status='executed-independent-oracle-pass')
            save()
        common.require(not common.changed_inputs(inputs), 'Native catalog inputs changed')
        common.write_json(out / 'programs.recipe.json', recipe)
        bench.freeze(out / 'programs.recipe.json', out / 'programs.manifest.json')
        report['programManifest'] = common.pin(out / 'programs.manifest.json')
        report['complete'] = True
    except BaseException as error:
        report['error'] = repr(error)
    finally:
        report['changedInputs'] = common.changed_inputs(inputs)
        if report['changedInputs']:
            report['complete'] = False
        save()
    print(json.dumps({key: report.get(key) for key in ('complete', 'programManifest', 'error')}))
    return 0 if report['complete'] else 1


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    request.arguments(parser, source_required=False)
    parser.add_argument('--role', required=True)
    parser.add_argument('--cases', default='development', help='development, heldout, all, or comma-separated native45 IDs')
    parser.add_argument('--guarded', action='store_true')
    return execute(parser.parse_args())


if __name__ == '__main__':
    sys.exit(main())
