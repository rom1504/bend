#!/usr/bin/env python3
"""Operation-count follow-up of the already measured saved-C BANGS0 ablation."""
import importlib.util
import json
import sys
import time
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('survey_run',HERE/'run.py')
R=importlib.util.module_from_spec(spec);spec.loader.exec_module(R)
S=R.S;ROOT=R.ROOT

def main():
    out=Path(sys.argv[1]).resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase68')
    out.mkdir(parents=True,exist_ok=False)
    products,pins=R.products()
    parent=ROOT/'selfhost/build/phase68/parity-survey23-bangs02'
    report=R.read(parent/'report.json');plan=R.read(parent/'plan.json');assert report['complete']
    pins += [S.identity(__file__),S.identity(parent/'report.json'),S.identity(parent/'plan.json')]
    jobs=[]
    for j in plan['jobs']:
        R.verify([j['original'],j['derived']]);pins += [j['original'],j['derived']]
        original=Path(j['original']['path']).read_text();derived=Path(j['derived']['path']).read_text()
        assert original.replace('#define BANGS '+str(j['oldBangs']),'#define BANGS 0',1)==derived
        d=out/j['case'];d.mkdir()
        code,sites=R.site_counts(derived);code,segments=R.N.instrument(code)
        source=d/'program.c';source.write_text(code)
        jobs.append(dict(case=j['case'],source=S.identity(source),sites=sites,segments=segments,parent=j))
    S.save(out/'plan.json',dict(inputs=pins,jobs=jobs,scope='Counts only; BANGS0 derivative. Compare source-operation frequencies with current23 counts01.'))
    result=dict(complete=False,started=time.time(),plan=S.identity(out/'plan.json'),records=[])
    try:
        with S.ExecutionGuard(rss_mib=2048,available_mib=4096) as guard:
            def run(cmd,dest,seconds=90):return guard.run(['taskset','-c','3',*map(str,cmd)],dest,time.monotonic()+seconds)
            for j in jobs:
                case=j['case'];d=out/case;exe=d/'program';recipe=products[(case,'selfhost')]['recipe']
                r=dict(job=j,runs=[]);result['records'].append(r)
                r['build']=run([recipe['clang'],*recipe['clangArgs'],j['source']['path'],*recipe['linkArgs'],'-o',exe],d/'build')
                assert r['build']['complete'];r['executable']=S.identity(exe)
                for n in (1,17):
                    rd=d/f'run-{n}';proc=run([exe,'--threads',1,'--gpu','off','--',n,0],rd,30)
                    obs=R.observed(rd,proc,case,n)
                    row=dict(repetitions=n,process=proc,**obs);r['runs'].append(row)
                    assert obs['correct']
                    logs=[json.loads(s) for s in (rd/'stderr.log').read_text().splitlines()];assert len(logs)==2
                    row['counts']=next(x for x in logs if x['kind']=='phase68-native-counts')
                    row['allocationSites']=next(x for x in logs if x['kind']=='phase68-allocation-sites')['sites']
                r['complete']=True;S.save(out/'report.json',result)
        R.verify(pins);result['complete']=True
    except BaseException as e:result['error']=repr(e);raise
    finally:result['finished']=time.time();S.save(out/'report.json',result)
    print(json.dumps(dict(complete=result['complete'],records=len(result['records']))))

if __name__=='__main__':main()
