#!/usr/bin/env python3
"""Root-only serial execution of the frozen Phase91 compilation plan."""
import argparse, hashlib, importlib.util, json, math, os, resource, shutil, statistics, sys, time
from pathlib import Path
sys.dont_write_bytecode = True
HERE=Path(__file__).resolve().parent


def read(p): return json.loads(Path(p).read_text())


def check(p):
    f=Path(p['file']);h=hashlib.sha256()
    with f.open('rb') as s:
        for b in iter(lambda:s.read(1024*1024),b''):h.update(b)
    assert h.hexdigest()==p['sha256'] and f.stat().st_size==p['bytes'],str(f)


def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--plan',type=Path,required=True)
    ap.add_argument('--target',choices=['js','c'],required=True)
    ap.add_argument('--group',choices=['prepare','clean'],required=True)
    a=ap.parse_args();os.sched_setaffinity(0,{0})
    plan=read(a.plan);base=a.plan.resolve().parent;root=base/'runs';root.mkdir(exist_ok=True)
    assert plan['kind']=='phase91-current-compiler-latency-plan'
    resource.setrlimit(resource.RLIMIT_CORE,(plan['coreLimitBytes'],plan['coreLimitBytes']))
    file_limit=plan['maximumFileMiB']*1024**2
    resource.setrlimit(resource.RLIMIT_FSIZE,(file_limit,file_limit))
    for p in plan['inputs']:check(p)
    spec=importlib.util.spec_from_file_location('guard_support',plan['support']['file'])
    S=importlib.util.module_from_spec(spec);spec.loader.exec_module(S)
    if a.group=='prepare':jobs=[(f'prepare-{a.target}-{r}',r,'prepare','all',None) for r in plan['roles']]
    else:
        prepared={r:read(root/f'prepare-{a.target}-{r}'/'report.json') for r in plan['roles']}
        for r,p in prepared.items():
            assert p['complete'] and p['pass'] and p['inputsUnchanged']
            assert p['plan']['sha256']==hashlib.sha256(a.plan.read_bytes()).hexdigest()
            for row in p['outputs']:check(row['output'])
        for left,right in zip(prepared['b1']['outputs'],prepared['b2']['outputs']):
            assert left['case']==right['case'] and left['output']['sha256']==right['output']['sha256']
            assert Path(left['output']['file']).read_bytes()==Path(right['output']['file']).read_bytes()
        jobs=[]
        for round_ in range(plan['rounds']):
            for i,name in enumerate(plan['cases'][a.target]):
                roles=plan['roles'];shift=(round_+i)%len(roles);roles=roles[shift:]+roles[:shift]
                jobs += [(f'clean-{a.target}-{round_}-{name}-{r}',r,'sample',name,round_) for r in roles]
    results=[];started=time.monotonic()
    reportfile=base/f'{a.target}-{a.group}.json'
    assert not reportfile.exists()
    report=dict(kind='phase91-current-compiler-latency-campaign',complete=False,passed=False,target=a.target,
                group=a.group,rows=results,plan=str(a.plan.resolve()),scope=plan['scope'])
    def save():reportfile.write_text(json.dumps(report,indent=2)+'\n')
    save()
    try:
        with S.ExecutionGuard(rss_mib=plan['rssMiB'],available_mib=plan['availableMiB']) as guard:
            for job,role,action,name,round_ in jobs:
                assert shutil.disk_usage(base).free>=plan['minimumDiskMiB']*1024**2,'Disk reserve below160MiB'
                out=root/job;guardout=root/(job+'-guard');assert not out.exists() and not guardout.exists()
                command=['taskset','-c',str(plan['cpu']),plan['node']['file'],*plan['execArgv'],
                         str(HERE/'worker.mjs'),str(a.plan.resolve()),a.target,role,action,name,str(out)]
                result=guard.run(command,guardout,time.monotonic()+plan['secondsPerJob'])
                row=dict(job=job,role=role,case=name,round=round_,guard=result);results.append(row);save()
                assert result['complete'],'Failed target preserved: '+job
                child=read(out/'report.json');row['report']=str(out/'report.json');row['timings']=child['timings']
                assert child['complete'] and child['pass'] and child['inputsUnchanged'];save()
                print(json.dumps(dict(job=job,timings=child['timings'])),flush=True)
        for p in plan['inputs']:check(p)
        if a.group=='clean':
            summary={}
            for name in plan['cases'][a.target]:
                byrole={}
                for role in plan['roles']:
                    rows=[r for r in results if r['case']==name and r['role']==role]
                    assert len(rows)==plan['rounds']
                    byrole[role]={metric:dict(values=[r['timings'][metric] for r in rows],
                         median=statistics.median(r['timings'][metric] for r in rows))
                         for metric in ['hostImportMs','apiLoadMs','firstRequestMs','importApiAndFirstMs']}
                summary[name]=byrole
            report['summary']=summary;report['geometricRatiosToTypeScript']={}
            for role in ['b1','b2']:
                report['geometricRatiosToTypeScript'][role]={m:math.exp(sum(math.log(c[role][m]['median']/c['typescript'][m]['median'])
                     for c in summary.values())/len(summary)) for m in ['firstRequestMs','importApiAndFirstMs']}
        report.update(complete=True,passed=True,inputsUnchanged=True)
    finally:
        report['wallSeconds']=time.monotonic()-started;save()


if __name__=='__main__':main()
