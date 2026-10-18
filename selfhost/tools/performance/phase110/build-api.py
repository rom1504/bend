#!/usr/bin/env python3
"""One checked Bend development API build; run under the serial outer guard."""
import argparse,hashlib,importlib.util,json,subprocess,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];HERE=ROOT/'selfhost/tools/performance/phase110'
p=argparse.ArgumentParser();p.add_argument('--source',required=True,type=Path);p.add_argument('--out',required=True,type=Path);p.add_argument('--calls',action='store_true');p.add_argument('--runtime-ir',action='store_true');a=p.parse_args();out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase110') and not out.exists();out.mkdir(parents=True)
exports='nxo_lower_policy nxlib_qbe nxlib_c nxlib_verify nxlib_runtime_imports_policy nxlib_control_report nx_json_function nxo_ownership_report nxo_policy_report nxo_lower110_policy nxlib_runtime110_imports_policy nxo110_policy_report nx110_pair_library nx110_verify nx110_qbe nx110_c nx110_control_report nx110_take_pair_library nx110_take_control_report nx110_alias_control_report'.split()
if a.calls:exports+=['nxc_lower_library','nxc_control_report']
if a.runtime_ir:exports+=['nxo_lower110rt','nx110rt_verify','nx110rt_qbe','nx110rt_c','nx110rt_machine','nx110rt_control_report','nx110rt_probe_qbe','nx110rt_probe_c','nx110rt_width_report']
command=[str(ROOT/'selfhost/.bootstrap/bun-1.4.3/bun'),str(ROOT/'selfhost/tools/stage0-library.mjs'),str(a.source.resolve()),str(out/'api.mjs'),*exports]
pin=lambda f:dict(file=str(f.resolve()),bytes=f.stat().st_size,sha256=hashlib.sha256(f.read_bytes()).hexdigest())
r=dict(kind='phase110-checked-api',complete=False,source=pin(a.source),method=pin(Path(__file__)),command=command,exports=exports);t=time.monotonic();c=subprocess.run(command,cwd=ROOT);r.update(seconds=time.monotonic()-t,status=c.returncode,complete=c.returncode==0)
if c.returncode==0:r['api']=pin(out/'api.mjs')
(out/'report.json').write_text(json.dumps(r,indent=2)+'\n');sys.exit(c.returncode)
