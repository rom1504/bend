#!/usr/bin/env python3
"""Construct checked Phase190 emissions and freeze exact-output native45 products.

One outer guard owns CPU3, disk and process limits. Source checking and lowering
remain in the checked Bend API; this transport only builds and checks its bytes.
"""
import argparse
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

CATALOG = ROOT / 'selfhost/tools/bench/catalogs/native45/catalog.json'
ASSETS = ROOT / 'selfhost/manifests/assets-native.json'


def emission(path):
    receipt = common.pin(path)
    common.require(receipt['bytes'] <= 16 * 1024 * 1024, 'Oversized emission receipt')
    report = bench.read(path)
    common.require(report.get('kind') == 'phase190-checked-native-emission'
                   and report.get('complete') is True and not report.get('error')
                   and report.get('target') == 'x86'
                   and report.get('emit') in ('object', 'assembly'),
                   'Complete checked emission required')
    inputs = bench.unique_inputs([receipt, *report['inputs']])
    for item in inputs:
        common.verify(item)
    authorities = []
    for item in report['inputs']:
        if Path(item['file']).suffix == '.json' and item['bytes'] <= 16 * 1024 * 1024:
            value = bench.read(item['file'])
            if value.get('kind') == 'bend-checked-hosted-api':
                common.require(value.get('complete') is True and value.get('checked') is True
                               and value.get('api') in inputs and value.get('source') in inputs,
                               'Emission checked API identity differs')
                authorities.append(value)
    common.require(len(authorities) == 1, 'Exactly one checked API authority required')
    catalog = bench.catalog(CATALOG)
    known = {case['id']: case for case in catalog['cases']}
    rows = report.get('rows', [])
    common.require(0 < len(rows) <= 45 and len({row['id'] for row in rows}) == len(rows),
                   'Empty, duplicate or oversized emission case set')
    suffix = '.o' if report['emit'] == 'object' else '.s'
    for row in rows:
        common.require(row['id'] in known and row.get('complete') is True and row.get('verified') is True,
                       'Unknown or unfinished emission row')
        common.require(row.get('source') == known[row['id']]['source'] and row['source'] in inputs,
                       'Emission source differs from native45: ' + row['id'])
        common.require(0 < row['product']['bytes'] <= 128 * 1024 * 1024
                       and Path(row['product']['file']).suffix == suffix,
                       'Invalid native product: ' + row['id'])
        common.verify(row['product'])
        assembly = row.get('assembly', {})
        common.require(0 < assembly.get('bytes', 0) <= 128 * 1024 * 1024
                       and Path(assembly.get('file', '')).suffix == '.s',
                       'Typed-sequence assembly diagnostic required: ' + row['id'])
        common.verify(assembly)
        common.require(report['emit'] != 'assembly' or assembly == row['product'],
                       'Assembly product differs from diagnostic: ' + row['id'])
        inputs += [row['product'], assembly, known[row['id']]['expectedFile']]
    inputs += [common.pin(CATALOG)]
    return report, authorities[0], known, bench.unique_inputs(inputs)


def machine_args(emit, product, out, seconds, asset_path):
    return argparse.Namespace(workspace=ROOT, assets=asset_path, target='x86', emit=emit,
        ir=Path(product['file']), source=None, image=None, image_key=None,
        runtime=None, runtime_key='qbe-runtime', expected=None, expected_stdout=None,
        retain_ir=True, output_stage=None, output_protocol=None, plan=False,
        out=out, seconds=seconds)


def execute(args):
    common.clean_environment()
    common.timeout(args.seconds)
    common.require(args.guarded and os.sched_getaffinity(0) == {3}, 'One outer guarded CPU3 lane required')
    common.require('BENDRTS' not in os.environ, 'Ambient BENDRTS must be unset')
    common.require(bench.NAME.fullmatch(args.role) and args.role not in ('.', '..'), 'Invalid role alias')
    start = time.monotonic()
    emitted, authority, known, inputs = emission(args.emission)
    document = assets.load_assets(args.assets, ROOT)
    runtime = assets.asset(document, 'qbe-runtime')
    inputs = bench.unique_inputs([*inputs, document['_manifest'], runtime, common.pin(__file__),
        common.pin(native.__file__), common.pin(request.__file__), common.pin(bench.__file__), common.pin(common.__file__),
        common.pin(assets.__file__), common.pin(sys.executable)])
    out = common.fresh_output(args.out, ROOT)
    role = dict(host='js', stage='B1', target=emitted['target'], preparation='cache',
        policy='ordinary', status='experimental-checked-api-output', emitter='selfhost',
        compiler=authority['api'], runtime=runtime, inputs=inputs, emit=emitted['emit'])
    recipe = dict(kind='programs', cwd=str(ROOT), catalog=str(CATALOG),
        reference=args.role, roles={args.role: role}, cases=[])
    report = dict(kind='bend-benchmark-acquisition', complete=False, inputs=inputs,
        roles=recipe['roles'], selected=[row['id'] for row in emitted['rows']], rows=[],
        emission=common.pin(args.emission), secondsLimit=args.seconds, cpu=3, guarded=True,
        emit=emitted['emit'],
        scope='Machine construction and one independent native45 value/count check; no compiler timing, self-hosting, promotion or broader qualification.')

    def save():
        report['seconds'] = time.monotonic() - start
        common.write_json(out / 'report.json', report)

    def left():
        remaining = args.seconds - (time.monotonic() - start)
        common.require(remaining > 0, 'Whole machine acquisition deadline exceeded')
        return remaining

    save()
    try:
        for source in emitted['rows']:
            case = known[source['id']]
            directory = out / source['id']
            directory.mkdir()
            row = dict(id=source['id'], complete=False)
            report['rows'].append(row)
            save()
            built = native.build(machine_args(emitted['emit'], source['product'], directory / 'machine', left(), args.assets))
            row['buildReceipt'] = common.pin(directory / 'machine/report.json')
            save()
            common.require(built.get('complete') is True and not built.get('changedInputs'),
                           'Machine construction failed: ' + str(built.get('error')))
            if emitted['emit'] == 'object':
                common.require(built.get('emissionFormat') == request.X86_OBJECT_FORMAT
                               and built.get('assemblerSkipped') is True
                               and isinstance(built.get('jobs'), list)
                               and not any(job.get('label') == 'assemble' for job in built['jobs']),
                               'Direct-object construction must skip the assembler')
            product = dict(artifact=built['binary'], generatedSource=source['product'],
                diagnosticAssembly=source['assembly'],
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
            recipe['cases'].append(dict(id=source['id'], products={args.role: product}))
            row['complete'] = True
            row['artifact'] = product['artifact']
            save()
        common.require(not common.changed_inputs(inputs), 'Acquisition inputs changed')
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
    parser.add_argument('--emission', type=Path, required=True)
    parser.add_argument('--assets', type=Path, default=ASSETS)
    parser.add_argument('--role', required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--seconds', type=float, required=True)
    parser.add_argument('--guarded', action='store_true')
    return execute(parser.parse_args())


if __name__ == '__main__':
    sys.exit(main())
