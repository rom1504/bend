"""Build the pinned current kernel in a fresh directory; no automatic acquisition."""
import json,os,subprocess,sys,time
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[2]/'tools/build'))
from common import pin,verify,fresh_output,ROOT,write_json
out=fresh_output(Path(sys.argv[1]),ROOT)
source=ROOT/'selfhost/.bootstrap/upstream-phase182/bend2/bendtt.lean'
lean=ROOT/'selfhost/build/phase94/toolchain/lean-4.34.0-linux/bin/lean'
inputs=[pin(__file__),pin(source),pin(lean)]
(out/'BendTT.lean').write_bytes(source.read_bytes());(out/'Run.lean').write_text('import BendTT\n')
env=dict(os.environ,LEAN_STACK_SIZE_KB='4096');env.pop('LEAN_PATH',None);env.pop('LEAN_SRC_PATH',None)
start=time.monotonic()
with (out/'stdout').open('w') as a,(out/'stderr').open('w') as b:
 r=subprocess.run([str(lean),'-M1400','-o',str(out/'BendTT.olean'),str(out/'BendTT.lean')],env=env,cwd=out,stdout=a,stderr=b,timeout=160)
for p in inputs:verify(p)
d=dict(kind='phase182-current-kernel-build',complete=r.returncode==0,seconds=time.monotonic()-start,inputs=inputs,exitCode=r.returncode)
if d['complete']:d['module']=pin(out/'BendTT.olean')
write_json(out/'report.json',d)
print(json.dumps(d));sys.exit(r.returncode)
