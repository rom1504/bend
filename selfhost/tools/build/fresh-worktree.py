#!/usr/bin/env python3
"""Finite installed-compiler gate in an actual sparse Git worktree.

Run inside ONE outer resource guard covering the whole fresh checkout and its
copied artifacts. The caller creates the worktree; this does not checkout Git,
change source, acquire dependencies implicitly, or rebuild a compiler image.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import time
sys.dont_write_bytecode = True


def require(value, message):
    if not value: raise ValueError(message)


def pin(file):
    file = Path(file).resolve(strict=True); digest = hashlib.sha256(); size = 0
    with file.open('rb') as stream:
        for block in iter(lambda: stream.read(1024**2), b''):
            digest.update(block); size += len(block)
    return dict(file=str(file), bytes=size, sha256=digest.hexdigest())


def same(actual, expected):
    return all(actual[k] == expected[k] for k in ['bytes', 'sha256'])


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for name in ['origin', 'worktree', 'out']: p.add_argument('--'+name, type=Path, required=True)
    p.add_argument('--commit', required=True); a = p.parse_args()
    origin = a.origin.resolve(strict=True); tree = a.worktree.resolve(strict=True); out = a.out.absolute()
    require(tree != origin, 'The worktree must differ from the original workspace')
    require(not tree.is_relative_to(origin) or tree.is_relative_to(origin/'selfhost/build'),
            'A nested worktree must be confined to the original ignored build tree')
    require((tree/'.git').is_file(), 'Actual linked Git worktree metadata required')
    require(out == out.resolve() and out.is_relative_to(tree/'selfhost/build') and not out.exists(), 'Fresh confined output required')
    env = {k:v for k,v in os.environ.items() if not k.startswith('BEND_') and k not in ['NODE_OPTIONS','NODE_PATH','LD_PRELOAD','PYTHONPATH','PYTHONHOME']}
    def git(*args):
        x = subprocess.run(['git','-C',str(tree),*args], capture_output=True, env=env, timeout=20)
        require(x.returncode == 0, 'Git inspection failed: '+x.stderr.decode()); return x.stdout.decode().strip()
    require(Path(git('rev-parse','--show-toplevel')).resolve() == tree, 'Git resolved an ancestor instead of the worktree')
    head = git('rev-parse','HEAD'); require(head == a.commit, 'Worktree is not the requested commit')
    require(not git('status','--porcelain','--untracked-files=no'), 'Fresh tracked worktree must be clean')
    require(not (tree/'selfhost/tools/performance').exists(), 'Historical performance methods must be absent')
    require(not (tree/'selfhost/build').exists(), 'Do not copy a preexisting build/cache tree')
    require(not (tree/'implementation').exists(), 'Historical evidence tree must be absent')
    current_file = tree/'selfhost/manifests/current.json'; current_pin = pin(current_file)
    require(same(current_pin,pin(origin/'selfhost/manifests/current.json')), 'Origin and HEAD release selectors differ')
    current = json.loads(current_file.read_text()); require(current.get('gateStatus',{}).get('qualified') is True, 'Qualified selector required')
    manifest = tree/'selfhost/manifests/assets-native.json'; manifest_pin = pin(manifest)
    require(same(manifest_pin,pin(origin/'selfhost/manifests/assets-native.json')), 'Operational asset manifest differs')
    assets = json.loads(manifest.read_text()); out.mkdir(parents=True)
    report = dict(kind='bend-fresh-git-worktree-gate',version=1,complete=False,commit=head,
      method=pin(__file__),worktree=str(tree),gitMetadata=git('rev-parse','--absolute-git-dir'),current=current_pin,
      operationalAssets=manifest_pin,copies=[],externalAssets=[],commands=[],outputs={},
      scope='Finite installed JS/C/QBE relocation qualification with explicit binary/tool inputs; no rebuild, broad conformance or bootstrap claim.')
    started = time.monotonic(); copied_bytes = 0
    def save():
        report['seconds'] = time.monotonic()-started
        (out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    def stage(row):
        nonlocal copied_bytes
        relative = Path(row['file'])
        require(not relative.is_absolute() and '..' not in relative.parts, 'Confined artifact path required')
        source = origin/relative; dest = tree/relative; before = pin(source)
        require(same(before,row), 'Origin artifact differs from explicit pin: '+str(relative))
        require(source.resolve() == source and dest.resolve() == dest, 'Artifact symlink refused')
        if dest.exists(): require(same(pin(dest),row), 'Fresh artifact differs from HEAD/pin')
        else:
            copied_bytes += row['bytes']; require(copied_bytes <= 256*1024**2, 'Explicit copies exceed 256MiB')
            dest.parent.mkdir(parents=True,exist_ok=True); shutil.copy2(source,dest)
        require(same(pin(dest),row) and same(pin(source),row), 'Artifact changed while copying')
        report['copies'].append(dict(source=before,destination=pin(dest))); save()
    def run(label, command, stdout=None, stderr=b'', seconds=60):
        begin = time.monotonic()
        with (out/(label+'.stdout')).open('wb') as so,(out/(label+'.stderr')).open('wb') as se:
            x = subprocess.run(list(map(str,command)),cwd=tree,env=env,stdout=so,stderr=se,timeout=seconds)
        row = dict(label=label,command=list(map(str,command)),exit=x.returncode,seconds=time.monotonic()-begin,
                   stdout=pin(out/(label+'.stdout')),stderr=pin(out/(label+'.stderr')))
        report['commands'].append(row); save(); require(x.returncode == 0, 'Command failed: '+label)
        if stdout is not None: require(Path(row['stdout']['file']).read_bytes() == stdout, 'Output differs: '+label)
        if stderr is not None: require(Path(row['stderr']['file']).read_bytes() == stderr, 'Diagnostics differ: '+label)
        return row
    save()
    try:
        for row in current['files'].values(): stage(row)
        stage(current['providers']['qbeRuntime'])
        for key in ['bun','qbe','qbe-n2','prepared-base']: stage(assets['assets'][key])
        # Explicit external pinned assets are permitted. No experimental artifact
        # or old compiler method is selected through an external path.
        for key in ['base','clang','assembler','linker']:
            row = assets['assets'][key]; require(Path(row['file']).is_absolute(), 'External pin must be absolute')
            actual = pin(row['file']); require(same(actual,row), 'External asset changed: '+key)
            report['externalAssets'].append(dict(key=key,identity=actual))
        tools = tree/'selfhost/tools/build'; python = sys.executable
        run('verify-release',[python,'-B',tools/'release.py','verify','--manifest',current_file])
        run('assemble',[python,'-B',tools/'source.py','assemble','--manifest',tree/'selfhost/src/compiler.json',
            '--root',tree/'selfhost','--profile','qbe','--out',out/'compiler.bend'])
        assembled = pin(out/'compiler.bend'); require(same(assembled,current['source']['identity']), 'Fresh source differs from selected source')
        report['assembledSource'] = assembled
        selected = ['bun','qbe','qbe-n2','prepared-base','qbe-runtime','base','clang','assembler','linker']
        run('verify-assets',[python,'-B',tools/'assets.py','verify','--manifest',manifest,*[v for k in selected for v in ['--key',k]]])
        source = out/'numeric.bend'; source.write_text('import Base\ndef main() -> U32:\n  U32.add(40, 2)\n')
        expected = out/'expected.txt'; expected.write_text('42\n')
        bun = tree/assets['assets']['bun']['file']
        report['fixture'] = pin(source); report['expected'] = pin(expected)
        run('js-run',[bun,tree/'selfhost/cli.mjs',source,'--run'],b'42\n')
        verdict = b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n\n'
        run('native-c-emit',[python,'-B',tree/'selfhost/native.py',source,'-o',out/'numeric.c','--live'],b'',verdict)
        policy = assets['toolchains']['c']; clang = assets['assets'][policy['compiler']]['file']
        run('native-c-build',[clang,*policy['flags'],*policy['includeFlags'],out/'numeric.c','-o',out/'numeric-c',*policy['libraries']],b'',None)
        run('native-c-run',[out/'numeric-c','--threads','1','--gpu','off'],b'42\n')
        run('qbe-live-build',[python,'-B',tools/'native.py','--assets',manifest,'--image-key','qbe-n2','--host','native',
            '--stage','N2','--target','qbe','--mode','live','--source',source,'--out',out/'qbe','--seconds','45',
            '--expected-stdout',expected],seconds=55)
        qbe = json.loads((out/'qbe/report.json').read_text())
        require(qbe.get('complete') is True and qbe.get('outputExact') is True, 'QBE live execution not qualified')
        report['outputs'] = dict(js='42\n',nativeC='42\n',qbe=Path(out/'qbe/execute.stdout').read_text())
        report['qbeReceipt'] = pin(out/'qbe/report.json'); report['copiedBytes'] = copied_bytes
        for item in report['copies']:
            require(same(pin(item['source']['file']),item['source']) and same(pin(item['destination']['file']),item['destination']), 'Copied input changed')
        for item in report['externalAssets']: require(same(pin(item['identity']['file']),item['identity']), 'External input changed')
        require(same(pin(current_file),current_pin) and same(pin(manifest),manifest_pin), 'Selector changed')
        require(not git('status','--porcelain','--untracked-files=no'), 'Qualification modified tracked source')
        require(not (tree/'selfhost/tools/performance').exists() and not (tree/'implementation').exists(), 'History unexpectedly acquired')
        report['complete'] = True
    except BaseException as error: report['error'] = repr(error)
    finally: save()
    print(json.dumps({k:report.get(k) for k in ['complete','seconds','copiedBytes','outputs','error']}))
    return 0 if report['complete'] else 1


if __name__ == '__main__': sys.exit(main())
