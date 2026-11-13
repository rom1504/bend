#!/usr/bin/env python3
"""Compare authenticated JS/C/QBE source profiles and maps; no compiler execution."""
import argparse
import copy
import hashlib
import importlib.util
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SOURCE = ROOT/'selfhost'
PROFILES = ['qbe', 'native-c', 'js-api']


def sha(data):
    return hashlib.sha256(data).hexdigest()


def pin(path):
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=sha(data))


def save(path, value):
    with path.open('x') as stream:
        json.dump(value, stream, indent=2)
        stream.write('\n')


def git(*args, input=None):
    return subprocess.check_output(['git', *args], cwd=ROOT, input=input)


def modules(manifest):
    result = set(manifest['modules']) | {manifest['preamble']}
    for profile in PROFILES:
        config = manifest['profiles'][profile]
        result.update(config.get('modules', []))
        if config.get('entryModule'):
            result.add(config['entryModule'])
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--baseline', action='append')
    args = parser.parse_args()
    out = args.out.resolve()
    assert out.is_relative_to(ROOT/'selfhost/build/phase191') and not out.exists(), 'Fresh Phase191 output required'
    out.mkdir(parents=True)
    current_path = SOURCE/'src/compiler.json'
    current_bytes = current_path.read_bytes()
    current = json.loads(current_bytes)
    current_copy = out/'current-compiler.json'
    current_copy.write_bytes(current_bytes)
    source_method = SOURCE/'tools/build/source.py'
    source_pin = pin(source_method)
    spec = importlib.util.spec_from_file_location('phase191_source', source_method)
    assembler = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(assembler)
    dependencies = sorted('selfhost/'+p for p in modules(current)) + ['selfhost/tools/build/source.py']
    inventory = {p: dict(path=p, **{k: v for k, v in pin(ROOT/p).items() if k != 'file'}, baselineGitBlobs={})
                 for p in dependencies}
    result = dict(kind='phase191-unchanged-non-x86-profiles-v1', complete=False, targetsRun=False,
        observedHead=git('rev-parse', 'HEAD').decode().strip(),
        inputs=[pin(Path(__file__)), source_pin, pin(current_path), pin(current_copy),
                pin(ROOT/'selfhost/build/phase190/unchanged-targets01/audit.py')],
        method='Authenticate every assembler-read module and the maintained assembler against each baseline Git blob; compare full assembled profile bytes and declaration maps in memory.',
        scope='Metadata/source transport only; no compiler/target execution or inherited qualification claim.',
        baselines=[], profiles=[], fullSourceCopiesRetained=False)
    try:
        for revision in args.baseline or ['e4cdffa', '6fb9da3']:
            commit = git('rev-parse', revision+'^{commit}').decode().strip()
            prior_bytes = git('show', commit+':selfhost/src/compiler.json')
            prior = json.loads(prior_bytes)
            old_other, current_other = copy.deepcopy(prior), copy.deepcopy(current)
            old_x86 = old_other['profiles']['x86'].pop('modules')
            new_x86 = current_other['profiles']['x86'].pop('modules')
            assert old_other == current_other, 'Manifest changed beyond x86 module list'
            assert [p for p in new_x86 if p in old_x86] == old_x86, 'Old x86 module ordering changed'
            assert modules(prior) == modules(current), 'Non-x86 module ownership changed'
            prior_path = out/(commit[:12]+'-compiler.json')
            prior_path.write_bytes(prior_bytes)
            requests = ''.join(commit+':'+p+'\n' for p in dependencies).encode()
            raw = git('cat-file', '--batch', input=requests)
            pos = 0
            for name in dependencies:
                end = raw.index(b'\n', pos)
                oid, kind, size = raw[pos:end].decode().split()
                assert kind == 'blob', 'Baseline dependency not blob'
                pos = end+1
                prior_data = raw[pos:pos+int(size)]
                pos += int(size)
                assert raw[pos:pos+1] == b'\n', 'Invalid Git batch framing'
                pos += 1
                current_data = (ROOT/name).read_bytes()
                assert current_data == prior_data, 'Changed dependency: '+name
                assert sha(current_data) == inventory[name]['sha256'], 'Dependency changed during audit'
                inventory[name]['baselineGitBlobs'][commit] = oid
            assert pos == len(raw)
            for profile in PROFILES:
                assert prior['profiles'][profile] == current['profiles'][profile]
                old_source, old_map = assembler.maintained_assemble(prior_path, SOURCE, profile, with_map=True)
                new_source, new_map = assembler.maintained_assemble(current_copy, SOURCE, profile, with_map=True)
                assert old_source == new_source, 'Source differs: '+profile
                assert old_map == new_map, 'Map differs: '+profile
                used = sorted({row['file'] for row in new_map} | {current['preamble']})
                assert set(used) <= modules(current)
                assert not any(p.startswith('src/back/x86/') for p in used)
                map_bytes = json.dumps(new_map, sort_keys=True, separators=(',', ':')).encode()
                result['profiles'].append(dict(baseline=commit, profile=profile,
                    bytes=len(new_source), sha256=sha(new_source), sourceMapSha256=sha(map_bytes),
                    byteIdentical=True, sourceMapIdentical=True, declarations=len(new_map),
                    selectedModules=len(used), x86ModulesSelected=0))
            result['baselines'].append(dict(commit=commit, manifest=pin(prior_path),
                onlyManifestChange='profiles.x86.modules', addedX86Modules=[p for p in new_x86 if p not in old_x86]))
        for name, expected in inventory.items():
            assert all(pin(ROOT/name)[k] == expected[k] for k in ['bytes', 'sha256']), 'Dependency changed after assembly'
        assert current_path.read_bytes() == current_bytes, 'Manifest changed during audit'
        save(out/'authenticated-modules.json', list(inventory.values()))
        result['authenticatedDependencies'] = dict(count=len(inventory), sourceModules=len(modules(current)),
            inventory=pin(out/'authenticated-modules.json'), allByteIdentical=True)
        result['complete'] = True
    except Exception as error:
        result['error'] = repr(error)
        raise
    finally:
        save(out/'report.json', result)
    print(json.dumps(dict(complete=result['complete'], profiles=len(result['profiles']),
                         dependencies=len(inventory), targetsRun=False, report=str(out/'report.json'))))


if __name__ == '__main__':
    main()
