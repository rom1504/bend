#!/usr/bin/env python3
"""Small emitted-C behavior and balanced timing probe, without compiler-image gates."""
import argparse, hashlib, json, statistics, subprocess, sys
from pathlib import Path

ROOT=Path(__file__).resolve().parents[4]
CC=Path('/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/bin/clang')
GUARD=ROOT/'selfhost/tools/performance/phase86/guard.py'
def pin(p):
    p=Path(p).resolve();raw=p.read_bytes();return dict(file=str(p),bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest())

def main():
    p=argparse.ArgumentParser(description=__doc__)
    for key in ['emission','cases','out']:p.add_argument('--'+key,type=Path,required=True)
    p.add_argument('--program',required=True);p.add_argument('--rounds',type=int,default=4)
    a=p.parse_args();out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase99');out.mkdir(exist_ok=False)
    emission=json.loads(a.emission.read_text());assert emission['complete'] and emission['inputsUnchanged']
    for item in emission['inputs']:assert pin(item['file'])==item
    cases=json.loads(a.cases.read_text())['cases'];assert cases and a.rounds>=2 and a.rounds%2==0
    report=dict(complete=False,method=pin(__file__),emission=pin(a.emission),cases=pin(a.cases),program=a.program,rows=[],samples=[],products={})
    def save():(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    def run(name,argv,seconds):
        folder=out/name
        result=subprocess.run([sys.executable,'-B',str(GUARD),'--out',str(folder),'--seconds',str(seconds),'--rss-mib','2048','--available-mib','4096','--cpu','3','--',*map(str,argv)],capture_output=True,text=True)
        (out/(name+'.launcher.log')).write_text(result.stdout+result.stderr)
        process=json.loads((folder/'process.json').read_text());report['rows'].append(dict(name=name,process=process,receipt=pin(folder/'process.json')));save()
        assert result.returncode==0 and process['complete'] and process['returncode']==0 and not process.get('stoppedFor'),name
        return folder,process
    def sample(name,role,case):
        folder,process=run(name,[report['products'][role]['binary']['file'],'--threads','1','--gpu','off','--',*case['argv']],30)
        assert (folder/'stdout.log').read_text()==case['stdout'] and (folder/'stderr.log').read_text()==case['stderr'],(name,case['id'])
        return dict(case=case['id'],role=role,wallSeconds=process['wallSeconds'],fullOutputExact=True)
    try:
        for role in ['baseline','candidate']:
            c=next(row['c'] for row in emission['programs'] if row['id']==a.program+'-'+role);assert pin(c['file'])==c
            binary=out/(role+'.program');run(role+'-build',[CC,'-isystem',CC.parent.parent/'include/clang','-O2',c['file'],'-o',binary,'-lm','-pthread'],60)
            report['products'][role]=dict(c=c,binary=pin(binary));save()
        for i,case in enumerate(cases):
            for role in ['baseline','candidate']:sample(f'control{i}-{role}',role,case)
        for rnd in range(a.rounds):
            for role in (['baseline','candidate'] if rnd%2==0 else ['candidate','baseline']):
                row=sample(f'round{rnd}-{role}',role,cases[0]);row['round']=rnd;report['samples'].append(row);save()
        med={role:statistics.median(r['wallSeconds'] for r in report['samples'] if r['role']==role) for role in report['products']}
        report.update(complete=True,medians=med,candidateOverBaseline=med['candidate']/med['baseline'],
            behaviorExecutions=2*len(cases),timedExecutions=2*a.rounds,
            timingAbove100ms=all(r['wallSeconds']>=.1 for r in report['samples']),
            scope='Complete native outputs on all supplied cases; balanced whole-process timings on first case only. Synthetic mechanism probe, not compiler latency or representative program aggregate.')
    except BaseException as e:report['error']=repr(e);raise
    finally:save()
    print(json.dumps({k:report[k] for k in ['complete','medians','candidateOverBaseline','behaviorExecutions','timedExecutions','timingAbove100ms']}))

if __name__=='__main__':main()
