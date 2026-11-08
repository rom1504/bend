#!/usr/bin/env python3
"""Prepare a main-only old-argv bootstrap bridge; never execute compiler targets."""
import argparse
import copy
import hashlib
import json
from pathlib import Path
import shutil
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
BUILD = ROOT / 'selfhost/tools/build'
sys.path.insert(0, str(BUILD))
import assets
import source
from common import changed_inputs, fresh_output, pin, require, verify, write_json

OLD_SEED = 'phase182-old-seed'
OLD_RUNTIME = 'phase182-old-runtime'
OLD_MAIN = b'    p111_native_args(List.tail(&1,String,args))'
BRIDGE_MAIN = b'    p111_native_args(args)'


def same(a, b):
    return isinstance(a, dict) and isinstance(b, dict) and all(a.get(k) == b.get(k)
        and k in a for k in ('bytes', 'sha256'))


def main_only(canonical):
    prefix, rows = source.blocks(canonical)
    before = source.grouped(rows)
    require(len(before.get('main', [])) == 1, 'Exactly one canonical main required')
    main = before['main'][0]
    require(main['data'].count(OLD_MAIN) == 1 and canonical.count(OLD_MAIN) == 1,
            'Exact new-argv main seam differs')
    replacement = main['data'].replace(OLD_MAIN, BRIDGE_MAIN)
    cut = main['offset']
    suffix = cut + len(main['data'])
    bridge = canonical[:cut] + replacement + canonical[suffix:]
    after_prefix, after_rows = source.blocks(bridge)
    after = source.grouped(after_rows)
    require(prefix == after_prefix and set(before) == set(after), 'Declaration inventory changed')
    changed = [name for name in before if [r['data'] for r in before[name]] != [r['data'] for r in after[name]]]
    require(changed == ['main'] and after['main'][0]['data'] == replacement,
            'Only the exact main body may differ')
    require(bridge[:cut] == canonical[:cut] and bridge[cut+len(replacement):] == canonical[suffix:],
            'Protected compiler bytes changed')
    return bridge, dict(changedDeclarations=changed, allOtherBodiesIdentical=True,
        protectedBytes=len(canonical)-len(main['data']),
        protectedSha256=hashlib.sha256(canonical[:cut]+canonical[suffix:]).hexdigest(),
        oldMain=dict(bytes=len(main['data']),sha256=hashlib.sha256(main['data']).hexdigest()),
        bridgeMain=dict(bytes=len(replacement),sha256=hashlib.sha256(replacement).hexdigest()))


def prepare(args):
    inputs = [pin(__file__), pin(source.__file__), pin(assets.__file__), pin(BUILD/'common.py')]
    def read(file):
        row = pin(file); inputs.append(row)
        return row, json.loads(verify(row).read_text())
    canonical = pin(args.canonical); inputs.append(canonical)
    manifest_pin, manifest = read(args.manifest)
    require(manifest.get('upstream') == '9a4223d577ba56a0cb53d1fd952d2b481c38930f',
            'Explicit Phase182 maintained source required')
    assembled = source.maintained_assemble(args.manifest, ROOT/'selfhost', 'qbe')
    require(same(canonical,dict(bytes=len(assembled),sha256=hashlib.sha256(assembled).hexdigest())),
            'Canonical snapshot differs from maintained source')
    inputs += [pin(ROOT/'selfhost'/name) for name in manifest['modules']]
    bridge, audit = main_only(verify(canonical).read_bytes())
    require(bridge.count(b'P111QLong{11102,0},P111QLong{192,0},') == 1,
            'Current target ABI descriptor source differs')
    seed_pin, seed = read(args.seed_report)
    qualified_pin, qualified = read(args.seed_qualification)
    reproduction_pin, reproduction = read(args.seed_reproduction)
    binding = seed.get('imageBinding', {})
    require(seed.get('kind') == 'bend-native-build' and seed.get('complete') is True
            and not seed.get('error') and not seed.get('changedInputs')
            and seed.get('comparedToReference') is True and same(seed.get('irDigest'), seed.get('expectedQbe'))
            and binding.get('complete') is True and binding.get('host') == 'native'
            and binding.get('stage') == 'N2' and binding.get('protocol') == 'qbe-source-v1'
            and binding.get('targets') == ['qbe'] and same(binding.get('image'), seed.get('binary')),
            'Actual fixed-point native N2 seed required')
    require(assets.runtime_argument_convention(binding) == 'bend-legacy-v1'
            and same(binding.get('linkedRuntime'), seed.get('runtime')), 'Seed runtime is not the old convention')
    require(qualified.get('kind') == 'bend-finite-qualification' and qualified.get('complete') is True
            and qualified.get('passed') is True and not qualified.get('changedInputs')
            and qualified.get('counts') == {'pass':64,'fail':0,'unsupported':0}
            and (qualified.get('host'),qualified.get('stage'),qualified.get('target')) == ('native','N2','qbe')
            and same(qualified.get('image'), seed['binary']), 'Exact seed64 qualification required')
    require(reproduction.get('kind') == 'bend-build-request' and reproduction.get('complete') is True
            and reproduction.get('byteExact') is True and not reproduction.get('changedInputs')
            and (reproduction.get('host'),reproduction.get('stage'),reproduction.get('target')) == ('native','N2','qbe')
            and same(reproduction.get('image'), seed['binary'])
            and same(reproduction.get('source'), binding['sourceIdentity'])
            and same(reproduction.get('product'), seed['irDigest']), 'Actual seed Q3 reproduction required')
    for row in (seed['binary'], seed['runtime'], binding['sourceIdentity']):
        verify(row); inputs.append(row)
    require(verify(binding['sourceIdentity']).read_bytes().count(b'P111QLong{11101,0},P111QLong{192,0},') == 1,
            'Seed source must emit ABI11101')
    document = assets.load_assets(args.assets, ROOT); inputs.append(document['_manifest'])
    require(document.get('upstream') == manifest['upstream'], 'Current asset/source upstream differs')
    base, carrier, stamp, base_inputs = assets.prepared_base(document,'cache')
    inputs += base_inputs
    new_runtime = assets.asset(document,'qbe-runtime'); inputs.append(new_runtime)
    require(assets.runtime_argument_convention(assets.runtime_provider(document,'qbe-runtime')) == 'bend-rts-v1'
            and not same(new_runtime,seed['runtime']), 'Distinct current RTS runtime required')
    require(OLD_SEED not in document['assets'] and OLD_RUNTIME not in document['assets'], 'Bridge asset key collision')
    out = fresh_output(args.out,ROOT)
    (out/'compiler.bend').write_bytes(bridge)
    shutil.copyfile(verify(seed['runtime']),out/'old-runtime.o')
    old_runtime = pin(out/'old-runtime.o')
    require(same(old_runtime,seed['runtime']), 'Copied old runtime differs')
    output_assets = {key:copy.deepcopy(value) for key,value in document.items() if not key.startswith('_')}
    output_assets['assets'][OLD_RUNTIME] = dict(old_runtime,runtimeArgumentConvention='bend-legacy-v1')
    output_assets['assets'][OLD_SEED] = dict(seed['binary'],executable=True)
    seed_binding = copy.deepcopy(binding)
    seed_binding['runtimeArgumentConvention'] = 'bend-legacy-v1'
    # Exact retained source/image/runtime identities; no stage or source relabel.
    output_assets.setdefault('images',{})[OLD_SEED] = seed_binding
    output_assets.setdefault('runtimePolicies',{})[OLD_RUNTIME] = dict(
        seed.get('runtimePolicy') or {},runtimeArgumentConvention='bend-legacy-v1')
    output_assets['bootstrapBridge'] = dict(kind='phase182-main-only-old-argv',version=1,
        seed=seed_pin,qualification=qualified_pin,reproduction=reproduction_pin,
        canonical=canonical,source=pin(out/'compiler.bend'),parentAssets=document['_manifest'],
        oldRuntimeSource=seed['runtime'],oldRuntimeCopy=old_runtime,
        scope='Bootstrap only. Old seed/bridge execute legacy CLI; ordinary generations link the current qbe-runtime.')
    write_json(out/'assets.json',output_assets)
    require(not changed_inputs(inputs), 'Inputs changed while preparing bridge')
    report = dict(kind='phase182-native-bootstrap-bridge',version=1,complete=True,targetsRun=False,
        sourceChecked=False,installed=False,promotable=False,source=pin(out/'compiler.bend'),
        canonicalSource=canonical,sourceRecipe=manifest_pin,assets=pin(out/'assets.json'),
        seed=seed_pin,seedQualification=qualified_pin,seedReproduction=reproduction_pin,
        oldRuntime=old_runtime,newRuntime=new_runtime,base=base,carrier=carrier,stamp=stamp,
        seedAssetKey=OLD_SEED,bridgeRuntimeKey=OLD_RUNTIME,ordinaryRuntimeKey='qbe-runtime',
        bridgeLinkedAbi=11101,bridgeEmittedAbi=11102,bridgeRuntimeArgumentConvention='bend-legacy-v1',
        ordinaryRuntimeArgumentConvention='bend-rts-v1',**audit,inputs=inputs,
        scope='Exact main-only source transport and retained seed evidence. Independent source checking, actual bridge construction, current N1/N2/Q3 execution and qualification remain required.')
    write_json(out/'report.json',report)
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--canonical',type=Path,required=True)
    parser.add_argument('--assets',type=Path,required=True)
    parser.add_argument('--manifest',type=Path,default=ROOT/'selfhost/src/compiler.json')
    parser.add_argument('--seed-report',type=Path,default=ROOT/'selfhost/build/phase175/full-native-n2/report.json')
    parser.add_argument('--seed-qualification',type=Path,default=ROOT/'selfhost/build/phase175/full-native64/report.json')
    parser.add_argument('--seed-reproduction',type=Path,default=ROOT/'selfhost/build/phase175/full-native-q3/report.json')
    parser.add_argument('--out',type=Path,required=True)
    result = prepare(parser.parse_args())
    print(json.dumps({key:result[key] for key in ('complete','targetsRun','source','assets')}))
