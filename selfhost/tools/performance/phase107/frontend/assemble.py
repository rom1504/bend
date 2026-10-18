#!/usr/bin/env python3
"""Assemble a small checked bridge; copy exact core declarations, never reparse Bend input."""
from pathlib import Path
import argparse,hashlib,json,re
ROOT=Path(__file__).resolve().parents[5]
HERE=ROOT/'selfhost/tools/performance/phase107'
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);a=p.parse_args()
out=a.out.resolve();assert not out.exists();out.mkdir(parents=True)
core=ROOT/'selfhost/src/core/term.bend';text=core.read_text()
names=['KTerm','KDef','kc','kt','atom','tg','nm','ix','qt','ks','terms_at','kid','dn','dk','da','dx','dt','dv','db','kl_number']
starts=list(re.finditer(r'^(?:@unsafe\n)?(?:def|type|law) ([A-Za-z0-9_]+)\b',text,re.M))
blocks={m.group(1):text[m.start():starts[i+1].start() if i+1<len(starts) else len(text)].strip() for i,m in enumerate(starts)}
selected='\n\n'.join(blocks[n] for n in names)
(out/'core-subset.bend').write_text(selected+'\n')
files=[ROOT/'selfhost/tools/performance/phase106/ir'/f'{n}.bend' for n in ['model','optimize','verify','json','c','workloads']]
files += [ROOT/'selfhost/tools/performance/phase106/laws/bridge.bend',HERE/'frontend/lower.bend',HERE/'backends/qbe.bend',HERE/'backends/controls.bend']
files += [HERE/'inline'/f'{n}.bend' for n in ['model','admit','rename','expand','deep','fixtures']]
source='import Base\n\n'+selected+'\n\n'+'\n\n'.join(f.read_text() for f in files)
(out/'source.bend').write_text(source)
pin=lambda f:dict(file=str(f),bytes=f.stat().st_size,sha256=hashlib.sha256(f.read_bytes()).hexdigest())
(out/'inputs.json').write_text(json.dumps(dict(core=pin(core),coreDeclarations=names,inputs=[pin(f) for f in files],source=pin(out/'source.bend')),indent=2)+'\n')
print(out/'source.bend')
