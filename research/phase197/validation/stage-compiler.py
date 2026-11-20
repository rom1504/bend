"""Produce a complete opt-in compiler source and a reviewable patch to the x86 modules."""
import argparse
import difflib
import importlib.util
import json
from pathlib import Path
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[3]
LIVE = ROOT/'selfhost'
HERE = ROOT/'research/phase197'
spec = importlib.util.spec_from_file_location('source', LIVE/'tools/build/source.py')
source = importlib.util.module_from_spec(spec)
spec.loader.exec_module(source)


def definition(path,name):
    hits=[r for r in source.blocks(path.read_bytes())[1] if r['kind']=='def' and r['name']==name]
    assert len(hits)==1,(path,name)
    return hits[0]


def replace(path,name,payload):
    original=path.read_bytes()
    row=definition(path,name)
    before=row['offset']
    path.write_bytes(original[:before]+b'\n'+payload.strip()+b'\n'+original[before+len(row['data']):])


def main(args):
    assert args.minimum or args.decrement
    baseline=source.maintained_assemble(LIVE/'src/compiler.json',LIVE,'x86')
    assert source.digest(baseline)=='ee95d489522b4fdbdf253137319417f3eb09abe12f192db493d840c542adb8c5'
    manifest=json.loads((LIVE/'src/compiler.json').read_text())
    stage=args.out/'maintained'
    args.out.mkdir(parents=True,exist_ok=False)
    shutil.copytree(LIVE/'src',stage/'src')
    for config in manifest['profiles'].values():
        for name in [*config.get('modules',[]),*manifest['modules'],config.get('entryModule')]:
            if name and not (stage/name).exists():
                (stage/name).parent.mkdir(parents=True,exist_ok=True)
                shutil.copy2(LIVE/name,stage/name)
    changed=[]
    modules=[]
    x86=stage/'src/back/x86'
    if args.minimum:
        parts=[HERE/'minimum/select.bend',HERE/'minimum/hook.bend']
        path=x86/'predicate-select.bend'
        replace(path,'x194_ps_emit',b'\n'.join(p.read_bytes() for p in parts))
        modules.extend(parts)
        changed.append(path)
    if args.decrement:
        # Share the unchanged signed-immediate predicate between the existing
        # encoder and the earlier instruction selector without a forward dependency.
        encoder=x86/'object-encode.bend'
        predicate=definition(encoder,'x187_e_signed32')['data']
        replace(encoder,'x187_e_signed32',b'')
        common=x86/'machine.bend'
        common.write_bytes(common.read_bytes().rstrip()+b'\n\n'+predicate.strip()+b'\n')
        path=x86/'frame-forward.bend'
        parts=[args.decrement,HERE/'decrement/hook.bend']
        replace(path,'x191_frame_forward',b'\n'.join(p.read_bytes() for p in parts))
        modules.extend(parts)
        changed.extend([encoder,common,path])
    assembled=source.maintained_assemble(stage/'src/compiler.json',stage,'x86')
    (args.out/'compiler.bend').write_bytes(assembled)
    if args.api:
        def declarations(data):
            return {(r['kind'],r['name']):r for r in source.blocks(data)[1]}
        expected=declarations(args.api.read_bytes())
        after=declarations(assembled)
        names=set().union(*(declarations(p.read_bytes()).keys() for p in modules))
        assert all(source.normalized([expected[k]])==source.normalized([after[k]]) for k in names)
    else:
        names=set()
    patch=[]
    for path in changed:
        rel=path.relative_to(stage)
        original=(LIVE/rel).read_text().splitlines(True)
        candidate=path.read_text().splitlines(True)
        patch.extend(difflib.unified_diff(original,candidate,fromfile='a/selfhost/'+str(rel),tofile='b/selfhost/'+str(rel)))
    patch_path=args.out/'compiler.patch'
    patch_path.write_text(''.join(patch))
    subprocess.run(['git','apply','--check',str(patch_path.resolve())],cwd=ROOT,check=True)
    result=dict(source=source.pin(args.out/'compiler.bend'),patch=source.pin(patch_path),
                matchesCheckedAPIDeclarations=len(names),inputs=[source.pin(p) for p in modules],
                baselineSha256=source.digest(baseline),changedModules=[str(p.relative_to(stage)) for p in changed])
    if args.api:result['comparedAPI']=source.pin(args.api)
    source.dump(args.out/'report.json',result)
    print(result['source'],result['matchesCheckedAPIDeclarations'])


if __name__=='__main__':
    p=argparse.ArgumentParser()
    p.add_argument('--minimum',action='store_true')
    p.add_argument('--decrement',type=Path,help='Frozen decrement selector module')
    p.add_argument('--api',type=Path,help='Verify all candidate declarations against the measured API source')
    p.add_argument('--out',required=True,type=Path)
    main(p.parse_args())
