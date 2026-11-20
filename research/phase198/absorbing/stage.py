"""Produce an opt-in full-source x86 compiler and reviewable patch without touching src."""
import argparse
import difflib
import importlib.util
import json
from pathlib import Path
import shutil
import subprocess

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
spec=importlib.util.spec_from_file_location('stage197',ROOT/'research/phase197/validation/stage-compiler.py')
prior=importlib.util.module_from_spec(spec)
spec.loader.exec_module(prior)
src=prior.source

def main(out,tree,api):
    root=tree.resolve()
    manifest=json.loads((root/'src/compiler.json').read_text())
    before=src.maintained_assemble(root/'src/compiler.json',root,'x86')
    stage=out/'maintained'
    out.mkdir(parents=True,exist_ok=False)
    shutil.copytree(root/'src',stage/'src')
    for profile in manifest['profiles'].values():
        for name in [*manifest['modules'],*profile.get('modules',[]),profile.get('entryModule')]:
            if name and not (stage/name).exists():
                (stage/name).parent.mkdir(parents=True,exist_ok=True);shutil.copy2(root/name,stage/name)
    relative=Path('src/back/x86/function.bend')
    dest=stage/relative
    parts=[HERE/'absorbing.bend',HERE/'hook.bend']
    prior.replace(dest,'x185_function_copied',b'\n'.join(p.read_bytes() for p in parts))
    built=src.maintained_assemble(stage/'src/compiler.json',stage,'x86')
    (out/'compiler.bend').write_bytes(built)
    def declarations(b):return {(r['kind'],r['name']):r for r in src.blocks(b)[1]}
    expected,got=declarations(api.read_bytes()),declarations(built)
    names=set().union(*(declarations(p.read_bytes()) for p in parts))
    assert all(src.normalized([expected[k]])==src.normalized([got[k]]) for k in names)
    patch=''.join(difflib.unified_diff((root/relative).read_text().splitlines(True),dest.read_text().splitlines(True),
                                         fromfile='a/selfhost/'+str(relative),tofile='b/selfhost/'+str(relative)))
    target=out/'compiler.patch'
    target.write_text(patch)
    subprocess.run(['git','apply','--check',target.resolve()],cwd=ROOT,check=True)
    report=dict(parent=src.digest(before),source=src.pin(out/'compiler.bend'),patch=src.pin(target),
                api=src.pin(api),modules=[src.pin(p) for p in parts],checkedDeclarations=len(names))
    src.dump(out/'report.json',report);print(json.dumps(report))


if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('--tree',type=Path,default=ROOT/'selfhost')
    p.add_argument('--api',type=Path,required=True);a=p.parse_args();main(a.out,a.tree,a.api)
