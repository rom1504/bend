"""Fresh independent checking + all controls after a static never-fixed-state refusal."""
from pathlib import Path
import argparse,json,subprocess,sys,hashlib,time
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);a=p.parse_args();out=a.out
here=Path(__file__).resolve().parent
cmd=['selfhost/.assets/bin/bun','selfhost/tools/build/hosted.mjs','acquire','--source','selfhost/build/phase198/numeric-api-source13/compiler.bend','--exports','selfhost/build/phase198/numeric-api-source13/exports.json','--out',str(out),'--engine','selfhost/.assets/bin/bun','--upstream','selfhost/.bootstrap/upstream-phase182']
start=time.monotonic();first=subprocess.run(cmd,capture_output=True,text=True,timeout=45)
if out.exists():
 (out/'acquire-stdout.log').write_text(first.stdout);(out/'acquire-stderr.log').write_text(first.stderr)
if first.returncode:print(first.stderr[-3000:]);raise SystemExit(first.returncode)
second=subprocess.run(['selfhost/.assets/bin/bun',str(here/'controls-selective.mjs'),'--api',str(out/'report.json'),'--out',str(out/'controls')],capture_output=True,text=True,timeout=25)
(out/'controls-stdout.log').write_text(second.stdout);(out/'controls-stderr.log').write_text(second.stderr)
if second.returncode:print(second.stderr[-3000:]);raise SystemExit(second.returncode)
def pin(p):return dict(file=str(p.resolve()),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
old=Path('selfhost/build/phase198/numeric-products03/controls/transformed-ir.json');new=out/'controls/transformed-ir.json'
assert old.read_bytes()==new.read_bytes(),'selective admission changed measured Mandelbrot IR'
r=dict(complete=True,method=pin(Path(__file__)),policy=pin(here/'progress.bend'),api=pin(out/'report.json'),controls=pin(out/'controls/controls.json'),previousTransformedIR=pin(old),newTransformedIR=pin(new),transformedIRBytesExact=True,seconds=time.monotonic()-start,scope='Fresh checking and expanded semantic controls for static never-fixed-state refusal. Mandelbrot transformed IR must remain identical; actual transfer is separate.')
(out/'selective-check.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(r))
