#!/usr/bin/env python3
"""Freeze a same-source profile N1/N2 transport manifest from completed receipts.

Defaults are the facts profile, excluding immediates. No target execution.
The original word-profile preparer remains unchanged and supplies build checks.
"""
import argparse
import copy
from datetime import datetime, timezone
import importlib.util
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
spec = importlib.util.spec_from_file_location('word_preparer', HERE/'prepare-word-generations.py')
original = importlib.util.module_from_spec(spec)
spec.loader.exec_module(original)
method, read, contains_pin, checked_build = original.method, original.read, original.contains_pin, original.checked_build


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--previous', type=Path, default=HERE/'manifest02.json')
    parser.add_argument('--profile', default='facts')
    parser.add_argument('--source-dir', type=Path, default=ROOT/'selfhost/build/phase112/facts-source01')
    parser.add_argument('--api-report', type=Path, default=ROOT/'selfhost/build/phase111/p112-facts-api02/report.json')
    parser.add_argument('--n1-emission', type=Path, default=ROOT/'selfhost/build/phase111/p112-facts-full-emit01/report.json')
    parser.add_argument('--n1-build', type=Path, default=ROOT/'selfhost/build/phase111/p112-facts-full-native01/report.json')
    parser.add_argument('--self-report', type=Path, default=ROOT/'selfhost/build/phase111/p112-facts-self01/report.json')
    parser.add_argument('--out', type=Path, default=HERE/'manifest04.json')
    args = parser.parse_args()
    if args.out.exists():
        raise ValueError('Fresh manifest path required')
    previous = read(args.previous)
    if previous.get('kind') != 'phase112-frozen-native-transport-comparison':
        raise ValueError('Frozen prior transport manifest required')
    source_manifest = args.source_dir/'manifest.json'
    profile_file = args.source_dir/'profile.json'
    composition, profile = read(source_manifest), read(profile_file)
    if not composition.get('prepared') or profile.get('profile') != args.profile:
        raise ValueError('Prepared exact named profile required')
    if any('/immediates/' in str(x) for x in profile['command']):
        raise ValueError('Immediates profile is excluded from this transport screen')
    source = composition['source']
    if method.verify(source) != (args.source_dir/'compiler.bend').resolve():
        raise ValueError('Composition source differs from selected source directory')
    api = read(args.api_report)
    if not api.get('complete') or not api.get('checked') or 'p111_compile_source' not in api.get('exports', []):
        raise ValueError('Completed checked compiler API required')
    if not contains_pin(api['inputs'], source):
        raise ValueError('Compiler API does not bind exact selected source')
    method.verify(api['api'])
    emit1, build1 = read(args.n1_emission), read(args.n1_build)
    self_receipt = read(args.self_report)
    if not all(x.get('complete') for x in [emit1, build1, self_receipt]):
        raise ValueError('N1 acquisition and N2 self-acquisition must complete; no manifest written')
    if not emit1.get('sourceChecked') or not contains_pin(emit1['inputs'], source):
        raise ValueError('N1 emission must check exact selected source')
    if not contains_pin(emit1['inputs'], api['api']) or not contains_pin(emit1['inputs'], method.pin(args.api_report)):
        raise ValueError('N1 emission must bind selected checked API and receipt')
    image1, product1 = build1['binary'], emit1['product']
    if self_receipt.get('image') != image1 or self_receipt.get('mode') != 'cache' or not contains_pin(self_receipt['inputs'], source):
        raise ValueError('N2 must be produced by exact N1 and identical source in cache mode')
    assets = previous['nativeAssets']
    command = [image1['file'], '--threads', '1', '--gpu', 'off', '--', 'phase111', source['file'],
               assets['base']['file'], 'cache', assets['cache']['carrier']['file'], assets['cache']['stamp']]
    requests = [x for x in self_receipt['jobs'] if x['label'] == 'native-request']
    if len(requests) != 1 or requests[0]['command'] != command or requests[0].get('status') != 'complete':
        raise ValueError('Successful self-request command must match exact N1/source/assets')
    comparison = self_receipt.get('comparison', {})
    if not comparison.get('byteExact') or comparison.get('reference') != method.pin(args.n1_emission) or comparison.get('product') != product1:
        raise ValueError('Exact comparison against actual selected N1 emission required')
    product2 = self_receipt['product']
    if any(product1[k] != product2[k] for k in ['bytes', 'sha256']):
        raise ValueError('Actual compiler QBE pins differ')
    build1_pin, build2_pin = method.pin(args.n1_build), self_receipt['buildReport']
    if self_receipt.get('imageReceipt') != build1_pin:
        raise ValueError('Self-request image receipt differs from selected N1 build')
    build2 = read(method.verify(build2_pin))
    image2 = build2['binary']
    checked_build(build1_pin, image1, product1, previous)
    checked_build(build2_pin, image2, product2, previous)
    for item in [*method.pins(previous), *api['inputs'], *emit1['inputs'], *self_receipt['inputs']]:
        method.verify(item)
    manifest = copy.deepcopy(previous)
    label = args.profile
    manifest['frozenUtc'] = datetime.now(timezone.utc).isoformat()
    manifest['roles']['phase111'] = dict(binary=image1, source=source,
        generation=f'{label} N1, acquired through checked hosted Bend source API; legacy role key phase111.')
    manifest['roles']['phase112'] = dict(binary=image2, source=source,
        generation=f'{label} N2, built from native N1 compilation of identical compiler source; legacy role key phase112.')
    manifest['lineage'] = dict(comparison=f'Same-source {label} N1 versus N2 and pinned upstream.',
        roleKeys=dict(phase111=label+' N1', phase112=label+' N2', upstream='pinned TypeScript/Bun C compiler'),
        sameCompilerSource=source, n1Qbe=product1, n2Qbe=product2, qbeByteExact=True,
        ratioKeys={'phase112/phase111':label+' N2 time / '+label+' N1 time',
                   'phase112/upstream':label+' N2 time / upstream time',
                   'phase111/upstream':label+' N1 time / upstream time'},
        excludedFeatures=['immediates'],
        limits='Route N1/N2, not production B1/B2 labels. Self-acquisition is not broad N2 semantic qualification; this screen checks three generated products.')
    manifest['roleAcquisition'] = dict(phase111=dict(api=api['api'], apiReceipt=method.pin(args.api_report),
        emission=method.pin(args.n1_emission), build=build1_pin),
        phase112=dict(selfRequest=method.pin(args.self_report), build=build2_pin))
    manifest['sourceComposition'] = dict(manifest=method.pin(source_manifest), profile=method.pin(profile_file),
        selectedProfile=label, immediateModulesSelected=False)
    manifest['historicalWordN1Qualification'] = manifest.pop('candidateAcquisition', [])
    manifest['derivation'] = dict(previous=method.pin(args.previous), preparer=method.pin(__file__),
        reusedPreparer=method.pin(HERE/'prepare-word-generations.py'), runner=method.pin(HERE/'run.py'),
        change='Replace native images with explicit same-source profile N1/N2 and pin actual provenance. Cases, outputs, clocks, order, upstream, assets, runtime, flags and limits unchanged.')
    for key in ['cases', 'nativeAssets', 'runtime', 'tools', 'scope', 'timer', 'buildPolicy', 'limits']:
        if manifest[key] != previous[key]:
            raise ValueError('Unexpected method change: '+key)
    if manifest['roles']['upstream'] != previous['roles']['upstream']:
        raise ValueError('Upstream changed')
    for item in method.pins(manifest):
        method.verify(item)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(manifest, indent=2)+'\n')
    print(json.dumps(dict(complete=True, targetsRun=False, manifest=method.pin(args.out),
        roles=manifest['lineage']['roleKeys'], qbeByteExact=True, immediatesExcluded=True)))


if __name__ == '__main__':
    main()
