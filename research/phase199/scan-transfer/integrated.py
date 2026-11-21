"""Exercise the actual integrated native compiler and both complete packet segments."""
import argparse
import os
from pathlib import Path
import statistics
import subprocess
import time
from baseline import (HERE, ROOT, SOURCE, EXPECTED_ORACLES, EXPECTED_SOURCE, authenticate,
                      checks, command, pin, read, write)
from worker import inspect

FLAGS = ['+RTS','--threads','1','--gpu','off','-RTS','--RTS']
OLD_OBJECT = '34372546c1b773b83d220d9f60d6e581a1c760fc4060c083c6c56b2cc24d342f'


def verified_call(binary,row,n,warm):
    cmd=[str(binary),*FLAGS,str(n),str(warm),*map(str,row['inputs'])]
    start=time.monotonic()
    p=subprocess.run(cmd,capture_output=True,timeout=12)
    wall=time.monotonic()-start
    lines=p.stdout.decode().splitlines()
    assert not p.returncode and not p.stderr and len(lines)==4
    assert lines[:3]==[row['output'].rstrip('\n'),str(warm),str(n)] and lines[3].isdecimal()
    ms=int(lines[3]);assert ms<=1000*wall+2
    return dict(count=n,warmups=warm,elapsedMs=ms,wall=wall,nsPerPacket=ms*1e6/n)


def timing(binaries, rows):
    result=[]
    for row in rows[:2]:
        counts={}
        for role,exe in binaries.items():
            n=1024
            for _ in range(8):
                ms=verified_call(exe,row,n,1)['elapsedMs']
                if 100<=ms<=210:break
                n=max(1,round(n*145/max(1,ms)))
            else:raise ValueError('failed calibration')
            counts[role]=n
        pairs=[]
        roles=list(binaries)
        for i in range(4):
            order=roles if i in (0,3) else roles[::-1]
            pair={role:verified_call(binaries[role],row,counts[role],3) for role in order}
            pairs.append(pair)
        ratios=[x['integrated']['nsPerPacket']/x['baseline']['nsPerPacket'] for x in pairs]
        result.append(dict(inputs=row['inputs'],pairs=pairs,integratedOverBaseline=ratios,
                           median=statistics.median(ratios)))
    return result


def main(out,image,timed):
    assert os.sched_getaffinity(0)=={3};out.mkdir(parents=True,exist_ok=False)
    receipts=read(ROOT/'selfhost/build/phase199/transfer-base02/upstream/report.json')
    assert receipts['complete'] and receipts['unresolvedHoles']==0
    assert pin(SOURCE)['sha256']==receipts['source']['sha256']==EXPECTED_SOURCE
    assert pin(HERE/'oracles.json')['sha256']==EXPECTED_ORACLES
    rows=read(HERE/'oracles.json')['transfer']
    image_meta=read(image.parent/'report.json')
    assert image_meta['complete'] and pin(image)==image_meta['binary']
    report=dict(complete=False,source=pin(SOURCE),compiler=pin(image),compilerReceipt=pin(image.parent/'report.json'),
                sourceCheck=pin(ROOT/'selfhost/build/phase199/transfer-base02/upstream/report.json'),steps={})
    write(out/'report.json',report)
    reference=read(ROOT/'selfhost/build/phase198/progress-native45-02/local-fold/machine/report.json')
    for p in reference['inputs']:authenticate(p)
    cmd=reference['compilerCommand'][:];assert cmd[8]=='x86-object'
    cmd[0]=str(image);cmd[9]=str(SOURCE)
    objs={'baseline':ROOT/'selfhost/build/phase199/transfer-base02/native.o','integrated':out/'integrated.o'}
    assert pin(objs['baseline'])['sha256']==OLD_OBJECT
    command(out,'emit-integrated',cmd,objs['integrated'])
    runtime=read(ROOT/'selfhost/build/phase199/runtime-bundle01/report.json')
    assert runtime['complete'] and runtime['leafSymbol']=='p199_rt_u32_scan4'
    bundle=Path(authenticate(runtime['variants']['live']['bundle']))
    assets=read(ROOT/'selfhost/build/phase194/assets.json')['assets']
    cc=authenticate(assets['linker']);tc=reference['toolchain']
    products={}
    for role,obj in objs.items():
        entry=inspect(obj);write(out/(role+'-worker.json'),entry)
        actual=[w for w in entry['workers'] if w['decoded']=='p113d_FID_$product.frame.segment']
        assert len(actual)==1 and bool(actual[0]['helperReferences'])==(role=='integrated'),entry
        exe=out/role
        command(out,role+'-link',[cc,*tc['linkerFlags'],obj,bundle,*tc['libraries'],'-o',exe])
        products[role]=exe
        report['steps'][role]=dict(object=pin(obj),binary=pin(exe),worker=actual[0],
                                   checkedInputs=checks(out,role,exe,rows))
        write(out/'report.json',report)
    report['linkedRuntime']=pin(bundle)
    counted=out/'counted'
    command(out,'counter-link',[cc,*tc['linkerFlags'],objs['integrated'],HERE/'count-calls.c',bundle,
            '-Wl,--wrap=p199_rt_u32_scan4',*tc['libraries'],'-o',counted])
    report['actualCalls']=[]
    for row in rows[:2]:
        cmd=[str(counted),*FLAGS,'0','0',*map(str,row['inputs'])]
        p=subprocess.run(cmd,capture_output=True,timeout=8)
        write(out/('counter-'+str(row['inputs'][0])+'.json'),dict(exit=p.returncode, stdout=p.stdout.decode(errors='replace'),
              stderr=p.stderr.decode(errors='replace'), inputs=row['inputs']))
        assert p.returncode==0 and p.stdout.decode().splitlines()[:3]==[row['output'].rstrip('\n'),'0','0']
        calls=[list(map(int,line.split())) for line in p.stderr.decode().splitlines()]
        assert len(calls)==2 and [x[0] for x in calls]==[63,63]
        assert [x[1] for x in calls]==row['counts'] and [x[2] for x in calls]==row['starts']
        assert calls[0][3]==row['inputs'][1]^0xa5a5a5a5 and calls[1][3]==calls[0][4] and calls[1][4]==row['carry']
        report['actualCalls'].append(dict(inputs=row['inputs'],fields=['mask','fuel','index','carry','result'],calls=calls))
    write(out/'report.json',report)
    if timed:
        report['timing']=timing(products,rows)
    report['complete']=True;write(out/'report.json',report)


if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('--time',action='store_true')
    p.add_argument('--image',type=Path,default=ROOT/'selfhost/build/phase198/p199-integrated-native-image01/program')
    a=p.parse_args();main(a.out.resolve(),a.image.resolve(),a.time)
