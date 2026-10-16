#!/usr/bin/env python3
"""Patched-C diagnostic of dispatch cost; never a production compiler receipt."""
import argparse, hashlib, json, statistics, subprocess, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
CC = Path('/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/bin/clang')
GUARD = ROOT / 'selfhost/tools/performance/phase86/guard.py'

def pin(p):
    p=Path(p).resolve(); raw=p.read_bytes()
    return dict(file=str(p),bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest())

def main():
    parser=argparse.ArgumentParser(description=__doc__); parser.add_argument('--out',type=Path,required=True)
    a=parser.parse_args(); out=a.out.resolve(); assert out.is_relative_to(ROOT/'selfhost/build/phase99');out.mkdir(exist_ok=False)
    ep=ROOT/'selfhost/build/phase99/scalars-micro03/emission/report.json'; emission=json.loads(ep.read_text())
    original=next(p['c'] for p in emission['programs'] if p['id']=='append-baseline');assert pin(original['file'])==original
    text=Path(original['file']).read_text(); guard='#if FID_ENTER >= 4096';assert text.count(guard)==1
    accessor='FAR PRESERVE(preserve_most) WlFn wl_target(Fid id) { return wl_tab[id]; }'
    assert text.count(accessor)==1 and text.count('return wl_target(F)(WL_ALL)')==1
    forced=text.replace(guard,'#if 1 /* diagnostic: force large-image dispatch */')
    variants=dict(direct=text,accessor=forced,volatile=forced.replace(accessor,'static const WlFn * volatile wl_dispatch = wl_tab;').replace('return wl_target(F)(WL_ALL)','return wl_dispatch[F](WL_ALL)'))
    report=dict(complete=False,method=pin(__file__),parent=pin(ep),originalC=original,patchedCDiagnostic=True,compilerChanged=False,rows=[],samples=[],products={})
    def save(): (out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    def run(name,argv,seconds=60):
        folder=out/name
        job=subprocess.run([sys.executable,'-B',str(GUARD),'--out',str(folder),'--seconds',str(seconds),'--rss-mib','2048','--available-mib','4096','--cpu','3','--',*map(str,argv)],capture_output=True,text=True)
        (out/(name+'.launcher.log')).write_text(job.stdout+job.stderr)
        p=json.loads((folder/'process.json').read_text());report['rows'].append(dict(name=name,receipt=pin(folder/'process.json'),process=p));save()
        assert job.returncode==0 and p['complete'] and p['returncode']==0 and not p.get('stoppedFor'),name
        return folder,p
    try:
        for role,code in variants.items():
            c=out/(role+'.c');c.write_text(code);binary=out/(role+'.program')
            run(role+'-build',[CC,'-isystem',CC.parent.parent/'include/clang','-O2',c,'-o',binary,'-lm','-pthread'])
            asm=subprocess.check_output(['objdump','-d',str(binary)],text=True);(out/(role+'.asm')).write_text(asm)
            calls=sum('call' in line and '<wl_target>' in line for line in asm.splitlines())
            assert (calls>0)==(role=='accessor'),(role,calls)
            report['products'][role]=dict(c=pin(c),binary=pin(binary),assembly=pin(out/(role+'.asm')),accessorCalls=calls);save()
        args=['abcdefgh'*8,'λ🙂xyz'];expected=str(sum(map(ord,''.join(args)))*1000000%2**32)+'\n'+'\n'.join(args)+'\n'
        orders=[['direct','accessor','volatile'],['accessor','volatile','direct'],['volatile','direct','accessor']]
        orders += [list(reversed(o)) for o in orders]
        for rnd,order in enumerate(orders):
            for role in order:
                folder,p=run(f'run{rnd}-{role}',[report['products'][role]['binary']['file'],'--threads','1','--gpu','off','--',*args],30)
                assert (folder/'stdout.log').read_text()==expected and (folder/'stderr.log').read_text()=='phase99-append\n'
                report['samples'].append(dict(round=rnd,role=role,wallSeconds=p['wallSeconds'],fullOutputExact=True));save()
        med={role:statistics.median(x['wallSeconds'] for x in report['samples'] if x['role']==role) for role in variants}
        report.update(complete=True,medians=med,volatileOverAccessor=med['volatile']/med['accessor'],accessorOverDirect=med['accessor']/med['direct'],scope='Single-worker whole-process synthetic append timing. No large-image scaling or compiler-speed claim; volatile initializer may still expose the LLVM callgraph.')
    except BaseException as e: report['error']=repr(e);raise
    finally: save()
    print(json.dumps({k:report[k] for k in ['complete','medians','volatileOverAccessor','accessorOverDirect']}))

if __name__=='__main__':main()
