#!/usr/bin/env python3
"""Prepare an audited additive x86 release and asset maps; never install or run targets.

The authenticated installed Phase182 promotion supplies the unchanged JS/C/QBE
components and gates. New assembly evidence is independently audited by the
maintained release tool. Historical preparation code is not imported.
"""
import argparse
import copy
import hashlib
import json
from pathlib import Path
import shutil
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
BUILD = ROOT/'selfhost/tools/build'
sys.path.insert(0, str(BUILD))
import assets
import release
import source
from common import changed_inputs, fresh_output, pin, require, verify, write_json

ROLES = ('sourceCheck', 'seed', 'n1', 'n2', 'reproduction', 'behavior', 'runtime')
MAPS = ('assets-native.json', 'assets-session.json', 'assets-c-request.json')
AUDIT_NAME = 'selfhost/dist/current-audit.json'


def identity(row):
    return {key: row[key] for key in ('bytes', 'sha256')}


def completed(report, label):
    require(report.get('complete') is True and not report.get('error') and not report.get('changedInputs'),
            'Incomplete, failed or changed receipt: '+label)


def preserved_bindings(current, previous, audit):
    """Authenticate the selected release without reading its now-old recipe pin."""
    require(current.get('kind') == 'bend-current-bindings' and current.get('version') == 1
            and current.get('complete') is True and current.get('gateStatus', {}).get('qualified') is True,
            'Qualified installed selector required')
    require(previous.get('kind') == 'bend-release-promotion' and previous.get('version') == 1,
            'Authenticated previous promotion required')
    completed(previous, 'previous promotion'); completed(audit, 'installed audit')
    require(audit.get('kind') == 'bend-release-audit' and audit.get('qualified') is True,
            'Qualified installed release audit required')
    require(set(current['components']) == {'qbe', 'js', 'nativeCli'},
            'Expected unchanged Phase182 components before additive assembly promotion')
    old = previous['bindings']
    for field in ('upstream', 'source', 'components', 'providers'):
        require(current[field] == old[field], 'Installed/previous release differs: '+field)
    require(audit['components'] == current['components']
            and release.same(audit['sourceIdentity'], current['source']['identity'])
            and audit['gates'] == {key: value['report'] for key, value in previous['gates'].items()},
            'Installed audit does not bind previous promotion')
    require(current['gateStatus']['components'] == {key: value['gates'] for key, value in current['components'].items()},
            'Installed component gates differ')
    files = {key: value for key, value in current['files'].items() if key != AUDIT_NAME}
    require(files == old['files'] and set(previous['files']) == set(files),
            'Installed/previous artifact inventory differs')
    require(current['files'].get(AUDIT_NAME) == current['provenance'], 'Installed audit inventory differs')
    result = copy.deepcopy(old)
    result.pop('provenance', None); result.pop('gateStatus', None)
    return result


def operational_map(original, current, n2, proposal_pin):
    """Keep every existing capability; add the separately qualified assembly image."""
    component = current['components']['x86']; runtime = current['providers']['qbeRuntime']
    require(original.get('upstream') == current['upstream'] and 'bootstrapBridge' not in original,
            'Ordinary current-upstream operational map required')
    require('x86-n2' not in original['assets'] and 'x86-n2' not in original['images'],
            'Assembly image already declared in operational map')
    require(release.same(original['assets']['qbe-n2'], current['components']['qbe']['image'])
            and release.same(original['assets']['qbe-runtime'], runtime)
            and original['preparedBase'] == current['components']['qbe']['preparedBase'],
            'Operational QBE image/runtime/prepared Base differs from selected release')
    for key in ('assembler', 'linker'):
        require(any(release.same(original['assets'][key], row) for row in n2['inputs']),
                'Operational '+key+' differs from qualified assembly construction')
    result = copy.deepcopy(original)
    result['assets']['x86-n2'] = dict(component['image'], executable=True)
    receipts = component['qualificationReceipts']
    result['images']['x86-n2'] = dict(host='native', stage='N2', targets=['x86'],
        protocol='native-x86-source-v1', sourceIdentity=component['sourceIdentity'],
        sourceProfile=component['sourceProfile'], linkedRuntime=runtime, linkedRuntimeABI=11102,
        runtimeArgumentConvention='bend-rts-v1', preparationModes=['cache', 'live'],
        acquisitionReceipt=receipts['x86-n2'], qualificationReceipt=receipts['x86-behavior'],
        runtimeQualification=receipts['x86-runtime'],
        qualification='Actual assembly N2; exact self-reproduction, native64 and ten runtime controls. No session qualification.')
    policy = n2['toolchain']
    assets.native_toolchain({'toolchains': {'x86': policy}}, 'x86')
    require('x86' not in result['toolchains'] or result['toolchains']['x86'] == policy,
            'Existing assembly toolchain differs from qualified construction')
    result['toolchains']['x86'] = copy.deepcopy(policy)
    provider = assets.runtime_provider(dict(result, _workspace=ROOT), 'qbe-runtime')
    require(assets.runtime_argument_convention(provider) == 'bend-rts-v1'
            and assets.runtime_abi(provider) in (None, 11102), 'Existing native runtime policy conflicts')
    result.setdefault('runtimePolicies', {}).setdefault('qbe-runtime', {}).update(
        runtimeArgumentConvention='bend-rts-v1', runtimeABI=11102)
    result['operationalParent'] = proposal_pin
    result['scope'] = ('Phase183 additive assembly target. Existing JS/C/QBE assets and capabilities are preserved; '
                       'x86 N2 has separate source-profile, generation and qualification bindings.')
    return result


def prepare(recipe_file, output):
    inputs = [pin(__file__), pin(release.__file__), pin(release.release_bridge.__file__),
              pin(source.__file__), pin(assets.__file__), pin(BUILD/'common.py')]

    def artifact(row):
        actual = pin(ROOT/row['file'])
        require(release.same(actual, row), 'Changed pinned artifact: '+row['file'])
        inputs.append(actual)
        return actual

    def read(file):
        row = artifact(file) if isinstance(file, dict) else pin(ROOT/file)
        if not isinstance(file, dict): inputs.append(row)
        return row, json.loads(verify(row).read_text())

    recipe_pin, recipe = read(recipe_file)
    require(recipe.get('kind') == 'phase183-release-inputs' and recipe.get('version') == 1
            and set(recipe['reports']) == set(ROLES), 'Explicit seven-role Phase183 recipe required')
    selector_pin, selected = read(recipe['current'])
    previous_audit_pin, previous_audit = read(selected['provenance'])
    previous_pin, previous = read(previous_audit['promotion'])
    current = preserved_bindings(selected, previous, previous_audit)
    files = {name: artifact(row) for name, row in current['files'].items()}
    for row in current['providers'].values(): artifact(row)
    recipe_source, config = read(current['source']['recipe']['file'])
    require(config['upstream'] == current['upstream'], 'Source/upstream identity differs')
    source_root = ROOT/current['source']['root']
    canonical = source.maintained_assemble(Path(recipe_source['file']), source_root, current['source']['profile'])
    require(release.same(current['source']['identity'],
            dict(bytes=len(canonical), sha256=hashlib.sha256(canonical).hexdigest())),
            'Existing canonical compiler bytes changed')
    current['source']['recipe'] = dict(recipe_source, file=selected['source']['recipe']['file'])
    assembly = source.maintained_assemble(Path(recipe_source['file']), source_root, 'x86')
    assembly_identity = dict(bytes=len(assembly), sha256=hashlib.sha256(assembly).hexdigest())
    # Pin every source dependency, not only the recipe and assembled digest.
    source_files = set(config['modules']) | {config['preamble']}
    for profile in (current['source']['profile'], 'x86'):
        selected_profile = config['profiles'][profile]
        source_files.update(selected_profile.get('modules', []))
        if selected_profile.get('entryModule'):
            source_files.add(selected_profile['entryModule'])
    for entry in sorted(source_files):
        inputs.append(pin(source.safe_path(source_root, entry)))
    reports, report_pins = {}, {}
    for role in ROLES:
        report_pins[role], reports[role] = read(recipe['reports'][role])
        completed(reports[role], role)
    n2 = reports['n2']; image = artifact(n2['binary'])
    require(release.same(n2['imageBinding']['sourceIdentity'], assembly_identity),
            'Qualified assembly image does not derive from maintained x86 profile')
    runtime = current['providers']['qbeRuntime']
    require(n2.get('runtimeABI') == 11102 and release.same(n2['runtime'], runtime),
            'Assembly image runtime differs from selected ABI11102 capsule')
    catalog_pin, catalog = read(recipe['qualificationCatalog'])
    require(catalog['upstream'] == current['upstream'], 'Qualification catalog upstream differs')
    originals, maps = {}, {}
    for name in MAPS:
        original_pin, document = read('selfhost/manifests/'+name)
        originals[name], maps[name] = original_pin, document
        require(document.get('kind') == 'bend-build-assets' and document.get('version') == 1
                and document.get('complete') is True, 'Complete maintained asset map required')
        for row in document['assets'].values(): artifact(row)
        require(release.same(document['qualificationCatalog'], catalog_pin), 'Operational catalog differs')
    for gate in previous['gates'].values():
        _, report = read(gate['report']); completed(report, 'retained gate')
    require(not changed_inputs(inputs), 'Inputs changed during release preparation')
    out = fresh_output(output, ROOT); (out/'evidence').mkdir()
    gates = copy.deepcopy(previous['gates'])
    for name, gate in gates.items():
        copied = out/'evidence'/(name+'.json'); shutil.copyfile(gate['report']['file'], copied)
        require(release.same(pin(copied), gate['report']), 'Retained gate copy differs')
        gate['report'] = pin(copied)
    names = {role: 'x86-'+role for role in ROLES}
    gate_specs = {
        'sourceCheck': ('lineage', {'checked': True, 'typeAccepted': True, 'unresolvedHoles': 0}, {'source': assembly_identity}),
        'seed': ('lineage', {'imageBinding.stage': 'N0', 'runtimeABI': 11102}, {'imageBinding.sourceIdentity': assembly_identity}),
        'n1': ('lineage', {'imageBinding.stage': 'N1', 'runtimeABI': 11102}, {'imageBinding.sourceIdentity': assembly_identity}),
        'n2': ('lineage', {'imageBinding.stage': 'N2', 'runtimeABI': 11102, 'comparedToReference': True},
               {'binary': image, 'imageBinding.sourceIdentity': assembly_identity}),
        'reproduction': ('lineage', {'byteExact': True, 'stage': 'N2'}, {'image': image, 'source': assembly_identity}),
        'behavior': ('qualification', {'passed': True, 'counts': {'pass': 64, 'fail': 0, 'unsupported': 0}}, {'image': image}),
        'runtime': ('qualification', {'passed': True, 'runtimeABI': 11102, 'selection.all': True}, {'image': image, 'runtime': runtime})}
    receipts = {}
    for role in ROLES:
        name = names[role]; require(name not in gates, 'Assembly gate name collision')
        copied = out/'evidence'/(name+'.json'); shutil.copyfile(report_pins[role]['file'], copied)
        row = pin(copied); require(release.same(row, report_pins[role]), 'Assembly receipt copy differs')
        kind, claims, bound = gate_specs[role]
        gates[name] = dict(report=row, role=kind, claims=claims, bindings=bound)
        destination = 'selfhost/dist/x86/evidence/'+name+'.json'
        files[destination] = row; current['files'][destination] = dict(row, file=destination)
        receipts[name] = current['files'][destination]
    destination = 'selfhost/dist/x86/bend'
    files[destination] = image; current['files'][destination] = dict(image, file=destination)
    current['components']['x86'] = dict(host='native', stage='N2', protocol='native-x86-source-v1',
        capabilities=['x86'], image=current['files'][destination], sourceIdentity=assembly_identity,
        sourceProfile=dict(recipe=current['source']['recipe'], root=current['source']['root'], profile='x86'),
        linkedRuntime=runtime, linkedRuntimeABI=11102, runtimeArgumentConvention='bend-rts-v1',
        preparationModes=['cache', 'live'], gates=list(names.values()), qualificationReceipts=receipts)
    proposal = dict(kind='bend-release-promotion', version=1, complete=True, bindings=current,
        files=files, gates=gates, jsFixedPoint=previous['jsFixedPoint'],
        nativeCliDerivation=previous['nativeCliDerivation'], x86Qualification=names,
        x86QualificationCatalog=catalog_pin,
        preparation=dict(method=pin(__file__), recipe=recipe_pin, previous=selector_pin,
                         previousAudit=previous_audit_pin, previousPromotion=previous_pin, inputs=inputs),
        scope='Additive current assembly target; exact selected JS/C/QBE artifacts, providers and prior gates preserved. No installation.')
    write_json(out/'promotion.json', proposal)
    _, audited = release.audit(out/'promotion.json', ROOT)
    write_json(out/'audit.json', audited)
    proposal_pin = pin(out/'promotion.json')
    (out/'operational').mkdir()
    (out/'previous-assets').mkdir()
    for name, original in maps.items():
        write_json(out/'operational'/name, operational_map(original, current, n2, proposal_pin))
        shutil.copyfile(originals[name]['file'], out/'previous-assets'/name)
        require(release.same(pin(out/'previous-assets'/name), originals[name]), 'Asset rollback copy differs: '+name)
    shutil.copyfile(selector_pin['file'], out/'previous-selector.json')
    shutil.copyfile(previous_audit_pin['file'], out/'previous-audit.json')
    require(release.same(pin(out/'previous-selector.json'), selector_pin)
            and release.same(pin(out/'previous-audit.json'), previous_audit_pin), 'Rollback reference copy differs')
    require(not changed_inputs(inputs), 'Inputs changed during release audit')
    write_json(out/'report.json', dict(kind='phase183-release-preparation', version=1, complete=True,
        targetsRun=False, installed=False, releaseAudited=True, recipe=recipe_pin,
        proposal=proposal_pin, audit=pin(out/'audit.json'), originalManifests=originals,
        proposedManifests={name: pin(out/'operational'/name) for name in MAPS}, inputs=inputs,
        rollbackManifests={name: pin(out/'previous-assets'/name) for name in MAPS},
        preservedComponents=['qbe', 'js', 'nativeCli'], sourceIdentity=current['source']['identity'],
        assemblySourceIdentity=assembly_identity,
        requiredOrder='Install with maintained release.py and its rollback transaction; reverify original maps and retained raw rollback copies, then atomically replace maps with proposed bytes only after installed pins verify. Restore all original maps on publication failure. Existing rollback artifacts remain untouched.'))
    return out/'promotion.json'


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--recipe', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    try:
        print(prepare(args.recipe, args.out))
    except (ValueError, KeyError, OSError, TypeError, json.JSONDecodeError) as error:
        print('Phase183 promotion refused: '+str(error), file=sys.stderr)
        raise SystemExit(1)
