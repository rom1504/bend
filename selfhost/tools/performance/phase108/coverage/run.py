#!/usr/bin/env python3
"""Serial frozen semantic screen; invoke under process-tree guard."""
import argparse, importlib.util, json, subprocess, sys, time
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent;PHASE=HERE.parent;ROOT=PHASE.parents[3]
def mod(name,path):
    s=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
R=mod('runner',PHASE/'run.py');B=mod('bridge',PHASE/'runtime/bridge-metadata.py')
def main():
    p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('--runtime',type=Path,required=True);p.add_argument('--compiler',type=Path);p.add_argument('--backend',choices=['gcc','qbe'],default='qbe');p.add_argument('--only',nargs='*');p.add_argument('--threads',type=int,default=1);a=p.parse_args()
    out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase108') and not out.exists();out.mkdir(parents=True)
    manifest=json.loads((HERE/'manifest.json').read_text());report=dict(kind='phase108-frozen-coverage',complete=False,manifest=R.pin(HERE/'manifest.json'),backend=a.backend,threads=a.threads,rows=[])
    save=lambda:R.save(out/'report.json',report);save();start=time.monotonic()
    def cmd(label,argv):
        with (out/(label+'.stdout')).open('xb') as stdout,(out/(label+'.stderr')).open('xb') as stderr:
            r=R.P.run(list(map(str,argv)),stdout=stdout,stderr=stderr,timeout=45,cwd=ROOT)
        return r.returncode
    try:
        assert cmd('verify',[sys.executable,'-B',HERE/'verify.py'])==0
        for case in manifest['fixtures']:
            name=case['name']
            if a.only and name not in a.only:continue
            row=dict(name=name,expected=case['expect'],complete=False);report['rows'].append(row);save()
            source=HERE/case['file'];emit=out/(name+'-emit')
            args=[sys.executable,'-B',PHASE/'run.py','emit',source,'--runtime',a.runtime,'--out',emit]
            if a.compiler:args+=['--compiler',a.compiler]
            status=cmd(name+'-emit',args);row['emit']=R.pin(emit/'report.json')
            negative=case['expect']['stage']!='execute'
            if negative:
                if status==0 or (emit/'program.1.c').exists():raise RuntimeError(name+': expected source refusal')
                row.update(complete=True,negativeRefused=True);save();continue
            if status:raise RuntimeError(name+': source emission failed')
            c=emit/'program.1.c';raw=c.read_bytes()
            if b'#define WL_WIDTH ' not in raw:
                fixed,width=B.add_metadata(raw);c=emit/'portable.c';c.write_bytes(fixed);row['temporaryMetadataBridge']=True
            else:row['temporaryMetadataBridge']=False
            build=out/(name+'-build')
            status=cmd(name+'-build',[sys.executable,'-B',PHASE/'run.py','build',c,'--backend',a.backend,'--out',build])
            row['build']=R.pin(build/'report.json')
            if status:raise RuntimeError(name+': machine build failed')
            expected=out/(name+'.expected');expected.write_text(case['expect']['stdout'])
            run=out/(name+'-run')
            status=cmd(name+'-run',[sys.executable,'-B',PHASE/'run.py','run',build/'program','--threads',a.threads,'--expected',expected,'--out',run])
            row['run']=R.pin(run/'report.json')
            if status:raise RuntimeError(name+': execution/output failed')
            row.update(complete=True);save()
        report.update(complete=True,seconds=time.monotonic()-start);save();print(json.dumps(dict(complete=True,rows=len(report['rows']),seconds=report['seconds'])))
    except BaseException as e:report.update(error=repr(e),seconds=time.monotonic()-start);save();raise
if __name__=='__main__':main()
