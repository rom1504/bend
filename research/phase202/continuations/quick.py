"""Acquire both typed selectors in one checked hosted API and compare their actual objects."""
import argparse,hashlib,json,os,subprocess,sys
from pathlib import Path
from standalone import previous
from prepare import apply,BASE,HERE,ROOT
EXPORTS=['x181_segment','x202s_old','x202k_shape','x188_assemble','x188_render','x202s_rows','missing']

def run(out,paired):
    assert os.sched_getaffinity(0)=={3};out=out.resolve();out.mkdir(parents=True,exist_ok=False)
    exports=EXPORTS if paired else ['x202k_shape','x202k_template','p111q_symbol','x188_assemble','x202s_rows']
    old=BASE.read_bytes();new=apply(old);bridge=(ROOT/'selfhost/tests/phase190/api-bridge.bend').read_bytes();i=bridge.index(b'@unsafe\ndef x188_assemble(');new+=b'\n'+bridge[i:].split(b'\n@unsafe',1)[0]+b'\n';start=old.index(b'@unsafe\ndef x181_segment(segment,ids):');end=old.index(b'\n#',start)
    prior=old[start:end].replace(b'def x181_segment(segment,ids):',b'def x202s_old(+segment: N111Segment, +ids: N111Ids) -> X181Output:'); rows=(HERE/'screen.bend').read_bytes().split(b'@unsafe\ndef x202s_work')[0]
    harness=b'\n'+(prior if paired else b'')+b'\n'+rows+b'\n# exported dependencies\n'+b'\n@unsafe\ndef x202s_roots() -> U32:\n  0\n';roots=b'\n'.join(x.encode() for x in exports)
    data,n=previous.slice_source(new,harness+b'\n'+roots);data=data[:-len(roots)]
    src=out/'compiler.bend';src.write_bytes(data);exp=out/'exports.json';exp.write_text(json.dumps({'kind':'bend-hosted-api-exports','version':1,'protocol':'typed-api-v1','targets':['qbe'],'exports':exports}));bun=ROOT/'selfhost/.assets/bin/bun';argv=[str(bun),'selfhost/tools/build/hosted.mjs','acquire','--source',str(src),'--exports',str(exp),'--out',str(out/'api'),'--engine',str(bun),'--upstream','selfhost/.bootstrap/upstream-phase182'];q=subprocess.run(argv,cwd=ROOT,capture_output=True,timeout=22);(out/'api.stdout').write_bytes(q.stdout);(out/'api.stderr').write_bytes(q.stderr);assert q.returncode==0,(q.stderr[-1000:],q.stdout[-1000:]);q=subprocess.run([str(bun),str(HERE/('quick.mjs' if paired else 'ceiling.mjs')),str(out)],cwd=ROOT,capture_output=True,timeout=12);(out/'controls.stderr').write_bytes(q.stderr);assert q.returncode==0,q.stderr[-1500:];print(q.stdout.decode())

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--out',required=True,type=Path);p.add_argument('--paired',action='store_true');a=p.parse_args();run(a.out,a.paired)
