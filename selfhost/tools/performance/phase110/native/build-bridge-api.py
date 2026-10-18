#!/usr/bin/env python3
"""Root-run checked API build for exact native production modules; guard serially."""
import argparse,hashlib,json,subprocess,sys,time
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--source',required=True,type=Path);p.add_argument('--out',required=True,type=Path);a=p.parse_args()
out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase110') and not out.exists();out.mkdir(parents=True)
pin=lambda file:dict(file=str(file.resolve()),bytes=file.stat().st_size,sha256=hashlib.sha256(file.read_bytes()).hexdigest())
exports='nxe_entry nxe_close nxe_lower_library nxe_lower_runtime_library nxlib_verify nxlib_qbe nxlib_c nx110_verify nx110_qbe nx110_c nx110_pair_library nx110_take_pair_library nx110rt_verify nx110rt_qbe nx110rt_c'.split()
command=[str(ROOT/'selfhost/.bootstrap/bun-1.4.3/bun'),str(ROOT/'selfhost/tools/stage0-library.mjs'),str(a.source.resolve()),str(out/'api.mjs'),*exports]
record=dict(kind='phase110-checked-api',complete=False,source=pin(a.source),method=pin(Path(__file__)),command=command,exports=exports)
start=time.monotonic();result=subprocess.run(command,cwd=ROOT)
record.update(complete=result.returncode==0,status=result.returncode,seconds=time.monotonic()-start)
if record['complete']:record['api']=pin(out/'api.mjs')
(out/'report.json').write_text(json.dumps(record,indent=2)+'\n');sys.exit(result.returncode)
