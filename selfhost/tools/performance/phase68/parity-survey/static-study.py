#!/usr/bin/env python3
"""Five-arm saved-C static-data/scheduling diagnostic with independent outputs."""
import importlib.util
import json
import os
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
    import argparse
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--static',type=Path,required=True);p.add_argument('--combined',type=Path,required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--derivation',type=Path,required=True)
    a=p.parse_args();out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase68')
    out.mkdir(parents=True,exist_ok=False)
    products,pins=R.products();recipe=products[('lexer','selfhost')]['recipe']
    env={k:os.environ.get(k) for k in recipe['compilerEnvironment']};assert env==recipe['compilerEnvironment']
    derivation=R.read(a.derivation);assert derivation['preparedOnly']
    R.verify(derivation['inputs']+[d['source'] for d in derivation['derivatives']])
    assert {d['source']['path'] for d in derivation['derivatives']}=={str(a.static.resolve()),str(a.combined.resolve())}
    pins += [S.identity(a.derivation),*derivation['inputs']]
    pins += [S.identity(__file__),S.identity(ROOT/'experiments/phase68/P68-024-static-constructor-data.md'),S.identity(a.static),S.identity(a.combined)]
    parent=ROOT/'selfhost/build/phase68/parity-survey23-bangs02'
    old=R.read(parent/'report.json');assert old['complete'];pins.append(S.identity(parent/'report.json'))
    seq=next(x['executable'] for x in old['records'] if x['case']=='lexer' and x['role']=='bangs-zero');pins.append(seq)
    exes={'selfhost':products[('lexer','selfhost')]['executable'],'seq':seq,'upstream':products[('lexer','upstream')]['executable']}
    assert a.static.read_text().replace('#define BANGS 16','#define BANGS 0',1)==a.combined.read_text()
    R.verify(pins);S.save(out/'plan.json',dict(inputs=pins,compilerEnvironment=env,roles=['selfhost','static','seq','combined','upstream'],rounds=5,repetitions=448,warmups=48,scope='Five-arm saved-C diagnostic; no compiler change or broad-conformance claim.'))
    result=dict(complete=False,started=time.time(),plan=S.identity(out/'plan.json'),builds=[],controls=[],records=[])
    try:
        with S.ExecutionGuard(rss_mib=2048,available_mib=4096) as guard:
            def run(cmd,dest,seconds=45):return guard.run(['taskset','-c','3',*map(str,cmd)],dest,time.monotonic()+seconds)
            for role,source in [('static',a.static),('combined',a.combined)]:
                dest=out/role;dest.mkdir();exe=dest/'program'
                build=run([recipe['clang'],*recipe['clangArgs'],source,*recipe['linkArgs'],'-o',exe],dest/'build',90)
                result['builds'].append(dict(role=role,source=S.identity(source),process=build));assert build['complete'];exes[role]=S.identity(exe)
                for threads,count in ((1,1),(1,17),(4,17)):
                    d=dest/f'control-{threads}-{count}';process=run([exe,'--threads',threads,'--gpu','off','--',count,0],d)
                    obs=R.observed(d,process,'lexer',count);result['controls'].append(dict(role=role,threads=threads,repetitions=count,process=process,**obs));S.save(out/'report.json',result);assert obs['correct']
            for rnd in range(5):
                roles=['selfhost','static','seq','combined','upstream'];roles=roles[rnd:]+roles[:rnd]
                for role in roles:
                    dest=out/f'round-{rnd}-{role}';exe=exes[role];assert S.identity(exe['path'])==exe
                    process=run([exe['path'],'--threads',1,'--gpu','off','--',448,48],dest)
                    obs=R.observed(dest,process,'lexer',448,48)
                    row=dict(role=role,round=rnd,executable=exe,process=process,**obs)
                    if obs['correct']:row['elapsedMs']=int(obs['stdout'][3])
                    row['qualified']=obs['correct'] and 100<=row['elapsedMs']<=process['wallSeconds']*1000+2
                    result['records'].append(row);S.save(out/'report.json',result);assert row['qualified']
            result['mediansMs']={role:statistics.median(r['elapsedMs'] for r in result['records'] if r['role']==role) for role in exes}
            R.verify(pins);result['complete']=True
    except BaseException as e:result['error']=repr(e);raise
    finally:result['finished']=time.time();S.save(out/'report.json',result)
    print(json.dumps(result['mediansMs']))

if __name__=='__main__':main()
