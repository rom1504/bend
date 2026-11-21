"""Paired timing on exact Bend-built private-ABI objects, including a held-out lexer size."""
import argparse
import json
import os
from pathlib import Path
import statistics
import subprocess
import sys
from project import ROOT,BUILD,HERE,sha
sys.path.insert(0,str(ROOT/'research/phase196/screen'))
from measure import ASSETS,REFERENCES,read,execute,checked_tool

def run(built,out):
    out=out.resolve()
    out.mkdir()
    assert os.sched_getaffinity(0)=={3}
    emitted=read(built)
    assert emitted['complete']
    refs={r['id']:r for r in read(REFERENCES)['cases']}
    current={r['id']:r for r in read(BUILD/'phase198/native45-01/programs.manifest.json')['cases']}
    assets=read(ASSETS)
    tc=assets['toolchains']['x86']
    cc=checked_tool(assets['assets']['linker'])
    rt=checked_tool(assets['assets']['qbe-runtime'])
    report=dict(complete=False,source=sha(Path(__file__)),emission=sha(built),cases={})
    save=lambda:(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    for i,(case,arm) in enumerate(emitted['rows'].items()):
        folder=out/case
        folder.mkdir()
        new=folder/'program'
        obj=checked_tool(arm['object'])
        subprocess.run([cc,*tc['linkerFlags'],obj,rt,*tc['libraries'],'-o',new],check=True,capture_output=True)
        paths={'baseline':checked_tool(current[case]['products']['candidate']['artifact']),'candidate':new}
        point=refs[case]['point']
        c=refs[case]['products']['c']
        row=dict(executable=sha(new),checks=[],timings=[])
        report['cases'][case]=row
        for j,args in enumerate([point['runtimeArgs'],[3,17],[6,123]]):
            n=int(j==0)
            oracle,expected=execute(checked_tool(c['artifact']),args,n,0,point['expectedStdout'] if n else None,c['runtimeArgumentConvention'])
            results={k:execute(v,args,n,0,expected)[0] for k,v in paths.items()}
            row['checks'].append(dict(args=args,c=oracle,outputs=results))
        if arm['exact']:
            assert new.read_bytes()==Path(paths['baseline']).read_bytes()
            row['baselineEqual']=True
        else:
            def timed(p,n):return execute(p,point['runtimeArgs'],n,4,point['expectedStdout'])[0]['elapsedMs']
            n=max(1,point['repetitions']//3)
            pilot=timed(paths['baseline'],n)
            n=max(1,round(n*185/max(pilot,1)))
            for rnd in range(6):
                order=['candidate','baseline'] if (rnd+i)%2 else ['baseline','candidate']
                times={r:timed(paths[r],n) for r in order}
                row['timings'].append(dict(order=order,n=n,times=times,ratio=times['candidate']/times['baseline']))
                save()
            row['median']=statistics.median(t['ratio'] for t in row['timings'])
            row['faster']=sum(t['ratio']<1 for t in row['timings'])
        save()
    report['complete']=True
    save()
    print({k:v.get('median','object equal') for k,v in report['cases'].items()})
if __name__=='__main__':
    p=argparse.ArgumentParser()
    p.add_argument('--built',required=True,type=Path)
    p.add_argument('--out',required=True,type=Path)
    a=p.parse_args()
    run(a.built,a.out)
