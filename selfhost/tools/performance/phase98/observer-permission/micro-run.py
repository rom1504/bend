#!/usr/bin/env python3
"""Root-only bounded native shared-comparison screen using already qualified APIs."""
import argparse
import hashlib
import json
from pathlib import Path
import statistics
import subprocess
import sys
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
BUILD=ROOT/'selfhost/build/phase98'
GUARD=ROOT/'selfhost/tools/performance/phase86/guard.py'
NODE=Path('/home/ai/.nvm/versions/node/v24.18.0/bin/node')
CLANG=Path('/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/bin/clang')
def pin(path):
    path=Path(path).resolve(); data=path.read_bytes()
    return dict(file=str(path),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())
def read(path): return json.loads(Path(path).read_text())
def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--qualification',type=Path,required=True)
    parser.add_argument('--corpus-report',type=Path,required=True)
    parser.add_argument('--out',type=Path,required=True)
    args=parser.parse_args();out=args.out.resolve();qualification=args.qualification.resolve()
    assert out.is_relative_to(BUILD) and not out.exists();out.mkdir(parents=True)
    inputs={};report=dict(kind='phase98-shared-string-native-screen',complete=False,rows=[],samples=[],inputs=[])
    def bind(path):
        row=pin(path);assert inputs.setdefault(row['file'],row)==row;return row
    def verify(value):
        if isinstance(value,list):
            for x in value:verify(x)
        elif isinstance(value,dict):
            if {'file','bytes','sha256'}<=value.keys():assert bind(value['file'])==value
            else:
                for x in value.values():verify(x)
    def save():
        report['inputs']=list(inputs.values());(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    def run(name,argv,seconds=30,rss=1024,available=4096):
        folder=out/(name+'-guard');cmd=[sys.executable,'-B',str(GUARD),'--out',str(folder),'--seconds',str(seconds),'--rss-mib',str(rss),'--available-mib',str(available),'--cpu','3','--',*map(str,argv)]
        job=subprocess.run(cmd,cwd=ROOT,capture_output=True,text=True)
        (out/(name+'.launcher.stdout')).write_text(job.stdout);(out/(name+'.launcher.stderr')).write_text(job.stderr)
        process=read(folder/'process.json');report['rows'].append(dict(name=name,launcherExit=job.returncode,guard=bind(folder/'process.json'),process=process));save()
        assert job.returncode==0 and process['complete'] and process['returncode']==0 and not process.get('stoppedFor'),name
        return folder,process
    try:
        previous=read(qualification/'report.json');assert previous['complete'] and previous['fullPrograms']==7;verify(previous);bind(qualification/'report.json')
        corpus=read(args.corpus_report);assert corpus['complete'] and corpus['pairs']==1444 and corpus['observedFields']==14;verify(corpus);bind(args.corpus_report)
        plan=read(qualification/'plan.json');verify(plan);bind(qualification/'plan.json')
        for path in [__file__,GUARD,NODE,CLANG,HERE/'qualify-v2.mjs',HERE/'shared-micro01.bend',*plan['apis'].values()]:bind(path)
        value='abcdefgh'*8;stdout='100000\n'+value+'\n'+value+'\n';stderr='phase98-shared-micro\n'
        plan['cases']=[];plan['controls']=[dict(id='shared-micro',source=pin(HERE/'shared-micro01.bend'),stdout=stdout,stderr=stderr,observerOwner='p98_shared_walk',scalar=0)]
        plan['scope']='One synthetic runtime-argument workload: two distinct64-character equal input strings,100000 comparisons, full surviving strings; realIO keeps packed/scalars off. Four balanced pairs time whole native process; not compiler throughput or representative program speed.'
        (out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n');bind(out/'plan.json')
        run('emission',[NODE,'--stack-size=16384','--max-old-space-size=3072',HERE/'qualify-v2.mjs',out/'plan.json',out/'emission'],180,4096,16384)
        emission=read(out/'emission/report.json');assert emission['complete'];verify(emission);report['emission']=bind(out/'emission/report.json')
        shape=next(x for x in emission['cases'] if x['id']=='shared-micro');assert shape['policies']['baseline']['READONLY_OBSERVERS']==0 and shape['policies']['candidate']['READONLY_OBSERVERS']==1
        rows={x['id']:x for x in emission['programs']};binaries={}
        for role in ['baseline','candidate']:
            c=rows['shared-micro-'+role]['c'];verify(c);binary=out/(role+'-program')
            run(role+'-clang',[CLANG,'-isystem',CLANG.parent.parent/'include/clang','-O2',c['file'],'-o',binary,'-lm','-pthread'],90,2048,4096);binaries[role]=bind(binary)
        for round_id,order in enumerate([['baseline','candidate'],['candidate','baseline'],['baseline','candidate'],['candidate','baseline']]):
            for role in order:
                folder,process=run(f'round{round_id}-{role}',[binaries[role]['file'],'--threads','1','--gpu','off','--',value,value])
                assert (folder/'stdout.log').read_text()==stdout and (folder/'stderr.log').read_text()==stderr
                report['samples'].append(dict(round=round_id,order=order,role=role,wallSeconds=process['wallSeconds'],fullOutputExact=True,stdout=bind(folder/'stdout.log'),stderr=bind(folder/'stderr.log')));save()
        medians={role:statistics.median(x['wallSeconds'] for x in report['samples'] if x['role']==role) for role in binaries}
        for row in inputs.values():assert pin(row['file'])==row
        report.update(complete=True,inputsUnchanged=True,medians=medians,candidateOverBaseline=medians['candidate']/medians['baseline'],scope=plan['scope'],binaries=binaries)
    except BaseException as error:
        report['error']=repr(error);raise
    finally:save()
if __name__=='__main__':main()
