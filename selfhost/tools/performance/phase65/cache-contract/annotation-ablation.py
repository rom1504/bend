#!/usr/bin/env python3
"""Same-image B2 H2 ablation: exact prepared sidecar present versus absent."""
import argparse
import difflib
import hashlib
import json
import shlex
import shutil
import sys
import time
from pathlib import Path

ROOT=Path(__file__).resolve().parents[5]
RAW=ROOT/'selfhost/build/phase65'
TOOLS=ROOT/'selfhost/tools/performance'


def identity(file):
    file=Path(file).resolve(strict=True)
    return dict(file=str(file),sha256=hashlib.sha256(file.read_bytes()).hexdigest())


def pin(item):
    actual=identity(item['file'] if isinstance(item,dict) else item)
    if isinstance(item,dict):assert actual['sha256']==item['sha256'],actual['file']
    return actual


def read(file):return json.loads(Path(file).read_text())


def save(file,value):
    file.parent.mkdir(parents=True,exist_ok=True)
    file.write_text(json.dumps(value,indent=2)+'\n')


p=argparse.ArgumentParser(description=__doc__);sub=p.add_subparsers(dest='mode',required=True)
prep=sub.add_parser('prepare');prep.add_argument('preparation',type=Path);prep.add_argument('out',type=Path)
prep.add_argument('--cases',default='numeric-recurrence,test-map-set-ops,map-churn',help='Comma-separated prepared case IDs, or all config cases; each requires a passing prepared full-output oracle')
run=sub.add_parser('run');run.add_argument('plan',type=Path);run.add_argument('out',type=Path)
run.add_argument('--rounds',type=int,default=1);run.add_argument('--seconds',type=int,default=35)
a=p.parse_args();out=a.out.resolve();assert out.is_relative_to(RAW.resolve()) and not out.exists()
if a.mode=='prepare':
    observation=read(a.preparation);assert observation['complete'] and observation['pass'] and observation['stage']=='prepare'
    config=read(pin(observation['config'])['file'])
    assert observation['image']['kind']=='direct' and observation['complete'] and observation['pass']
    inputs=[identity(__file__),identity(Path(__file__).with_name('annotation-ablation-worker.mjs')),
        identity(a.preparation),pin(observation['config']),pin(config['node']),
        identity(Path(__file__).with_name('annotation-ablation.derivation.json')),
        identity(TOOLS/'programs/support.py')]
    inputs += [pin(x) for x in observation['inputs']]
    original=Path(observation['project'])
    copies=[pin(x['after']) for x in observation['copies']]+[pin(x) for x in observation['verification']['cacheFiles']]
    assert len({x['file'] for x in copies})==len(copies)
    products=observation['verification']['baseProducts']
    assert products['supported'] and products['declared'] and products['exists'] and len(products['files'])==1
    product=pin(products['files'][0]);assert Path(product['file']).parent==original/'build/typed/base-products'
    assert products['headerBinding']['compilerSha256']==observation['image']['api']['sha256']
    assert products['headerBinding']['baseSha256']==observation['image']['base']['sha256']
    assert Path(product['file']).name.endswith('-annotations64-v1.bin')
    inputs.append(product)
    variants={'without_products':False,'with_products':True}
    selected=[x['id'] for x in config['cases']] if a.cases=='all' else [x.strip() for x in a.cases.split(',')]
    assert selected and all(selected) and len(set(selected))==len(selected), 'Empty or repeated case ID'
    available={x['id'] for x in config['cases']}
    assert set(selected)<=available, 'Selected case absent from prepared config'
    cases=[]
    for name in selected:
        case=next(x for x in config['cases'] if x['id']==name)
        oracle=next(x for x in observation['outputs'] if x['id']==name)
        assert oracle['oracle']['pass']
        inputs += [pin(case['source']),*[pin(x) for x in case['files']],*[pin(x) for x in case['emissionInputs']],pin(oracle['output'])]
        cases.append(dict(id=name,source=case['source'],files=case['files'],emissionInputs=case['emissionInputs'],expected=oracle['output']))
    out.mkdir(parents=True);roles={}
    for label,present in variants.items():
        project=out/label/'project';bound=[];changes=[]
        for item in copies:
            source=Path(item['file']);relative=source.relative_to(original);target=project/relative
            target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(source,target)
            assert identity(target)['sha256']==item['sha256']
            bound.append(identity(target))
        product_dir=project/'build/typed/base-products';product_files=[]
        assert not product_dir.exists()
        if present:
            product_dir.mkdir(parents=True);target=product_dir/Path(product['file']).name
            shutil.copyfile(product['file'],target);assert identity(target)['sha256']==product['sha256']
            product_files.append(identity(target));bound.extend(product_files)
        changes.append(dict(kind='optional-product-presence',present=present,original=product))
        image={key:(identity(project/Path(value['file']).relative_to(original)) if Path(value['file']).is_relative_to(original) else pin(value))
            for key,value in observation['image'].items() if key in ['api','runtime','base','directRuntime','driver','source']}
        assert image['api']['sha256']==observation['image']['api']['sha256']
        assert image['driver']['sha256']==observation['image']['driver']['sha256']
        assert image['base']==pin(observation['image']['base'])
        roles[label]=dict(project=str(project),image=image,files=bound,changes=changes,
            cache=[identity(project/Path(x['file']).relative_to(original)) for x in observation['verification']['cacheFiles']],
            products=dict(directory=str(product_dir),exists=present,files=product_files))
    common=[{str(Path(x['file']).relative_to(Path(r['project']))):x['sha256'] for x in r['files'] if '/base-products/' not in x['file']} for r in roles.values()]
    assert common[0]==common[1], 'Only product presence may differ'
    for item in inputs+copies:pin(item)
    plan=dict(kind='phase65-base-annotation-presence-ablation',diagnosticOnly=True,productionQualified=False,
        imageKind='same-genuine-b2-and-helper-with-explicit-optional-product-presence',complete=True,**{'pass':True},
        sourcePreparation=identity(a.preparation),originalImage=observation['image'],node=config['node'],roles=roles,cases=cases,
        inputs=inputs,copiedOriginals=copies,
        productBinding=products['headerBinding'],
        scope='Actual combined B2 API/source/Base/driver/runtime/helper/frame bytes identical in both clones. '
              'Only exact optional annotation sidecar presence differs; no priming or compiler runs during cloning. '
              'Full project and product inventory checked before/after each fresh ordinary request; all bytes pinned. '
              'Diagnostic incremental H2 effect on H6 image, not separate compiler qualification. Raw output equality after clocks.')
    save(out/'plan.json',plan)
    command=['python3',str(Path(__file__).resolve()),'run',str(out/'plan.json'),str(out/'screen'),'--rounds','2','--seconds','60']
    (out/'commands.txt').write_text(shlex.join(command)+'\n')
    print(json.dumps(dict(plan=identity(out/'plan.json'),command=command)))
else:
    assert 1<=a.rounds<=3 and 10<=a.seconds<=180
    plan=read(a.plan);assert plan['kind']=='phase65-base-annotation-presence-ablation' and plan['diagnosticOnly'] and not plan['productionQualified']
    for item in plan['inputs']+plan['copiedOriginals']:pin(item)
    for role in plan['roles'].values():
        for item in role['files']:pin(item)
    sys.path.insert(0,str(TOOLS/'programs'))
    from support import ExecutionGuard
    out.mkdir(parents=True);plan_id=identity(a.plan)
    result=dict(kind='phase65-base-annotation-presence-ablation-results',complete=False,**{'pass':False},
        diagnosticOnly=True,productionQualified=False,plan=plan_id,rows=[],failures=[],rounds=a.rounds)
    started=time.monotonic();save(out/'report.json',result)
    with ExecutionGuard(rss_mib=2048,available_mib=4096) as guard:
        roles=list(plan['roles'])
        for case in plan['cases']:
            for sample in range(a.rounds):
                ordered=roles[sample%len(roles):]+roles[:sample%len(roles)]
                for role in ordered:
                    name=case['id']+'-'+str(sample)+'-'+role;output=out/(name+'.json')
                    command=['taskset','-c','3',plan['node']['file'],'--stack-size=4096','--max-old-space-size=1024',
                        str(Path(__file__).with_name('annotation-ablation-worker.mjs')),str(a.plan.resolve()),role,case['id'],str(output)]
                    execution=guard.run(command,out/(name+'-process'),started+a.seconds)
                    observation=read(output) if output.exists() else None
                    passed=bool(execution['complete'] and execution.get('returncode')==0 and observation and observation.get('pass'))
                    result['rows'].append(dict(case=case['id'],role=role,sample=sample,execution=execution,
                        observation=observation,result=identity(output) if output.exists() else None,success=passed))
                    if not passed:result['failures'].append(name)
                    save(out/'report.json',result)
    for item in plan['inputs']+plan['copiedOriginals']:pin(item)
    for role in plan['roles'].values():
        for item in role['files']:pin(item)
    assert identity(a.plan)==plan_id
    result.update(complete=True,**{'pass':not result['failures']},wallSeconds=time.monotonic()-started)
    save(out/'report.json',result)
    print(json.dumps({k:result[k] for k in ['complete','pass','wallSeconds','failures']}))
    if not result['pass']:raise SystemExit(1)
