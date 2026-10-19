#!/usr/bin/env python3
"""Freeze word-profile native N1/N2 transport roles after self-acquisition completes.

Source-only receipt/hash authentication. No compiler or product execution.
"""
import argparse
import copy
from datetime import datetime, timezone
import importlib.util
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
spec = importlib.util.spec_from_file_location('transport_method', HERE / 'run.py')
method = importlib.util.module_from_spec(spec)
spec.loader.exec_module(method)


def read(path):
    return json.loads(Path(path).read_text())


def contains_pin(rows, expected):
    return any(x == expected for x in method.pins(rows))


def checked_build(receipt_pin, binary, product, manifest):
    path = method.verify(receipt_pin)
    built = read(path)
    if not built.get('complete') or built.get('perProgramC') or built.get('cproc') or built.get('binary') != binary:
        raise ValueError('Complete direct build for exact binary required: ' + str(path))
    method.verify(binary)
    method.verify(product)
    jobs = {x['label']: x['command'] for x in built['jobs']}
    qbe, assembler, linker = [jobs[x] for x in ['qbe', 'assemble', 'link']]
    if (len(qbe) != 6 or qbe[1:4] != ['-t', 'amd64_sysv', '-o'] or qbe[-1] != product['file'] or
            len(assembler) != 4 or assembler[1] != '-o' or assembler[3] != qbe[4] or
            len(linker) != 8 or linker[1] != '-no-pie' or linker[2] != assembler[2] or
            linker[3] != manifest['runtime']['file'] or linker[-4:-2] != ['-pthread', '-lm'] or
            linker[-1] != binary['file']):
        raise ValueError('Unexpected direct build graph or runtime')
    for name, command in [('qbe', qbe), ('assembler', assembler), ('linker', linker)]:
        if method.pin(command[0]) != manifest['tools'][name]:
            raise ValueError('Changed build tool: ' + name)
    for item in built['inputs']:
        method.verify(item)
    if not contains_pin(built['inputs'], product) or not contains_pin(built['inputs'], manifest['runtime']):
        raise ValueError('Build must bind exact QBE and runtime inputs')
    return built


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--previous', type=Path, default=HERE/'manifest02.json')
    parser.add_argument('--self-report', type=Path, default=ROOT/'selfhost/build/phase111/p112-word-self01/report.json')
    parser.add_argument('--out', type=Path, default=HERE/'manifest03.json')
    args = parser.parse_args()
    if args.out.exists():
        raise ValueError('Fresh manifest path required')
    previous = read(args.previous)
    if previous.get('kind') != 'phase112-frozen-native-transport-comparison':
        raise ValueError('Frozen prior transport manifest required')
    n1 = previous['roles']['phase112']
    source, image1 = n1['source'], n1['binary']
    method.verify(source)
    method.verify(image1)
    for item in method.pins(previous):
        method.verify(item)
    self_receipt = read(args.self_report)
    if not self_receipt.get('complete'):
        raise ValueError('Word N2 self-acquisition is not complete; no manifest written')
    if self_receipt.get('image') != image1 or self_receipt.get('mode') != 'cache':
        raise ValueError('N2 must be produced by exact word N1 in cache mode')
    if not contains_pin(self_receipt['inputs'], source):
        raise ValueError('Self-request did not bind exact word N1 source')
    requests = [x for x in self_receipt['jobs'] if x['label'] == 'native-request']
    assets = previous['nativeAssets']
    expected_command = [image1['file'], '--threads', '1', '--gpu', 'off', '--', 'phase111',
                        source['file'], assets['base']['file'], 'cache',
                        assets['cache']['carrier']['file'], assets['cache']['stamp']]
    if len(requests) != 1 or requests[0]['command'] != expected_command or requests[0].get('status') != 'complete':
        raise ValueError('Actual successful self-request command must match pinned N1/source/assets')
    comparison = self_receipt.get('comparison', {})
    if not comparison.get('byteExact'):
        raise ValueError('Self-request must have completed exact comparison with checked N1 acquisition')
    emission1_pin = comparison['reference']
    emission1 = read(method.verify(emission1_pin))
    if not emission1.get('complete') or not emission1.get('sourceChecked') or not contains_pin(emission1['inputs'], source):
        raise ValueError('Checked hosted N1 acquisition for exact same compiler source required')
    if comparison['product'] != emission1['product']:
        raise ValueError('Comparison reference product differs from checked N1 acquisition')
    product1, product2 = emission1['product'], self_receipt['product']
    if any(product1[k] != product2[k] for k in ['bytes', 'sha256']):
        raise ValueError('N1/N2 compiler QBE comparison does not match actual pins')
    build1_pin, build2_pin = self_receipt['imageReceipt'], self_receipt['buildReport']
    build2 = read(method.verify(build2_pin))
    image2 = build2['binary']
    checked_build(build1_pin, image1, product1, previous)
    checked_build(build2_pin, image2, product2, previous)
    for item in self_receipt['inputs']:
        method.verify(item)
    manifest = copy.deepcopy(previous)
    manifest['frozenUtc'] = datetime.now(timezone.utc).isoformat()
    manifest['roles']['phase111'] = dict(n1, generation='Word-profile N1, acquired through checked hosted Bend source API; legacy role key phase111.')
    manifest['roles']['phase112'] = dict(binary=image2, source=source,
        generation='Word-profile N2, built from word N1 native compilation of the identical compiler source; legacy role key phase112.')
    manifest['lineage'] = dict(
        comparison='Same-source word-profile route N1 versus N2 and pinned upstream; not the earlier Phase111-source versus Phase112-source comparison.',
        roleKeys=dict(phase111='word N1', phase112='word N2', upstream='pinned TypeScript/Bun C compiler'),
        sameCompilerSource=source, n1Qbe=product1, n2Qbe=product2, qbeByteExact=True,
        ratioKeys={'phase112/phase111':'word N2 time / word N1 time',
                   'phase112/upstream':'word N2 time / upstream time',
                   'phase111/upstream':'word N1 time / upstream time'},
        limits='N1/N2 names describe this experimental route, not production B1/B2 labels. This screen checks three emitted products; self-acquisition alone is not broad N2 semantic qualification.')
    manifest['roleAcquisition'] = dict(phase111=dict(emission=emission1_pin, build=build1_pin),
        phase112=dict(selfRequest=method.pin(args.self_report), build=build2_pin))
    manifest['historicalWordN1Qualification'] = manifest.pop('candidateAcquisition', [])
    manifest['derivation'] = dict(previous=method.pin(args.previous), preparer=method.pin(__file__),
        runner=method.pin(HERE/'run.py'),
        change='Map legacy phase111 to word N1 and legacy phase112 to same-source word N2; add explicit lineage and acquisition pins. Cases, expected outputs, runtime, assets, upstream, timer, schedule, flags and limits unchanged.')
    for key in ['cases', 'nativeAssets', 'runtime', 'tools', 'scope', 'timer', 'buildPolicy', 'limits']:
        if manifest[key] != previous[key]:
            raise ValueError('Unexpected screen-method change: ' + key)
    if manifest['roles']['upstream'] != previous['roles']['upstream']:
        raise ValueError('Upstream changed')
    for item in method.pins(manifest):
        method.verify(item)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(manifest, indent=2)+'\n')
    print(json.dumps(dict(complete=True, targetsRun=False, manifest=method.pin(args.out),
                         roleKeys=manifest['lineage']['roleKeys'], sameSource=True, qbeByteExact=True)))


if __name__ == '__main__':
    main()
