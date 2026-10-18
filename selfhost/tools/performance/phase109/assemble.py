#!/usr/bin/env python3
"""Compose existing core/Nx and new Bend-owned lowering; no compiler execution."""
import argparse,hashlib,json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];HERE=ROOT/'selfhost/tools/performance/phase109'
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);a=p.parse_args();out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase109') and not out.exists();out.mkdir(parents=True)
core=ROOT/'selfhost/src/core/term.bend';text=core.read_text();names=['KTerm','KDef','kc','kt','atom','tg','nm','ix','qt','ks','terms_at','kid','dn','dk','da','dv']
starts=list(re.finditer(r'^(?:@unsafe\n)?(?:def|type|law) ([A-Za-z0-9_]+)\b',text,re.M));blocks={m.group(1):text[m.start():starts[i+1].start() if i+1<len(starts) else len(text)].strip() for i,m in enumerate(starts)}
modules=[ROOT/'selfhost/tools/performance/phase106/ir'/f'{n}.bend' for n in ['model','optimize','verify','json','c']]+[ROOT/'selfhost/tools/performance/phase107/backends/qbe.bend']+[HERE/'nx'/f'{n}.bend' for n in ['library','runtime','controls','c']]+[HERE/'lower'/f'{n}.bend' for n in ['model','verify','verify-controls','lower','admission','nx','policy','policy-controls']]
source='import Base\n\n'+'\n\n'.join(blocks[n] for n in names)+'\n\n'+'\n\n'.join(f.read_text() for f in modules)
(out/'source.bend').write_text(source+'\n');pin=lambda f:dict(file=str(f.resolve()),bytes=f.stat().st_size,sha256=hashlib.sha256(f.read_bytes()).hexdigest())
(out/'manifest.json').write_text(json.dumps(dict(kind='phase109-owned-bridge-source',complete=True,targetsRun=False,core=pin(core),declarations=names,inputs=[pin(f) for f in modules],method=pin(Path(__file__)),source=pin(out/'source.bend')),indent=2)+'\n');print(out/'source.bend')
