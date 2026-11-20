"""Time actually emitted candidate ELF objects, authenticating the previous native compiler."""
import argparse
import json
import math
import os
from pathlib import Path
import statistics
import subprocess
import sys
import time

HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(HERE))
from screen import read,pin,checked_tool,execute,BUILD,extra_output

def independent_invoice(size,seed):
    keys=[]
    for _ in range(size):
        keys.append(seed);seed=(seed+19)&0xffffffff
    for k in reversed(keys):
        if k%4==0:seed=k+11-seed
        elif k%4==1:seed=(k%7+3)*seed
        else:seed-=k*5
        seed&=0xffffffff
    return str(seed)+'\n'

def run(o):
    assert os.sched_getaffinity(0)=={3}
    out=o.out;out.mkdir(parents=True)
    ref={c['id']:c for c in read(BUILD/'phase195/references01/manifest.json')['cases']}
    current={c['id']:c for c in read(BUILD/'phase198/native45-01/programs.manifest.json')['cases']}
    emission=read(o.emission)
    assert emission['complete']
    r={'complete':False,'emission':pin(o.emission),'driver':pin(__file__),'reverse':o.reverse,'rows':[]}
    save=lambda:(out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
    for idx,row in enumerate(c for c in emission['cases'] if 'object' in c):
        id=row['id'];ordinary=current.get(id,current['coverage-expression-128'])
        auth=read(BUILD/'phase198/native45-01'/ordinary['id']/'machine/report.json')
        jobs={j['label']:j['command'] for j in auth['jobs']}
        base=ordinary['products']['candidate'];c=ref[ordinary['id']]['products']['c']
        assert auth['complete'] and auth['binary']==base['artifact']
        exe=out/id;exe.mkdir()
        def link(obj,binary):
            cmd=jobs['link'][:]
            cmd[cmd.index(base['generatedSource']['file'])]=str(obj)
            cmd[cmd.index(base['artifact']['file'])]=str(binary)
            subprocess.run(cmd,check=True,timeout=12,capture_output=True)
        link(checked_tool(row['object']),exe/'candidate')
        binaries={'candidate':exe/'candidate'}
        if id=='heldout':
            src=checked_tool(row['source']);old=exe/'baseline.o'
            cmd=jobs['compiler'][:]
            cmd[cmd.index(ordinary['source']['file'])]=src
            with old.open('wb') as f:subprocess.run(cmd,check=True,timeout=40,stdout=f,stderr=subprocess.PIPE)
            link(old,exe/'baseline');binaries['baseline']=exe/'baseline'
        else:
            if o.source_ceiling:
                assert emission['scope']=='source ceiling' and row['ordinary']==ordinary['source']
                checked_tool(row['source'])
                original_text=Path(checked_tool(ordinary['source'])).read_text()
                assert Path(row['source']['file']).read_text().split('# Phase93:',1)[1]==original_text.split('# Phase93:',1)[1]
            else:
                assert row['source']==ordinary['source']
            binaries.update(baseline=checked_tool(base['artifact']),c=checked_tool(c['artifact']))
        point=ordinary['point'];inputs=point['runtimeArgs']
        expected=independent_invoice(*inputs) if id=='heldout' else point['expectedStdout']
        results={'id':id,'inputs':inputs,'expected':expected,'binaries':{k:pin(v) for k,v in binaries.items()},
                 'oracles':[],'calibration':{},'samples':{}}
        r['rows'].append(results);save()
        # Some original programs require a bounded input size (e.g. fork depth).
        # Use their frozen catalog point plus legal nearby inputs, bounded by family.
        if id=='heldout' or 'expression' in id or 'record-aggregation' in id or 'local-fold' in id or 'numeric-recurrence' in id:
            extra=[[0,0],[1,4294967295],[19,7],[57,12345]]
        elif 'scalar-region' in id:extra=[[0,0],[1,4294967295],[19,7],[8192,31],[8192,524800]]
        elif 'lexer' in id or 'mandelbrot' in id:extra=[[1,0],[3,7],[4,123]]
        else:extra=[[1,0],[2,17]]
        for inputs2 in extra:
            want=independent_invoice(*inputs2) if id=='heldout' else extra_output(c,inputs2)
            obs={k:execute(v,inputs2,0,0,want,c['runtimeArgumentConvention'] if k=='c' else base['runtimeArgumentConvention'])[0] for k,v in binaries.items()}
            results['oracles'].append({'args':inputs2,'expect':want,'obs':obs})
        for role,prog in binaries.items():
            n=max(1,min(512,point['repetitions']));cal=[]
            for _ in range(18):
                obs,_=execute(prog,inputs,n,3,expected,c['runtimeArgumentConvention'] if role=='c' else base['runtimeArgumentConvention'])
                ms=obs['elapsedMs'];cal.append([n,ms])
                if 130<=ms<=360:break
                n=max(1,math.ceil(n*195/max(1,ms)))
            else:raise ValueError('calibration '+id)
            results['calibration'][role]=cal;results['samples'][role]=[]
        order=list(reversed(binaries)) if o.reverse else list(binaries)
        for t in range(len(order)*2):
            start=(t+idx)%len(order)
            for role in order[start:]+order[:start]:
                n=results['calibration'][role][-1][0]
                obs,_=execute(binaries[role],inputs,n,3,expected,c['runtimeArgumentConvention'] if role=='c' else base['runtimeArgumentConvention'])
                assert obs['elapsedMs']>=90
                results['samples'][role].append(dict(repetitions=n,**obs))
        m={k:statistics.median(o['elapsedMs']/o['repetitions'] for o in obs) for k,obs in results['samples'].items()}
        results['candidateOverBaseline']=m['candidate']/m['baseline']
        if 'c' in m:results['candidateOverC']=m['candidate']/m['c']
        save()
    assert r['rows']
    r['complete']=True;save();print([(x['id'],x['candidateOverBaseline'],x.get('candidateOverC')) for x in r['rows']])

p=argparse.ArgumentParser()
p.add_argument('--source-ceiling',action='store_true')
p.add_argument('--emission',required=True,type=Path);p.add_argument('--out',required=True,type=Path);p.add_argument('--reverse',action='store_true')
if __name__=='__main__':run(p.parse_args())
