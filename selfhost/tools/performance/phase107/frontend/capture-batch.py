#!/usr/bin/env python3
from pathlib import Path
import subprocess,sys,json,time
ROOT=Path(__file__).resolve().parents[5];HERE=ROOT/'selfhost/tools/performance/phase107'
out=Path(sys.argv[1]).resolve();out.mkdir(parents=True,exist_ok=False)
rows=[]
for source in sorted((HERE/'cases').glob('*.bend')):
 target=out/source.stem;start=time.monotonic()
 cmd=[ROOT/'selfhost/.bootstrap/bun-1.4.3/bun',HERE/'frontend/capture.mjs',source,target]
 r=subprocess.run(list(map(str,cmd)),cwd=ROOT,capture_output=True,text=True,timeout=30)
 rows.append(dict(name=source.stem,returncode=r.returncode,seconds=time.monotonic()-start,stdout=r.stdout,stderr=r.stderr))
 (out/'batch.json').write_text(json.dumps(rows,indent=2)+'\n')
 print(source.stem,r.returncode,r.stdout[:250],flush=True)
assert all(r['returncode']==0 for r in rows)
