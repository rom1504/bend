"""Train only the runtime on four disjoint families. Time independent held-out workloads."""
import argparse
import importlib.util
import json
import math
import os
from pathlib import Path
import shutil
import statistics
import subprocess
import sys
import time

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
BUILD=ROOT/'selfhost/build'
NOW=BUILD/'phase198'
sys.path.insert(0,str(HERE.parent/'fusion'))
from screen import read,pin,checked_tool,execute,bench,extra_output
from variant import source
TRAIN=['tree-bitonic','coverage-map-churn-32','coverage-bst-32','mandelbrot']
TEST=['lexer','coverage-unicode-text-64','coverage-record-aggregation-256','test-rle-roundtrip','test-morning-program','local-fold']
def cmd(argv,cwd=None):
    r=subprocess.run(list(map(str,argv)),cwd=cwd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=35)
    if r.returncode:
        raise RuntimeError((list(map(str,argv)),r.returncode,r.stderr.decode()[-3500:]))
    return r
def main(o):
    assert os.sched_getaffinity(0)=={3} and not set(TRAIN)&set(TEST)
    out=o.out.resolve();out.mkdir(parents=True)
    catalog=NOW/'native45-01/programs.manifest.json'
    c={x['id']:x for x in read(catalog)['cases']}
    refs={x['id']:x['products']['c'] for x in read(BUILD/'phase195/references01/manifest.json')['cases']}
    meta=read(BUILD/'phase194/assets.json')
    cc=checked_tool(meta['assets']['linker']);tc=meta['toolchains']['x86']
    base=BUILD.parent/'src/runtime/qbe/runtime.c'
    static=NOW/'runtime-split-controls01/report.json'
    status=read(static);assert status['complete']
    live=Path(checked_tool(status['liveRuntime']))
    r={'complete':False,'driver':pin(__file__),'variant':pin(HERE/'variant.py'),'catalog':pin(catalog),
       'liveControls':pin(static),'compiler':pin(cc),'runtimeSource':pin(base),'training':[],'validation':[],'samples':[],
       'trainingFamilies':['tree','map','bst','mandelbrot'],'declaredTest':TEST,'roles':{}}
    save=lambda:(out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
    save()
    def build(role,form,flags=(),saved=None):
        folder=out/role;folder.mkdir(exist_ok=True)
        src=folder/'runtime.c';src.write_text(source(base.read_text(),form))
        obj=folder/'runtime.o'
        flags=['-O2','-std=gnu11','-ffp-contract=off','-DP144_SINGLE_MUTATOR_RFC=1',*flags,'-I',base.parent]
        proc=cmd([cc,*flags,'-c','runtime.c','-o','runtime.o'],folder)
        r['roles'][saved or role]={'object':pin(obj),'source':pin(src),'flags':[str(f) for f in flags],'stderr':proc.stderr.decode()}
        save();return obj
    def link(id,role,rt,flags=()):
        directory=out/'programs'/id;directory.mkdir(parents=True,exist_ok=True)
        exe=directory/role
        obj=checked_tool(c[id]['products']['candidate']['generatedSource'])
        cmd([cc,*flags,*tc['linkerFlags'],obj,rt,*tc['libraries'],'-o',exe])
        return exe
    profile=out/'profile';profile.mkdir()
    instr=build('pgo','specialize',['-fprofile-generate='+str(profile)],'instrumented')
    for case in TRAIN:
        exe=link(case,'training',instr,['-fprofile-generate'])
        p=c[case]['point'];reps=max(1,p['repetitions']//3)
        before=time.monotonic()
        obs,_=execute(exe,p['runtimeArgs'],reps,1,p['expectedStdout'])
        r['training'].append({'id':case,'inputs':p['runtimeArgs'],'exe':pin(exe),'observation':obs,'reps':reps,'wall':time.monotonic()-before});save()
    files=sorted(profile.rglob('*.gcda')); assert files
    r['profiles']=[pin(f) for f in files]
    training_object=out/'pgo/instrumented.o'
    shutil.copyfile(instr,training_object)
    r['roles']['instrumented']['object']=pin(training_object)
    save()
    profiles={'live':live,'release':build('release','release'),'specialize':build('specialize','specialize'),
        'pgo':build('pgo','specialize',['-fprofile-use='+str(profile),'-Werror=missing-profile','-Werror=coverage-mismatch'])}
    r['roles']['live']={'source':status.get('liveSource'),'object':pin(live)}
    probe_file=HERE.parent/'runtime-broad/prepare.py'
    sys.path.insert(0,str(probe_file.parent))
    module=importlib.util.spec_from_file_location('phase198_runtime_controls',probe_file)
    controls=importlib.util.module_from_spec(module);module.loader.exec_module(controls)
    abi_dir=out/'abi';abi_dir.mkdir()
    r['verificationMethod']=pin(probe_file)
    r['abi']=controls.probes(abi_dir,cc,profiles,tc)
    r['runtimeControls']=controls.runtime_controls(out/'runtime10',cc,profiles,tc)
    assert all(len(q['rows'])==44 for q in r['abi'].values())
    assert len(r['runtimeControls']['rows'])==10
    save()
    for case in TEST:
        products={role:link(case,role,rt) for role,rt in profiles.items()}
        point=c[case]['point'];p=point['runtimeArgs'];expected=point['expectedStdout'];ref=refs[case]
        alternate=[2,17] if case not in ('test-morning-program','test-rle-roundtrip') else [1,19]
        exp=extra_output(ref,alternate)
        row={'id':case,'executables':{r:pin(v) for r,v in products.items()},'extraInput':alternate,'extraExpected':exp,'ordinary':expected,
             'extraOutputs':{k:execute(e,alternate,0,0,exp)[0] for k,e in products.items()},'samples':{},'calibration':{}}
        r['samples'].append(row);save()
        for role,exe in products.items():
            n=max(1,min(point['repetitions'],512));row['samples'][role]=[]
            for _ in range(12):
                got,_=execute(exe,p,n,2,expected)
                if 105<=got['elapsedMs']<=340:break
                n=max(1,math.ceil(n*155/max(1,got['elapsedMs'])))
            else:raise ValueError('unmetered '+case)
            row['calibration'][role]=[n,got]
        roles=list(products)
        if o.reverse:roles.reverse()
        for i in range(4):
            for role in roles[i:]+roles[:i]:
                n=row['calibration'][role][0]
                obs,_=execute(products[role],p,n,2,expected)
                assert obs['elapsedMs']>=68,(case,role,obs)
                row['samples'][role].append({'n':n,**obs})
        med={k:statistics.median(x['elapsedMs']/x['n'] for x in xs) for k,xs in row['samples'].items()}
        row['overLive']={k:v/med['live'] for k,v in med.items()}
        save()
    r['complete']=True;save()
    print([(row['id'],row['overLive']) for row in r['samples']])
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('--reverse',action='store_true')
    main(p.parse_args())
