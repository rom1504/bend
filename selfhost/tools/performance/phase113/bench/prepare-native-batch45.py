#!/usr/bin/env python3
"""Plan unchanged native batch45 acquisition/binding/timing after N2 qualification."""
import argparse
import importlib.util
import json
from pathlib import Path
import re
import sys

HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('qualification_tools',HERE/'prepare-native-plan.py')
q=importlib.util.module_from_spec(spec);spec.loader.exec_module(q)
ROOT,pin,verify,read=q.ROOT,q.pin,q.verify,q.read
BROAD=ROOT/'selfhost/tools/performance/phase112/benchmark45'


def main():
    p=argparse.ArgumentParser(description=__doc__)
    modes=p.add_subparsers(dest='mode',required=True)
    prep=modes.add_parser('prepare')
    prep.add_argument('--qualification-plan',type=Path,required=True)
    prep.add_argument('--tag',required=True)
    prep.add_argument('--out',type=Path,required=True)
    check=modes.add_parser('verify');check.add_argument('--plan',type=Path,required=True)
    a=p.parse_args()
    if a.mode=='verify':
        plan=read(a.plan)
        if plan.get('kind')!='phase113-native-batch45-plan':raise ValueError('Native batch plan required')
        for item in plan['inputs']:verify(item)
        qualification=read(verify(plan['qualificationPlan']))
        for item in qualification['inputs']:verify(item)
        paths=qualification['artifacts']
        comparison=read(paths['comparison'])
        image=pin(Path(paths['self'])/'build/program')
        if not comparison.get('complete') or not comparison.get('byteExact') or comparison['n2']!=image:
            raise ValueError('Completed exact-QBE N2 lineage required')
        if qualification['source'] not in comparison['inputs']:
            raise ValueError('N2 comparison must bind planned source')
        for item in comparison['inputs']:verify(item)
        for name in ['n2Focused','n2Full45']:
            report=read(Path(paths[name])/'report.json')
            if not report.get('complete') or not report.get('passed') or image not in report['inputs'] or qualification['runtime'] not in report['inputs']:
                raise ValueError('Completed exact-image N2 semantics required: '+name)
            for item in report['inputs']:verify(item)
        print(json.dumps(dict(complete=True,targetsRun=False,image=image,qualificationPlan=plan['qualificationPlan'])))
        return
    if a.out.exists() or not re.fullmatch(r'p113-[a-z0-9_-]+',a.tag):raise ValueError('Fresh plan and lowercase p113- tag required')
    qualification=read(a.qualification_plan)
    if qualification.get('kind')!='phase113-native-qualification-plan':raise ValueError('Native qualification plan required')
    for item in qualification['inputs']:verify(item)
    manifest=read(BROAD/'manifest01.json')
    finite=read(q.PHASE/'coverage/full45/manifest.json')
    finite_by={case['name']:case for case in finite['fixtures']}
    if len(manifest['cases'])!=45 or len(finite_by)!=45:raise ValueError('Original complete45 corpora required')
    exact=[case['name'] for case in manifest['cases'] if case['source']==finite_by[case['name']]['source']]
    if exact:raise ValueError('Unexpected corpus overlap; review possible direct product reuse explicitly')
    for case in manifest['cases']:verify(case['source'])
    frozen=read(BROAD/'freeze01.json')
    frozen_by={item['file']:item for item in frozen['inputs']}
    for name in ['manifest01.json','upstream-50ms-profile01.json','run.py']:verify(frozen_by[str(BROAD/name)])
    artifacts={name:ROOT/'selfhost/build/phase112'/(a.tag+'-'+suffix) for name,suffix in
               [('acquisition','acquisition'),('binding','binding.json'),('timing','timing')]}
    artifacts.update(productsPrefix=ROOT/'selfhost/build/phase111'/a.tag,
                     jobs=ROOT/'selfhost/build/phase113'/(a.tag+'-jobs'),
                     guard=ROOT/'selfhost/build/phase113'/(a.tag+'-guard'))
    if any(path.exists() for path in artifacts.values()):raise ValueError('Fresh planned artifact paths required')
    if any(Path(str(artifacts['productsPrefix'])+'-'+case['name']).exists() for case in manifest['cases']):raise ValueError('Fresh product prefix required')
    py=[sys.executable,'-B'];image=Path(qualification['artifacts']['self'])/'build/program'
    jobs=[dict(name='authenticate-qualified-n2',seconds=20,command=py+[str(Path(__file__).resolve()),'verify','--plan',str(a.out.resolve())]),
          dict(name='native-original-batch45-acquisition',seconds=330,command=py+[str(BROAD/'acquire-native.py'),'--image',str(image),
               '--runtime',qualification['runtime']['file'],'--producer-receipt',qualification['artifacts']['comparison'],
               '--prefix',str(artifacts['productsPrefix']),'--out',str(artifacts['acquisition']),'--seconds','30','--build-seconds','30','--budget-seconds','300']),
          dict(name='authenticate-batch45-products',seconds=20,command=py+[str(BROAD/'run.py'),'bind','--label',a.tag,
               '--reports',str(artifacts['acquisition']/'products-map.json'),'--out',str(artifacts['binding'])]),
          dict(name='batch45-three-rotated-rounds',seconds=330,command=py+[str(BROAD/'run.py'),'measure','--bindings',str(artifacts['binding']),
               '--profile',str(BROAD/'upstream-50ms-profile01.json'),'--rounds','3','--seconds','30','--budget-seconds','300','--out',str(artifacts['timing'])])]
    inputs=[pin(a.qualification_plan),*[pin(path) for path in [Path(__file__),HERE/'prepare-native-plan.py',BROAD/'acquire-native.py',BROAD/'run.py',
            BROAD/'freeze01.json',BROAD/'manifest01.json',BROAD/'upstream-50ms-profile01.json',q.PHASE/'coverage/full45/manifest.json',
            q.PHASE/'native-emit.py',q.PHASE/'build.py',q.PHASE/'guard.py',HERE.parent/'run-jobs.py']],*qualification['inputs']]
    inputs=list({row['file']:row for row in inputs}.values())
    guard=py+[str(q.PHASE/'guard.py'),'--out',str(artifacts['guard']),'--seconds','720','--rss-mib','4096',
              '--available-mib','16384','--file-mib','128','--cpu','3','--',*py,str(HERE.parent/'run-jobs.py'),
              '--plan',str(a.out.resolve()),'--out',str(artifacts['jobs'])]
    result=dict(kind='phase113-native-batch45-plan',targetsRun=False,qualificationPlan=pin(a.qualification_plan),inputs=inputs,
                artifacts={name:str(path) for name,path in artifacts.items()},jobs=jobs,rootGuardCommand=guard,
                sourceReuseAudit=dict(conformanceSourceCount=45,batchSourceCount=45,exactSourceMatches=exact,
                     sharedWorkloadOutputs=sum(case['expectedStdout']==finite_by[case['name']]['expect']['stdout'] for case in manifest['cases'])),
                scope='Actual qualified N2 compiles original Phase93 batch sources. Conformance one-shot products cannot substitute: none has the same source pin. Existing native acquisition/binder/rotated-three-round method remain unchanged; 45 output gates and44 timing ratios, scalar-region-0 excluded. Acquisition and runtime clocks remain separate. No target executed during preparation.')
    a.out.parent.mkdir(parents=True,exist_ok=True);a.out.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(plan=pin(a.out),targetsRun=False,rootGuardCommand=guard)))


if __name__=='__main__':main()
