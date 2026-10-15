#!/usr/bin/env python3
"""Root-only serial followup: reuse qualified APIs, emit and run full corpus."""
import argparse
import hashlib
import json
from pathlib import Path
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
    parser.add_argument('--prepared',type=Path,required=True)
    parser.add_argument('--out',type=Path,required=True)
    args=parser.parse_args(); out=args.out.resolve(); prepared=args.prepared.resolve()
    assert out.is_relative_to(BUILD) and not out.exists();out.mkdir(parents=True)
    inputs={};report=dict(complete=False,rows=[],inputs=[],kind='phase98-real-io-full-string-corpus')
    def bind(path):
        row=pin(path);assert inputs.setdefault(row['file'],row)==row;return row
    def verify(value):
        if isinstance(value,list):
            for x in value:verify(x)
        elif isinstance(value,dict):
            if {'file','bytes','sha256'}<=value.keys():assert bind(value['file'])==value
            else:
                for x in value.values():verify(x)
    def flush():
        report['inputs']=list(inputs.values());(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    def run(name,argv,seconds=60,rss=1024,available=4096):
        folder=out/(name+'-guard');cmd=[sys.executable,'-B',str(GUARD),'--out',str(folder),'--seconds',str(seconds),'--rss-mib',str(rss),'--available-mib',str(available),'--cpu','3','--',*map(str,argv)]
        job=subprocess.run(cmd,cwd=ROOT,capture_output=True,text=True)
        (out/(name+'.launcher.stdout')).write_text(job.stdout);(out/(name+'.launcher.stderr')).write_text(job.stderr)
        process=read(folder/'process.json');report['rows'].append(dict(name=name,launcherExit=job.returncode,guard=bind(folder/'process.json'),process=process));flush()
        assert job.returncode==0 and process['complete'] and process['returncode']==0 and not process.get('stoppedFor'),name
        return folder
    try:
        receipt=read(prepared/'receipt.json');assert receipt['complete'] and not receipt['targetsRun'];verify(receipt);bind(prepared/'receipt.json')
        qualification=Path(receipt['qualification']);previous=read(qualification/'report.json')
        assert previous['complete'] and previous['fullPrograms']==7;verify(previous);bind(qualification/'report.json')
        plan=read(prepared/'plan.json');verify(plan)
        for name in [__file__,GUARD,NODE,CLANG,HERE/'qualify-v2.mjs']:bind(name)
        for path in plan['apis'].values():bind(path)
        assert read(qualification/'plan.json')['apis']==plan['apis']
        run('emission',[NODE,'--stack-size=16384','--max-old-space-size=3072',HERE/'qualify-v2.mjs',prepared/'plan.json',out/'emission'],180,4096,16384)
        emission=read(out/'emission/report.json');assert emission['complete'];verify(emission);report['emission']=bind(out/'emission/report.json')
        actual=[row for row in emission['cases'] if row['id']=='full-string-corpus'];assert len(actual)==1
        assert actual[0]['policies']['baseline']['READONLY_OBSERVERS']==0
        assert actual[0]['policies']['candidate']['READONLY_OBSERVERS']==1
        assert len(emission['programs'])==3
        for row in emission['programs']:
            c=Path(row['c']['file']);verify(row['c']);binary=out/(row['id']+'-program')
            run(row['id']+'-clang',[CLANG,'-isystem',CLANG.parent.parent/'include/clang','-O2',c,'-o',binary,'-lm','-pthread'],90,2048,4096);bind(binary)
            folder=run(row['id']+'-run',[binary,'--threads','1','--gpu','off'],30)
            assert (folder/'stdout.log').read_text()==row['stdout'] and (folder/'stderr.log').read_text()==row['stderr'],row['id']
            report['rows'][-1]['fullOutputExact']=True;flush()
        for row in inputs.values():assert pin(row['file'])==row
        report.update(complete=True,inputsUnchanged=True,pairs=1444,observedFields=14,programs=3,scope=plan['scope'],source=receipt['source'])
    except BaseException as error:
        report['error']=repr(error);raise
    finally:flush()
if __name__=='__main__':main()
