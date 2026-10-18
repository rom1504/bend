#!/usr/bin/env python3
"""One checked Bend development API build; run under the serial outer guard."""
import argparse,hashlib,importlib.util,json,subprocess,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];HERE=ROOT/'selfhost/tools/performance/phase110'
p=argparse.ArgumentParser();p.add_argument('--source',required=True,type=Path);p.add_argument('--out',required=True,type=Path);p.add_argument('--calls',action='store_true');p.add_argument('--runtime-ir',action='store_true');p.add_argument('--runtime',type=Path);a=p.parse_args();out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase110') and not out.exists();out.mkdir(parents=True)
exports='nxo_lower_policy nxlib_qbe nxlib_c nxlib_verify nxlib_runtime_imports_policy nxlib_control_report nx_json_function nxo_ownership_report nxo_policy_report nxo_lower110_policy nxlib_runtime110_imports_policy nxo110_policy_report nx110_pair_library nx110_verify nx110_qbe nx110_c nx110_control_report nx110_take_pair_library nx110_take_control_report nx110_alias_control_report'.split()
if a.calls:exports+=['nxc_lower_library','nxc_control_report']
if a.runtime_ir:exports+=['nxo_lower110rt','nx110rt_verify','nx110rt_qbe','nx110rt_c','nx110rt_machine','nx110rt_control_report','nx110rt_probe_qbe','nx110rt_probe_c','nx110rt_width_report']
source_text=a.source.read_text()
for name in ['nx110rt_lower_library','nx110rt_call_control_report','nx110rt_predicate_report','nx110rtg_control_report','nx110rtg_probe_qbe','nx110rtg_probe_c','nx110rts_control_report','nxe_entry','nxe_layout_ok','nxe_source','nxe_role','nxe_signature','nx110rtn_control_report','nx110rtw_control_report','nx110rtc_control_report','nxe_close','nxe_lower_library','nxe_lower_runtime_library']:
 if ('def '+name+'(') in source_text:exports.append(name)
admission=None
stored='def nx110rts_control_report(' in source_text
wrapper='def nx110rtw_control_report(' in source_text
combined='def nx110rtc_control_report(' in source_text
if stored or wrapper or combined:
 if not a.runtime:raise ValueError('stored-field/wrapper/combined profile requires --runtime for exact source admission')
 version='-v2' if 'def nx110rtn_check(' in source_text else ''
 extra=[]
 if combined:
  variants=[v for v in ['combined','delayed'] if source_text.count(json.loads((HERE/'runtime-ir'/f'wrapper-{v}-overrides.json').read_text())['replacements'][0]['new'])==1]
  if len(variants)!=1:raise ValueError('one exact combined/delayed template required')
  method='wrapper-combined-admit.py';extra=['--variant',variants[0]]
 else:method=('wrapper-spare-admit' if wrapper else 'stored-field-admit')+version+'.py'
 subprocess.run([sys.executable,'-B',str(HERE/'runtime-ir'/method),'--source',str(a.source.resolve()),'--runtime',str(a.runtime.resolve()),'--out',str(out/'admission'),*extra],cwd=ROOT,check=True,stdout=subprocess.DEVNULL)
 admission=out/'admission/manifest.json'
command=[str(ROOT/'selfhost/.bootstrap/bun-1.4.3/bun'),str(ROOT/'selfhost/tools/stage0-library.mjs'),str(a.source.resolve()),str(out/'api.mjs'),*exports]
pin=lambda f:dict(file=str(f.resolve()),bytes=f.stat().st_size,sha256=hashlib.sha256(f.read_bytes()).hexdigest())
r=dict(kind='phase110-checked-api',complete=False,source=pin(a.source),method=pin(Path(__file__)),command=command,exports=exports,admission=pin(admission) if admission else None);t=time.monotonic();c=subprocess.run(command,cwd=ROOT);r.update(seconds=time.monotonic()-t,status=c.returncode,complete=c.returncode==0)
if c.returncode==0:r['api']=pin(out/'api.mjs')
(out/'report.json').write_text(json.dumps(r,indent=2)+'\n');sys.exit(c.returncode)
