#!/usr/bin/env python3
"""Compose existing core/Nx and new Bend-owned lowering; no compiler execution."""
import argparse,hashlib,json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];OLD=ROOT/'selfhost/tools/performance/phase109';HERE=ROOT/'selfhost/tools/performance/phase110'
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);a=p.parse_args();out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase110') and not out.exists();out.mkdir(parents=True)
core=ROOT/'selfhost/src/core/term.bend';text=core.read_text();names=['KTerm','KDef','kc','kt','atom','tg','nm','ix','qt','ks','terms_at','kid','dn','dk','da','dv']
starts=list(re.finditer(r'^(?:@unsafe\n)?(?:def|type|law) ([A-Za-z0-9_]+)\b',text,re.M));blocks={m.group(1):text[m.start():starts[i+1].start() if i+1<len(starts) else len(text)].strip() for i,m in enumerate(starts)}
modules=[ROOT/'selfhost/tools/performance/phase106/ir'/f'{n}.bend' for n in ['model','optimize','verify','json','c']]+[ROOT/'selfhost/tools/performance/phase107/backends/qbe.bend']+[OLD/'nx'/f'{n}.bend' for n in ['library','runtime','controls','c']]+[OLD/'lower'/f'{n}.bend' for n in ['model','verify','verify-controls','lower','admission','nx','policy','policy-controls']]
modules += [HERE/'laws/helper.bend']+[HERE/'lower'/f'{n}.bend' for n in ['policy','controls']]+[HERE/'nx'/f'{n}.bend' for n in ['model','verify','c','qbe','pair','controls','take']]
modules += [HERE/'runtime-ir'/f'{n}.bend' for n in ['lower','library','controls','probe','width-controls']]
source='import Base\n\n'+'\n\n'.join(blocks[n] for n in names)+'\n\n'+'\n\n'.join(f.read_text() for f in modules)
width=HERE/'runtime-ir/overrides.json'; overrides=json.loads(width.read_text())
for item in overrides['replacements']:
 assert hashlib.sha256(item['old'].encode()).hexdigest()==item['oldSha256'] and hashlib.sha256(item['new'].encode()).hexdigest()==item['newSha256']
 assert (ROOT/item['origin']).read_text().count(item['old'])==1 and source.count(item['old'])==1
 source=source.replace(item['old'],item['new'],1)
(out/'source.bend').write_text(source+'\n');pin=lambda f:dict(file=str(f.resolve()),bytes=f.stat().st_size,sha256=hashlib.sha256(f.read_bytes()).hexdigest())
(out/'manifest.json').write_text(json.dumps(dict(kind='phase110-owned-bridge-source',complete=True,targetsRun=False,core=pin(core),declarations=names,inputs=[pin(f) for f in modules]+[pin(width)],exactWidthOverrides=[dict(name=r['name'],oldSha256=r['oldSha256'],newSha256=r['newSha256']) for r in overrides['replacements']],method=pin(Path(__file__)),source=pin(out/'source.bend')),indent=2)+'\n');print(out/'source.bend')
