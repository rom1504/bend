"""Apply the pairwise proof and lowering to an isolated maintained x86 layout."""
from pathlib import Path
import argparse
import hashlib
import importlib.util
import json
import shutil
import sys

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
BUILD=ROOT/'selfhost/build/phase198'
mod=importlib.util.spec_from_file_location('candidate_stage',ROOT/'research/phase197/validation/stage-compiler.py')
base=importlib.util.module_from_spec(mod);mod.loader.exec_module(base)

def apply(stage):
    x86=stage/'src/back/x86'
    tracked=['machine.bend','proof.bend','attach.bend','hook.bend']
    modules=[HERE/m for m in tracked]
    base.replace(x86/'recursive-regions.bend','x192h_emit_checked',b'\n\n'.join(p.read_bytes() for p in modules))
    base.replace(x86/'entry.bend','x181_request',(HERE/'entry.bend').read_bytes())
    return [*modules,HERE/'entry.bend']

def main():
    p=argparse.ArgumentParser();p.add_argument('--parent-maintained',type=Path,default=BUILD/'selected-source01/maintained');p.add_argument('--out',type=Path,required=True);a=p.parse_args();out=a.out.resolve();assert BUILD in out.parents
    out.mkdir();stage=out/'maintained';shutil.copytree(a.parent_maintained,stage)
    source=base.source; manifest=json.loads((stage/'src/compiler.json').read_text());profiles=list(manifest['profiles']);prior={k:source.digest(source.maintained_assemble(stage/'src/compiler.json',stage,k)) for k in profiles}
    modules=apply(stage);after={k:source.digest(source.maintained_assemble(stage/'src/compiler.json',stage,k)) for k in profiles};assert [k for k in profiles if prior[k]!=after[k]]==['x86']
    compiler=source.maintained_assemble(stage/'src/compiler.json',stage,'x86');(out/'compiler.bend').write_bytes(compiler)
    decls=lambda data:{(r['kind'],r['name']):r for r in source.blocks(data)[1]}
    got=decls(compiler);mods=[]
    for mod in modules:
        ds={k:v for k,v in decls(mod.read_bytes()).items() if k[1] not in ('x198pw_probe','x198pw_symbolic','x198pw_descriptor')};assert all(k in got and source.normalized([got[k]])==source.normalized([v]) for k,v in ds.items());mods.append(dict(file=mod.name,sha256=source.digest(mod.read_bytes())))
    report=dict(complete=True,previous=prior,profiles=after,modules=mods,source=dict(bytes=len(compiler),sha256=source.digest(compiler)),method=source.digest(Path(__file__).read_bytes()))
    (out/'report.json').write_text(json.dumps(report,indent=2)+'\n');print(report['source'],profiles)
if __name__=='__main__':main()
