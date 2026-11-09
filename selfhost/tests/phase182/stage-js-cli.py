#!/usr/bin/env python3
"""Copy a finite qualified B2 public-shell workspace; never install or run targets."""
import argparse
import json
from pathlib import Path
import shutil
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT/'selfhost/tools/build'))
import assets
import release
from common import changed_inputs, fresh_output, pin, require, verify, write_json

UPSTREAM = '9a4223d577ba56a0cb53d1fd952d2b481c38930f'


def qualified(report, image, target):
    require(report.get('kind') == 'bend-finite-qualification' and report.get('complete') is True
            and report.get('passed') is True and not report.get('error') and not report.get('changedInputs')
            and report.get('upstream') == UPSTREAM
            and (report.get('host'), report.get('stage'), report.get('target')) == ('js', 'B2', target)
            and release.same(report.get('image'), image)
            and report.get('counts') == {'pass': 18, 'fail': 0, 'unsupported': 0},
            'Actual current B2 '+target+' focused18 required')
    selected, rows = report.get('selected', []), report.get('rows', [])
    require(len(selected) == len(set(selected)) == len(rows) == 18
            and {row['id'] for row in rows} == set(selected)
            and all(row.get('status') == 'pass' for row in rows), 'Qualification rows differ')


def stage(a):
    inputs = [pin(__file__), pin(assets.__file__), pin(release.__file__), pin(ROOT/'selfhost/tools/build/common.py')]
    def read(file):
        row = pin(file); inputs.append(row)
        return row, json.loads(verify(row).read_text())
    b2_pin, b2 = read(a.image_receipt)
    require(b2.get('kind') == 'bend-js-self-emission' and b2.get('stage') == 'B2'
            and b2.get('complete') is True and not b2.get('error') and not b2.get('changedInputs'), 'Complete actual B2 required')
    verify(b2['authority']); b1_pin, b1 = read(b2['authority']['file'])
    require(b1.get('kind') == 'bend-checked-hosted-api' and b1.get('complete') is True
            and b1.get('checked') is True and b1.get('status') == 0 and not b1.get('error')
            and b1['upstream']['revision'] == UPSTREAM and release.same(b2['generator'], b1['api'])
            and release.same(b2['source'], b1['source']), 'B2 must derive from actual same-source checked B1')
    binding = b2['imageBinding']; image = b2['image']
    require(binding.get('complete') is True and binding.get('checked') is True
            and (binding['host'], binding['stage'], binding['protocol']) == ('js', 'B2', 'hosted-api-v1')
            and binding['targets'] == ['js', 'c'] and binding['preparationModes'] == ['live']
            and release.same(binding['image'], image) and release.same(binding['sourceIdentity'], b2['source']), 'B2 operational binding differs')
    gates, qualifications = {}, []
    _, selection = read(Path(__file__).with_name('qualification-selections.json'))
    expected_cases = {'focused/'+name for name in selection['hosted-js-c']['cases']}
    for target, file in [('js', a.js_qualification), ('c', a.c_qualification)]:
        row, report = read(file); qualified(report, image, target); gates[target] = row
        require(set(report['selected']) == expected_cases, 'Expected exact Phase182 focused18 selection')
        qualifications.append(report)
    document = assets.load_assets(a.assets, ROOT); inputs.append(document['_manifest'])
    require(document['upstream'] == UPSTREAM, 'Current assets required')
    require(all(any(release.same(row, document['_manifest']) for row in report['inputs'])
                for report in qualifications), 'Qualification used different provider assets')
    providers = {key: assets.asset(document, name) for key, name in [
        ('base', 'base'), ('jsLegacyRuntime', 'js-legacy-runtime'), ('jsDirectRuntime', 'js-direct-runtime'),
        ('cRuntime', 'c-runtime'), ('cRuntimeTemplate', 'c-runtime-template')]}
    require(release.same(providers['base'], b2['base']) and release.same(providers['jsDirectRuntime'], b2['directRuntime']), 'B2 provider bytes differ')
    inputs += [image, b2['source'], b1['api'], *providers.values(), *b1['inputs'], *b2['inputs']]
    for row in inputs: verify(row)
    originals = {str(file.relative_to(ROOT)): pin(file) for file in [ROOT/'selfhost/cli.mjs',
        ROOT/'selfhost/src/compiler.json', ROOT/'selfhost/src/runtime.mjs',
        *sorted((ROOT/'selfhost/tools').glob('*.mjs')),
        *[p for p in sorted((ROOT/'selfhost/src/runtime').rglob('*')) if p.is_file()]]}
    require(release.same(originals['selfhost/src/runtime.mjs'], providers['jsLegacyRuntime'])
            and release.same(originals['selfhost/src/runtime/js/direct.mjs'], providers['jsDirectRuntime'])
            and release.same(originals['selfhost/src/runtime/native/runtime.c'], providers['cRuntime']), 'Maintained provider closure differs')
    originals.update({'selfhost/dist/typed-api.mjs': image, 'selfhost/dist/base.bend': providers['base'],
                      'selfhost/dist/native/runtime-template.json': providers['cRuntimeTemplate']})
    require(len(originals) <= 1024 and sum(row['bytes'] for row in originals.values()) <= 64*1024**2, 'Staged closure exceeds finite bound')
    inputs += list(originals.values())
    out = fresh_output(a.out, ROOT); tree = out/'workspace'; tree.mkdir()
    copies, files = {}, {}
    for name, original in originals.items():
        relative = Path(name)
        require(not relative.is_absolute() and '..' not in relative.parts and name.startswith('selfhost/'), 'Nonconfined copy')
        destination = tree/relative; destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(verify(original), destination)
        actual = pin(destination); require(release.same(original, actual), 'Staged copy differs')
        copies[name] = dict(source=original, destination=actual); files[name] = actual
    def installed(name): return dict(files[name], file=name)
    selected = {'base': installed('selfhost/dist/base.bend'),
        'jsLegacyRuntime': installed('selfhost/src/runtime.mjs'),
        'jsDirectRuntime': installed('selfhost/src/runtime/js/direct.mjs'),
        'cRuntime': installed('selfhost/src/runtime/native/runtime.c'),
        'cRuntimeTemplate': installed('selfhost/dist/native/runtime-template.json')}
    selector = dict(kind='bend-current-bindings', version=1, complete=True, testOnly=True, installable=False,
        upstream=UPSTREAM, files={name:installed(name) for name in files if name.startswith('selfhost/dist/')},
        components={'js': dict(host='js', stage='B2', protocol='hosted-api-v1', capabilities=['js','c'],
                              image=installed('selfhost/dist/typed-api.mjs'), sourceIdentity=b2['source'])},
        providers=selected, gateStatus=dict(qualified=True, scope='Only this B2 JS18/C18; not a complete compiler release.', receipts=gates))
    selector_file = tree/'selfhost/manifests/current.json'; selector_file.parent.mkdir()
    write_json(selector_file, selector); files['selfhost/manifests/current.json'] = pin(selector_file)
    require(not changed_inputs(inputs), 'Staging input changed')
    report = dict(kind='bend-staged-public-js-package', version=1, complete=True, testOnly=True, installable=False,
        upstream=UPSTREAM, origin=str(ROOT), workspace=str(tree), image=pin(tree/'selfhost/dist/typed-api.mjs'),
        source=b2['source'], base=pin(tree/'selfhost/dist/base.bend'), selector=pin(selector_file),
        authority=b2_pin, checkedAuthority=b1_pin, qualifications=gates, assets=document['_manifest'],
        inputs=inputs, copies=copies, files=files, targetsRun=False, installed=False,
        scope='Exact maintained public shell and provider copies with a qualified B2-only test selector. No B3/global-release qualification or installation claim.')
    write_json(out/'report.json', report)
    return out/'report.json'


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ['image-receipt', 'js-qualification', 'c-qualification', 'assets', 'out']:
        parser.add_argument('--'+name, type=Path, required=True)
    print(stage(parser.parse_args()))
