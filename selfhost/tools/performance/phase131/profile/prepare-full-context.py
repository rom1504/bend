#!/usr/bin/env python3
"""Plan one full-source diagnostic context sample; counters remain disabled."""
import argparse
import copy
import json
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[5]
PROF=ROOT/'selfhost/tools/profiler'
sys.dont_write_bytecode=True
sys.path.insert(0,str(PROF))
from run import pin,verify,save,all_pins


def read(path):return json.loads(Path(path).read_text())


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
    out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase131')
    full_path=ROOT/'selfhost/build/phase131/final-full-profile01/manifest.json'
    context_path=ROOT/'selfhost/build/phase131/final-context01/manifest.json'
    full,context=copy.deepcopy(read(full_path)),read(context_path)
    build_path=context_path.parent/'build/report.json';built=read(build_path)
    diagnostic=context['workloads'][0]['variants'][0]['binary']
    assert built['complete'] and diagnostic in built['products']
    assert full['lineage']['source']==context['lineage']['source'] and full['lineage']['image']==context['lineage']['image']
    assert len(full['workloads'])==1 and len(full['workloads'][0]['variants'])==1
    variant=full['workloads'][0]['variants'][0]
    assert variant['command'][8:]==context['workloads'][0]['variants'][0]['command'][8:]
    variant['name']='phase131-final-n2-context';variant['binary']=diagnostic;variant['command'][0]=diagnostic['file']
    variant['dispatchInstrumentation']=True;variant['inputs']=[pin(x) for x in variant['command'] if Path(x).is_file()]
    full.pop('unwindTable',None)
    full['inputs'] += [pin(__file__),pin(full_path),pin(context_path),pin(build_path),pin(context_path.parent/'lineage.json'),pin(context_path.parent/'owners.json'),diagnostic]
    full['scope']='One32ms full-source context-only diagnostic sample using existing final-N2 relink. Runtime counters disabled by generic sample mode. Exact frozen Q2 oracle. No clean timing or new speed ratio. Caller CFI omitted; original physical capture remains separate.'
    full['diagnosticImage']=diagnostic;full['ownerMap']=pin(context_path.parent/'owners.json')
    for item in all_pins(full):verify(item)
    out.mkdir(parents=True);save(out/'manifest.json',full)
    command=[sys.executable,'-B',str(PROF/'run.py'),'--manifest',str(out/'manifest.json'),
        '--out',str(out/'capture'),'--names','compiler-self-source','--modes','sample','--rounds','1','--periods-us','32000']
    save(out/'jobs.json',dict(complete=True,targetsRun=False,inputs=[pin(__file__),pin(out/'manifest.json'),pin(PROF/'run.py')],
        jobs=[dict(name='final-n2-full-source-context-sample',seconds=600,command=command)],resourcePlan=full['resourcePlan'],
        runtimeCountersEnabled=False,relinkRequired=False))
    print(json.dumps(dict(complete=True,targetsRun=False,manifest=pin(out/'manifest.json'),jobs=pin(out/'jobs.json'),command=command)))


if __name__=='__main__':main()
