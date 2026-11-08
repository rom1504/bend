#!/usr/bin/env python3
"""Validate completed Phase182 receipts and prepare a proposal; never run targets or install."""
import argparse
import copy
import hashlib
import importlib.util
import json
from pathlib import Path
import shutil
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
BUILD = ROOT / 'selfhost/tools/build'
sys.path.insert(0, str(BUILD))
import assets
import release
import source
from common import changed_inputs, fresh_output, pin, require, verify, write_json

UPSTREAM = '9a4223d577ba56a0cb53d1fd952d2b481c38930f'
ROLES = {'qbeN1', 'qbeN2', 'qbeQ3', 'qbeQualification', 'jsB1', 'jsB2', 'jsB3',
         'jsQualification', 'jsCQualification', 'jsPublic', 'cliProfile', 'cliPackage',
         'cliControls', 'cliQualification'}
PROVIDERS = {'base', 'jsLegacyRuntime', 'jsDirectRuntime', 'cRuntime', 'cRuntimeTemplate', 'qbeRuntime'}


def identity(row):
    return {k: row[k] for k in ('bytes', 'sha256')}


def completed(report, label):
    require(report.get('complete') is True and not report.get('error') and not report.get('changedInputs'),
            'Incomplete, failed or changed receipt: '+label)


def qualification(report, host, stage, target, image, count):
    require(type(count) is int and 0 < count <= 64, 'Explicit bounded positive qualification count required')
    require(report.get('kind') == 'bend-finite-qualification' and report.get('passed') is True
            and report.get('upstream') == UPSTREAM
            and (report['host'], report['stage'], report['target']) == (host, stage, target)
            and release.same(report['image'], image)
            and report['counts'] == {'pass': count, 'fail': 0, 'unsupported': 0},
            'Wrong selected-image/current-upstream qualification')
    require(len(report['selected']) == len(set(report['selected'])) == len(report['rows']) == count
            and all(row.get('status') == 'pass' for row in report['rows'])
            and {row['id'] for row in report['rows']} == set(report['selected']),
            'Qualification rows/selection differ from declared count')


def native_generation(report, stage, canonical, runtime):
    binding = report['imageBinding']
    require(report.get('kind') == 'bend-native-build' and binding.get('complete') is True
            and (binding['host'], binding['stage'], binding['protocol']) == ('native', stage, 'qbe-source-v1')
            and binding['targets'] == ['qbe'] and release.same(report['binary'], binding['image'])
            and release.same(binding['sourceIdentity'], canonical)
            and release.same(report['request']['source'], canonical)
            and report['request']['target'] == 'qbe'
            and release.same(binding['linkedRuntime'], runtime)
            and assets.runtime_argument_convention(binding) == 'bend-rts-v1',
            'Actual same-source/current-runtime '+stage+' required')
    return binding


def prepare(recipe_file, output):
    inputs = [pin(__file__), pin(release.__file__), pin(source.__file__), pin(assets.__file__), pin(BUILD/'common.py')]

    def artifact(row):
        actual = pin(ROOT/row['file'])
        require(release.same(actual, row), 'Changed artifact: '+row['file'])
        inputs.append(actual)
        return actual

    def read(file):
        row = pin(ROOT/file); inputs.append(row)
        return row, json.loads(verify(row).read_text())

    recipe_pin, recipe = read(recipe_file)
    require(recipe.get('kind') == 'phase182-release-inputs' and recipe.get('version') == 1,
            'Explicit Phase182 release recipe required')
    require(set(recipe['reports']) == ROLES, 'Exactly the documented receipt roles are required')
    require(set(recipe['providers']) == PROVIDERS, 'Explicit six-provider asset-key mapping required')
    counts = recipe['qualificationCounts']
    require(set(counts) == {'qbeQualification', 'jsQualification', 'jsCQualification', 'cliQualification'}
            and counts['qbeQualification'] == 64, 'QBE all64 plus explicit JS/C/CLI counts required')
    canonical = artifact(pin(ROOT/recipe['canonical']))
    source_recipe, source_config = read(recipe['sourceRecipe'])
    require(source_config.get('upstream') == UPSTREAM, 'Maintained source recipe is not Phase182')
    source_root = (ROOT/recipe.get('sourceRoot', 'selfhost')).resolve(strict=True)
    actual = source.maintained_assemble(Path(source_recipe['file']), source_root, 'qbe')
    require(release.same(canonical, dict(bytes=len(actual), sha256=hashlib.sha256(actual).hexdigest())),
            'Canonical source differs from current maintained assembly')
    document = assets.load_assets(ROOT/recipe['assets'], ROOT)
    require(document.get('upstream') == UPSTREAM, 'Current provider asset map required')
    inputs.append(document['_manifest'])
    providers = {name: artifact(assets.asset(document, key)) for name, key in recipe['providers'].items()}
    for key in document.get('providers', {}).get('c', {}).get('effects', []):
        providers['cEffect:'+key] = artifact(assets.asset(document, key))
    require(providers['base']['sha256'] == 'ff90fb27ed19d5c7a6165170f28ad81562bf345b9a9e6134e5c2e326beff9de4',
            'Expected exact Phase182 Base')
    for name in ('cRuntime', 'qbeRuntime'):
        require(assets.runtime_argument_convention(assets.runtime_provider(document, recipe['providers'][name])) == 'bend-rts-v1',
                'Current runtime argument convention required: '+name)
    spec = importlib.util.spec_from_file_location('phase182_public_assets', BUILD/'public-cli.py')
    public_assets = importlib.util.module_from_spec(spec); spec.loader.exec_module(public_assets)
    inputs.append(pin(BUILD/'public-cli.py'))
    public = public_assets.fresh_assets(ROOT/recipe['publicAssets'])
    inputs += public['inputs']
    public_document = assets.load_assets(ROOT/recipe['publicAssets'], ROOT)
    require(public_document.get('upstream') == UPSTREAM and public['runtimeArgumentConvention'] == 'bend-rts-v1',
            'Fresh current public assets required')
    for field, provider in [('base','base'),('runtime','cRuntime'),('runtimeTemplate','cRuntimeTemplate')]:
        require(release.same(assets.asset(public_document, public_document['publicCliAssets'][field]), providers[provider]),
                'Public and compiler provider differs: '+field)
    for name, key in public_document['publicCliAssets']['effects'].items():
        providers['publicEffect:'+name] = artifact(assets.asset(public_document, key))

    reports, report_pins = {}, {}
    for role, file in recipe['reports'].items():
        report_pins[role], reports[role] = read(file); completed(reports[role], role)
    n1, n2, q3, b1, b2, b3, cp, pkg = (reports[k] for k in
        ('qbeN1', 'qbeN2', 'qbeQ3', 'jsB1', 'jsB2', 'jsB3', 'cliProfile', 'cliPackage'))
    native_generation(n1, 'N1', canonical, providers['qbeRuntime'])
    qb = native_generation(n2, 'N2', canonical, providers['qbeRuntime'])
    require(n2.get('comparedToReference') is True and release.same(n2['request']['image'], n1['binary'])
            and (n2['request']['host'], n2['request']['stage']) == ('native', 'N1')
            and release.same(n2['expectedQbe'], n1['irDigest']) and release.same(n2['irDigest'], n1['irDigest']),
            'N2 must execute actual same-source N1 and match the whole independent N1 QBE')
    require(q3.get('kind') == 'bend-build-request' and q3.get('byteExact') is True
            and (q3['host'], q3['stage'], q3['target']) == ('native', 'N2', 'qbe')
            and release.same(q3['image'], n2['binary']) and release.same(q3['source'], canonical)
            and release.same(q3['product'], n2['irDigest']) and release.same(q3['request']['expected'], n2['irDigest'])
            and q3['process']['complete'] is True and q3['process']['exitCode'] == 0
            and release.same(q3['process']['stdout'], n2['irDigest'])
            and not q3['process'].get('timedOut') and q3['process']['stderr']['bytes'] == 0,
            'Actual N2 checked-source Q3 reproduction required')
    require(b1.get('kind') == 'bend-checked-hosted-api' and b1.get('checked') is True
            and b1.get('status') == 0 and not b1.get('signal')
            and b1['upstream']['revision'] == UPSTREAM and release.same(b1['source'], canonical),
            'Genuine current-upstream same-source checked B1 required')
    artifact(n1['binary']); artifact(b1['api']); artifact(b3['image'])
    require(b2.get('kind') == b3.get('kind') == 'bend-js-self-emission'
            and b2['stage'] == 'B2' and b3['stage'] == 'B3'
            and release.same(b2['generator'], b1['api']) and release.same(b2['authority'], report_pins['jsB1'])
            and release.same(b3['generator'], b2['image']) and release.same(b3['authority'], report_pins['jsB2'])
            and release.same(b2['image'], b3['image'])
            and all(b3.get(k) is True for k in ('freshSelfCheck', 'typeAccepted', 'byteEquality')),
            'Actual checked B1→B2→B3 fixed-point chain required')
    for item in (b2, b3):
        require(release.same(item['source'], canonical) and release.same(item['base'], providers['base'])
                and release.same(item['directRuntime'], providers['jsDirectRuntime'])
                and item['imageBinding']['targets'] == ['js', 'c']
                and item['imageBinding']['preparationModes'] == ['live'], 'JS source/provider/capability differs')
    require(cp.get('kind') == 'bend-public-cli-source-profile' and cp['allOtherBodiesIdentical'] is True
            and set(cp['changedDeclarations']) == {'main', 'p86_effect_read'}
            and release.same(cp['canonicalSource'], canonical)
            and release.same(cp['assetAuthority'], public['authority'])
            and cp['baseIdentity'] == public['baseIdentity'] and cp['cacheStamp'] == public['cacheStamp'],
            'Canonical-derived profile with fresh asset authority required')
    require(pkg.get('kind') == 'bend-public-cli-package' and pkg['stage'] == 'N1'
            and pkg['protocol'] == 'native-public-cli-v1' and pkg['constructionBackend'] == 'c'
            and pkg['generatedCUnmodified'] is True and release.same(pkg['profile'], report_pins['cliProfile'])
            and release.same(pkg['source'], cp['source']) and release.same(pkg['canonicalSource'], canonical)
            and release.same(pkg['runtime'], providers['cRuntime'])
            and assets.runtime_argument_convention(pkg) == 'bend-rts-v1', 'Actual current public C package required')
    binding = pkg['imageBinding']
    require(binding.get('complete') is True
            and (binding['host'],binding['stage'],binding['protocol']) == ('native','N1','native-public-cli-v1')
            and binding['targets'] == ['c'] and release.same(binding['image'],pkg['image'])
            and release.same(binding['sourceIdentity'],pkg['source'])
            and release.same(binding['linkedRuntime'],providers['cRuntime'])
            and release.same(binding['targetRuntime'],providers['cRuntime'])
            and binding['runtimeArgumentConvention'] == binding['targetRuntimeArgumentConvention'] == 'bend-rts-v1'
            and binding['packageAssets'] == pkg['assets']
            and binding['baseIdentity'] == pkg['baseIdentity'] == cp['baseIdentity']
            and binding['cacheStamp'] == pkg['cacheStamp'] == cp['cacheStamp'],
            'Public package operational binding differs from actual construction')
    artifact(pkg['source'])
    require(set(pkg['assets']) == set(cp['assets']) == set(public['payloads']), 'Public asset inventory differs')
    for name, payload in public['payloads'].items():
        expected = dict(bytes=len(payload), sha256=hashlib.sha256(payload).hexdigest())
        require(release.same(pkg['assets'][name], expected) and release.same(cp['assets'][name], expected),
                'Packaged current effect/Base/runtime asset differs: '+name)
    require(release.same(pkg['assets']['base.bend'], providers['base']), 'Public/JS Base differs')
    images = {k: artifact(v) for k, v in [('qbe', n2['binary']), ('js', b2['image']), ('nativeCli', pkg['image'])]}
    for role, component, host, stage, target in [
        ('qbeQualification','qbe','native','N2','qbe'), ('jsQualification','js','js','B2','js'),
        ('jsCQualification','js','js','B2','c'), ('cliQualification','nativeCli','native','N1','c')]:
        qualification(reports[role], host, stage, target, images[component], counts[role])
    controls = reports['cliControls']
    require(controls.get('kind') == 'bend-native-public-cli-qualification'
            and all(controls.get(k) is True for k in ('passed','qualified','liveCacheByteExact'))
            and release.same(controls['image'], images['nativeCli']) and release.same(controls['source'], pkg['source'])
            and release.same(controls['actualExecutingImage'], images['nativeCli'])
            and controls['rows'] and all(row.get('passed') is True for row in controls['rows']), 'Actual public CLI behavior gate required')
    js_public = reports['jsPublic']
    require(js_public.get('kind') == 'bend-public-cli-qualification'
            and js_public.get('passed') is True and js_public.get('cacheUnchanged') is True
            and js_public.get('upstream') == UPSTREAM and len(js_public['rows']) == 7
            and all(row.get('passed') is True for row in js_public['rows'])
            and release.same(js_public['image'], images['js']), 'Actual B2 public seven controls required')
    previous_pin, previous = read(recipe['previous']); completed(previous, 'previous selector')
    for row in previous['files'].values(): artifact(row)

    out = fresh_output(output, ROOT); (out/'evidence').mkdir()
    files, installed, gates = {}, {}, {}
    def installable(name, row):
        value = artifact(row); files[name] = value; installed[name] = dict(value, file=name)
        return installed[name]
    def gate(name, role, receipt, claims, bound):
        original, report = read(receipt['file']); completed(report, name)
        require(release.same(original, receipt), 'Gate changed before copy: '+name)
        require(name not in gates and name.replace('-', '').replace('_', '').isalnum(), 'Invalid/duplicate gate name')
        for field, expected in claims.items():
            observed = release.at(report, field)
            require(type(observed) is type(expected) and observed == expected, 'Gate claim differs: '+name+':'+field)
        for field, expected in bound.items(): require(release.same(release.at(report, field), expected), 'Gate binding differs: '+name)
        copied = out/'evidence'/(name+'.json'); shutil.copyfile(original['file'], copied)
        require(release.same(pin(copied), original), 'Receipt copy differs')
        gates[name] = dict(report=pin(copied), role=role, claims=claims, bindings=bound)
    components = {}
    for key, dest, host, stage, protocol, targets, subject in [
        ('qbe','qbe/bend','native','N2','qbe-source-v1',['qbe'],canonical),
        ('js','typed-api.mjs','js','B2','hosted-api-v1',['js','c'],canonical),
        ('nativeCli','native/bend','native','N1','native-public-cli-v1',['c'],pkg['source'])]:
        components[key] = dict(host=host, stage=stage, protocol=protocol, capabilities=targets,
            sourceIdentity=identity(subject), image=installable('selfhost/dist/'+dest, images[key]), gates=[])
    specs = [
        ('qbe-n1','qbe','qbeN1','lineage',{'imageBinding.stage':'N1'},{'binary':n1['binary'],'imageBinding.sourceIdentity':canonical}),
        ('qbe-build','qbe','qbeN2','lineage',{'imageBinding.stage':'N2','comparedToReference':True},{'binary':images['qbe'],'imageBinding.sourceIdentity':canonical,'request.image':n1['binary']}),
        ('qbe-reproduction','qbe','qbeQ3','lineage',{'byteExact':True,'stage':'N2'},{'image':images['qbe'],'source':canonical,'product':n2['irDigest']}),
        ('source-checked','js','jsB1','lineage',{'checked':True,'status':0},{'api':b1['api'],'source':canonical}),
        ('js-b2','js','jsB2','lineage',{'stage':'B2'},{'image':images['js'],'source':canonical,'generator':b1['api']}),
        ('js-fixedpoint','js','jsB3','lineage',{'stage':'B3','freshSelfCheck':True,'typeAccepted':True,'byteEquality':True},{'generator':images['js'],'image':images['js'],'source':canonical}),
        ('js-public','js','jsPublic','qualification',{'passed':True,'cacheUnchanged':True},{'image':images['js']}),
        ('cli-profile','nativeCli','cliProfile','derivation',{'allOtherBodiesIdentical':True},{'source':pkg['source'],'canonicalSource':canonical}),
        ('cli-package','nativeCli','cliPackage','lineage',{'stage':'N1','generatedCUnmodified':True},{'image':images['nativeCli'],'source':pkg['source']}),
        ('cli-behavior','nativeCli','cliControls','qualification',{'passed':True,'qualified':True,'liveCacheByteExact':True},{'image':images['nativeCli'],'source':pkg['source']})]
    for name, component, role in [('qbe-qualified','qbe','qbeQualification'),('js-qualified','js','jsQualification'),
                                  ('js-c-qualified','js','jsCQualification'),('cli-qualified','nativeCli','cliQualification')]:
        specs.append((name,component,role,'qualification',{'passed':True,'counts':{'pass':counts[role],'fail':0,'unsupported':0},
                      'selected':reports[role]['selected'],'upstream':UPSTREAM},{'image':images[component]}))
    for name, component, role, kind, claims, bound in specs:
        gate(name, kind, report_pins[role], claims, bound); components[component]['gates'].append(name)
    for name, extra in recipe.get('extraGates', {}).items():
        receipt, _ = read(extra['report']); gate(name,extra['role'],receipt,extra['claims'],extra.get('bindings',{}))
        for key in extra['components']:
            require(key in components, 'Unknown extra-gate component'); components[key]['gates'].append(name)
    components['qbe']['runtimeArgumentConvention'] = qb['runtimeArgumentConvention']
    components['js'].update(exports=b2['imageBinding']['exports'], preparationModes=['live'])
    providers['base'] = installable('selfhost/dist/base.bend', providers['base'])
    package_assets = {name:installable('selfhost/dist/native/assets/'+name,row) for name,row in pkg['assets'].items()}
    components['nativeCli'].update(preparationModes=['cache','live'], packageAssets=package_assets,
        baseIdentity=pkg['baseIdentity'], cacheStamp=pkg['cacheStamp'], targetRuntime=providers['cRuntime'],
        runtimeArgumentConvention=pkg['imageBinding']['runtimeArgumentConvention'],
        targetRuntimeArgumentConvention=pkg['imageBinding']['targetRuntimeArgumentConvention'])
    cli_binding = copy.deepcopy(pkg['imageBinding'])
    cli_binding.update(image=components['nativeCli']['image'], packageAssets=package_assets,
                       sourceIdentity=identity(pkg['source']))
    write_json(out/'native-BUILD.json',dict(kind='bend-public-cli-package',version=1,complete=True,operationalOnly=True,
        host='native',stage='N1',targets=['c'],protocol='native-public-cli-v1',image=components['nativeCli']['image'],
        source=identity(pkg['source']),canonicalSource=identity(canonical),assets=package_assets,
        baseIdentity=pkg['baseIdentity'],cacheStamp=pkg['cacheStamp'],runtime=providers['cRuntime'],
        runtimeArgumentConvention=pkg['runtimeArgumentConvention'],imageBinding=cli_binding,
        provenance={name:gates[name]['report'] for name in ['cli-package','cli-behavior']}))
    installable('selfhost/dist/native/BUILD.json',pin(out/'native-BUILD.json'))
    shutil.copyfile(previous_pin['file'],out/'previous-selector.json')
    bindings = dict(kind='bend-current-bindings',version=1,complete=True,upstream=UPSTREAM,files=installed,
        components=components,providers=providers,source=dict(recipe=dict(source_recipe,file=str(Path(source_recipe['file']).relative_to(ROOT))),
        root=str(source_root.relative_to(ROOT)),profile='qbe',identity=identity(canonical)))
    proposal = dict(kind='bend-release-promotion',version=1,complete=True,bindings=bindings,files=files,gates=gates,
        jsFixedPoint='js-fixedpoint',nativeCliDerivation='cli-profile',
        preparation=dict(method=pin(__file__),recipe=recipe_pin,previous=previous_pin,inputs=inputs),
        scope='Completed current-source evidence only; explicit finite counts. No installation or unchanged hosted/session capability inherited.')
    require(not changed_inputs(inputs),'Inputs changed during proposal preparation')
    write_json(out/'promotion.json',proposal)
    _, audit = release.audit(out/'promotion.json',ROOT); write_json(out/'audit.json',audit)
    require(not changed_inputs(inputs),'Inputs changed during release audit')
    write_json(out/'report.json',dict(kind='phase182-release-preparation',complete=True,targetsRun=False,installed=False,
        releaseAudited=True,recipe=recipe_pin,proposal=pin(out/'promotion.json'),audit=pin(out/'audit.json'),inputs=inputs))
    return out/'promotion.json'


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--recipe',type=Path,required=True)
    parser.add_argument('--out',type=Path,required=True)
    args = parser.parse_args()
    try:
        print(prepare(args.recipe,args.out))
    except (ValueError,KeyError,OSError,TypeError,json.JSONDecodeError) as error:
        print('Phase182 promotion refused: '+str(error),file=sys.stderr); raise SystemExit(1)
