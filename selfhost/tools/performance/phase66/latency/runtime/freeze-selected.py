#!/usr/bin/env python3
"""Freeze qualified new Bend output for unchanged old/new/HEAD-TS runtime clocks."""
import argparse
import hashlib
import json
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[6]
RAW = ROOT / 'selfhost/build/phase66'
PIN = '059266225b77c8ca256ac6b25ee5c21449bab151'
inputs = {}


def pin(value):
    item = value if isinstance(value, dict) else None
    file = Path(item.get('file', item.get('path')) if item else value).resolve(strict=True)
    data = file.read_bytes()
    row = dict(file=str(file), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))
    if item:
        assert row['sha256'] == item['sha256'], file
        if 'bytes' in item:
            assert row['bytes'] == item['bytes'], file
    assert str(file) not in inputs or inputs[str(file)] == row
    inputs[str(file)] = row
    return row


def read(value):
    return json.loads(Path(pin(value)['file']).read_text())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--oracles', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve()
    assert out.is_relative_to(RAW) and not out.exists()
    catalog_file = ROOT / 'selfhost/tools/performance/phase37/catalog.json'
    catalog = read(catalog_file)
    selected = read(args.oracles)
    assert selected['kind'] == 'phase61-qualified-compiler-output-oracles'
    assert selected['complete'] and selected['pass'] and selected['upstreamCommit'] == PIN
    assert selected['counts'] == dict(sources=23, points=45)
    assert selected['originalRuntimeCatalog']['sha256'] == pin(catalog_file)['sha256']
    for row in selected['inputs']:
        pin(row)
    for row in selected['image'].values():
        pin(row)
    manifest_pin = pin(selected['acquisition'])
    manifest = read(manifest_pin)
    assert manifest['complete'] and manifest['upstreamCommit'] == PIN
    assert set(manifest['roles']) == {'candidate'}
    assert manifest['roles']['candidate']['compiler'] == selected['compiler']
    assert selected['compiler']['api']['sha256'] == selected['image']['api']['sha256']
    smoke = read(selected['semanticQualification'])
    assert smoke['complete'] and smoke['passed'] and smoke['inputsUnchanged']
    assert len(smoke['cases']) == 45 and all(row['passed'] for row in smoke['cases'])
    rows = {row['id']: row for row in manifest['cases']}
    assert len(rows) == len(manifest['cases']) == 45
    assert set(rows) == set(catalog['sets']['full'])
    baseline_file = RAW / 'program-reference-snapshot/selected-baseline.json'
    baseline = read(baseline_file)
    assert baseline['kind'] == 'phase66-mixed-target-program-bundle' and baseline['complete']
    assert baseline['catalogSha256'] == pin(catalog_file)['sha256']
    assert set(baseline['roles']) == {'baseline', 'typescript'}
    assert baseline['compilerTargets'] == dict(baseline=catalog['upstreamCommit'], typescript=PIN)
    assert set(baseline['provenance']) == {'oldB1', 'oldB2Equality', 'headAdmission'}
    for row in baseline['provenance'].values():
        pin(row)
    snapshot = read(RAW / 'program-reference-snapshot/report.json')
    assert snapshot['complete'] and snapshot['pass']
    assert pin(snapshot['selectedBaseline']) == pin(baseline_file)
    copies, cases = [], []
    out.mkdir(parents=True)
    for case in catalog['cases']:
        row = rows[case['id']]
        assert row['sourceSha256'] == case['source']['sha256'] and row['point'] == case['point']
        assert set(row['modules']) == {'candidate'}
        module = row['modules']['candidate']
        before = pin(dict(file=str(Path(manifest_pin['file']).parent / module['path']),
                          sha256=module['sha256'], bytes=module['bytes']))
        # Content-addressed names avoid basename collisions across source files.
        destination = out / 'modules' / (before['sha256'] + '.mjs')
        destination.parent.mkdir(exist_ok=True)
        if not destination.exists():
            shutil.copyfile(before['file'], destination)
        after = pin(destination)
        assert after['sha256'] == before['sha256'] and after['bytes'] == before['bytes']
        copies.append(dict(before=before, after=after))
        cases.append(dict(id=case['id'], sourceSha256=case['source']['sha256'], point=case['point'],
            modules=dict(candidate=dict(path=str(destination.relative_to(out)),
                                        sha256=after['sha256'], bytes=after['bytes']))))
    bundle = dict(kind='phase66-selected-target-program-bundle', schemaVersion=1, complete=True,
        sourceCorpusUpstreamCommit=catalog['upstreamCommit'], catalogSha256=pin(catalog_file)['sha256'],
        compilerTargets=dict(candidate=PIN), roles=manifest['roles'], cases=cases,
        provenance={**baseline['provenance'], 'candidateAdmission': pin(args.oracles)},
        scope='New checked Bend B1 output after complete23-source/45-point qualification. '
              'Actual compiler metadata retained; this is not a claim that B2 emitted identical modules. '
              'The separate genuine-B2 equality gate must establish that later.')
    bundle_file = out / 'candidate.json'
    bundle_file.write_text(json.dumps(bundle, indent=2) + '\n')
    runner = Path(__file__).with_name('run-v3.py')
    parent_recipe = read(RAW / 'program-reference-snapshot/timing-recipe-v2.json')
    commands = {}
    for name, old in parent_recipe['commands'].items():
        argv = list(old)
        argv[1] = str(runner)
        argv[argv.index('--baseline') + 1] = str(baseline_file)
        argv[argv.index('--candidate') + 1] = str(bundle_file)
        argv[argv.index('--out') + 1] = str(out / ('timing-' + name))
        commands[name] = argv
    for row in list(inputs.values()):
        pin(row)
    recipe = dict(kind='phase66-selected-runtime-budget-recipe', complete=True, dataOnly=True,
        targetExecuted=False, producer=pin(__file__), method=pin(runner),
        catalog=pin(catalog_file), candidate=pin(bundle_file), baseline=pin(baseline_file),
        inputs=list(inputs.values()), copies=copies, commands=commands,
        scope='Baseline=Phase65 selected Bend output; candidate=qualified selected Phase66 Bend output; '
              'typescript=HEAD TypeScript output. Preparation and compilation excluded. '
              'Stock20/60/300/600 presets and three15-point full batches retained unchanged.')
    recipe_file = out / 'recipe.json'
    recipe_file.write_text(json.dumps(recipe, indent=2) + '\n')
    print(json.dumps(dict(recipe=pin(recipe_file), targetExecuted=False)))


if __name__ == '__main__':
    main()
