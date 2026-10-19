#!/usr/bin/env python3
"""Freeze original Phase111 N2 versus facts N2/upstream; authenticate only."""
import argparse
import copy
from datetime import datetime, timezone
import importlib.util
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
spec = importlib.util.spec_from_file_location('transport_generation_checks', HERE/'prepare-word-generations.py')
checks = importlib.util.module_from_spec(spec)
spec.loader.exec_module(checks)
method, read = checks.method, checks.read


def canonical(item):
    actual = method.pin(ROOT/item['file'])
    if any(actual[k] != item[k] for k in ['bytes', 'sha256']):
        raise ValueError('Changed input: '+item['file'])
    return actual


def authenticate_parent(pin, image, product, template):
    parent = read(method.verify(pin))
    if 'jobs' in parent:
        checks.checked_build(pin, image, product, template)
        return
    if parent.get('kind') != 'phase111-direct-qbe-runtime-relink' or not parent.get('complete') or parent.get('exitCode') != 0 or parent.get('binary') != image:
        raise ValueError('Unknown or incomplete parent build/relink receipt')
    command = parent['command']
    if command[1:] != ['-no-pie', parent['object']['file'], template['runtime']['file'], '-pthread', '-lm', '-o', image['file']] or method.pin(command[0]) != template['tools']['linker']:
        raise ValueError('Parent relink graph differs from selected runtime/flags')
    original = read(method.verify(parent['originalBuild']))
    if not original.get('complete') or original.get('object') != parent['object'] or not checks.contains_pin(original['inputs'], product):
        raise ValueError('Parent relink must retain original checked-source object')
    jobs = {x['label']: x['command'] for x in original['jobs']}
    qbe, assembler = jobs['qbe'], jobs['assemble']
    if qbe[1:4] != ['-t', 'amd64_sysv', '-o'] or qbe[-1] != product['file'] or assembler[1:] != ['-o', parent['object']['file'], qbe[4]]:
        raise ValueError('Original parent object graph differs from checked QBE')
    for tool, command in [('qbe', qbe), ('assembler', assembler)]:
        if method.pin(command[0]) != template['tools'][tool]:
            raise ValueError('Parent object tool changed')
    for item in [*parent['inputs'], product, image]:
        method.verify(item)


def authenticate_n2(role, self_pin, template):
    receipt = read(method.verify(self_pin))
    if not receipt.get('complete') or receipt.get('gates', {}).get('build') != 'passed':
        raise ValueError('Completed native self-request and build required')
    if not checks.contains_pin(receipt['inputs'], role['source']):
        raise ValueError('N2 self-request must bind its exact compiler source')
    comparison = receipt.get('comparison', {})
    if not comparison.get('byteExact'):
        raise ValueError('Completed exact compiler QBE comparison required')
    hosted = read(method.verify(comparison['reference']))
    if not hosted.get('complete') or not hosted.get('sourceChecked') or not checks.contains_pin(hosted['inputs'], role['source']):
        raise ValueError('Checked source-authentic hosted acquisition required')
    if hosted['product'] != comparison['product'] or any(hosted['product'][k] != receipt['product'][k] for k in ['bytes', 'sha256']):
        raise ValueError('Native/checked compiler QBE pins differ')
    assets = template['nativeAssets']
    command = [receipt['image']['file'], '--threads', '1', '--gpu', 'off', '--', 'phase111',
               role['source']['file'], assets['base']['file'], 'cache', assets['cache']['carrier']['file'], assets['cache']['stamp']]
    requests = [x for x in receipt['jobs'] if x['label'] == 'native-request']
    if len(requests) != 1 or requests[0]['command'] != command or requests[0].get('status') != 'complete':
        raise ValueError('Self-request command differs from source/assets/parent image')
    authenticate_parent(receipt['imageReceipt'], receipt['image'], hosted['product'], template)
    checks.checked_build(receipt['buildReport'], role['binary'], receipt['product'], template)
    for item in receipt['inputs']:
        method.verify(item)
    return dict(selfRequest=self_pin, build=receipt['buildReport'],
                parentBuild=receipt['imageReceipt'], checkedSourceEmission=comparison['reference'])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--baseline-manifest', type=Path, default=HERE/'manifest02.json')
    parser.add_argument('--candidate-manifest', type=Path, default=HERE/'manifest04.json')
    parser.add_argument('--selection', type=Path, default=ROOT/'implementation/phase111/selection.json')
    parser.add_argument('--candidate-focused', type=Path, default=ROOT/'selfhost/build/phase111/p112-facts-n2-focused01/report.json')
    parser.add_argument('--candidate-full45', type=Path, default=ROOT/'selfhost/build/phase111/p112-facts-n2-full45-01/report.json')
    parser.add_argument('--out', type=Path, default=HERE/'manifest05.json')
    args = parser.parse_args()
    if args.out.exists():
        raise ValueError('Fresh comparison manifest required')
    baseline, candidate, selection = [read(p) for p in [args.baseline_manifest, args.candidate_manifest, args.selection]]
    for value in [baseline, candidate]:
        if value.get('kind') != 'phase112-frozen-native-transport-comparison':
            raise ValueError('Frozen transport manifests required')
        for item in method.pins(value):
            method.verify(item)
    for key in ['cases', 'nativeAssets', 'runtime', 'tools', 'scope', 'timer', 'buildPolicy', 'limits', 'upstreamRevision']:
        if baseline[key] != candidate[key]:
            raise ValueError('Unmatched comparison method: '+key)
    if baseline['roles']['upstream'] != candidate['roles']['upstream']:
        raise ValueError('Upstream differs')
    old_role, new_role = baseline['roles']['phase111'], candidate['roles']['phase112']
    if not selection.get('complete') or not selection.get('qualified') or canonical(selection['source']) != old_role['source'] or canonical(selection['successor']) != old_role['binary']:
        raise ValueError('Baseline must match exact qualified Phase111 source/N2 selection')
    old_self = next(canonical(x) for x in selection['evidence'] if x['file'].endswith('/native-self02/report.json'))
    old_acquisition = authenticate_n2(old_role, old_self, baseline)
    new_acquisition = authenticate_n2(new_role, candidate['roleAcquisition']['phase112']['selfRequest'], candidate)
    qualification = []
    for path, count in [(args.candidate_focused, 19), (args.candidate_full45, 45)]:
        report = read(path)
        if not report.get('complete') or not report.get('passed') or len(report.get('names', [])) != count or not checks.contains_pin(report['inputs'], new_role['binary']):
            raise ValueError('Completed exact facts N2 qualification required: '+str(path))
        qualification.append(method.pin(path))
    manifest = copy.deepcopy(candidate)
    manifest['frozenUtc'] = datetime.now(timezone.utc).isoformat()
    manifest['roles']['phase111'] = dict(old_role, generation='Original qualified Phase111 route N2 from full-source05; baseline key phase111.')
    manifest['roles']['phase112'] = dict(new_role, generation='Final facts-profile route N2 from facts-source01; candidate key phase112.')
    stages = dict(phase111=dict(label='Original Phase111 N2', generation='N2', source=old_role['source'], binary=old_role['binary']),
                  phase112=dict(label='Facts N2', generation='N2', source=new_role['source'], binary=new_role['binary']),
                  upstream=dict(label='Pinned TypeScript/Bun C workflow', generation='upstream acquisition'))
    manifest['stageLineage'] = stages
    manifest['lineage'] = dict(comparison='Direct matched original Phase111 N2 versus facts N2 and upstream; different compiler sources at equal route generation.',
        roleKeys=dict(phase111='Original Phase111 N2', phase112='Facts N2', upstream='Pinned TypeScript/Bun C workflow'),
        stageLineage=stages, sameCompilerSource=False,
        ratioKeys={'phase112/phase111':'Facts N2 time / original Phase111 N2 time',
                   'phase112/upstream':'Facts N2 time / upstream time',
                   'phase111/upstream':'Original Phase111 N2 time / upstream time'},
        excludedFeatures=['immediates'],
        limits='Direct same-campaign observations only; no multiplication of ratios from other campaigns. Experimental route N2 labels do not rename production B1/B2. Native QBE versus upstream C remains a configured-workflow comparison.')
    manifest['candidateParentAcquisition'] = copy.deepcopy(candidate['roleAcquisition']['phase111'])
    manifest['roleAcquisition'] = dict(phase111=dict(old_acquisition, selection=method.pin(args.selection)), phase112=new_acquisition)
    manifest['candidateQualification'] = qualification
    manifest['roleSourceComposition'] = dict(phase112=manifest.pop('sourceComposition'))
    manifest['derivation'] = dict(baseline=method.pin(args.baseline_manifest), candidate=method.pin(args.candidate_manifest),
        preparer=method.pin(__file__), checks=method.pin(HERE/'prepare-word-generations.py'), runner=method.pin(HERE/'run.py'),
        change='Select original Phase111 N2 role from manifest02 and final facts N2 role from manifest04. Preserve exact three sources/output checks, upstream, runtime, clocks, order, policy, flags and limits.')
    for item in method.pins(manifest):
        method.verify(item)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(manifest, indent=2)+'\n')
    print(json.dumps(dict(complete=True, targetsRun=False, manifest=method.pin(args.out), roles=manifest['lineage']['roleKeys'])))


if __name__ == '__main__':
    main()
