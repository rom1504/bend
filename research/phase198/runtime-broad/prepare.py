"""Qualify the existing split runtime object and freeze a same-object three-role screen."""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
BUILD=ROOT/'selfhost/build'
NOW=BUILD/'phase198'
RUNTIME=ROOT/'selfhost/src/runtime/qbe'
sys.path.insert(0,str(ROOT/'selfhost/tools/bench'))
import bench as B
import live

def check(cmd,timeout=20):
    child=subprocess.run(list(map(str,cmd)),capture_output=True,timeout=timeout)
    assert child.returncode==0,(cmd,child.stderr[-1000:])
    return child.stdout

def exported(obj):
    data=check(['nm','-g','--defined-only',obj]).decode().splitlines()
    return sorted(' '.join(line.split()[1:]) for line in data if line.strip())

def probes(out,cc,runtimes,tc):
    invalid={
        'bad-cap':'unsupported capabilities','zero-count':'program identifier capacity exceeded','over-count':'program identifier capacity exceeded',
        'bad-hot':'invalid constructor metadata','bad-name':'invalid constructor metadata','no-arity':'missing program tables',
        'no-static':'static image exceeds initial corpus','bad-abi':'descriptor ABI mismatch','bad-size':'descriptor ABI mismatch',
        'bad-core':'missing core constructor identity','rebind':'one program per process',
        'bad-take-id':'take arity mismatch','bad-arity':'take arity mismatch','max-arity':'take arity mismatch',
        'bad-owner':'expected constructor owner','bad-checked-ctor':'constructor arity mismatch',
    }
    cases=[('valid',cap,65536 if cap in (1,15) else 26,static,'checks '+('35' if static>=4 else '33')+'\n','',0)
           for cap in range(1,16,2) for static in (0,129,257)]
    for name,message in invalid.items():
        prefix='phase118' if name in ('bad-arity','bad-take-id','max-arity','bad-owner') else 'phase111'
        cases.append((name,16 if name=='bad-cap' else 9,65536 if name=='max-arity' else 26,4,'',f'bend: {prefix}: {message}\n',1))
    cases += [(name,15,26,4,'','bend: Phase111 ABI v1 requires --threads 1 --gpu off\n',1) for name in ('two-threads','gpu-on')]
    cases += [('bad-cap',cap,26,4,'','bend: phase111: unsupported capabilities\n',1) for cap in (0,2)]
    result={}
    for role,obj in runtimes.items():
        directory=out/role
        directory.mkdir()
        elf=directory/'probe'
        check([cc,'-std=gnu11','-Wall','-Wextra','-Werror','-O2','-I',RUNTIME,*tc['linkerFlags'],
               HERE/'observer.c',ROOT/'selfhost/tests/phase183/abi-contract.c',obj,*tc['libraries'],'-o',elf])
        rows=[]
        for name,cap,count,words,stdout,stderr,status in cases:
            child=subprocess.run([str(elf),name,str(cap),str(count),str(words)],capture_output=True,timeout=5)
            got=(child.stdout.decode(),child.stderr.decode(),child.returncode)
            assert got==(stdout,stderr,status),(role,name,cap,count,words,got,(stdout,stderr,status))
            rows.append(dict(mode=name,capabilities=cap,constructorCount=count,staticWords=words,stdout=stdout,stderr=stderr,status=status))
        mutation=[]
        for name in ('owner-hot','owner-cap'):
            child=subprocess.run([str(elf),name,'15','26','4'],capture_output=True,timeout=5)
            expected='sealed '+('0' if role=='candidate' else '1')+' field 13\n'
            assert child.returncode==0 and child.stdout.decode()==expected and child.stderr==b'',(role,name,child)
            mutation.append(dict(mode=name,stdout=child.stdout.decode(),status=child.returncode))
        result[role]=dict(elf=B.pin(elf),rows=rows,foreignMutableMetadata=mutation)
    return result

def runtime_controls(out,cc,runtimes,tc):
    execution=BUILD/'phase195/runtime10-01/report.json'
    suite=B.read(execution)
    assert suite['passed'] and suite['selection']['all'] and suite['runtimeABI']==11102
    rows=[]
    for item in suite['rows']:
        B.verify(item['receipt'])
        B.verify(item['source'])
        production=B.read(item['receipt']['file'])
        obj=production['object']
        B.verify(obj)
        stdout=[l[2:] for l in Path(item['source']['file']).read_text().splitlines() if l.startswith('#|') and not l.startswith('#|exit ')]
        status=[int(l[7:]) for l in Path(item['source']['file']).read_text().splitlines() if l.startswith('#|exit ')]
        want=('\n'.join(stdout)+ ('\n' if stdout else ''),'',status[0] if status else 0)
        if item['name']=='halt-valid':want=('before\n','reported\n',7)
        assert want==(item['expected']['stdout'],item['expected']['stderr'],item['expected']['exitCode']),(item['name'],want,item['expected'])
        pairs={}
        for role,runtime in runtimes.items():
            folder=out/item['name']/role
            folder.mkdir(parents=True)
            exe=folder/'program'
            check([cc,*tc['linkerFlags'],obj['file'],runtime,*tc['libraries'],'-o',exe])
            child=subprocess.run([str(exe),*suite['runtimeArguments']],cwd=folder,capture_output=True,timeout=8)
            assert (child.stdout.decode(),child.stderr.decode(),child.returncode)==want,(item['name'],role,child)
            pairs[role]=dict(exe=B.pin(exe),stdout=child.stdout.decode(),stderr=child.stderr.decode(),status=child.returncode)
        rows.append(dict(name=item['name'],source=item['source'],object=obj,expected=item['expected'],results=pairs))
    return dict(source=B.pin(execution),rows=rows)

def prepare(out,only_controls=False,controls=None):
    assert os.sched_getaffinity(0)=={3}
    out=out.resolve()
    out.mkdir(parents=True)
    assert not list(out.iterdir())
    assets=B.read(BUILD/'phase194/assets.json')
    tc=assets['toolchains']['x86']
    cc=B.bind(assets['assets']['linker'],ROOT)['file']
    recorded=NOW/'runtime-screen01/report.json'
    screen=B.read(recorded)
    assert screen['complete']
    original=B.bind(assets['assets']['qbe-runtime'],ROOT)
    split=B.bind(screen['builds']['split']['object'],ROOT)
    runtimes=dict(baseline=original['file'],candidate=split['file'])
    new_source=B.bind(screen['builds']['split']['source'],ROOT)
    derivation=HERE.parent/'runtime/bind-facts.py'
    spec=importlib.util.spec_from_file_location('facts',derivation)
    facts=importlib.util.module_from_spec(spec)
    spec.loader.exec_module(facts)
    assert facts.variant((RUNTIME/'runtime.c').read_text(),'split')==Path(new_source['file']).read_text()
    assert screen['builds']['original']['object']['sha256']==original['sha256']
    assert exported(split['file'])==exported(original['file'])
    live_source=out/'runtime-live.c'
    live_object=out/'runtime-live.o'
    live_source.write_text(live.variant((RUNTIME/'runtime.c').read_text(),Path(new_source['file']).read_text()))
    cmd=[cc,'-O2','-std=gnu11','-ffp-contract=off','-DP144_SINGLE_MUTATOR_RFC=1','-I',RUNTIME,'-c',live_source,'-o',live_object]
    check(cmd)
    assert exported(live_object)==exported(original['file'])
    runtimes['live']=str(live_object)
    report=dict(complete=False,liveRuntime=B.pin(live_object),liveSource=B.pin(live_source),liveCommand=list(map(str,cmd)),
                inputs=[B.pin(p) for p in [__file__,HERE/'observer.c',HERE/'live.py',recorded,derivation,RUNTIME/'runtime.c',RUNTIME/'runtime.h',
        RUNTIME/'primitives.h',ROOT/'selfhost/tests/phase183/abi-contract.c']],runtime=split,baseline=original,exported=exported(split['file']),cases={})
    report['sections']={}
    for role,runtime in runtimes.items():
        data=check(['size','-A',runtime]).decode().splitlines()
        report['sections'][role]={cols[0]:int(cols[1]) for line in data if (cols:=line.split()) and cols[0].startswith('.') and cols[1].isdigit()}
    def save(): B.save(out/'report.json',report)
    save()
    if controls:
        prior=B.read(controls)
        assert prior['complete'] and prior['controlsOnly'] and prior['inputs']==report['inputs']
        assert prior['runtime']==split and prior['baseline']==original and prior['exported']==report['exported']
        assert prior['liveRuntime']['sha256']==report['liveRuntime']['sha256']
        assert len(prior['abi']['candidate']['rows'])==44 and len(prior['runtime10']['rows'])==10
        report.update(controlsReceipt=B.pin(controls),abi=prior['abi'],runtime10=prior['runtime10'])
    else:
        report['abi']=probes(out,cc,runtimes,tc)
        save()
        report['runtime10']=runtime_controls(out/'runtime10',cc,runtimes,tc)
    report['controlsOnly']=only_controls
    if only_controls:
        report['complete']=True
        save()
        print('ABI and runtime controls passed',flush=True)
        return
    save()
    old_file=NOW/'broad-runtime-plan01/recipe.json'
    old=B.read(old_file)
    src_file=NOW/'native45-01/programs.manifest.json'
    current={c['id']:c for c in B.read(src_file)['cases']}
    candidate_role=dict(old['roles']['candidate'],runtime=split,status='experimental-current-object-split-runtime',
                        policy='ordinary-serial-split',inputs=[*old['roles']['candidate']['inputs'],B.pin(recorded),B.pin(__file__),B.pin(derivation),new_source,split])
    live_role=dict(candidate_role,runtime=report['liveRuntime'],policy='ordinary-serial-split-live-descriptor',
                   status='experimental-current-object-live-runtime',inputs=[*candidate_role['inputs'],B.pin(HERE/'live.py'),report['liveSource'],report['liveRuntime']])
    recipe=dict(kind='programs',cwd=str(ROOT),catalog=old['catalog'],reference='c',
                roles=dict(c=old['roles']['c'],baseline=old['roles']['candidate'],candidate=candidate_role,live=live_role),cases=[])
    for row in old['cases']:
        case=row['id']
        archived=row['products']['candidate']
        assert archived==current[case]['products']['candidate']
        B.verify(archived['artifact'])
        B.verify(archived['generatedSource'])
        obj=Path(archived['generatedSource']['file'])
        folder=out/'native45'/case
        folder.mkdir(parents=True)
        for role,runtime in runtimes.items():
            exe=folder/role
            check([cc,*tc['linkerFlags'],obj,runtime,*tc['libraries'],'-o',exe])
        baseline=B.pin(folder/'baseline')
        assert baseline['sha256']==archived['artifact']['sha256'],case
        proposed=dict(archived,artifact=B.pin(folder/'candidate'))
        live_product=dict(archived,artifact=B.pin(folder/'live'))
        recipe['cases'].append(dict(id=case,products=dict(c=row['products']['c'],baseline=archived,candidate=proposed,live=live_product)))
        report['cases'][case]=dict(object=archived['generatedSource'],original=archived['artifact'],baseline=baseline,candidate=proposed['artifact'],live=live_product['artifact'])
    assert len(recipe['cases'])==45
    B.save(out/'recipe.json',recipe)
    B.freeze(out/'recipe.json',out/'manifest.json')
    report.update(complete=True,manifest=B.pin(out/'manifest.json'))
    save()
    print(json.dumps(dict(complete=True,probes=len(report['abi']['baseline']['rows']),runtime10=len(report['runtime10']['rows']),linked=len(recipe['cases']))))
if __name__=='__main__':
    p=argparse.ArgumentParser()
    p.add_argument('--out',required=True,type=Path)
    p.add_argument('--only-controls',action='store_true')
    p.add_argument('--controls',type=Path)
    a=p.parse_args()
    prepare(a.out,a.only_controls,a.controls)
