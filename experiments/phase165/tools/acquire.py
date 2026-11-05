#!/usr/bin/env python3
"""Acquire one private source-ablation compiler under the outer resource guard."""
import argparse, json, os, sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT/'selfhost/tools/build'))
from common import pin, verify, run, write_json, fresh_output, require

p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--source-tree', type=Path, required=True)
p.add_argument('--base', type=Path, required=True)
p.add_argument('--preparation', type=Path, required=True)
p.add_argument('--support', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
p.add_argument('--original', action='store_true')
a=p.parse_args(); out=fresh_output(a.out,ROOT)
seed_receipt=ROOT/'selfhost/build/phase160/capped-seed01/report.json'
seed_info=json.loads(seed_receipt.read_text()); require(seed_info['complete'],'Seed incomplete')
seed=verify(seed_info['binary'])
parent=ROOT/'selfhost/build/phase157/seed01/report.json'
header_receipt=ROOT/'selfhost/build/phase159/refill-prepare01/report.json'
h=json.loads(header_receipt.read_text()); header=verify(h['candidate']); verify(h['original'])
require(header.read_text().replace(h['replacement'],h['needle'])==Path(h['original']['file']).read_text(),'Runtime patch drift')
source=a.source_tree.resolve()/'bendc.bend'; base=a.base.resolve()
inputs=[pin(__file__),pin(a.preparation),pin(a.support),pin(seed_receipt),pin(seed),pin(parent),pin(header_receipt),h['candidate'],h['original']]
inputs += [pin(x) for x in sorted(a.source_tree.resolve().rglob('*')) if x.is_file()]
inputs += [pin(base)] + [pin(x) for x in sorted((base.parent/'effs').glob('*')) if x.is_file()]
cmd=list(json.loads(parent.read_text())['command'])
inputs.append(pin(cmd[0])); require(not (out/'bendrt.h').exists(),'Shadow runtime')
env={k:v for k,v in os.environ.items() if not k.startswith('BEND_') and k not in ('LD_PRELOAD','LD_AUDIT')}
env.update(BEND_RC='0',BEND_NO_FREE='1',BEND_AUTO_PAR='0',TMPDIR=str(out))
r=dict(kind='phase165-source-variant-acquisition',complete=False,inputs=inputs,original=a.original,
       environment={k:v for k,v in env.items() if k.startswith('BEND_')},
       scope='Private experiment. Checked emission and machine acquisition; not semantic or production qualification.')
write_json(out/'report.json',r)
r['emission']=run([seed,'--threads','1','--gpu','off','--',base,source],cwd=ROOT,stdout=out/'program.c',stderr=out/'emission.stderr',seconds=60,env=env)
write_json(out/'report.json',r)
if r['emission']['complete']:
    if a.original:
        expected=pin(ROOT/'selfhost/build/phase157/vendor/seed/bendc.c')
        r['expectedC']=expected
        r['exactOriginalC']=all(r['emission']['stdout'][k]==expected[k] for k in ('bytes','sha256'))
        require(r['exactOriginalC'],'Private source control did not reproduce original C')
        # Exact same C, compiler flags and runtime already acquired and pinned.
        r['binary']=pin(seed); r['reusedExactMachineAcquisition']=pin(seed_receipt)
        r['complete']=True
    else:
        cmd[cmd.index('-I'):cmd.index('-I')]=['-I',str(header.parent)]
        cmd[cmd.index('-o')-1]=str(out/'program.c')
        cmd[cmd.index('-o')+1]=str(out/'bendc')
        r['machine']=run(cmd,cwd=ROOT,stdout=out/'machine.stdout',stderr=out/'machine.stderr',seconds=180,env=env)
        r['complete']=r['machine']['complete']
        if r['complete']: r['binary']=pin(out/'bendc')
for x in inputs: verify(x)
write_json(out/'report.json',r)
print(json.dumps({'complete':r['complete'],'emissionSeconds':r['emission']['seconds'],'machineSeconds':r.get('machine',{}).get('seconds'),'binary':r.get('binary')}))
sys.exit(0 if r['complete'] else 1)
