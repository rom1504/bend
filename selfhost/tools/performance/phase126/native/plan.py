#!/usr/bin/env python3
"""Phase126 output-path adapter for the unchanged aligned native qualification contract."""
import argparse
import importlib.util
import json
from pathlib import Path
import re
import shutil
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
ADAPTERS = ROOT / 'selfhost/tools/performance/phase125/native'
PHASE = ROOT / 'selfhost/tools/performance/phase111'
LEGACY = ROOT / 'selfhost/tools/performance/phase118'
BUILDER = ROOT / 'selfhost/tools/performance/phase123/build-aligned.py'
PARENT_RUNTIME_SHA = '1b740d48e0db4504b214e0c909d0b5f28cd49064850e9be69fdb20a53a6c55fe'
KIND = 'phase125-aligned-request-bound-native-qualification-plan'
spec = importlib.util.spec_from_file_location('p125_original_native_contract', LEGACY / 'native-plan-v2.py')
original = importlib.util.module_from_spec(spec)
spec.loader.exec_module(original)
pin, verify, read, require, unique = original.pin, original.verify, original.read, original.require, original.unique
source_contract, REQUIRED = original.source_contract, original.REQUIRED


def receipt_pins(value):
    if isinstance(value, dict):
        if {'file', 'bytes', 'sha256'} <= set(value):
            yield {key: value[key] for key in ['file', 'bytes', 'sha256']}
        for child in value.values():
            yield from receipt_pins(child)
    elif isinstance(value, list):
        for child in value:
            yield from receipt_pins(child)


def runtime_abi(file, source, runtime, built):
    # Successful linking alone cannot admit compiler imports or owning ABIs.
    if file is None:
        require(pin(runtime)['sha256'] == PARENT_RUNTIME_SHA,
                'Changed runtime requires --abi-receipt; no ABI inference from symbols')
        return dict(kind='unchanged-phase118-runtime', runtime=pin(runtime)), []
    receipt = read(file)
    require(receipt.get('kind') == 'phase125-native-runtime-abi-admission' and receipt.get('complete'),
            'Complete Phase125 native runtime ABI admission required')
    require(receipt.get('source') == pin(source) and receipt.get('runtime') == pin(runtime),
            'ABI admission belongs to another compiler/runtime')
    require(receipt.get('runtimeSource') == built.get('source'), 'ABI/runtime build source mismatch')
    imports = receipt.get('imports', [])
    require(imports and all(isinstance(row, dict) and isinstance(row.get('symbol'), str) for row in imports),
            'Explicit admitted import catalogue required')
    require(len({row['symbol'] for row in imports}) == len(imports), 'Duplicate admitted import')
    require(receipt.get('inputs'), 'ABI source/declaration/implementation pins required')
    rows = unique([pin(file), *receipt_pins(receipt)])
    for row in rows:
        verify(row)
    return dict(receipt=pin(file), imports=imports,
                authority='Explicit source-bound ABI receipt; not link inference'), rows


def verify_plan(path):
    plan = read(path)
    require(plan.get('kind') == KIND, 'Phase125 aligned native plan required')
    for row in plan['inputs']:
        verify(row)
    return plan


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    modes = parser.add_subparsers(dest='mode', required=True)
    prep = modes.add_parser('prepare')
    for name in ['api', 'source', 'runtime', 'out']:
        prep.add_argument('--' + name, type=Path, required=True)
    prep.add_argument('--abi-receipt', type=Path)
    prep.add_argument('--tag', required=True)
    prep.add_argument('--hosted-seconds', type=int, default=1200)
    prep.add_argument('--native-seconds', type=int, default=1200)
    prep.add_argument('--build-seconds', type=int, default=120)
    prep.add_argument('--rss-mib', type=int, default=6144)
    check = modes.add_parser('verify')
    check.add_argument('--plan', type=Path, required=True)
    args = parser.parse_args()
    if args.mode == 'verify':
        verify_plan(args.plan)
        print(json.dumps(dict(complete=True, targetsRun=False, plan=pin(args.plan))))
        return
    source, api, runtime, out = [getattr(args, key).resolve() for key in ['source', 'api', 'runtime', 'out']]
    require(not out.exists() and out.is_relative_to(ROOT / 'selfhost/build/phase126'), 'Fresh Phase126 plan required')
    require(re.fullmatch(r'p126-[a-z0-9_-]+', args.tag), 'Lowercase p126- tag required')
    require(min(args.hosted_seconds, args.native_seconds, args.build_seconds) > 0, 'Positive limits required')
    require(2048 <= args.rss_mib <= 6144, 'Full-image RSS ceiling must be 2–6 GiB')
    sr, ar, rr = source.parent / 'manifest.json', api.parent / 'report.json', runtime.parent / 'report.json'
    composed, checked, built = read(sr), read(ar), read(rr)
    require(checked.get('complete') and checked.get('checked') and checked['api'] == pin(api), 'Checked API required')
    require(set(REQUIRED) <= set(checked['exports']) and pin(source) in checked['inputs'], 'API export/source mismatch')
    require([str(Path(x).resolve()) for x in checked['command'] if x.endswith('.bend')] == [str(source)], 'API checked another source')
    require(built.get('complete') and built.get('object') == pin(runtime), 'Complete exact runtime build required')
    contract = source_contract(source, composed)  # Exact original declaration-overlay replay.
    abi, abi_inputs = runtime_abi(args.abi_receipt, source, runtime, built)
    derivation = read(ADAPTERS / 'derivation01.json')
    derived_inputs = [row for item in derivation['adapters'] for row in [item['original'], item['derived']]]
    for row in derived_inputs:
        verify(row)
    assets_path = PHASE / 'native-assets01.json'
    assets = read(assets_path)
    require(assets.get('complete'), 'Frozen native assets required')
    selection = read(verify(assets['selection']))
    admission = read(verify(assets['admission']))
    require(selection['admission'] == assets['admission'] and admission.get('qualified') and admission.get('complete'), 'Seed admission mismatch')
    require(admission['assets']['base'] == assets['base'] and admission['assets']['cache'] == assets['cache'], 'Base/cache mismatch')
    artifacts = {name: ROOT / 'selfhost/build/phase111' / (args.tag + '-' + suffix)
                 for name, suffix in [('hosted', 'full-emit'), ('n1', 'n1'), ('self', 'self'),
                                      ('n1Focused', 'n1-focused'), ('n2Focused', 'n2-focused'), ('n2Full45', 'n2-full45')]}
    artifacts.update(comparison=ROOT / 'selfhost/build/phase126' / (args.tag + '-qbe-comparison.json'),
                     jobs=ROOT / 'selfhost/build/phase113' / (args.tag + '-qualification'),
                     guard=ROOT / 'selfhost/build/phase126' / (args.tag + '-qualification-guard'))
    require(not any(path.exists() for path in artifacts.values()), 'Artifact destination already exists')
    py = [str(Path(sys.executable).resolve()), '-B']
    hosted, emit, focused, full45 = LEGACY / 'native-hosted-v2.mjs', ADAPTERS / 'native-emit.py', ADAPTERS / 'coverage.py', ADAPTERS / 'full45.py'
    runner = ROOT / 'selfhost/tools/performance/phase113/run-jobs.py'
    n1, n2 = artifacts['n1'] / 'program', artifacts['self'] / 'build/program'
    def focus(label, image, target):
        return dict(name=label, seconds=180, command=py + [str(focused), '--image', str(image), '--runtime', str(runtime), '--suite', 'focused', '--seconds', '30', '--build-seconds', '30', '--out', str(target)])
    jobs = [dict(name='authenticate-plan', seconds=30, command=py + [str(Path(__file__).resolve()), 'verify', '--plan', str(out)]),
            dict(name='full-hosted-integrated-emission', seconds=args.hosted_seconds, command=[checked['command'][0], str(hosted), str(api), str(source), str(artifacts['hosted']), 'cache', 'array']),
            dict(name='n1-build', seconds=3 * args.build_seconds + 30, command=py + [str(BUILDER), '--source', str(artifacts['hosted'] / 'program.ssa'), '--runtime', str(runtime), '--out', str(artifacts['n1']), '--seconds', str(args.build_seconds)]),
            focus('n1-focused19', n1, artifacts['n1Focused']),
            dict(name='native-self-emission-n2-build', seconds=args.native_seconds + 3 * args.build_seconds + 60, command=py + [str(emit), '--image', str(n1), '--source', str(source), '--out', str(artifacts['self']), '--mode', 'cache', '--runtime', str(runtime), '--seconds', str(args.native_seconds), '--build-seconds', str(args.build_seconds)]),
            dict(name='exact-hosted-native-qbe', seconds=60, command=py + [str(ADAPTERS / 'comparison.py'), '--plan', str(out), '--out', str(artifacts['comparison'])]),
            focus('n2-focused19', n2, artifacts['n2Focused']),
            dict(name='n2-original-full45', seconds=300, command=py + [str(full45), '--partition', 'all45', '--image', str(n2), '--runtime', str(runtime), '--seconds', '120', '--build-seconds', '10', '--out', str(artifacts['n2Full45'])])]
    methods = [Path(__file__), ADAPTERS / 'plan.py', ADAPTERS / 'comparison.py', LEGACY / 'native-plan-v2.py', LEGACY / 'integrated-entry.bend', hosted,
               BUILDER, emit, focused, full45, runner, PHASE / 'guard.py', assets_path, ADAPTERS / 'derivation01.json',
               PHASE / 'coverage/manifest.json', PHASE / 'coverage/full45/manifest.json',
               ROOT / 'selfhost/tools/performance/programs/support.py']
    tools = [Path(sys.executable).resolve(), Path(checked['command'][0]).resolve(),
             ROOT / 'selfhost/build/phase108/toolchain/qbe-1.3/qbe',
             Path(shutil.which('as')).resolve(), Path(shutil.which('gcc')).resolve()]
    inputs = [*[pin(path) for path in methods + tools + [sr, ar, rr, source, api, runtime]],
              *composed['inputs'], *contract['snapshots'], *checked['inputs'], *built['inputs'], built['source'],
              assets['selection'], assets['admission'], assets['base'], assets['cache']['carrier'], *abi_inputs, *derived_inputs]
    for suite in [read(PHASE / 'coverage/manifest.json'), read(PHASE / 'coverage/full45/manifest.json')]:
        rows = list(suite.get('inputs', []))
        for case in suite['fixtures']:
            rows.extend(case[key] for key in ['source', 'origin', 'stdoutFile', 'expectationFile', 'independentPriorEvidence'] if key in case)
        inputs.extend(dict(row, file=str((ROOT / row['file']).resolve())) for row in rows)
    inputs = unique(inputs)
    for row in inputs:
        verify(row)
    seconds = sum(job['seconds'] for job in jobs) + 60
    guard = py + [str(PHASE / 'guard.py'), '--out', str(artifacts['guard']), '--seconds', str(seconds), '--rss-mib', str(args.rss_mib), '--available-mib', '16384', '--file-mib', '128', '--cpu', '3', '--', *py, str(runner), '--plan', str(out), '--out', str(artifacts['jobs'])]
    plan = dict(phase126Adapter=dict(parent=pin(ADAPTERS / 'plan.py'), scope='Only output paths/tag and method locations changed; retain the Phase125 contract kind for its unchanged verification/comparison adapters.'), kind=KIND, complete=True, targetsRun=False, inputs=inputs, source=pin(source), api=pin(api), runtime=pin(runtime),
                sourceManifest=pin(sr), apiReport=pin(ar), runtimeReport=pin(rr), transportContract=contract, runtimeAbiAdmission=abi,
                machineBuild=dict(method=pin(BUILDER), assemblerOption='-mbranches-within-32B-boundaries'),
                assets={key: assets[key] for key in ['base', 'cache', 'selection', 'admission']}, jobs=jobs,
                artifacts={key: str(value) for key, value in artifacts.items()}, rootGuardCommand=guard,
                guard=dict(cpu=3, rssMiB=args.rss_mib, availableMiB=16384, fileMiB=128, seconds=seconds),
                scope='Aligned integrated hosted→N1→native-self→N2 raw-QBE reproduction, original focused19/full45. Original native checker/verifier retained. No ELF fixed point, N2 self-emission, timing or installed promotion claim.')
    out.parent.mkdir(parents=True, exist_ok=True)
    with out.open('x') as stream:
        json.dump(plan, stream, indent=2)
        stream.write('\n')
    print(json.dumps(dict(complete=True, targetsRun=False, plan=pin(out), rootGuardCommand=guard)))


if __name__ == '__main__':
    main()
