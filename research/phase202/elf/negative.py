"""Prepare or run one late-invalid ELF relocation control; root owns guarded execution."""
import argparse,json,os,subprocess,sys
from pathlib import Path
from focus import standalone
from prepare import apply,BASE,ROOT,source

HARNESS=b'''
@unsafe
def main() -> IO(U32):
  x202p_x187_elf(X187Object{x187_build_fill(16384,65,[]),[],[],[],
    [X187Relocation{1,16380,4,"missing_symbol",4294967292,4294967295}]})
'''

def prepare(out, transform=None):
    data,counts=standalone.slice_source((transform or apply)(BASE.read_bytes()),HARNESS)
    out.mkdir(parents=True,exist_ok=False);p=out/'late-invalid.bend';p.write_bytes(data)
    (out/'recipe.json').write_text(json.dumps(dict(source=source.pin(p),parent=source.pin(BASE),declarations=counts,
        oracle=dict(exitCode=1,stdoutBytes=0,diagnostic='invalid ELF relocation'),reason='16 KiB valid text and in-bounds PC32 relocation whose symbol is absent.'),indent=2)+'\n')

def run(out,fixture):
    assert os.sched_getaffinity(0)=={3};out=out.resolve();out.mkdir(parents=True,exist_ok=False)
    spec=json.loads((fixture/'recipe.json').read_bytes());p=fixture/'late-invalid.bend';assert source.pin(p)==spec['source']
    image=ROOT/'selfhost/build/phase198/progress-native-image01';cmd=[sys.executable,'-B',str(ROOT/'selfhost/tools/build/native.py'),'--assets',str(ROOT/'selfhost/build/phase194/assets.json'),'--host','native','--stage','N1','--target','x86','--mode','cache','--emit','object','--image',str(image/'program'),'--image-receipt',str(image/'report.json'),'--source',str(p),'--out',str(out/'machine'),'--seconds','30'];q=subprocess.run(cmd,cwd=ROOT,capture_output=True,timeout=35)
    (out/'build.stdout').write_bytes(q.stdout);(out/'build.stderr').write_bytes(q.stderr);assert q.returncode==0,(q.stdout[-1500:],q.stderr[-500:]);built=json.loads((out/'machine/report.json').read_bytes());assert built['complete'] and not built['changedInputs'];q=subprocess.run([str(out/'machine/program'),'+RTS','--threads','1','--gpu','off','-RTS'],capture_output=True,timeout=10)
    (out/'execute.stdout').write_bytes(q.stdout);(out/'execute.stderr').write_bytes(q.stderr);r=dict(complete=False,fixture=spec['source'],image=built['request']['image'],binary=built['binary'],exitCode=q.returncode,stdoutBytes=len(q.stdout),stderr=q.stderr.decode(errors='replace'))
    r['complete']=q.returncode==1 and q.stdout==b'' and b'invalid ELF relocation' in q.stderr;(out/'report.json').write_text(json.dumps(r,indent=2)+'\n');print(r);assert r['complete']

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('--fixture',type=Path);p.add_argument('--prepare',action='store_true');p.add_argument('--sized',action='store_true');a=p.parse_args()
    if a.prepare and a.sized:
        from sized import apply as sized
        prepare(a.out,sized)
    elif a.prepare:
        prepare(a.out)
    else:
        run(a.out,a.fixture)
