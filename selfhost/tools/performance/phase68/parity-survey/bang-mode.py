#!/usr/bin/env python3
"""Saved-C diagnostic: isolate dead-bang global scheduling mode, no compiler edit."""
import importlib.util
import json
import math
import os
import re
import statistics
import sys
import time
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('survey_run',HERE/'run.py')
R=importlib.util.module_from_spec(spec);spec.loader.exec_module(R)
S=R.S;ROOT=R.ROOT

def main():
    out=Path(sys.argv[1]).resolve()
    assert out.is_relative_to(ROOT/'selfhost/build/phase68')
    out.mkdir(parents=True,exist_ok=False)
    products,pins=R.products()
    pins += [S.identity(__file__),S.identity(ROOT/'experiments/phase68/P68-023-dead-bang-metadata.md')]
    recipe=products[('tree','selfhost')]['recipe']
    env={k:os.environ.get(k) for k in recipe['compilerEnvironment']}
    assert env==recipe['compilerEnvironment']
    jobs=[]
    for case in ('tree','lexer'):
        source=Path(products[(case,'selfhost')]['nativeSource']['path'])
        code=source.read_text()
        matches=list(re.finditer(r'^#define BANGS (\d+)$',code,re.M))
        assert len(matches)==1
        m=matches[0];assert int(m[1])=={'tree':39,'lexer':16}[case]
        changed=code[:m.start()]+'#define BANGS 0'+code[m.end():]
        dest=out/case;dest.mkdir();path=dest/'bangs-zero.c';path.write_text(changed)
        jobs.append(dict(case=case,original=S.identity(source),derived=S.identity(path),oldBangs=int(m[1]),newBangs=0))
    R.verify(pins)
    S.save(out/'plan.json',dict(inputs=pins,jobs=jobs,compilerEnvironment=env,
        counts={'tree':1280,'lexer':448},roles=['selfhost','bangs-zero','upstream'],rounds=3,
        scope='Pure saved-C runtime-mode ablation, not compiler correctness/promotion; clocks exclude builds.'))
    report=dict(complete=False,started=time.time(),plan=S.identity(out/'plan.json'),builds=[],controls=[],records=[])
    try:
        with S.ExecutionGuard(rss_mib=2048,available_mib=4096) as guard:
            def run(cmd,dest,seconds=45):
                return guard.run(['taskset','-c','3',*map(str,cmd)],dest,time.monotonic()+seconds)
            executables={}
            for job in jobs:
                case=job['case'];dest=out/case;exe=dest/'program'
                b=run([recipe['clang'],*recipe['clangArgs'],job['derived']['path'],*recipe['linkArgs'],'-o',exe],dest/'build',90)
                report['builds'].append(dict(job=job,process=b));assert b['complete']
                executables[(case,'bangs-zero')]=S.identity(exe)
                for role in ('selfhost','upstream'):
                    executables[(case,role)]=products[(case,role)]['executable']
                for threads,count in [(1,1),(1,17),(4,17)]:
                    d=dest/f'control-{threads}-{count}'
                    proc=run([exe,'--threads',threads,'--gpu','off','--',count,0],d)
                    obs=R.observed(d,proc,case,count)
                    report['controls'].append(dict(case=case,threads=threads,repetitions=count,process=proc,**obs))
                    S.save(out/'report.json',report);assert obs['correct']
            for case in ('tree','lexer'):
                n={'tree':1280,'lexer':448}[case];warm=(n//8//16)*16
                for rnd in range(3):
                    roles=['selfhost','bangs-zero','upstream'];roles=roles[rnd:]+roles[:rnd]
                    for role in roles:
                        d=out/f'{case}-{rnd}-{role}';exe=executables[(case,role)]
                        assert S.identity(exe['path'])==exe
                        proc=run([exe['path'],'--threads',1,'--gpu','off','--',n,warm],d)
                        obs=R.observed(d,proc,case,n,warm)
                        item=dict(case=case,role=role,round=rnd,repetitions=n,warmups=warm,executable=exe,process=proc,**obs)
                        if obs['correct']:item['elapsedMs']=int(obs['stdout'][3])
                        item['qualified']=obs['correct'] and 100<=item['elapsedMs']<=proc['wallSeconds']*1000+2
                        report['records'].append(item);S.save(out/'report.json',report)
                        assert item['qualified'],item
            report['rows']=[]
            for case in ('tree','lexer'):
                ms={role:statistics.median(x['elapsedMs'] for x in report['records'] if x['case']==case and x['role']==role)
                    for role in ('selfhost','bangs-zero','upstream')}
                report['rows'].append(dict(case=case,mediansMs=ms,speedup=ms['selfhost']/ms['bangs-zero'],
                    diagnosticOverUpstream=ms['bangs-zero']/ms['upstream']))
            R.verify(pins)
            report['complete']=True
    except BaseException as e:
        report['error']=repr(e);raise
    finally:
        report['finished']=time.time();S.save(out/'report.json',report)
    print(json.dumps(report['rows'],indent=2))

if __name__=='__main__':main()
