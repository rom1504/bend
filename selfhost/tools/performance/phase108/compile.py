#!/usr/bin/env python3
"""Experimental full-source native Bend/cproc/QBE build. Python only hosts tools."""
import argparse, importlib.util, json, os, shutil, sys, time
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
s=importlib.util.spec_from_file_location('run',HERE/'run.py');R=importlib.util.module_from_spec(s);s.loader.exec_module(R)
def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('source',type=Path);p.add_argument('--out',type=Path,required=True);p.add_argument('--image',type=Path,default=HERE/'image.json');p.add_argument('--live',action='store_true');p.add_argument('--seconds',type=int,default=300);a=p.parse_args();assert 1<=a.seconds<=1800
    out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase108') and not out.exists();out.mkdir(parents=True)
    imagepin=R.pin(a.image);image=json.loads(a.image.read_text());assert image['kind']=='phase108-qualified-qbe-compiler' and image['complete']
    for item in image['inputs']:R.N.verify(item)
    source=R.pin(a.source);report=dict(kind='phase108-source-to-native',complete=False,image=imagepin,source=source,jobs=[]);R.save(out/'report.json',report);start=time.monotonic()
    try:
        for label,argv in [('emit',[sys.executable,'-B',HERE/'run.py','emit',a.source,'--runtime',image['runtime']['file'],'--compiler',image['binary']['file'],'--out',out/'emit','--seconds',str(a.seconds),*(['--live'] if a.live else [])]),('build',[sys.executable,'-B',HERE/'run.py','build',out/'emit/program.1.c','--backend','qbe','--out',out/'build','--seconds',str(a.seconds)])]:
            command=[sys.executable,'-B',ROOT/'selfhost/tools/performance/phase86/guard.py','--out',out/(label+'-guard'),'--seconds',str(a.seconds+10),'--rss-mib','4096','--available-mib','16384','--cpu','3','--',*argv]
            with (out/(label+'.stdout')).open('xb') as stdout,(out/(label+'.stderr')).open('xb') as stderr:
                child=R.P.run(list(map(str,command)),stdout=stdout,stderr=stderr,cwd=ROOT,timeout=a.seconds+25)
            report['jobs'].append(dict(label=label,command=list(map(str,command)),receipt=R.pin(out/(label+'-guard/process.json'))));R.save(out/'report.json',report)
            if child.returncode:raise RuntimeError(label+' failed; see '+str(out))
        assert b'#define WL_WIDTH ' in (out/'emit/program.1.c').read_bytes(), 'new compiler failed metadata contract'
        for item in image['inputs']:R.N.verify(item)
        R.N.verify(imagepin);R.N.verify(source)
        os.link(out/'build/program',out/'program')
        report.update(complete=True,binary=R.pin(out/'program'),seconds=time.monotonic()-start);R.save(out/'report.json',report)
        print(json.dumps(dict(complete=True,binary=str(out/'program'),seconds=report['seconds'])))
    except BaseException as e:report.update(error=repr(e),seconds=time.monotonic()-start);R.save(out/'report.json',report);raise
if __name__=='__main__':main()
