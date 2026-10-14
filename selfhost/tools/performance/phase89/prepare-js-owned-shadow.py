#!/usr/bin/env python3
"""Offline Phase88 checked-workflow snapshot + one owned-composition module."""
import argparse
import hashlib
import json
import subprocess
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]


def digest(data):
    return hashlib.sha256(data).hexdigest()


def pin(path):
    path = path.resolve()
    return dict(file=str(path), sha256=digest(path.read_bytes()), bytes=path.stat().st_size)


def checked(path, expected):
    data = path.read_bytes()
    assert digest(data) == expected['sha256'], str(path)
    assert 'bytes' not in expected or len(data) == expected['bytes'], str(path)
    return data


def write_json(path, value):
    with path.open('x') as stream:
        stream.write(json.dumps(value, indent=2) + '\n')


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('output', type=Path)
    args = ap.parse_args()
    out = args.output.resolve()
    assert out.is_relative_to(ROOT/'selfhost/build/phase89')
    config_file = out.with_suffix('.config.json')
    receipt_file = out.with_suffix('.receipt.json')
    assert not any(p.exists() for p in [out, config_file, receipt_file])

    evidence_file = ROOT/'implementation/phase88/evidence.json'
    evidence = json.loads(evidence_file.read_text())
    archive = ROOT/evidence['archive']['file']
    checked(archive, evidence['archive'])
    manifest_file = ROOT/evidence['manifest']['file']
    manifest = json.loads(checked(manifest_file, evidence['manifest']))
    members = {p['file']: p for p in manifest}
    assert len(members) == len(manifest)
    attempt_file = ROOT/'selfhost/build/phase88/js-development01/attempt.json'
    attempt = json.loads(checked(attempt_file, members[str(attempt_file.relative_to(ROOT))]))
    assert attempt['checked'] and attempt['config']['profile'] == 'equality'
    snapshot = Path(attempt['snapshot']['root'])
    selected = {}
    baseline = []
    with zipfile.ZipFile(archive) as z:
        assert z.namelist() == [p['file'] for p in manifest]
        for row in attempt['snapshot']['sources']:
            old = Path(row['frozen']['file'])
            rel = old.relative_to(snapshot)
            assert rel.parts[0] in ('src', 'tools', 'tests')
            assert '..' not in rel.parts and rel not in selected
            member = str(old.relative_to(ROOT))
            data = z.read(member)
            assert digest(data) == row['frozen']['sha256'] == members[member]['sha256']
            assert len(data) == members[member]['bytes']
            selected[rel] = data
            baseline.append(dict(relative=str(rel), archiveMember=member,
                sha256=digest(data), bytes=len(data), original=row['original']))
    assert len(selected) == 333

    compiler = json.loads(selected[Path('src/compiler.json')])
    assert len(compiler['modules']) == len(set(compiler['modules'])) == 132
    assert (ROOT/'selfhost/src/compiler.json').read_bytes() == selected[Path('src/compiler.json')]
    modules = []
    for name in compiler['modules']:
        path = ROOT/'selfhost'/name
        assert path.read_bytes() == selected[Path(name)], f'Production changed: {name}'
        modules.append(pin(path))

    candidate = ROOT/'selfhost/tools/performance/phase89/composition'
    derivation_file = candidate/'source.json'
    derivation = json.loads(derivation_file.read_text())
    checked(Path(derivation['baseline']['file']), derivation['baseline'])
    path = Path(derivation['candidate']['file'])
    assert path == candidate/'bridge.candidate.bend'
    data = checked(path, derivation['candidate'])
    rel = Path('src/back/native/bridge.bend')
    assert str(rel) in compiler['modules']
    assert digest(selected[rel]) == derivation['baseline']['sha256']
    overrides = [dict(relative=str(rel), baselineSha256=digest(selected[rel]),
        candidate=pin(path), output=str(out/rel))]
    selected[rel] = data
    checked(candidate/'candidate.patch', derivation['patch'])

    upstream = Path(attempt['config']['upstream']).resolve()
    upstream_head = subprocess.check_output(['git', '-C', str(upstream), 'rev-parse', 'HEAD'], text=True).strip()
    assert upstream_head == compiler['upstream']
    checked(Path(attempt['node']['file']), attempt['node'])
    checked(Path(attempt['base']['file']), attempt['base'])
    config = dict(attempt['config'], project=str(out), upstream=str(upstream),
        profile='equality', jobs=1, cpu='3', heapMb=1024, strictExact=True)
    assert config['selection'] is None and config['fullFrontend'] is False

    out.mkdir()
    outputs = []
    for rel, data in sorted(selected.items()):
        dest = out/rel
        dest.parent.mkdir(parents=True, exist_ok=True)
        with dest.open('xb') as stream:
            stream.write(data)
        outputs.append(pin(dest))
    write_json(config_file, config)
    launcher = out/'tools/development/workflow.mjs'
    receipt = dict(kind='phase89-ordinary-js-owned-shadow-project', complete=True,
        compiled=False, productionChanged=False, sourceFiles=len(outputs),
        productionModulesVerified=len(modules), overriddenModules=len(overrides),
        inputs=[pin(p) for p in [Path(__file__), evidence_file, archive, manifest_file,
            attempt_file, derivation_file, candidate/'candidate.patch',
            ROOT/'selfhost/tools/performance/phase89/prepare-js-shadow.py']],
        upstream=dict(file=str(upstream), commit=upstream_head), node=attempt['node'],
        base=attempt['base'], baselineInventory=baseline, currentProductionModules=modules,
        overrides=overrides, outputs=outputs, config=pin(config_file), launcher=pin(launcher),
        workflowCommand=[attempt['node']['file'], str(launcher), 'run', str(config_file),
            str(out.parent/'js-owned-development01')],
        scope='Ordinary 132-module checked JS B1; owned composition only, one module override, equality profile. No native entry, decoder, effect extension, String.eq adaptation, generated image, cache, build or dist copied.',
        baselineApis=dict(checked=attempt['checkedApi'], selected=attempt['api']))
    write_json(receipt_file, receipt)
    print(json.dumps(dict(project=str(out), config=pin(config_file), receipt=pin(receipt_file),
        sourceFiles=len(outputs), modulesVerified=len(modules), overrides=len(overrides),
        copiedBytes=sum(p['bytes'] for p in outputs), compiled=False), indent=2))


if __name__ == '__main__':
    main()
