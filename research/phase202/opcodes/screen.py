"""Guard-owned two-product decoder micro-screen. Compilation and timing separated."""
import argparse,hashlib,json,os,statistics,subprocess,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]

def run(a):
    assert os.sched_getaffinity(0)=={3}
    a.out=a.out.resolve();a.out.mkdir(parents=True,exist_ok=False)
    fixture=json.loads((a.fixture/'report.json').read_text())
    report=dict(complete=False,fixture=fixture,builds={},observations=[],pairs=[],scope='Standalone decoder mixed-case screen; includes process startup, list fixture construction, exact field checks, checksum and printing. Not whole compiler speed.')
    def save():(a.out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    save()
    try:
        for role in ['old','new']:
            p=fixture['roles'][role];src=Path(p['file']);assert hashlib.sha256(src.read_bytes()).hexdigest()==p['sha256']
            command=[sys.executable,'-B',str(ROOT/'selfhost/tools/build/native.py'),'--assets',str(ROOT/'selfhost/build/phase194/assets.json'),'--host','native','--stage','N1','--target','x86','--mode','cache','--emit','object','--image',str(a.image.resolve()),'--image-receipt',str(a.image_receipt.resolve()),'--source',str(src),'--out',str(a.out/role),'--seconds','25']
            begin=time.monotonic();p=subprocess.run(command,cwd=ROOT,capture_output=True,timeout=29)
            (a.out/(role+'.build.stdout')).write_bytes(p.stdout);(a.out/(role+'.build.stderr')).write_bytes(p.stderr)
            if p.returncode:raise RuntimeError((role,p.returncode,p.stdout[-1000:].decode(errors='replace'),p.stderr[-500:].decode(errors='replace')))
            built=json.loads((a.out/role/'report.json').read_text());assert built['complete'] and built['assemblerSkipped'] and not built['changedInputs']
            report['builds'][role]=dict(argv=command,seconds=time.monotonic()-begin,receipt=built);save()
        for order in [('old','new'),('new','old'),('old','new'),('new','old')]:
            pair={}
            for role in order:
                argv=[str(a.out/role/'program'),'+RTS','--threads','1','--gpu','off','-RTS']
                begin=time.monotonic();p=subprocess.run(argv,cwd=ROOT,capture_output=True,timeout=8);seconds=time.monotonic()-begin
                assert p.returncode==0 and not p.stderr and p.stdout.decode()==fixture['expectedStdout'],(role,p.returncode,p.stdout,p.stderr)
                pair[role]=seconds;report['observations'].append(dict(role=role,seconds=seconds,stdout=p.stdout.decode(),argv=argv));save()
            report['pairs'].append(pair['new']/pair['old']);save()
        report['medianPairedNewOverOld']=statistics.median(report['pairs']);report['complete']=True
        report['shortSamples']=any(x['seconds']<0.1 for x in report['observations'])
    except BaseException as e:report['error']=repr(e);raise
    finally:save()
    print(json.dumps({k:report[k] for k in ['complete','pairs','medianPairedNewOverOld','shortSamples']}))
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--fixture',type=Path,required=True);p.add_argument('--image',type=Path,required=True);p.add_argument('--image-receipt',type=Path,required=True);p.add_argument('--out',type=Path,required=True);run(p.parse_args())
