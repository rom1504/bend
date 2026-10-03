#!/usr/bin/env python3
"""Materialize three supported serial 15-case preset600 commands; run no timing."""
import argparse,hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
def ident(p):
 p=Path(p).resolve();return dict(file=str(p),sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('recipe',type=Path);p.add_argument('--binding',type=Path,required=True);p.add_argument('--plan',type=Path,required=True);a=p.parse_args();assert not a.plan.exists()
 r=json.loads(a.recipe.read_text());b=json.loads(a.binding.read_text());assert b['complete'] and b['kind']=='phase42-frozen-measurement-bindings' and b['cases']==45
 assert b['attempt']['sha256']==r['candidateBinding']['attempt']['sha256'] and b['api']==r['candidateBinding']['api']
 assert b['node']==r['candidateBinding']['node'] and ident(b['node']['file'])['sha256']==b['node']['sha256']
 for k in ['candidate','baseline','catalog']:assert ident(b[k]['file'])['sha256']==b[k]['sha256']
 catalog=json.loads(Path(b['catalog']['file']).read_text());ids=catalog['sets']['full'];assert len(ids)==len(set(ids))==45
 out=Path(r['bindings']['OUT']);node=r['bindings']['NODE'];assert Path(node).resolve()==Path(b['node']['file']).resolve();steps=[];batches=[]
 for i in range(3):
  selected=ids[i*15:(i+1)*15];dest=out/('runtime-batch'+str(i+1));assert not dest.exists()
  command=['python3','selfhost/tools/performance/programs/run.py','--catalog',b['catalog']['file'],'--baseline',b['baseline']['file'],'--candidate',b['candidate']['file'],'--node',node,'--cpu','3','--rss-mib','2048','--available-mib','2048','--budget','600','--cases',','.join(selected)]
  name='runtime-batch'+str(i+1);steps.append(dict(name=name+'-plan',argv=command+['--plan']));steps.append(dict(name=name,lockOwner=True,argv=command+['--out',str(dest)]));batches.append(dict(name=name,ids=selected,report=str(dest/'report.json'),samples=sum(3*(3 if n=='raytrace' else 5) for n in selected)))
 plan=dict(kind='phase42-full45-serial-runtime-batches',complete=True,bound=True,executed=False,producer=ident(__file__),parent=ident(a.recipe),measurementBinding=ident(a.binding),attempt=b['attempt'],api=b['api'],node=node,nodeIdentity=b['node'],baseline=b['baseline'],candidate=b['candidate'],catalog=b['catalog'],selectedIds=ids,protocol=dict(defaultSet='full',rounds=5,warmupCalls=3,warmupMs=1000,calibrationMs=50,targetMs=300),roles=['typescript','baseline','candidate'],cpu=3,rssMiB=2048,availableMiB=2048,batches=batches,steps=steps,executionPolicy='Three serial15-case runs;600s independent deadlines, exact unchanged preset600 sample protocol; never parallel timing. Campaign ordering is by batch, then historical balanced rotations within each batch.',expectedSamples=sum(x['samples'] for x in batches))
 assert plan['expectedSamples']==669;a.plan.parent.mkdir(parents=True,exist_ok=True);a.plan.write_text(json.dumps(plan,indent=2)+'\n');print(json.dumps(dict(complete=True,executed=False,plan=str(a.plan),batches=3,samples=669)))
if __name__=='__main__':main()
