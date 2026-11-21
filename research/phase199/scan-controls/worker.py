"""Call one actual generated product worker on initialized packed and fallback handles."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
def pin(path):
    path=Path(path).resolve()
    return dict(file=str(path),bytes=path.stat().st_size,sha256=hashlib.sha256(path.read_bytes()).hexdigest())
def cmd(args):
    child=subprocess.run(list(map(str,args)),capture_output=True,text=True,timeout=12)
    if child.returncode:raise ValueError(' '.join(map(str,args))+' failed: '+child.stderr[-1900:])
    return child.stdout
def run(a):
    assert os.sched_getaffinity(0)=={3}
    out=a.out.resolve();out.mkdir()
    assets=json.loads((ROOT/'selfhost/build/phase194/assets.json').read_text())
    compiler=assets['assets']['linker']
    assert pin(compiler['file'])['sha256']==compiler['sha256']
    runtime=Path(assets['assets']['qbe-runtime']['file'])
    assert pin(runtime)['sha256']==assets['assets']['qbe-runtime']['sha256']
    program=a.object.resolve(strict=True)
    worker='p113d_FID_'+''.join(str(ord(c))+'_' for c in a.worker_name)
    defs=cmd(['nm','-S','--defined-only',program]).splitlines()
    loc=[s.split() for s in defs if s.split()[-1]==worker]
    assert len(loc)==1 and len(loc[0])==4
    address,size=[int(x,16) for x in loc[0][:2]]
    reloc=cmd(['readelf','-Wr',program])
    text=False;sites=[]
    for row in reloc.splitlines():
        if row.startswith('Relocation section '):
            text=row.startswith("Relocation section '.rela.text'")
        if text and re.search(r'\bp199_rt_u32_scan4\b',row):
            offset=int(row.split()[0],16)
            if address<=offset<address+size:sites.append(offset-address)
    assert bool(sites)==bool(a.helper),('helper relocation',worker,sites)
    report=dict(complete=False,object=pin(program),runtime=pin(runtime),source=pin(HERE/'worker.c'),method=pin(__file__),
        tools={k:pin(v) for k,v in [('compiler',compiler['file']),('nm',shutil.which('nm')),('readelf',shutil.which('readelf'))]},
        worker=worker,workerBytes=size,helperSites=sites,helper=pin(a.helper) if a.helper else None,checks=[])
    def save():(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    save()
    binary=out/'worker'
    link=[compiler['file'],'-std=c11','-Wall','-Wextra','-Werror','-O2','-no-pie','-I',ROOT/'selfhost/src/runtime/qbe',
        '-DTEST_WORKER="'+worker+'"','-Wl,--wrap=main','-Wl,--wrap=p199_rt_u32_scan4',HERE/'worker.c',program,
        *([a.helper.resolve(strict=True)] if a.helper else []),runtime,'-pthread','-lm','-o',binary]
    try:
        cmd(link);report['link']=list(map(str,link));report['binary']=pin(binary)
        for uniform in (0,1):
            text=cmd([binary,int(bool(a.helper)),uniform])
            m=re.fullmatch(r'trials (\d+) cells (\d+) helper (\d+) long-raw (\d+) uniform (\d+)\n',text)
            assert m and int(m[5])==uniform
            report['checks'].append(dict(zip(('trials','checkedCells','calls','longRawCalls','uniform'),map(int,m.groups()))));save()
        report['complete']=True
    except Exception as e:
        report['error']=repr(e);raise
    finally:save()
    print(json.dumps(report['checks']))
if __name__=='__main__':
    p=argparse.ArgumentParser()
    p.add_argument('--object',type=Path,required=True);p.add_argument('--helper',type=Path)
    p.add_argument('--worker-name',default='$product.fold.loop')
    p.add_argument('--out',type=Path,required=True)
    run(p.parse_args())
