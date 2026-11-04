#!/usr/bin/env python3
"""Acquire a private current bendc seed with Phase159's exact runtime ablation."""
import argparse,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin,verify,run,write_json,fresh_output,require
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True)
a=p.parse_args();out=fresh_output(a.out,ROOT)
parent=ROOT/'selfhost/build/phase157/seed01/report.json'
patch=ROOT/'selfhost/build/phase159/refill-prepare01/report.json'
d=json.loads(parent.read_text());h=json.loads(patch.read_text())
source=ROOT/'selfhost/build/phase157/vendor/seed/bendc.c'
header=verify(h['candidate']);verify(h['original'])
require(header.read_text().replace(h['replacement'],h['needle'])==Path(h['original']['file']).read_text(),'Patch no longer one exact loop condition')
require(not (source.parent/'bendrt.h').exists(),'Quoted include could shadow private runtime')
cmd=list(d['command']);cmd[cmd.index('-I'):cmd.index('-I')]=['-I',str(header.parent)]
cmd[cmd.index('-o')+1]=str(out/'bendc')
r=dict(kind='phase160-private-seed',complete=False,inputs=[pin(__file__),pin(parent),pin(patch),pin(source),h['candidate'],h['original'],pin(d['command'][0])],
    scope='Same pinned seed C and -O2 flags; only audited GC search bound differs. Exact self-C gate required before comparison.')
write_json(out/'report.json',r)
r['process']=run(cmd,cwd=ROOT,stdout=out/'stdout',stderr=out/'stderr',seconds=120)
r['complete']=r['process']['complete']
if r['complete']:r['binary']=pin(out/'bendc')
for x in r['inputs']:verify(x)
write_json(out/'report.json',r);print(json.dumps(dict(complete=r['complete'],seconds=r['process']['seconds'])))
sys.exit(0 if r['complete'] else 1)
