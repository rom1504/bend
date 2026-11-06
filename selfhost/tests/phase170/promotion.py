#!/usr/bin/env python3
"""Assemble and audit a fresh three-component release proposal; never install it."""
import argparse
import copy
import hashlib
import json
from pathlib import Path
import shutil
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
import release
import source
from common import changed_inputs, fresh_output, pin, require, verify, write_json


def identity(value):
    return {key: value[key] for key in ('bytes', 'sha256')}


def assemble(recipe_file, output):
    inputs = [pin(__file__), pin(release.__file__), pin(source.__file__)]

    def artifact(row):
        row = dict(row, file=str((ROOT / row['file']).resolve(strict=True)))
        verify(row)
        inputs.append(row)
        return row

    def read(file):
        row = pin(ROOT / file)
        inputs.append(row)
        return row, json.loads(Path(row['file']).read_text())

    recipe_pin, recipe = read(str(recipe_file))
    require(recipe.get('kind') == 'phase170-release-inputs' and recipe.get('version') == 1,
            'Explicit Phase170 input recipe required')
    canonical = artifact(pin(ROOT / recipe['canonical']))
    source_recipe = artifact(pin(ROOT / recipe['sourceRecipe']))
    source_root = (ROOT / recipe.get('sourceRoot', 'selfhost')).resolve(strict=True)
    profile = recipe.get('sourceProfile', 'qbe')
    actual = source.maintained_assemble(Path(source_recipe['file']), source_root, profile)
    require(release.same(canonical, dict(bytes=len(actual), sha256=hashlib.sha256(actual).hexdigest())),
            'Frozen canonical bytes differ from maintained assembly')

    reports, report_pins = {}, {}
    required = {'qbeBuild', 'qbeQualification', 'jsB2', 'jsB3', 'jsQualification',
                'jsPublic', 'cliProfile', 'cliPackage', 'cliControls', 'cliQualification'}
    require(set(recipe['reports']) == required, 'Explicit ten receipt roles required')
    for key, file in recipe['reports'].items():
        report_pins[key], reports[key] = read(file)
        report = reports[key]
        require(report.get('complete') is True and not report.get('error') and not report.get('changedInputs'),
                'Incomplete, failed or changed receipt: ' + key)
    qb, b2, b3, cp, pkg = (reports[k] for k in ('qbeBuild', 'jsB2', 'jsB3', 'cliProfile', 'cliPackage'))
    require(qb['kind'] == 'bend-native-build', 'Actual maintained native build required')
    qbinding = qb['imageBinding']
    require(qbinding.get('complete') is True and release.same(qb['binary'], qbinding['image'])
            and (qbinding['host'], qbinding['stage'], qbinding['protocol']) == ('native', 'N2', 'qbe-source-v1'),
            'Actual N2 QBE binding required; labels are not rewritten')
    require(qbinding['targets'] == ['qbe'] and release.same(qbinding['sourceIdentity'], canonical),
            'QBE must be genuinely built from the exact canonical source; no historical equivalence inferred')
    require(b2['kind'] == b3['kind'] == 'bend-js-self-emission' and b2['stage'] == 'B2' and b3['stage'] == 'B3',
            'Actual JS B2/B3 receipts required')
    require(all(b3.get(k) is True for k in ('freshSelfCheck', 'typeAccepted', 'byteEquality')),
            'Actual B3 check and fixed point required')
    require(all(release.same(x, canonical) for x in (b2['source'], b3['source']))
            and release.same(b2['image'], b3['generator']) and release.same(b2['image'], b3['image']),
            'JS source/generation/equality chain differs')
    require(b2['imageBinding']['targets'] == ['js', 'c'] and b2['imageBinding']['preparationModes'] == ['live'],
            'Expected maintained JS/C public API capability boundary')
    require(cp['kind'] == 'bend-public-cli-source-profile' and cp['allOtherBodiesIdentical'] is True
            and set(cp['changedDeclarations']) == {'main', 'p86_effect_read'}
            and release.same(cp['canonicalSource'], canonical), 'CLI source derivation differs')
    require(pkg['kind'] == 'bend-public-cli-package' and pkg['stage'] == 'N1'
            and pkg['protocol'] == 'native-public-cli-v1' and pkg['constructionBackend'] == 'c'
            and pkg['generatedCUnmodified'] is True and release.same(pkg['source'], cp['source'])
            and release.same(pkg['canonicalSource'], canonical), 'Actual canonical-derived C package required')
    images = {k: artifact(v) for k, v in [('qbe', qbinding['image']), ('js', b2['image']), ('nativeCli', pkg['image'])]}
    for role, component, host, target, stage, count in [
        ('qbeQualification', 'qbe', 'native', 'qbe', 'N2', 64),
        ('jsQualification', 'js', 'js', 'js', 'B2', 45),
        ('cliQualification', 'nativeCli', 'native', 'c', 'N1', 45),
    ]:
        r = reports[role]
        require(r['kind'] == 'bend-finite-qualification' and r.get('passed') is True
                and (r['host'], r['target'], r['stage']) == (host, target, stage)
                and r['counts'] == {'pass': count, 'fail': 0, 'unsupported': 0}
                and release.same(r['image'], images[component]), 'Selected-image finite qualification differs: ' + role)
    cli = reports['cliControls']
    require(cli['kind'] == 'bend-native-public-cli-qualification' and cli.get('passed') is True
            and cli.get('qualified') is True and cli.get('liveCacheByteExact') is True
            and release.same(cli['image'], images['nativeCli']) and release.same(cli['source'], pkg['source']),
            'Public CLI independent behavior gate differs')
    public = reports['jsPublic']
    require(public.get('passed') is True and len(public['rows']) == 7
            and release.same(public['image'], images['js']), 'Actual B2 public seven controls required')
    providers = {key: artifact(value) for key, value in recipe['providers'].items()}
    require(set(providers) == {'base', 'jsLegacyRuntime', 'jsDirectRuntime', 'cRuntime', 'cRuntimeTemplate', 'qbeRuntime'},
            'Explicit maintained provider inventory required')
    require(release.same(providers['base'], b2['base']) and release.same(providers['base'], pkg['assets']['base.bend'])
            and release.same(providers['jsDirectRuntime'], b2['directRuntime'])
            and release.same(providers['cRuntime'], pkg['runtime'])
            and release.same(providers['qbeRuntime'], qbinding['linkedRuntime']), 'Image/provider closure differs')

    out = fresh_output(output, ROOT)
    (out / 'evidence').mkdir()
    files, installed, gates = {}, {}, {}

    def installable(destination, row):
        row = artifact(row)
        require(destination.startswith('selfhost/dist/') and '..' not in Path(destination).parts, 'Unsafe installation path')
        files[destination] = row
        installed[destination] = dict(row, file=destination)
        return installed[destination]

    def gate(name, role, receipt, claims, bindings):
        require(name not in gates and name.replace('-', '').replace('_', '').isalnum(), 'Invalid/duplicate gate name')
        original = artifact(receipt)
        target = out / 'evidence' / (name + '.json')
        shutil.copy2(original['file'], target)
        require(release.same(pin(target), original), 'Evidence copy differs')
        gates[name] = dict(report=pin(target), role=role, claims=claims, bindings=bindings)

    components = {}
    for key, destination, host, stage, protocol, caps, src in [
        ('qbe', 'selfhost/dist/qbe/bend', 'native', 'N2', 'qbe-source-v1', ['qbe'], canonical),
        ('js', 'selfhost/dist/typed-api.mjs', 'js', 'B2', 'hosted-api-v1', ['js', 'c'], canonical),
        ('nativeCli', 'selfhost/dist/native/bend', 'native', 'N1', 'native-public-cli-v1', ['c'], pkg['source']),
    ]:
        components[key] = dict(host=host, stage=stage, protocol=protocol, capabilities=caps,
                               sourceIdentity=identity(src), image=installable(destination, images[key]), gates=[])
    specs = [
        ('qbe-build', 'qbe', 'qbeBuild', 'lineage', {'complete': True, 'imageBinding.stage': 'N2'}, {'imageBinding.image': images['qbe'], 'imageBinding.sourceIdentity': canonical}),
        ('qbe-qualified', 'qbe', 'qbeQualification', 'qualification', {'passed': True, 'counts.pass': 64, 'counts.fail': 0, 'counts.unsupported': 0}, {'image': images['qbe']}),
        ('js-b2', 'js', 'jsB2', 'lineage', {'stage': 'B2', 'complete': True}, {'image': images['js'], 'source': canonical}),
        ('js-fixedpoint', 'js', 'jsB3', 'lineage', {'stage': 'B3', 'freshSelfCheck': True, 'typeAccepted': True, 'byteEquality': True}, {'generator': images['js'], 'image': images['js'], 'source': canonical}),
        ('js-qualified', 'js', 'jsQualification', 'qualification', {'passed': True, 'counts.pass': 45, 'counts.fail': 0, 'counts.unsupported': 0}, {'image': images['js']}),
        ('js-public', 'js', 'jsPublic', 'qualification', {'passed': True}, {'image': images['js']}),
        ('cli-profile', 'nativeCli', 'cliProfile', 'derivation', {'allOtherBodiesIdentical': True}, {'source': pkg['source'], 'canonicalSource': canonical}),
        ('cli-package', 'nativeCli', 'cliPackage', 'lineage', {'generatedCUnmodified': True, 'stage': 'N1'}, {'image': images['nativeCli'], 'source': pkg['source']}),
        ('cli-behavior', 'nativeCli', 'cliControls', 'qualification', {'passed': True, 'qualified': True, 'liveCacheByteExact': True}, {'image': images['nativeCli'], 'source': pkg['source']}),
        ('cli-qualified', 'nativeCli', 'cliQualification', 'qualification', {'passed': True, 'counts.pass': 45, 'counts.fail': 0, 'counts.unsupported': 0}, {'image': images['nativeCli']}),
    ]
    for name, component, receipt, role, claims, bound in specs:
        gate(name, role, report_pins[receipt], claims, bound)
        components[component]['gates'].append(name)
    if 'hostedQbe' in recipe:
        hosted = recipe['hostedQbe']
        acquisition_pin, acquisition = read(hosted['acquisition'])
        qualification_pin, qualification = read(hosted['qualification'])
        export_pin, exports = read(hosted['exports'])
        for report in (acquisition, qualification):
            require(report.get('complete') is True and not report.get('error') and not report.get('changedInputs'),
                    'Hosted QBE acquisition/qualification incomplete, changed or failed')
        binding = acquisition['imageBinding']
        require(acquisition.get('kind') == 'bend-checked-hosted-api' and acquisition.get('checked') is True
                and acquisition.get('status') == 0 and not acquisition.get('signal')
                and binding.get('complete') is True and binding.get('checked') is True
                and (binding['host'], binding['stage'], binding['protocol']) == ('js', 'B1', 'qbe-api-v1')
                and binding['targets'] == ['qbe']
                and release.same(acquisition['api'], binding['image'])
                and all(release.same(row, canonical) for row in (acquisition['source'], binding['sourceIdentity'])),
                'Actual checked, canonical-derived QBE B1 API required')
        require(exports.get('kind') == 'bend-hosted-api-exports' and exports.get('version') == 1
                and exports['protocol'] == binding['protocol'] and exports['targets'] == binding['targets']
                and exports['exports'] == acquisition['exports'] == binding['exports']
                and exports['preparationModes'] == binding['preparationModes']
                and any(release.same(row, export_pin) for row in acquisition['inputs']),
                'Hosted QBE declared exports/modes differ from checked acquisition')
        image = artifact(acquisition['api'])
        require(qualification.get('kind') == 'bend-finite-qualification' and qualification.get('passed') is True
                and (qualification['host'], qualification['stage'], qualification['target']) == ('js', 'B1', 'qbe')
                and qualification['counts'] == {'pass': 19, 'fail': 0, 'unsupported': 0}
                and release.same(qualification['image'], image), 'Hosted QBE focused19 did not qualify this image')
        gate('qbe-hosted-acquisition', 'lineage', acquisition_pin,
             {'kind': 'bend-checked-hosted-api', 'checked': True, 'imageBinding.stage': 'B1',
              'imageBinding.protocol': 'qbe-api-v1', 'imageBinding.exports': exports['exports'],
              'imageBinding.preparationModes': exports['preparationModes']},
             {'api': image, 'source': canonical, 'imageBinding.image': image, 'imageBinding.sourceIdentity': canonical})
        gate('qbe-hosted-qualified', 'qualification', qualification_pin,
             {'passed': True, 'counts.pass': 19, 'counts.fail': 0, 'counts.unsupported': 0,
              'host': 'js', 'stage': 'B1', 'target': 'qbe'}, {'image': image})
        components['qbe']['gates'] += ['qbe-hosted-acquisition', 'qbe-hosted-qualified']
        components['qbe']['hostedApi'] = dict(host='js', stage='B1', protocol='qbe-api-v1', capabilities=['qbe'],
            image=installable('selfhost/dist/qbe/hosted-api.mjs', image), sourceIdentity=identity(canonical),
            exports=binding['exports'], preparationModes=binding['preparationModes'],
            gates=['qbe-hosted-acquisition', 'qbe-hosted-qualified'])
    # Explicit expected claims, never computed from whatever result happened.
    extras = recipe['extraGates']
    require('qbe-reproduction' in extras, 'Explicit same-source QBE reproduction gate required')
    reproduction = extras['qbe-reproduction']
    require(reproduction.get('claims') and any(value is True for value in reproduction['claims'].values())
            and any(release.same(value, images['qbe']) for value in reproduction.get('bindings', {}).values())
            and any(release.same(value, canonical) for value in reproduction.get('bindings', {}).values()),
            'Explicit successful reproduction assertions must bind actual N2 image and canonical source')
    for name, spec in extras.items():
        receipt, _ = read(spec['report'])
        gate(name, spec['role'], receipt, spec['claims'], spec.get('bindings', {}))
        for component in spec.get('components', []):
            require(component in components, 'Unknown gate component')
            components[component]['gates'].append(name)
    require('qbe-reproduction' in components['qbe']['gates'], 'QBE reproduction must belong to selected component')
    retained_gates = recipe.get('installedQbeGates', [])
    require(len(retained_gates) == len(set(retained_gates))
            and set(retained_gates) <= set(components['qbe']['gates']), 'Unknown/duplicate retained QBE gate')
    if retained_gates:
        components['qbe']['qualificationReceipts'] = {
            name: installable('selfhost/dist/qbe/evidence/' + name + '.json', gates[name]['report'])
            for name in retained_gates}
    components['js'].update(exports=b2['imageBinding']['exports'], preparationModes=['live'])
    providers['base'] = installable('selfhost/dist/base.bend', providers['base'])
    package_assets = {name: installable('selfhost/dist/native/assets/' + name, row) for name, row in pkg['assets'].items()}
    component = components['nativeCli']
    component.update(preparationModes=['cache', 'live'], packageAssets=package_assets,
                     baseIdentity=pkg['baseIdentity'], cacheStamp=pkg['cacheStamp'], targetRuntime=providers['cRuntime'])
    binding = copy.deepcopy(pkg['imageBinding'])
    binding.update(image=component['image'], sourceIdentity=component['sourceIdentity'], packageAssets=package_assets,
                   targetRuntime=providers['cRuntime'], linkedRuntime=providers['cRuntime'])
    write_json(out / 'native-BUILD.json', dict(kind='bend-public-cli-package', version=1, complete=True,
        operationalOnly=True, host='native', stage='N1', targets=['c'], protocol='native-public-cli-v1',
        image=component['image'], source=component['sourceIdentity'], canonicalSource=identity(canonical),
        assets=package_assets, baseIdentity=pkg['baseIdentity'], cacheStamp=pkg['cacheStamp'], runtime=providers['cRuntime'],
        imageBinding=binding, currentSelector='selfhost/manifests/current.json',
        provenance={key: gates[name]['report'] for key, name in [('construction', 'cli-package'), ('qualification', 'cli-behavior')]}))
    installable('selfhost/dist/native/BUILD.json', pin(out / 'native-BUILD.json'))
    previous_pin, previous = read(recipe['previous'])
    for row in previous['files'].values():
        artifact(row)  # Source recipe may be stale; still authenticate every rollback artifact.
    shutil.copy2(previous_pin['file'], out / 'previous-selector.json')
    bindings = dict(kind='bend-current-bindings', version=1, complete=True, files=installed, components=components,
        providers=providers, source=dict(recipe=dict(source_recipe, file=str(Path(source_recipe['file']).relative_to(ROOT))),
        root=str(source_root.relative_to(ROOT)), profile=profile, identity=identity(canonical)))
    proposal = dict(kind='bend-release-promotion', version=1, complete=True, bindings=bindings, files=files,
        gates=gates, jsFixedPoint='js-fixedpoint', nativeCliDerivation='cli-profile',
        scope='Prepared only. All images freshly source-bound; no historical QBE equivalence, installation or session promotion.',
        preparation=dict(method=pin(__file__), recipe=recipe_pin, previous=previous_pin, inputs=inputs))
    require(not changed_inputs(inputs), 'Inputs changed during assembly')
    write_json(out / 'promotion.json', proposal)
    _, audited = release.audit(out / 'promotion.json', ROOT)
    write_json(out / 'audit.json', audited)
    require(not changed_inputs(inputs), 'Inputs changed during audit')
    write_json(out / 'report.json', dict(kind='phase170-promotion-preparation', complete=True,
        installed=False, targetsRun=False, proposal=pin(out / 'promotion.json'), audit=pin(out / 'audit.json'),
        previousSelector=pin(out / 'previous-selector.json'), rollback='Installer must retain its actual destination backups and journal.'))
    return out / 'promotion.json'


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--recipe', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    try:
        print(assemble(args.recipe, args.out))
    except (ValueError, KeyError, OSError, json.JSONDecodeError) as error:
        print('Promotion preparation refused: ' + str(error), file=sys.stderr)
        raise SystemExit(1)
