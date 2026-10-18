#!/usr/bin/env python3
"""Matched whole-output compiler request screen; no target runtime speed claim."""
import argparse, importlib.util, json, re, sys, time
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def mod(name,path):
    s=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
R=mod('run',HERE/'run.py');B=mod('bridge',HERE/'runtime/bridge-metadata.py')
def clean(text):return re.sub(r'^(?:base_prepare_ms=\d+|runtime_prepare_ms=\d+|request=\d+ request_ms=\d+ consumed_chars=\d+)\n','',text,flags=re.M)
def main():
    p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('--runtime',type=Path,required=True);p.add_argument('--compiler',type=Path,required=True);p.add_argument('--source',type=Path,action='append');p.add_argument('--calls',type=int,choices=[1,5],default=1);p.add_argument('--live',action='store_true');p.add_argument('--rounds',type=int,default=1);a=p.parse_args()
    out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase108') and not out.exists();out.mkdir(parents=True)
    plan=json.loads((HERE/'coverage/full-compiler-plan.json').read_text())
    sources=a.source or [ROOT/x['source']['file'] for x in plan['representatives']]
    report=dict(kind='phase108-whole-product-comparison',complete=False,compiler=R.pin(a.compiler),runtime=R.pin(a.runtime),calls=a.calls,live=a.live,rows=[]);save=lambda:R.save(out/'report.json',report);save();start=time.monotonic()
    try:
        for index,src in enumerate(sources):
            for round in range(a.rounds):
                row=dict(source=R.pin(src),round=round,stages={},exact=False);report['rows'].append(row);save();raw={};errors={}
                for stage in (['parent','candidate'] if round%2==0 else ['candidate','parent']):
                    dest=out/(str(index)+'-'+str(round)+'-'+stage)
                    argv=[sys.executable,'-B',HERE/'run.py','emit',src,'--runtime',a.runtime,'--out',dest,'--calls',str(a.calls)]
                    if a.live:argv+=['--live']
                    if stage=='candidate':argv+=['--compiler',a.compiler]
                    with (out/(dest.name+'.stdout')).open('xb') as stdout,(out/(dest.name+'.stderr')).open('xb') as stderr:
                        result=R.P.run(list(map(str,argv)),stdout=stdout,stderr=stderr,cwd=ROOT,timeout=300)
                    receipt=json.loads((dest/'report.json').read_text());row['stages'][stage]=dict(receipt=R.pin(dest/'report.json'),seconds=receipt['jobs'][0]['seconds'])
                    if result.returncode:raise RuntimeError(stage+' request failed')
                    raw[stage]=(dest/'program.1.c').read_bytes();errors[stage]=clean((dest/'emit.stderr').read_text())
                parent=raw['parent']
                if b'#define WL_WIDTH ' not in parent:parent=B.add_metadata(parent)[0]
                row['exact']=parent==raw['candidate'];row['diagnosticExact']=errors['parent']==errors['candidate'];row['ratio']=row['stages']['candidate']['seconds']/row['stages']['parent']['seconds'];save()
                if not row['exact'] or not row['diagnosticExact']:raise RuntimeError('whole-product or verdict mismatch')
        report.update(complete=True,seconds=time.monotonic()-start);save();print(json.dumps(dict(complete=True,rows=len(report['rows']),seconds=report['seconds'],ratios=[x['ratio'] for x in report['rows']])))
    except BaseException as e:report.update(error=repr(e),seconds=time.monotonic()-start);save();raise
if __name__=='__main__':main()
