#!/usr/bin/env python3
"""Offline native-host conformance inventory and authenticated command preparation."""
import argparse,hashlib,importlib.util,json,sys
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
PROJECT=ROOT/'selfhost'
SOURCE='d04ad79cf08c019b509cfbbd4be2b16ae9e4af189767715d12e0645b9eee8097'

def pin(file):
    p=Path(file).resolve();data=p.read_bytes()
    return dict(file=str(p),sha256=hashlib.sha256(data).hexdigest(),bytes=len(data))

def read(file):return json.loads(Path(file).read_text())
def write(file,value):
    with Path(file).open('x') as out:json.dump(value,out,indent=2);out.write('\n')

def inventory():
    collection=read(ROOT/'implementation/phase91/conformance-results02.json')
    reference=next(x['report'] for x in collection['rows'] if x['name']=='native100-01')
    assert pin(reference['file'])==reference
    old=read(reference['file']);assert old['selectedComplete'] and old['summary']['statuses']=={'pass':100}
    selection=PROJECT/'build/phase82/compiler04-native100/selection.json'
    selected=read(selection)['cases'];tests={x['id']:x for x in old['inventory']['tests']}
    eligible=[];excluded=[]
    for entry in selected:
        test=tests[entry['id']];source=pin(entry['file'])
        assert source['sha256']==test['sha256'] and source['bytes']==test['bytes']
        imports=[line.strip()[7:].strip() for line in Path(source['file']).read_text().splitlines() if line.strip().startswith('import ')]
        reasons=[]
        if not test['base']:reasons.append('No canonical Base import')
        if test['imports']:reasons.append('Additional Bend module import')
        if test['foreign']:reasons.append('Fixture-specific foreign provider')
        if imports!=['Base'] and not reasons:reasons.append('Other import form; not statically admitted')
        if not test['main']:reasons.append('No executable main')
        row=dict(id=entry['id'],source=source,expected=test['expected'],imports=imports,
            foreign=test['foreign'],moduleImports=test['imports'],reasons=reasons)
        (excluded if reasons else eligible).append(row)
    assert len(eligible)==69 and len(excluded)==31 and len(selected)==100
    assert all(not tests[x['id']]['negative'] for x in eligible)
    return dict(kind='phase92-native-conformance-inventory',complete=True,targetExecuted=False,
        sourceSelection=pin(selection),reference=reference,eligible=eligible,excluded=excluded,
        counts=dict(original=100,eligible=69,excluded=31,moduleImport=30,foreignOnly=1),
        eligibility='Conservative source/retained-inventory audit, not parsing or compilation. Runtime gates must still pass.',
        scope='69 unchanged native100 sources can use the frozen entry.31 host-contract exclusions are not passes. No parse/check-only or JS output capability.')

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True)
    p.add_argument('--inventory-only',action='store_true')
    p.add_argument('--build',type=Path,default=PROJECT/'build/phase92/upstream-b1/build.json')
    a=p.parse_args();out=a.out.resolve();assert not out.exists();assert out.is_relative_to(PROJECT/'build/phase92')
    inv=inventory();out.mkdir(parents=True)
    write(out/'inventory.json',inv)
    write(out/'selection.json',dict(cases=[dict(id=x['id'],file=x['source']['file'],lanes=['native']) for x in inv['eligible']]))
    if a.inventory_only:
        print(json.dumps(dict(complete=True,targetExecuted=False,inventory=str(out/'inventory.json'),counts=inv['counts'])));return
    support_path=HERE.parent/'comparison/support.py'
    spec=importlib.util.spec_from_file_location('p92_native_binding',support_path)
    support=importlib.util.module_from_spec(spec);sys.modules[spec.name]=support;spec.loader.exec_module(support)
    context=support.authenticate(a.build)
    records={}
    def add(file):
        q=pin(file);records[q['file']]=q;return q
    def add_record(record):
        q=add(record.get('file',record.get('path')))
        assert q['sha256']==record['sha256']
        if 'bytes' in record:assert q['bytes']==record['bytes']
        return q
    for record in context['inputs']:add_record(record)
    roles={};source_marker='/tmp/phase92-conformance-source-marker';output_marker='/tmp/phase92-conformance-output-marker'
    for role in ['b1','b2']:
        item=context['roles'][role];assert item['admission']['source']['sha256']==SOURCE
        argv=support.native_args(context,role,source_marker,output_marker,calls=1,live=False)
        assert argv.count(source_marker)==argv.count(output_marker)==1
        roles[role]=dict(argv=argv,producer=dict(label=item['producer'],source=context['source'],
            image=item['admission']['binary'],argvSentinel=item['argvSentinel'],
            build=context['build'] if role=='b1' else item['admission']['build'],
            checked=context['checked'] if role=='b1' else None,
            publicAdmission=role=='b2',scope='Build authentication is not a new B1 semantic admission.'))
    for file in [__file__,support_path,HERE/'adapter.mjs',HERE/'diagnostics.mjs',HERE/'collect.py',
                 out/'inventory.json',out/'selection.json',inv['sourceSelection']['file'],inv['reference']['file']]:add(file)
    for row in inv['eligible']+inv['excluded']:add_record(row['source'])
    for name in ['run.mjs','worker.mjs','inventory.mjs','judge.mjs','selection.mjs','run-probe.mjs','replay.mjs']:
        add(PROJECT/'tools/conformance'/name)
    add(PROJECT/'src/compiler.json')
    node=add('/home/ai/.nvm/versions/node/v24.18.0/bin/node')
    clang=add('/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/bin/clang')
    negative_ref=add(PROJECT/'build/phase90/native07-qualification01/report.json')
    prior=read(negative_ref['file']);negatives=[]
    for row in prior['negativeRows']:
        add_record(row['source'])
        negatives.append(dict(id=row['name'],source=row['source'],expectedPhase=row['expectedError'],historicalStderr=row['stderr']))
    deep=add(PROJECT/'.bootstrap/upstream-phase66/tests/page/deep_list_walk.bend')
    negatives.append(dict(id='page/deep_list_walk.bend',source=deep,expectedPhase='check',
        expectedConcise='thm: reflexivity endpoints differ',
        limitation='Frozen p86_plan_checked discards DResult.diagnostic; no rich diagnostic rendering is observed.'))
    diagnostics_ref=add(ROOT/'implementation/phase91/conformance-results02.json')
    delta=read(diagnostics_ref['file'])['frontend']['differences'][0]
    assert delta['id']=='page/deep_list_walk.bend'
    negatives[-1]['historicalJS']={k:delta[k]['diagnostic'] for k in ['before','after']}
    guard=add(PROJECT/'tools/performance/phase86/guard.py')
    upstream=PROJECT/'.bootstrap/upstream-phase66'
    env=dict(PATH='/usr/bin:/bin',LANG='C.UTF-8',LC_ALL='C.UTF-8',BEND_UPSTREAM=str(upstream),NODE_OPTIONS='',NODE_PATH='')
    plan=dict(kind='phase92-native-conformance-plan',complete=True,targetReady=True,targetExecuted=False,
        method=pin(__file__),inventory=pin(out/'inventory.json'),selection=pin(out/'selection.json'),
        reference=inv['reference'],eligible=inv['eligible'],excluded=inv['excluded'],roles=roles,
        sourceMarker=source_marker,outputMarker=output_marker,node=node,clang=clang,
        clangArgs=['-isystem',str(Path(clang['file']).parent.parent/'include/clang'),'-std=c11','-O3'],
        environment=env,negatives=negatives,inputs=list(records.values()),
        scope=inv['scope'],execution='Single CPU worker/GPU off for compiler and emitted programs. No nested guard. Original full golden outputs judged by unchanged conformance judge.')
    write(out/'plan.json',plan);jobs=[]
    for role in ['b1','b2']:
        role_env={**env,'BEND_NATIVE_CONFORMANCE_PLAN':str(out/'plan.json'),'BEND_NATIVE_CONFORMANCE_ROLE':role}
        command=[node['file'],'--stack-size=4096','--max-old-space-size=512',str(PROJECT/'tools/conformance/run.mjs'),
            '--upstream',str(upstream),'--adapter',str(HERE/'adapter.mjs'),'--output',str(out/role/'report.json'),
            '--jobs','1','--timeout','60000','--worker-mode','isolated','--stack-kb','4096','--heap-mb','512',
            '--lanes','native','--selection',str(out/'selection.json'),'--retain','failed','--selected-exit','1']
        jobs.append(dict(role=role,command=[sys.executable,'-B',guard['file'],'--out',str(out/(role+'-guard')),
            '--seconds','300','--rss-mib','2048','--available-mib','4096','--cpu','3','--','env',
            *[k+'='+v for k,v in role_env.items()],*command]))
    jobs.append(dict(role='diagnostics',command=[sys.executable,'-B',guard['file'],'--out',str(out/'diagnostics-guard'),
        '--seconds','90','--rss-mib','2048','--available-mib','4096','--cpu','3','--',node['file'],
        str(HERE/'diagnostics.mjs'),str(out/'plan.json'),str(out/'diagnostics')]))
    write(out/'commands.json',jobs)
    print(json.dumps(dict(complete=True,targetExecuted=False,plan=str(out/'plan.json'),jobs=len(jobs))))

if __name__=='__main__':main()
