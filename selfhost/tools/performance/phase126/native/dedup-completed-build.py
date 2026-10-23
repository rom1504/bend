"""After full lineage comparison, hardlink equal completed N1/N2 assembly/objects."""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import shutil

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
spec = importlib.util.spec_from_file_location('p126_storage',HERE/'storage-checkpoint.py')
S = importlib.util.module_from_spec(spec);spec.loader.exec_module(S)
P = S.P


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--plan',type=Path,required=True);parser.add_argument('--out',type=Path,required=True)
    args=parser.parse_args();assert not args.out.exists()
    plan=P.verify_plan(args.plan)
    comparison=Path(plan['artifacts']['comparison']);gate=P.read(comparison)
    assert gate['complete'] and gate['byteExact'] and P.pin(args.plan) in gate['inputs']
    n1=Path(plan['artifacts']['n1']);n2=Path(plan['artifacts']['self'])/'build'
    before=P.read(n1/'report.json');after=P.read(n2/'report.json')
    assert before['complete'] and after['complete'] and gate['n1']==before['binary'] and gate['n2']==after['binary']
    inputs=[P.pin(__file__),P.pin(HERE/'storage-checkpoint.py'),P.pin(args.plan),P.pin(comparison),
            P.pin(n1/'report.json'),P.pin(n2/'report.json')]
    r=dict(complete=False,targetsRun=False,inputs=inputs,rows=[],reclaimedAllocatedBytes=0,
           freeBefore=shutil.disk_usage(ROOT).free,
           scope='Exact SHA256+byte dedup of completed assembly/object pairs only, after actual N1/N2 lineage and raw QBE comparison. Paths, contents, build receipts and binaries remain unchanged.')
    try:
        for name in ['program.s','program.o']:
            left,right=n1/name,n2/name;lp,rp=P.pin(left),P.pin(right);inputs.extend([lp,rp])
            row=dict(keeper=lp,file=rp,equal=False,reclaimedAllocatedBytes=0);r['rows'].append(row)
            if lp['sha256']!=rp['sha256'] or lp['bytes']!=rp['bytes'] or not S.equal(left,right):continue
            row['equal']=True;ls,rs=left.stat(),right.stat()
            assert not left.is_symlink() and not right.is_symlink()
            assert (ls.st_dev,ls.st_mode,ls.st_uid,ls.st_gid)==(rs.st_dev,rs.st_mode,rs.st_uid,rs.st_gid)
            if ls.st_ino!=rs.st_ino:
                assert rs.st_nlink==1
                temporary=right.with_name(name+'.p126-completed-link');assert not temporary.exists()
                os.link(left,temporary);os.replace(temporary,right)
                row['reclaimedAllocatedBytes']=rs.st_blocks*512
                r['reclaimedAllocatedBytes']+=row['reclaimedAllocatedBytes']
            P.verify(lp);P.verify(rp)
        for value in inputs:P.verify(value)
        r.update(complete=True,freeAfter=shutil.disk_usage(ROOT).free)
    except BaseException as error:r['error']=str(error);raise
    finally:
        args.out.parent.mkdir(parents=True,exist_ok=True)
        with args.out.open('x') as stream:json.dump(r,stream,indent=2);stream.write('\n')
    print(json.dumps(dict(complete=True,reclaimedAllocatedBytes=r['reclaimedAllocatedBytes'],freeAfter=r['freeAfter'])))


if __name__=='__main__':main()
