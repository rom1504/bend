#!/usr/bin/env python3
"""Offline filtered-tree audit. Copies explicit inputs; executes no compiler/toolchain."""
import argparse
import importlib.util
import json
from pathlib import Path
import shutil
import subprocess
import sys
sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
from common import fresh_output, pin, require, verify, workspace, write_json

# Deny reads/writes into the original repository from each relocated command.
# The filtered tree is nested inside that repository, so test its exception first.
AUDIT = '''import json,os,pathlib,runpy,sys
forbidden,allowed,receipt,script,*argv=sys.argv[1:]
forbidden=pathlib.Path(forbidden).resolve();allowed=pathlib.Path(allowed).resolve()
events=[];blocked=[]
def hook(event,args):
 if event!='open' or not isinstance(args[0],(str,bytes,os.PathLike)):return
 p=pathlib.Path(os.fsdecode(args[0])).resolve()
 if p.is_relative_to(allowed):return
 if p.is_relative_to(forbidden):
  blocked.append(str(p));raise RuntimeError('Original workspace access refused: '+str(p))
 events.append(str(p))
sys.addaudithook(hook);sys.argv=[script,*argv]
sys.path.insert(0,str(pathlib.Path(script).parent))
try:runpy.run_path(script,run_name='__main__')
finally:pathlib.Path(receipt).write_text(json.dumps(dict(blocked=blocked,externalFiles=sorted(set(events)))))
'''


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--workspace', type=Path); parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--assets', type=Path, required=True)
    args = parser.parse_args(); root = workspace(args.workspace); out = fresh_output(args.out, root)
    tree = out / 'tree'; tree.mkdir(); files = []; report = dict(kind='bend-session-portability', version=1,
        complete=False, compilerTargetsRun=False, originalWorkspace=str(root), filteredWorkspace=str(tree),
        method=pin(__file__), files=files, commands=[], scope='Offline relocation only; no native/JS execution qualification.')
    def save(): write_json(out / 'report.json', report)
    def copy_file(source, relative):
        before = pin(source); dest = tree / relative; dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, dest); verify(before); got = pin(dest)
        require((before['bytes'], before['sha256']) == (got['bytes'], got['sha256']), 'Copy changed bytes')
        files.append(dict(source=before, copied=got)); return dest
    recipe = json.loads((root / 'selfhost/src/compiler.json').read_text())
    source_paths = set(recipe['modules']) | {recipe['preamble']}
    source_paths.update(x['entryModule'] for x in recipe['profiles'].values() if x.get('entryModule'))
    for relative in sorted(source_paths): copy_file(root / 'selfhost' / relative, 'selfhost/' + relative)
    copy_file(root / 'selfhost/src/compiler.json', 'selfhost/src/compiler.json')
    copy_file(root / 'selfhost/src/session/object-frames.bend', 'selfhost/src/session/object-frames.bend')
    for name in ['common.py', 'assets.py', 'request.py', 'hosted.mjs', 'source.py']:
        copy_file(HERE.parent / name, 'selfhost/tools/build/' + name)
    for file in sorted(HERE.iterdir()):
        if file.is_file(): copy_file(file, 'selfhost/tools/build/session/' + file.name)
    spec = importlib.util.spec_from_file_location('portability_source', HERE.parent / 'source.py')
    source = importlib.util.module_from_spec(spec); spec.loader.exec_module(source)
    expected = source.maintained_assemble(root / 'selfhost/src/compiler.json', root / 'selfhost', 'qbe')
    import hashlib
    report['expectedSource'] = dict(bytes=len(expected), sha256=hashlib.sha256(expected).hexdigest())
    original_assets = pin(args.assets); document = json.loads(args.assets.read_text())
    keep = ['base', 'prepared-base', 'qbe-runtime', 'qbe', 'assembler', 'linker', 'objcopy']
    document['assets'] = {key: document['assets'][key] for key in keep}
    document['images'] = {}; document['providers'] = {}; document['toolchains'] = {'qbe': document['toolchains']['qbe']}
    for key in ['base', 'prepared-base', 'qbe-runtime', 'qbe']:
        row = document['assets'][key]; old = Path(row['file']); old = old if old.is_absolute() else root / old
        copied = copy_file(old, 'selfhost/.assets/portable/' + key)
        require((pin(copied)['bytes'], pin(copied)['sha256']) == (row['bytes'], row['sha256']), 'Asset differs from admitted pin')
        row['file'] = str(copied.relative_to(tree))
    manifest = tree / 'selfhost/assets.json'; write_json(manifest, document)
    audit = tree / 'audit.py'; audit.write_text(AUDIT)
    (tree / 'selfhost/build').mkdir(); save()
    def command(label, script, arguments, expected_code=0, needle=None):
        receipt = tree / ('audit-' + label + '.json')
        cmd = [sys.executable, '-B', str(audit), str(root), str(tree), str(receipt), str(tree / script), *map(str, arguments)]
        proc = subprocess.run(cmd, cwd=tree, capture_output=True, timeout=20)
        (out / (label + '.stdout')).write_bytes(proc.stdout); (out / (label + '.stderr')).write_bytes(proc.stderr)
        observed = json.loads(receipt.read_text())
        require(not observed['blocked'], 'Relocated command attempted original-workspace access')
        require(proc.returncode == expected_code, 'Unexpected command exit: ' + label)
        if needle: require(needle.encode() in proc.stderr, 'Missing expected refusal: ' + label)
        report['commands'].append(dict(label=label, command=cmd, exit=proc.returncode, audit=pin(receipt),
                                      stdout=pin(out / (label + '.stdout')), stderr=pin(out / (label + '.stderr')))); save()
    try:
        command('assemble', 'selfhost/tools/build/source.py', ['assemble', '--manifest', 'selfhost/src/compiler.json', '--root', 'selfhost', '--profile', 'qbe', '--out', 'selfhost/build/compiler.bend'])
        assembled = pin(tree / 'selfhost/build/compiler.bend')
        require({k: assembled[k] for k in ['bytes', 'sha256']} == report['expectedSource'], 'Relocated assembly differs')
        command('session-prepare', 'selfhost/tools/build/session/prepare.py', ['--source', 'selfhost/build/compiler.bend', '--out', 'selfhost/build/session'])
        command('assets-verify', 'selfhost/tools/build/assets.py', ['verify', '--manifest', 'selfhost/assets.json'])
        command('fixtures', 'selfhost/tools/build/session/controls.py', ['prepare', '--out', 'selfhost/build/fixtures'])
        command('session-help', 'selfhost/tools/build/session/session.py', ['--help'])
        command('objects-help', 'selfhost/tools/build/session/objects.py', ['--help'])
        command('transport', 'selfhost/tools/build/session/transport-controls.py', ['--out', 'selfhost/build/transport'])
        command('protocol', 'selfhost/tools/build/session/protocol-controls.py', ['--out', 'selfhost/build/protocol.json'])
        refusal = tree / 'prepared-refusal.py'
        refusal.write_text("import sys,pathlib\nsys.path.insert(0,str(pathlib.Path('selfhost/tools/build').resolve()))\nimport assets\ndoc=assets.load_assets('selfhost/assets.json')\nassets.prepared_base(doc,'cache')\n")
        command('prepared-path-refusal', 'prepared-refusal.py', [], 1, 'Prepared Base source identity/path differs')
        require(not (tree / 'selfhost/tools/performance').exists() and not (tree / '.git').exists(), 'Filtered tree included history')
        verify(original_assets)
        report.update(complete=True, source=assembled, sourceModules=len(source_paths), explicitAssetPins=len(keep),
          originalWorkspaceAccesses=0, transportControls=34, protocolControls=12, preparedBaseRelocation='refused as required')
    except BaseException as error:
        report['error'] = repr(error)
    finally: save()
    print(json.dumps({k:report.get(k) for k in ['complete', 'sourceModules', 'originalWorkspaceAccesses', 'error']}))
    return 0 if report['complete'] else 1


if __name__ == '__main__': sys.exit(main())
