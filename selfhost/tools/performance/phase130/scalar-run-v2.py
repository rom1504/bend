"""Build/timing v2: IO.now returns integer milliseconds; root CPU3 guard required."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import statistics
import subprocess
import time

ROOT = Path(__file__).resolve().parents[4]
def pin(p):
    p=Path(p).resolve(); b=p.read_bytes()
    return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def check(p):
    assert pin(p['file']) == p
    return Path(p['file'])

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--emission',type=Path,required=True)
    ap.add_argument('--cases',type=Path,required=True)
    ap.add_argument('--out',type=Path,required=True)
    ap.add_argument('--build-tag',required=True)
    ap.add_argument('--rounds',type=int,default=5)
    ap.add_argument('--repeats',type=int,default=16384)
    ap.add_argument('--size',type=int,default=64)
    a=ap.parse_args(); out=a.out.resolve()
    assert list(os.sched_getaffinity(0))==[3]
    assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase130')
    e=json.loads(a.emission.read_text()); cases=json.loads(a.cases.read_text())
    assert e['complete'] and cases['complete'] and len(e['cases'])==2
    out.mkdir(parents=True)
    r=dict(complete=False,kind='phase130-source-ceiling',inputs=[pin(__file__),pin(a.emission),pin(a.cases)],
           repeats=a.repeats,size=a.size,rounds=a.rounds,builds=[],runs=[],scope='Source-level ceiling; no compiler transformation claim.')
    save=lambda:(out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
    save()
    try:
        runtime=check(e['runtime']); r['inputs'].append(e['runtime'])
        expected=json.loads(check(cases['cases'][0]['expected']).read_text())
        (out/'expected.stdout').write_text(expected['stdout'])
        binaries={}
        for row in e['cases']:
            qbe=check(row['qbe']); name=row['name']; dest=ROOT/'selfhost/build/phase111'/(a.build_tag+'-'+name)
            command=['python3','-B',str(ROOT/'selfhost/tools/performance/phase123/build-aligned.py'),
                     '--source',str(qbe),'--runtime',str(runtime),'--out',str(dest),
                     '--expected',str(out/'expected.stdout'),'--seconds','30']
            p=subprocess.run(command,cwd=ROOT,capture_output=True,timeout=60)
            (out/(name+'.build.stdout')).write_bytes(p.stdout); (out/(name+'.build.stderr')).write_bytes(p.stderr)
            r['builds'].append(dict(name=name,command=command,status=p.returncode,report=pin(dest/'report.json')));save()
            assert p.returncode==0
            br=json.loads((dest/'report.json').read_text()); assert br['complete'] and br['outputExact']
            binaries[name]=check(br['binary']); r['inputs'] += [br['binary'],row['source'],row['qbe']]
        # The frozen independently derived per-pass digest is identical at all positive prefix sizes.
        assert a.size>0
        oracle=ROOT/'selfhost/tools/performance/phase130/scalar/oracle.json'
        expected_digest=json.loads(oracle.read_text())['ordinary'][1]['digest'];r['inputs'].append(pin(oracle))
        prefix=[str(expected_digest),str((2*expected_digest)%2**32),str((a.repeats*expected_digest)%2**32)]
        names=list(binaries)
        for round_no in range(a.rounds):
            for name in names if round_no%2==0 else names[::-1]:
                command=[str(binaries[name]),'--threads','1','--gpu','off','--',str(a.repeats),'2',str(a.size),'0']
                start=time.monotonic();p=subprocess.run(command,cwd=ROOT,capture_output=True,timeout=30); wall=time.monotonic()-start
                lines=p.stdout.decode().splitlines()
                row=dict(name=name,round=round_no,command=command,status=p.returncode,wallSeconds=wall,stdout=lines,stderr=p.stderr.decode())
                r['runs'].append(row);save()
                assert p.returncode==0 and not p.stderr and len(lines)==4 and lines[:3]==prefix and lines[3].isdigit()
                row['runtimeSeconds']=int(lines[3])*1e-3; save()
        r['medians']={name:statistics.median(x['runtimeSeconds'] for x in r['runs'] if x['name']==name) for name in names}
        r['candidateOverBaseline']=r['medians']['scalar-order-scalar']/r['medians']['scalar-order-baseline']
        for row in r['inputs']:check(row)
        r['complete']=True
    except BaseException as error:
        r['error']=repr(error);raise
    finally:save()
    print(json.dumps({k:r[k] for k in ['complete','medians','candidateOverBaseline']}))
if __name__=='__main__':main()
